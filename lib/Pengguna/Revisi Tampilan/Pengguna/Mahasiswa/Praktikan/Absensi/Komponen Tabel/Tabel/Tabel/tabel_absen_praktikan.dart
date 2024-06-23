import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TabelAbsensiPraktikan extends StatefulWidget {
  final String kodeKelas;
  const TabelAbsensiPraktikan({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  State<TabelAbsensiPraktikan> createState() => _TabelAbsensiPraktikanState();
}

class _TabelAbsensiPraktikanState extends State<TabelAbsensiPraktikan> {
  List<AbsensiPraktikan> demoAbsensiPraktikan = [];
  List<AbsensiPraktikan> filteredAbsensiPraktikan = [];

  int nim = 0;

  @override
  void initState() {
    super.initState();
    textController.addListener(_onTextChanged);
    fetchData();
  }

  Future<void> fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('akun_mahasiswa')
          .doc(user.uid)
          .get();
      nim = userDoc['nim'];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('absensiMahasiswa')
          .where('nim', isEqualTo: nim)
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .get();

      setState(() {
        demoAbsensiPraktikan = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return AbsensiPraktikan(
            kode: data['kodeKelas'] ?? '',
            nama: data['nama'] ?? '',
            nim: data['nim'] ?? 0,
            modul: data['judulMateri'] ?? '',
            timestap: (data['waktuAbsensi'] as Timestamp).toDate(),
            keterangan: data['keterangan'] ?? '',
            file: data['namaFile'] ?? '',
            pertemuan: data['pertemuan'] ?? '',
          );
        }).toList();

        filteredAbsensiPraktikan = List.from(demoAbsensiPraktikan);
      });

      // Print hasil fetch data
      if (kDebugMode) {
        print('Fetched data: $filteredAbsensiPraktikan');
      }
    }
  }

  //== Fungsi Controller pada Search ==//
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredAbsensiPraktikan = demoAbsensiPraktikan
          .where((data) =>
              (data.modul.toLowerCase().contains(query.toLowerCase()) ||
                  data.pertemuan.toLowerCase().contains(query.toLowerCase())))
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
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Text(
                      'Search :',
                      style: TextStyle(fontSize: 16.0),
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
          Padding(
            padding: const EdgeInsets.only(
                left: 30.0, right: 30.0, bottom: 20.0, top: 30.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredAbsensiPraktikan.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Timestamp',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Judul Modul',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Pertemuan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Keterangan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredAbsensiPraktikan),
                      rowsPerPage:
                          calculateRowsPerPage(filteredAbsensiPraktikan.length),
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text(
                          'No data available',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 50;

    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class AbsensiPraktikan {
  final String kode;
  final String nama;
  final int nim;
  final String modul;
  final DateTime timestap;
  final String keterangan;
  final String file;

  final String pertemuan;

  AbsensiPraktikan({
    required this.kode,
    required this.nama,
    required this.nim,
    required this.modul,
    required this.timestap,
    required this.keterangan,
    required this.file,
    required this.pertemuan,
  });
}

DataRow dataFileDataRow(AbsensiPraktikan fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(
        SizedBox(
          width: 170.0,
          child: Text(getLimitedText(fileInfo.timestap.toString(), 19)),
        ),
      ),
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(getLimitedText(fileInfo.modul, 25)),
        ),
      ),
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(getLimitedText(fileInfo.pertemuan, 25)),
        ),
      ),
      DataCell(Text(fileInfo.keterangan)),
    ],
  );
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

class DataSource extends DataTableSource {
  final List<AbsensiPraktikan> data;

  DataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
