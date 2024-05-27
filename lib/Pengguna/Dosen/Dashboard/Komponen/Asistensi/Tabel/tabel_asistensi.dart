import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Details/Screen/details_ds.dart';

class TabelDataPraktikanDosen extends StatefulWidget {
  final String kodeKelas;
  const TabelDataPraktikanDosen({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  State<TabelDataPraktikanDosen> createState() =>
      _TabelDataPraktikanDosenState();
}

class _TabelDataPraktikanDosenState extends State<TabelDataPraktikanDosen> {
  //== Fungsi Tabel ==//
  List<DataPraktikan> filteredDataPraktikan = [];
  List<DataPraktikan> demoDataPraktikan = [];

  //== Filtering ==//
  bool _isTextFieldNotEmpty = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  void fetchDataFromFirestore() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tokenKelas')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    final data = querySnapshot.docs
        .map((doc) => DataPraktikan.fromFirestore(doc))
        .toList();

    // Inisialisasi demoDataPraktikan dengan data sebelumnya
    demoDataPraktikan = data;

    // Mengurutkan data berdasarkan nama secara ascending
    demoDataPraktikan.sort((a, b) => a.nama.compareTo(b.nama));

    setState(() {
      filteredDataPraktikan = data;
    });
  }

  //== Clear ==//
  void clearSearchField() {
    setState(() {
      _textController.clear();
      filterData(
        '',
      );
    });
  }

  void _onTextChanged(String value) {
    setState(() {
      _isTextFieldNotEmpty = value.isNotEmpty;
      filterData(value);
    });
  }

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredDataPraktikan = demoDataPraktikan
          .where((data) =>
              data.nim.toString().toLowerCase().contains(query.toLowerCase()) ||
              data.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //== Search ==//
        Padding(
          padding: const EdgeInsets.only(left: 1010.0),
          child: SizedBox(
            width: 300.0,
            height: 35.0,
            child: Row(
              children: [
                const Text("Search :",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: TextField(
                    onChanged: _onTextChanged,
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 18),
                      suffixIcon: Visibility(
                        visible: _isTextFieldNotEmpty,
                        child: IconButton(
                          onPressed: clearSearchField,
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 27.0,
                )
              ],
            ),
          ),
        ),
        //== Tabel ==//
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
            child: SizedBox(
                width: 1200.0,
                child: filteredDataPraktikan.isNotEmpty
                    ? PaginatedDataTable(
                        columnSpacing: 10,
                        columns: const [
                          DataColumn(
                              label: Text('NIM',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Nama',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Asisten Laporan',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        source: DataSource(filteredDataPraktikan, context),
                        rowsPerPage:
                            calculateRowsPerPage(filteredDataPraktikan.length),
                      )
                    : const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      )),
          ),
        )
      ],
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;
    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }
}

class DataPraktikan {
  int nim;
  String nama;
  String kode;
  String tahun;
  String matkul;
  String dosen;
  String dosenPengampu;

  DataPraktikan(
      {required this.nim,
      required this.nama,
      required this.kode,
      required this.tahun,
      required this.matkul,
      required this.dosen,
      required this.dosenPengampu});

  factory DataPraktikan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DataPraktikan(
      nim: data['nim'] ?? 0,
      nama: data['nama'] ?? '',
      kode: data['kodeKelas'] ?? '',
      tahun: data['tahunAjaran'] ?? '',
      matkul: data['mataKuliah'] ?? '',
      dosen: data['dosenPengampu'] ?? '',
      dosenPengampu: data['dosenPengampu2'] ?? '',
    );
  }
}

DataRow dataFileDataRow(
    DataPraktikan fileInfo, int index, BuildContext context) {
  return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return getRowColor(index);
        },
      ),
      cells: [
        DataCell(SizedBox(width: 200.0, child: Text(fileInfo.nim.toString()))),
        DataCell(SizedBox(
            width: 350.0, child: Text(getLimitedText(fileInfo.nama, 40)))),
        DataCell(SizedBox(
          width: 200.0,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AsistensiLaporanDosen(
                    kodeKelas: fileInfo.kode,
                    nama: fileInfo.nama,
                    modul: fileInfo.matkul,
                    nim: fileInfo.nim,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    'Lihat Detail',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ))
      ]);
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  if (index % 2 == 0) {
    return Colors.grey.shade200;
  } else {
    return Colors.transparent;
  }
}

class DataSource extends DataTableSource {
  final List<DataPraktikan> data;
  final BuildContext context;

  DataSource(this.data, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, context);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
