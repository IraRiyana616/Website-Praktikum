import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabelAbsenKu extends StatefulWidget {
  final String kodeKelas;

  const TabelAbsenKu({
    Key? key,
    required this.kodeKelas,
  }) : super(key: key);

  @override
  State<TabelAbsenKu> createState() => _TabelAbsenKuState();
}

class _TabelAbsenKuState extends State<TabelAbsenKu> {
  List<AbsensiPraktikan> demoAbsensiPraktikan = [];
  List<AbsensiPraktikan> filteredAbsensiPraktikan = [];
  int nim = 0;

  @override
  void initState() {
    super.initState();
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
          .collection('absensiAsisten')
          .where('nim', isEqualTo: nim)
          .get();

      setState(() {
        demoAbsensiPraktikan = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return AbsensiPraktikan(
            kode: data['kodeAsisten'] ?? '',
            nama: data['nama'] ?? '',
            nim: data['nim'] ?? 0,
            modul: data['judulMateri'] ?? '',
            tanggal: data['tanggal'] ?? '',
            timestap: (data['timestamp'] as Timestamp).toDate().toString(),
            keterangan: data['keterangan'] ?? '',
          );
        }).toList();

        filteredAbsensiPraktikan = List.from(demoAbsensiPraktikan);
      });
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
          width: 250.0,
          child: Text(getLimitedText(fileInfo.modul, 35)),
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
