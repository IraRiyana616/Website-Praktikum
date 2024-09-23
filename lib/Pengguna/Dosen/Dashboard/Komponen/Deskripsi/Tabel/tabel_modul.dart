import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../Revisi Tampilan/Pengguna/Mahasiswa/Praktikan/Dashboard/Komponen/Silabus Praktikum/Pengumpulan/Latihan/pengumpulan_latihan.dart';

class TabelSilabusPraktikumDosen extends StatefulWidget {
  final String idkelas;
  final String kodeMatakuliah;
  final String mataKuliah;
  const TabelSilabusPraktikumDosen(
      {Key? key,
      required this.idkelas,
      required this.kodeMatakuliah,
      required this.mataKuliah})
      : super(key: key);

  @override
  State<TabelSilabusPraktikumDosen> createState() =>
      _TabelSilabusPraktikumDosenState();
}

class _TabelSilabusPraktikumDosenState
    extends State<TabelSilabusPraktikumDosen> {
  //== List Data Tabel ==//
  List<DataSilabus> demoDataSilabus = [];
  List<DataSilabus> filteredDataSilabus = [];
  //== Loading ==//
  bool isLoading = false;

//== Fungsi untuk menampilkan data dari Firestore ==//
  Future<void> fetchDataFromFirestore() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('silabusMatakuliah')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      List<DataSilabus> loadedData = [];
      for (var doc in snapshot.docs) {
        loadedData.add(DataSilabus(
            id: doc.id,
            idkelas: widget.idkelas,
            idModul: doc['idModul'] ?? '',
            judulModul: doc['judulModul'] ?? '',
            namaFile: doc['namaFile'] ?? '',
            pertemuan: doc['pertemuan'] ?? '',

            ///=======///
            kode: widget.kodeMatakuliah,
            matakuliah: widget.mataKuliah));
      }

      updateTableData(loadedData);
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 75.0, right: 75.0, top: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredDataSilabus.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                            label: Text(
                          'id Modul',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
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
                            'File Modul',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredDataSilabus, context),
                      rowsPerPage:
                          calculateRowsPerPage(filteredDataSilabus.length),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
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
        )
      ],
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 15;

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }

  //== Fungsi Update Data ==//
  void updateTableData(List<DataSilabus> newData) {
    setState(() {
      demoDataSilabus.clear();
      filteredDataSilabus.clear();
      demoDataSilabus.addAll(newData);
      filteredDataSilabus.addAll(newData);
    });
  }
}

class DataSilabus {
  String id;
  String idkelas;
  String idModul;
  String pertemuan;
  String judulModul;
  String namaFile;

  //========//
  String kode;
  String matakuliah;

  DataSilabus({
    required this.id,
    required this.idkelas,
    required this.judulModul,
    required this.namaFile,
    required this.idModul,
    required this.pertemuan,

    //=======//
    required this.matakuliah,
    required this.kode,
  });
}

DataRow dataFileDataRow(DataSilabus fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      //== idModul ==//
      DataCell(SizedBox(width: 100.0, child: Text(fileInfo.idModul))),
      //== Nama Modul ==//
      DataCell(
        SizedBox(
          width: 300.0,
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PengumpulanLatihanPraktikan(
                      idkelas: fileInfo.idkelas,
                      judulModul: fileInfo.judulModul,
                      kode: fileInfo.kode,
                      matkul: fileInfo.matakuliah,
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
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(getLimitedText(fileInfo.judulModul, 50)))),
        ),
      ),

      //== Pertemuan ==//
      DataCell(
        SizedBox(
            width: 250, child: Text(getLimitedText(fileInfo.pertemuan, 30))),
      ),
      //== Nama File ==//
      DataCell(Row(
        children: [
          const Icon(
            Icons.download,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 5.0,
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                downloadFile(
                    fileInfo.idkelas, fileInfo.judulModul, fileInfo.namaFile);
              },
              child: Text(
                fileInfo.namaFile,
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      )),
    ],
  );
}

void downloadFile(String idTA, String judulModul, String fileName) async {
  final ref =
      FirebaseStorage.instance.ref().child('$idTA/$judulModul/$fileName');

  try {
    final url = await ref.getDownloadURL();
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error downloading file: $e');
    }
  }
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  if (index % 2 == 0) {
    return Colors.grey.shade200; // Grey for even rows
  } else {
    return Colors.transparent; // Transparent for odd rows
  }
}

class DataSource extends DataTableSource {
  final List<DataSilabus> data;
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

  // Function to update data after deletion
  void updateData(List<DataSilabus> newData) {
    data.clear();
    data.addAll(newData);
    notifyListeners();
  }
}
