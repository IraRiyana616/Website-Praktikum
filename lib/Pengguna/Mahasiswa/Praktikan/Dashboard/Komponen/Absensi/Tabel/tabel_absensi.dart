import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabelAbsensiPraktikan extends StatefulWidget {
  const TabelAbsensiPraktikan({Key? key}) : super(key: key);

  @override
  State<TabelAbsensiPraktikan> createState() => _TabelAbsensiPraktikanState();
}

class _TabelAbsensiPraktikanState extends State<TabelAbsensiPraktikan> {
  List<DataAbsensi> demoDataAbsensi = [];
  List<DataAbsensi> filteredDataAbsensi = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    // Load data from Firestore here
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('absensiMahasiswa')
        .orderBy('waktu')
        .get();

    setState(() {
      demoDataAbsensi = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return DataAbsensi(
          kelas: data['kelas'],
          nama: data['nama'],
          nim: data['nim'],
          modul: data['modul'],
          keterangan: data['keterangan'],
          tanggal: data['tanggal'],
          waktu: data['waktu'],
        );
      }).toList();
      filterData('');
    });
  }

  void filterData(String query) {
    setState(() {
      filteredDataAbsensi = demoDataAbsensi
          .where((data) =>
              data.nim.toString().contains(query) ||
              data.kelas.toLowerCase().contains(query.toLowerCase()) ||
              data.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      _textController.clear();
      filterData('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0),
            child: Text('Data Absensi Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                child: SizedBox(
                  width: double.infinity,
                  child: filteredDataAbsensi.isNotEmpty
                      ? PaginatedDataTable(
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(
                              label: Text(
                                "NIM",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Nama",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Keterangan",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Waktu Absensi",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          source: DataSource(filteredDataAbsensi, context),
                          rowsPerPage:
                              calculateRowsPerPage(filteredDataAbsensi.length),
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
            ],
          ),
        ],
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 50;

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }
}

class DataAbsensi {
  String kelas;
  int nim;
  String nama;
  String modul;
  String keterangan;
  String tanggal;
  String waktu;
  DataAbsensi({
    required this.kelas,
    required this.nama,
    required this.nim,
    required this.modul,
    required this.keterangan,
    required this.tanggal,
    required this.waktu,
  });
}

DataRow dataFileDataRow(DataAbsensi fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.nim.toString())),
      DataCell(SizedBox(
          width: 180.0, child: Text(getLimitedText(fileInfo.nama, 30)))),
      DataCell(Text(fileInfo.keterangan)),
      DataCell(Text(getLimitedText(fileInfo.waktu, 30))),
    ],
  );
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
  final List<DataAbsensi> data;
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
