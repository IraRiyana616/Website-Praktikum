import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Dashboard/Tabel/Komponen/token_mhs.dart';

import '../Komponen/Deskripsi/Screen/deskripsi_mhs.dart';

class TabelKelasPraktikan extends StatefulWidget {
  const TabelKelasPraktikan({super.key});

  @override
  State<TabelKelasPraktikan> createState() => _TabelKelasPraktikanState();
}

class _TabelKelasPraktikanState extends State<TabelKelasPraktikan> {
  List<DataToken> demoTokenData = [];
  List<DataToken> filteredTokenData = [];

  //== Fungsi Controller pada Search ==//
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredTokenData = demoTokenData
          .where((data) => (data.matkul
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              data.dosenpengampu.toLowerCase().contains(query.toLowerCase()) ||
              data.dosenpengampu2.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      textController.clear();
      filterData('');
    });
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = textController.text.isNotEmpty;
      filterData(textController.text);
    });
  }

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

      List<DataToken> data = [];

      // Pemrosesan pencocokan berdasarkan NIM
      for (var tokenDoc in tokenQuerySnapshot.docs) {
        // Menggunakan 'nim' sebagai int karena sudah diubah di fetchUserNIMFromDatabase
        int tokenNim = tokenDoc['nim'] as int;

        if (tokenNim.toString() == nim) {
          // Check kesamaan NIM dengan pengguna yang sedang login
          Map<String, dynamic> tokenData = tokenDoc.data();
          data.add(DataToken(
            kode: tokenData['kodeKelas'] ?? '',
            tahun: tokenData['tahunAjaran'] ?? '',
            matkul: tokenData['mataKuliah'] ?? '',
            dosenpengampu: tokenData['dosenPengampu'] ?? '',
            dosenpengampu2: tokenData['dosenPengampu2'] ?? '',
          ));
        }
      }

      setState(() {
        demoTokenData = data;
        filteredTokenData = demoTokenData;
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
            child: Text('Data Kelas Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 20.0, fontWeight: FontWeight.bold)),
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
                            width: 10.0,
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
                    //== ElevatedButton Token Asisten ==//
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0, top: 10.0),
                      child: SizedBox(
                        height: 40.0,
                        width: 165.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3CBEA9),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TokenPraktikan()));
                          },
                          child: const Text(
                            "+ Token Praktikum",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredTokenData.isNotEmpty
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
                            source: DataSource(filteredTokenData, context),
                            rowsPerPage:
                                calculateRowsPerPage(filteredTokenData.length),
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

class DataToken {
  String kode;
  String matkul;
  String tahun;
  String dosenpengampu;
  String dosenpengampu2;

  DataToken(
      {required this.kode,
      required this.tahun,
      required this.matkul,
      required this.dosenpengampu,
      required this.dosenpengampu2});
}

DataRow dataFileDataRow(DataToken fileInfo, int index, BuildContext context) {
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
                  DeskripsiMahasiswa(
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
  final List<DataToken> data;
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
