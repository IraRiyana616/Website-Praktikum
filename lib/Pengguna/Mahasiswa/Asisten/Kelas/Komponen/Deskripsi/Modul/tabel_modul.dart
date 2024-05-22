import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Komponen/Deskripsi/Modul/Komponen/Latihan/latihan_mhs.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelSilabusPraktikum extends StatefulWidget {
  final String kodeKelas;

  const TabelSilabusPraktikum({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  State<TabelSilabusPraktikum> createState() => _TabelSilabusPraktikumState();
}

class _TabelSilabusPraktikumState extends State<TabelSilabusPraktikum> {
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
        hari: data['hariPraktikum'],
        waktu: data['waktuPraktikum'],
        file: data['modulPraktikum'],
        deskripsiKelas: kodeKelasMap[kodeKelas] ?? '',
        documentId: doc.id,
      );
    }).toList();

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
                            'Aksi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredDataSilabus,
                          deleteDataFromFirestore, context),
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
  String hari;
  String waktu;
  String file;
  String deskripsiKelas;
  String documentId;

  DataSilabus({
    required this.modul,
    required this.hari,
    required this.waktu,
    required this.kode,
    required this.file,
    required this.deskripsiKelas,
    required this.documentId,
  });
}

DataRow dataFileDataRow(DataSilabus fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LatihanAsisten(
                            kodeKelas: fileInfo.kode,
                            modul: fileInfo.modul,
                          )));
            },
            child: SizedBox(
              width: 250.0,
              child: Text(getLimitedText(fileInfo.modul, 50)),
            ),
          ),
        ),
      ),
      DataCell(SizedBox(width: 170.0, child: Text(fileInfo.hari))),
      DataCell(SizedBox(
        width: 170.0,
        child: Text(fileInfo.waktu),
      )),
      DataCell(Row(
        children: [
          //== Download ==//
          IconButton(
            onPressed: () {
              downloadFile(fileInfo.kode, fileInfo.file);
            },
            icon: const Icon(
              Icons.download,
              color: Colors.grey,
            ),
            tooltip: 'Download Modul',
          ),
          //== Edit Data ==//
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit_document,
              color: Colors.grey,
            ),
            tooltip: 'Edit Data',
          ),
          //== Delete ==//
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Hapus Modul',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      content:
                          const Text('Apakah Anda yakin ingin menghapusnya ?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Batal')),
                        TextButton(
                            onPressed: () {
                              onDelete(fileInfo.documentId);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Hapus'))
                      ],
                    );
                  });
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.grey,
            ),
            tooltip: 'Hapus Data',
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
