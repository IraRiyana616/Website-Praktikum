import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Detail/Screen/detail_asistensi_dosen.dart';

class TabelDataMahasiswaDosenAsistensiLaporan extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const TabelDataMahasiswaDosenAsistensiLaporan(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<TabelDataMahasiswaDosenAsistensiLaporan> createState() =>
      _TabelDataMahasiswaDosenAsistensiLaporanState();
}

class _TabelDataMahasiswaDosenAsistensiLaporanState
    extends State<TabelDataMahasiswaDosenAsistensiLaporan> {
  //== List Data Tabel ==//
  List<DataPraktikan> filteredDataPraktikan = [];
  List<DataPraktikan> demoDataPraktikan = [];

  @override
  void initState() {
    super.initState();
    textController.addListener(_onTextChanged);
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

    // Mengurutkan data berdasarkan nama secara ascending
    data.sort((a, b) => a.nama.compareTo(b.nama));

    setState(() {
      filteredDataPraktikan = data;
    });
  }

  //== Fungsi Controller pada Search ==//
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredDataPraktikan = demoDataPraktikan
          .where(
              (data) => (data.nama.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      textController.clear();
      filterData('');
    });
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = textController.text.isNotEmpty;
      filterData(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //== Search ==//
            Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 10.0),
              child: SizedBox(
                width: 300.0,
                height: 35.0,
                child: Row(children: [
                  Text(
                    'Search :',
                    style: GoogleFonts.quicksand(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                      child: TextField(
                    onChanged: (value) {
                      filterData(value);
                    },
                    controller: textController,
                    decoration: InputDecoration(
                        hintText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10.0),
                        suffixIcon: Visibility(
                            visible: _isTextFieldNotEmpty,
                            child: IconButton(
                                onPressed: clearSearchField,
                                icon: const Icon(Icons.clear))),
                        labelStyle: const TextStyle(fontSize: 16.0),
                        filled: true,
                        fillColor: Colors.white),
                  )),
                  const SizedBox(
                    width: 27.0,
                  )
                ]),
              ),
            ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0),
            child: SizedBox(
                width: 1250.0,
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
                              label: Text(
                            '',
                          )),
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
        DataCell(Text(fileInfo.nim.toString())),
        DataCell(SizedBox(
            width: 250.0, child: Text(getLimitedText(fileInfo.nama, 40)))),
        DataCell(GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    DetailAsistensiLaporanDosen(
                  kodeKelas: fileInfo.kode,
                  nama: fileInfo.nama,
                  modul: fileInfo.matkul,
                  nim: fileInfo.nim,
                  mataKuliah: fileInfo.matkul,
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
