import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabelAbsensiPraktikan extends StatefulWidget {
  final String kodeKelas;

  const TabelAbsensiPraktikan({
    Key? key,
    required this.kodeKelas,
  }) : super(key: key);

  @override
  State<TabelAbsensiPraktikan> createState() => _TabelAbsensiPraktikanState();
}

class _TabelAbsensiPraktikanState extends State<TabelAbsensiPraktikan> {
  List<AbsensiPraktikan> demoAbsensiPraktikan = [];
  List<AbsensiPraktikan> filteredAbsensiPraktikan = [];
  late String userNIM; // Menyimpan NIM pengguna yang sedang login

  @override
  void initState() {
    super.initState();
    // Call function to fetch attendance data
    fetchData();
  }

  void fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      // Fetch token from Firestore based on the user's UID
      DocumentSnapshot<Map<String, dynamic>> tokenSnapshot =
          await FirebaseFirestore.instance
              .collection('tokenKelas')
              .doc(uid)
              .get();
      String? token = tokenSnapshot.data()?['nim'];

      if (token != null) {
        setState(() {
          userNIM = token; // Set userNIM dengan NIM pengguna yang sedang login
        });

        // Fetch data from Firestore collection 'absensiMahasiswa' based on 'kodeKelas'
        QuerySnapshot<Map<String, dynamic>> attendanceSnapshot =
            await FirebaseFirestore.instance
                .collection('absensiMahasiswa')
                .where('kodeKelas', isEqualTo: widget.kodeKelas)
                .get();

        List<AbsensiPraktikan> fetchedData =
            attendanceSnapshot.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          return AbsensiPraktikan(
            kode: data['kodeKelas'] ?? '',
            nama: data['nama'] ?? '',
            nim: data['nim'] ?? 0,
            modul: data['judulMateri'] ?? '',
            timestap: (data['timestamp'] as Timestamp).toDate(),
            tanggal: data['tanggal'] ?? '',
            keterangan: data['keterangan'] ?? '',
          );
        }).toList();

        // Filter fetched data based on userNIM
        List<AbsensiPraktikan> filteredData = fetchedData
            .where((absensi) => absensi.nim.toString() == userNIM)
            .toList();

        setState(() {
          demoAbsensiPraktikan = fetchedData;
          filteredAbsensiPraktikan = filteredData;
        });
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
  final DateTime timestap;
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
