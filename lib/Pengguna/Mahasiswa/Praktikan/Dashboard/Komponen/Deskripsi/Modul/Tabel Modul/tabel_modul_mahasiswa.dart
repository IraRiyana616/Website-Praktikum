import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Komponen/Pre-Test/pre_test.dart';

class TabelModulPraktikum extends StatefulWidget {
  final String kodeKelas;
  const TabelModulPraktikum({super.key, required this.kodeKelas});

  @override
  State<TabelModulPraktikum> createState() => _TabelModulPraktikumState();
}

class _TabelModulPraktikumState extends State<TabelModulPraktikum> {
  List<DataSilabus> demoDataSilabus = [];
  List<DataSilabus> filteredDataSilabus = [];

  Future<void> deleteDataFromFirestore(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('silabusPraktikum')
          .doc(documentId)
          .delete();
      fetchDataFromFirestore();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document: $e');
      }
    }
  }

  Future<void> fetchDataFromFirestore() async {
    final QuerySnapshot silabusSnapshot = await FirebaseFirestore.instance
        .collection('silabusPraktikum')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    final QuerySnapshot deskripsiSnapshot = await FirebaseFirestore.instance
        .collection('deskripsiKelas')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    final Map<String, String> kodeKelasMap = Map.fromEntries(
      deskripsiSnapshot.docs.map(
        (doc) => MapEntry(doc.id, doc['kodeKelas']),
      ),
    );

    final List<DataSilabus> dataList = silabusSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final String kodeKelas = data['kodeKelas'];
      return DataSilabus(
        kode: kodeKelas,
        modul: data['judulMateri'],
        jadwal: data['waktuPraktikum'],
        tanggal: data['tanggalPraktikum'],
        file: data['modulPraktikum'],
        deskripsiKelas: kodeKelasMap[kodeKelas] ?? '',
        documentId: doc.id,
      );
    }).toList();
    dataList.sort((a, b) => a.modul.compareTo(b.modul));

    setState(() {
      demoDataSilabus = dataList;
      filteredDataSilabus = dataList;
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
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: Container(
              width: 1100.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6.0)),
              child: filteredDataSilabus.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Judul Modul',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Hari Praktikum',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Waktu Praktikum',
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
                      source: DataSource(
                          filteredDataSilabus,
                          deleteDataFromFirestore,
                          context), // Pass delete function
                      rowsPerPage:
                          calculateRowsPerPage(filteredDataSilabus.length),
                    )
                  : const Center(
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
}

class DataSilabus {
  String kode;
  String modul;
  String jadwal;
  String tanggal;
  String file;
  String deskripsiKelas;
  String documentId;

  DataSilabus({
    required this.modul,
    required this.jadwal,
    required this.tanggal,
    required this.kode,
    required this.file,
    required this.deskripsiKelas,
    required this.documentId,
  });
}

DataRow dataFileDataRow(DataSilabus fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  // Pass onDelete function
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    UjianPemahaman(
                  kodeKelas: fileInfo.kode,
                  modul: fileInfo.modul,
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
              child: Text(
                getLimitedText(fileInfo.modul, 50),
              )))),
      DataCell(SizedBox(width: 170.0, child: Text(fileInfo.tanggal))),
      DataCell(SizedBox(width: 170.0, child: Text(fileInfo.jadwal))),
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
                downloadFile(fileInfo.kode, fileInfo.file);
              },
              child: const Text(
                'Download',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      )),
    ],
  );
}

void downloadFile(String kodeKelas, String fileName) async {
  final ref = FirebaseStorage.instance.ref().child('$kodeKelas/$fileName');

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
  final Function(String) onDelete;
  final BuildContext context;

  DataSource(this.data, this.onDelete, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, onDelete, context);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
