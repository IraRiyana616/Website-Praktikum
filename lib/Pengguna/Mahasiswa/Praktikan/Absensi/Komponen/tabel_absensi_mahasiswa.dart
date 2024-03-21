import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabelAbsensiPraktikan extends StatefulWidget {
  const TabelAbsensiPraktikan({Key? key}) : super(key: key);

  @override
  State<TabelAbsensiPraktikan> createState() => _TabelAbsensiPraktikanState();
}

class _TabelAbsensiPraktikanState extends State<TabelAbsensiPraktikan> {
  late List<AbsensiPraktikan> demoAbsensiPraktikan;
  late List<AbsensiPraktikan> filteredAbsensiPraktikan;

  @override
  void initState() {
    super.initState();
    demoAbsensiPraktikan = [];
    filteredAbsensiPraktikan = [];
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      final absensiSnapshot =
          await FirebaseFirestore.instance.collection('absensiMahasiswa').get();

      final tokenSnapshot =
          await FirebaseFirestore.instance.collection('tokenKelas').get();

      final Map<String, Map<String, dynamic>> tokenDataMap = {};
      for (var doc in tokenSnapshot.docs) {
        tokenDataMap[doc['kodeKelas'] + doc['nim'].toString()] = doc.data();
      }

      final List<AbsensiPraktikan> absenList = absensiSnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();
        final key = data['kodeKelas'] + data['nim'].toString();
        if (tokenDataMap.containsKey(key)) {
          final tokenData = tokenDataMap[key]!;
          return AbsensiPraktikan(
            kode: tokenData['kodeKelas'] ?? '',
            nama: tokenData['nama'] ?? '',
            nim: tokenData['nim'] ?? 0,
            modul: data['judulMateri'] ?? '',
            timestap: data['timestamp'] != null
                ? (data['timestamp'] as Timestamp).toDate().toString()
                : '',
            tanggal: data['tanggal'] ?? '',
            keterangan: data['keterangan'] ?? '',
          );
        } else {
          return AbsensiPraktikan(
            kode: data['kodeKelas'] ?? '',
            nama: '',
            nim: 0,
            modul: data['judulMateri'] ?? '',
            timestap: data['timestamp'] != null
                ? (data['timestamp'] as Timestamp).toDate().toString()
                : '',
            tanggal: data['tanggal'] ?? '',
            keterangan: data['keterangan'] ?? '',
          );
        }
      }).toList();

      setState(() {
        demoAbsensiPraktikan = absenList;
        filteredAbsensiPraktikan = demoAbsensiPraktikan;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
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
  final String timestap;
  final String tanggal;
  final String keterangan;

  AbsensiPraktikan({
    required this.kode,
    required this.nama,
    required this.nim,
    required this.modul,
    required this.timestap,
    required this.tanggal,
    required this.keterangan,
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
          width: 130.0,
          child: Text(getLimitedText(fileInfo.timestap, 19)),
        ),
      ),
      DataCell(
        SizedBox(
          width: 200.0,
          child: Text(getLimitedText(fileInfo.modul, 30)),
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
