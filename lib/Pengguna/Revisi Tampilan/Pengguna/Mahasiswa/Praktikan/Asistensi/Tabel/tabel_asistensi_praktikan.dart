import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Komponen/Screen/data_asistensi_praktikan.dart';

class TabelAsistensiLaporan extends StatefulWidget {
  const TabelAsistensiLaporan({super.key});

  @override
  State<TabelAsistensiLaporan> createState() => _TabelAsistensiLaporanState();
}

class _TabelAsistensiLaporanState extends State<TabelAsistensiLaporan> {
  List<DataKelas> demoDataKelas = [];
  List<DataKelas> filteredDataKelas = [];

  //Dropdown Button Tahun Ajaran
  String selectedYear = 'Tahun Ajaran';
  List<String> availableYears = [];

  String nim = ''; // Deklarasi variable nim di luar block if
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> fetchUserNIMFromDatabase(
      String userUid, String? selectedYear) async {
    try {
      if (userUid.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();
        if (userSnapshot.exists) {
          int userNim = userSnapshot['nim'] as int;
          nim = userNim.toString(); // Ubah ke string dan simpan ke dalam nim

          QuerySnapshot<Map<String, dynamic>> querySnapshot =
              await FirebaseFirestore.instance.collection('tokenKelas').get();
          Set<String> years = querySnapshot.docs
              .map((doc) => doc['tahunAjaran'].toString())
              .toSet();
          setState(() {
            availableYears = ['Tahun Ajaran', ...years.toList()];
          });
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching user data from Firebase: $error');
      }
    }
  }

  Future<void> fetchDataFromFirebase(String? selectedYear) async {
    try {
      QuerySnapshot<Map<String, dynamic>> tokenQuerySnapshot;
      if (selectedYear != null && selectedYear != 'Tahun Ajaran') {
        tokenQuerySnapshot = await FirebaseFirestore.instance
            .collection('tokenKelas')
            .where('tahunAjaran', isEqualTo: selectedYear)
            .get();
      } else {
        tokenQuerySnapshot =
            await FirebaseFirestore.instance.collection('tokenKelas').get();
      }

      List<DataKelas> data = [];

      // Pemrosesan pencocokan berdasarkan NIM
      for (var tokenDoc in tokenQuerySnapshot.docs) {
        // Menggunakan 'nim' sebagai int karena sudah diubah di fetchUserNIMFromDatabase
        int tokenNim = tokenDoc['nim'] as int;

        if (tokenNim.toString() == nim) {
          // Check kesamaan NIM dengan pengguna yang sedang login
          Map<String, dynamic> tokenData = tokenDoc.data();
          data.add(DataKelas(
            kode: tokenData['kodeKelas'] ?? '',
            tahun: tokenData['tahunAjaran'] ?? '',
            matkul: tokenData['mataKuliah'] ?? '',
            dosenpengampu: tokenData['dosenPengampu'] ?? '',
            dosenpengampu2: tokenData['dosenPengampu2'] ?? '',
          ));
        }
      }

      setState(() {
        demoDataKelas = data;
        filteredDataKelas = demoDataKelas;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data from Firebase: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Ambil tahun ajaran yang tersedia
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Dapatkan NIM pengguna yang sedang Login
      String userUid = user.uid;
      fetchUserNIMFromDatabase(userUid, selectedYear).then((_) {
        // Mengambil data dari Firebase
        fetchDataFromFirebase(selectedYear);
      });
    }
  }

  Future<void> _onRefresh() async {
    await fetchDataFromFirebase(selectedYear);
  }

  Color getRowColor(int index) {
    if (index % 2 == 0) {
      return Colors.grey.shade200;
    } else {
      return Colors.transparent;
    }
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
            child: Text('Data Asistensi Laporan',
                style: GoogleFonts.quicksand(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0, left: 0.0),
                  child: Container(
                    height: 47.0,
                    width: 1020.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                      value: selectedYear,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedYear = newValue!;
                          fetchDataFromFirebase(selectedYear);
                        });
                      },
                      items: availableYears
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                      style: const TextStyle(color: Colors.black),
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      iconSize: 24,
                      elevation: 16,
                      isExpanded: true,
                      underline: Container(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredDataKelas.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Kode Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "MataKuliah",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Dosen Pengampu 1",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Dosen Pengampu 2",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: DataSource(filteredDataKelas, context),
                            rowsPerPage:
                                calculateRowsPerPage(filteredDataKelas.length),
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

class DataKelas {
  String kode;
  String matkul;
  String tahun;
  String dosenpengampu;
  String dosenpengampu2;

  DataKelas(
      {required this.kode,
      required this.tahun,
      required this.matkul,
      required this.dosenpengampu,
      required this.dosenpengampu2});
}

DataRow dataFileDataRow(DataKelas fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(width: 140.0, child: Text(fileInfo.kode))),
      DataCell(
        SizedBox(
          width: 170.0,
          child: Text(
            fileInfo.matkul,
            style: TextStyle(
                color: Colors.lightBlue[700], fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DataAsistensiLaporanPraktikan(
                kodeKelas: fileInfo.kode,
                mataKuliah: fileInfo.matkul,
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
      ),
      DataCell(SizedBox(
          width: 250.0,
          child: Text(getLimitedText(fileInfo.dosenpengampu, 40)))),
      DataCell(SizedBox(
          width: 250.0,
          child: Text(getLimitedText(fileInfo.dosenpengampu2, 40)))),
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
  final List<DataKelas> data;
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
