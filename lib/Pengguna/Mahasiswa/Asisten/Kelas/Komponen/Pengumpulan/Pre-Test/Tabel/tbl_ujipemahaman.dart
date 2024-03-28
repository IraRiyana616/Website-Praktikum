import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelPengumpulanUjiPemahaman extends StatefulWidget {
  final String kodeKelas;
  const TabelPengumpulanUjiPemahaman({super.key, required this.kodeKelas});

  @override
  State<TabelPengumpulanUjiPemahaman> createState() =>
      _TabelPengumpulanUjiPemahamanState();
}

class _TabelPengumpulanUjiPemahamanState
    extends State<TabelPengumpulanUjiPemahaman> {
  List<Pengumpulan> demoPengumpulan = [];
  List<Pengumpulan> filteredPengumpulan = [];
  Future<void> deleteDataFromFirestore(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('pre-test')
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
        .collection('pre-test')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    final List<Pengumpulan> dataList = silabusSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final String kodeKelas = data['kodeKelas'];
      return Pengumpulan(
        kode: kodeKelas,
        nama: data['nama'] ?? '',
        nim: data['nim'] ?? 0,
        file: data['namaFile'] ?? '',
        waktu: data['waktuPengumpulan'] != null
            ? (data['waktuPengumpulan'] as Timestamp).toDate().toString()
            : '',
      );
    }).toList();

    setState(() {
      demoPengumpulan = dataList;
      filteredPengumpulan =
          dataList; // Initialize filteredDataSilabus with all data
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 70.0, right: 100.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredPengumpulan.isNotEmpty
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
                            'NIM',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama File',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredPengumpulan),
                      rowsPerPage:
                          calculateRowsPerPage(filteredPengumpulan.length),
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
    const int defaultRowsPerPage = 25;

    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class Pengumpulan {
  final String kode;
  final String nama;
  final int nim;
  final String file;
  final String waktu;

  Pengumpulan({
    required this.kode,
    required this.nama,
    required this.nim,
    required this.file,
    required this.waktu,
  });
}

DataRow dataFileDataRow(Pengumpulan fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(
        SizedBox(
          width: 130.0,
          child: Text(getLimitedText(fileInfo.waktu, 19,
              style: const TextStyle(color: Colors.black))),
        ),
      ),
      DataCell(Text(fileInfo.nim.toString())),
      DataCell(
        SizedBox(
          width: 200.0,
          child: Text(getLimitedText(fileInfo.nama, 25,
              style: const TextStyle(color: Colors.black))),
        ),
      ),
      DataCell(Row(
        children: [
          const Icon(
            Icons.download,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 5.0,
          ),
          GestureDetector(
            onTap: () {
              downloadFile(fileInfo.kode, fileInfo.file);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(getLimitedText(
                  fileInfo.file,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                  20)),
            ),
          )
        ],
      )),
    ],
  );
}

void downloadFile(String kodeKelas, String fileName) async {
  final ref =
      FirebaseStorage.instance.ref().child('pre-test/$kodeKelas/$fileName');

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

String getLimitedText(String text, int limit, {required TextStyle style}) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

class DataSource extends DataTableSource {
  final List<Pengumpulan> data;

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
