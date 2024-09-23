import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Komponen/Latihan/Screen/latihan_asisten.dart';

class TabelFilePengumpulanAsisten extends StatefulWidget {
  const TabelFilePengumpulanAsisten({super.key});

  @override
  State<TabelFilePengumpulanAsisten> createState() =>
      _TabelFilePengumpulanAsistenState();
}

class _TabelFilePengumpulanAsistenState
    extends State<TabelFilePengumpulanAsisten> {
  //== List Tabel ==//
  List<DataKelas> demoDataKelas = [];
  List<DataKelas> filteredDataKelas = [];

  //== Fungsi Controller pada Search ==//
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredDataKelas = demoDataKelas
          .where((data) =>
              (data.matkul.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      textController.clear();
      filterData('');
    });
  }

//== Fungsi Menampilkan Data dari Firebase ==//
  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userUid = user.uid;
      fetchUserNIMFromDatabase(userUid);
      fetchDataFromFirebase(userUid);
    }
    textController.addListener(_onTextChanged);
  }

//== Fungsi untuk mengambil berdasarkan nim yang sama pada database ==//
  Future<void> fetchUserNIMFromDatabase(String userUid) async {
    try {
      if (userUid.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();

        if (userSnapshot.exists) {
          int userNim = userSnapshot['nim'] as int;

          QuerySnapshot<Map<String, dynamic>> mahasiswaSnapshot =
              await FirebaseFirestore.instance
                  .collection('dataAsisten')
                  .where('nim', isEqualTo: userNim)
                  .get();

          if (mahasiswaSnapshot.docs.isNotEmpty) {
            String idKelas = mahasiswaSnapshot.docs.first['idKelas'] as String;

            QuerySnapshot<Map<String, dynamic>> kelasPraktikumSnapshot =
                await FirebaseFirestore.instance
                    .collection('dataAsisten')
                    .where('idKelas', isEqualTo: idKelas)
                    .get();

            List<DataKelas> data = kelasPraktikumSnapshot.docs
                .map((doc) => DataKelas(
                      kode: doc['kodeMatakuliah'],
                      idkelas: doc['idKelas'],
                      matkul: doc['matakuliah'],
                      tahunAjaran: doc['tahunAjaran'],
                    ))
                .toList();

            setState(() {
              demoDataKelas = data;
              filteredDataKelas = demoDataKelas;
            });
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching user data from Firebase: $error');
      }
    }
  }

//=== Fungsi mengambil data dari database ===//
  Future<void> fetchDataFromFirebase(String userUid) async {
    try {
      if (userUid.isNotEmpty) {
        // Mendapatkan NIM user dari 'akun_mahasiswa'
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();

        if (userSnapshot.exists) {
          int userNim = userSnapshot['nim'] as int;

          // Mencari dokumen yang sesuai di 'dataAsisten'
          final dataAsistenSnapshots = await Future.wait([
            FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim', isEqualTo: userNim)
                .get(),
            FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim2', isEqualTo: userNim)
                .get(),
            FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim3', isEqualTo: userNim)
                .get(),
            FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim4', isEqualTo: userNim)
                .get()
          ]);

          // Menggabungkan hasil pencarian dataAsisten
          List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];
          for (var snapshot in dataAsistenSnapshots) {
            allDocs.addAll(snapshot.docs);
          }

          if (allDocs.isNotEmpty) {
            List<String> idKelasList =
                allDocs.map((doc) => doc['idKelas'] as String).toList();

            List<DataKelas> allDataKelas = [];

            for (String idKelas in idKelasList) {
              // Mengambil data dari 'dataKelasPraktikum'
              QuerySnapshot<Map<String, dynamic>> kelasPraktikumSnapshot =
                  await FirebaseFirestore.instance
                      .collection('dataKelasPraktikum')
                      .where('idKelas', isEqualTo: idKelas)
                      .get();

              List<DataKelas> data = kelasPraktikumSnapshot.docs
                  .map((doc) => DataKelas(
                        kode: doc['kodeMatakuliah'] ?? '',
                        idkelas: doc['idKelas'] ?? '',
                        matkul: doc['matakuliah'] ?? '',
                        tahunAjaran: doc['tahunAjaran'] ?? '',
                      ))
                  .toList();

              allDataKelas.addAll(data);
            }
            allDataKelas.sort((a, b) => a.matkul.compareTo(b.matkul));
            setState(() {
              demoDataKelas = allDataKelas;
              filteredDataKelas = demoDataKelas;
            });
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data from Firebase: $error');
      }
    }
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = textController.text.isNotEmpty;
      filterData(textController.text);
    });
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
            child: Text('Data Kelas Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //== Search ==//
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 25.0),
                    child: SizedBox(
                      width: 300.0,
                      height: 35.0,
                      child: Row(children: [
                        const Text(
                          'Search :',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                            child: TextField(
                          onChanged: (value) {
                            filterData(value);
                          },
                          controller: textController,
                          decoration: InputDecoration(
                              hintText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10.0),
                              suffixIcon: Visibility(
                                  visible: _isTextFieldNotEmpty,
                                  child: IconButton(
                                      onPressed: clearSearchField,
                                      icon: const Icon(Icons.clear))),
                              labelStyle: const TextStyle(fontSize: 16.0),
                              filled: true,
                              fillColor: Colors.white),
                        )),
                        const SizedBox(
                          width: 27.0,
                        )
                      ]),
                    ),
                  ),
                ],
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
                              'Kode Matakuliah',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataColumn(
                              label: Text(
                                "MataKuliah",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Tahun Ajaran",
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
        ],
      ),
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

class DataKelas {
  String kode;
  String idkelas;
  String matkul;
  String tahunAjaran;

  DataKelas(
      {required this.kode,
      required this.idkelas,
      required this.matkul,
      required this.tahunAjaran});
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
            width: 250.0,
            child: Text(getLimitedText(fileInfo.matkul, 25),
                style: TextStyle(
                    color: Colors.lightBlue[700], fontWeight: FontWeight.bold)),
          ), onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                LatihanAsistenScreen(
              idkelas: fileInfo.idkelas,
              mataKuliah: fileInfo.matkul,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }),
      DataCell(SizedBox(width: 220.0, child: Text(fileInfo.tahunAjaran))),
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
