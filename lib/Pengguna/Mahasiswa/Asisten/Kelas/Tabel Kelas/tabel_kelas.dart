import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Data%20Mahasiswa/Screen/data_mahasiswa.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Form%20Komponen/Deskripsi/form_deskripsi.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Komponen/Deskripsi/Screen/deskripsi_kelas.dart';

class TabelKelasAsisten extends StatefulWidget {
  const TabelKelasAsisten({Key? key}) : super(key: key);

  @override
  State<TabelKelasAsisten> createState() => _TabelKelasAsistenState();
}

class _TabelKelasAsistenState extends State<TabelKelasAsisten> {
  //== List Tabel ==//
  List<DataKelas> demoDataKelas = [];
  List<DataKelas> filteredDataKelas = [];

  //== Dropdown Button Tahun Ajaran ==
  String selectedYear = 'Tahun Ajaran';
  List<String> availableYears = [];

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

//== Fungsi dari Authentikasi ==//
  String nim = '';
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
          nim = userNim.toString();

          QuerySnapshot<Map<String, dynamic>> querySnapshot =
              await FirebaseFirestore.instance.collection('dataAsisten').get();
          Set<String> years = querySnapshot.docs
              .map((doc) => doc['tahunAjaran'].toString())
              .toSet();
          setState(() {
            availableYears = ['Tahun Ajaran', ...years.toList()];
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data from Firebase: $e');
      }
    }
  }

  Future<void> fetchDataFromFirebase(String? selectedYear) async {
    try {
      QuerySnapshot<Map<String, dynamic>> tokenQuerySnapshot;
      if (selectedYear != null && selectedYear != 'Tahun Ajaran') {
        tokenQuerySnapshot = await FirebaseFirestore.instance
            .collection('dataAsisten')
            .where('tahunAjaran', isEqualTo: selectedYear)
            .get();
      } else {
        tokenQuerySnapshot =
            await FirebaseFirestore.instance.collection('dataAsisten').get();
      }
      List<DataKelas> data = [];
      for (var tokenDoc in tokenQuerySnapshot.docs) {
        int tokenNim = tokenDoc['nim'] as int;

        if (tokenNim.toString() == nim) {
          Map<String, dynamic> tokenData = tokenDoc.data();
          data.add(DataKelas(
              kode: tokenData['kodeKelas'] ?? '',
              tahun: tokenData['tahunAjaran'] ?? '',
              matkul: tokenData['mataKuliah'] ?? '',
              dosenpengampu: tokenData['dosenPengampu'] ?? '',
              dosenpengampu2: tokenData['dosenPengampu2'] ?? '',
              asisten: tokenData['kodeAsisten'] ?? ''));
        }
      }
      setState(() {
        demoDataKelas = data;
        filteredDataKelas = demoDataKelas;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data from Firebase:$e');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    textController.addListener(_onTextChanged);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userUid = user.uid;
      fetchUserNIMFromDatabase(userUid, selectedYear).then((_) {
        fetchDataFromFirebase(selectedYear);
      });
    }
  }

  Future<void> _onRefresh() async {
    await fetchDataFromFirebase(selectedYear);
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
                                'Kode Asisten',
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
                              DataColumn(
                                label: Text(
                                  "      Aksi",
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
    const int defaultRowsPerPage = 25;

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }
}

class DataKelas {
  String asisten;
  String kode;
  String matkul;
  String tahun;
  String dosenpengampu;
  String dosenpengampu2;

  DataKelas({
    required this.asisten,
    required this.kode,
    required this.tahun,
    required this.matkul,
    required this.dosenpengampu,
    required this.dosenpengampu2,
  });
}

DataRow dataFileDataRow(DataKelas fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(width: 140.0, child: Text(fileInfo.asisten))),
      DataCell(
          SizedBox(
            width: 170.0,
            child: Text(fileInfo.matkul,
                style: TextStyle(
                    color: Colors.lightBlue[700], fontWeight: FontWeight.bold)),
          ), onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeskripsiKelas(
                      kodeKelas: fileInfo.kode,
                      mataKuliah: fileInfo.matkul,
                    )));
      }),
      DataCell(SizedBox(
          width: 220.0,
          child: Text(getLimitedText(fileInfo.dosenpengampu, 30)))),
      DataCell(SizedBox(
          width: 220.0,
          child: Text(getLimitedText(fileInfo.dosenpengampu2, 30)))),
      DataCell(Row(
        children: [
          //== Tambah Data ==//
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FormDeskripsiKelas(
                            kodeKelas: fileInfo.kode,
                            mataKuliah: fileInfo.matkul)));
              },
              icon: const Icon(
                Icons.add_box,
                color: Colors.grey,
              )),
          //== Informasi ==//
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DataMahasiswaKelas(
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
            icon: const Icon(
              Icons.info,
              color: Colors.grey,
            ),
            tooltip: 'Data Mahasiswa',
          ),
        ],
      ))
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
