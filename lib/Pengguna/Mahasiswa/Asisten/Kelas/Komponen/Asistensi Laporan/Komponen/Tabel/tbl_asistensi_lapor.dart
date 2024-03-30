import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelAsistensiLaporan extends StatefulWidget {
  final String kodeKelas;
  const TabelAsistensiLaporan({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  State<TabelAsistensiLaporan> createState() => _TabelAsistensiLaporanState();
}

class _TabelAsistensiLaporanState extends State<TabelAsistensiLaporan> {
  List<AsistensiLaporan> demoAsistensiLaporan = [];
  List<AsistensiLaporan> filteredAsistenLaporan = [];
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
        .map((doc) => AsistensiLaporan.fromFirestore(doc))
        .toList();

    setState(() {
      filteredAsistenLaporan = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: SizedBox(
              width: 1195.0,
              child: filteredAsistenLaporan.isNotEmpty
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
                            'Nama Modul',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Dowload File',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredAsistenLaporan, context),
                      rowsPerPage:
                          calculateRowsPerPage(filteredAsistenLaporan.length),
                    )
                  : const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
            ),
          ),
        ),
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

class AsistensiLaporan {
  String modul;
  String kode;
  String nama;
  String file;
  int nim;
  DateTime waktu;
  AsistensiLaporan({
    required this.modul,
    required this.kode,
    required this.nama,
    required this.file,
    required this.nim,
    required this.waktu,
  });
  factory AsistensiLaporan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AsistensiLaporan(
      nim: data['nim'] ?? 0,
      nama: data['nama'] ?? '',
      kode: data['kodeKelas'] ?? '',
      modul: data['judulMateri'] ?? '',
      file: data['namaFile'] ?? '',
      waktu: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

DataRow dataFileDataRow(
    AsistensiLaporan fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(
        width: 150.0,
        child: Text(
          getLimitedText(fileInfo.waktu.toString(), 19),
          style: const TextStyle(color: Colors.black),
        ),
      )),
      DataCell(SizedBox(
        width: 250.0,
        child: Text(
          getLimitedText(fileInfo.modul, 40),
          style: const TextStyle(color: Colors.black),
        ),
      )),
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
              downloadFile(fileInfo.kode, fileInfo.file, fileInfo.modul);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                getLimitedText(
                  fileInfo.file,
                  20,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    ],
  );
}

void downloadFile(String kodeKelas, String fileName, String judulMateri) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('tugas/$kodeKelas/$judulMateri/$fileName');

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

String getLimitedText(String text, int limit, {TextStyle? style}) {
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
  final List<AsistensiLaporan> data;
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
