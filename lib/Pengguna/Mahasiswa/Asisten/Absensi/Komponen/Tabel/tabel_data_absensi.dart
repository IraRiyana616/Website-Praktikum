import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabelDataAbsensiPraktikan extends StatefulWidget {
  const TabelDataAbsensiPraktikan({Key? key}) : super(key: key);

  @override
  State<TabelDataAbsensiPraktikan> createState() =>
      _TabelDataAbsensiPraktikanState();
}

class _TabelDataAbsensiPraktikanState extends State<TabelDataAbsensiPraktikan> {
  List<DataAbsensi> demoDataAbsensi = [];
  List<DataAbsensi> filteredDataAbsensi = [];

  // Menampilkan data yang memiliki kesamaan kodeKelas dan nim
  void displayDataFromFirestore() async {
    List<DataAbsensi> absensi = [];
    QuerySnapshot tokenSnapshot =
        await FirebaseFirestore.instance.collection('tokenKelas').get();
    QuerySnapshot absensiSnapshot =
        await FirebaseFirestore.instance.collection('absensiMahasiswa').get();

    for (var tokenDoc in tokenSnapshot.docs) {
      String kodeKelas = tokenDoc['kodeKelas'];
      int nim = tokenDoc['nim'];

      for (var absensiDoc in absensiSnapshot.docs) {
        if (absensiDoc['kodeKelas'] == kodeKelas && absensiDoc['nim'] == nim) {
          DataAbsensi data = DataAbsensi(
            nim: absensiDoc['nim'],
            nama: absensiDoc['nama'],
            kode: absensiDoc['kodeKelas'],
            modul: absensiDoc['modul'],
            keterangan: absensiDoc['keterangan'],
            tanggal: absensiDoc['tanggal'],
            waktu: absensiDoc['waktu'],
          );
          absensi.add(data);
        }
      }
    }

    setState(() {
      demoDataAbsensi = absensi;
      filteredDataAbsensi = demoDataAbsensi;
    });
  }

  @override
  void initState() {
    super.initState();
    displayDataFromFirestore();
  }

  void filterData(String query) {
    setState(() {
      filteredDataAbsensi = demoDataAbsensi
          .where((data) => (data.nim.toString().contains(query) ||
              data.kode.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: Container(
                width: 900.0,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6.0)),
                child: filteredDataAbsensi.isNotEmpty
                    ? PaginatedDataTable(
                        columnSpacing: 10,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Waktu Absensi',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Modul',
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
                        source: DataSource(filteredDataAbsensi),
                        rowsPerPage:
                            calculateRowsPerPage(filteredDataAbsensi.length),
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

class DataAbsensi {
  int nim;
  String nama;
  String kode;
  String modul;
  String keterangan;
  String tanggal;
  String waktu;
  DataAbsensi({
    required this.nim,
    required this.nama,
    required this.kode,
    required this.modul,
    required this.keterangan,
    required this.tanggal,
    required this.waktu,
  });
}

DataRow dataFileDataRow(DataAbsensi fileInfo, int index) {
  return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        return getRowColor(index);
      }),
      cells: [
        DataCell(SizedBox(
            width: 180.0, child: Text(getLimitedText(fileInfo.waktu, 30)))),
        DataCell(SizedBox(
            width: 180.0, child: Text(getLimitedText(fileInfo.modul, 30)))),
        DataCell(Text(fileInfo.keterangan))
      ]);
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
  final List<DataAbsensi> data;

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
