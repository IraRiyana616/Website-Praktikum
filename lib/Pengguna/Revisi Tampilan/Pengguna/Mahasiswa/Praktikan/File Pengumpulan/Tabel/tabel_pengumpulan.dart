import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Komponen/Latihan/latihan_praktikan.dart';

class TabelMataKuliahPraktikan extends StatefulWidget {
  const TabelMataKuliahPraktikan({Key? key}) : super(key: key);

  @override
  State<TabelMataKuliahPraktikan> createState() =>
      _TabelMataKuliahPraktikanState();
}

class _TabelMataKuliahPraktikanState extends State<TabelMataKuliahPraktikan> {
  List<DataKelasPraktikan> demoKelasPraktikan = [];
  List<DataKelasPraktikan> filteredKelasPraktikan = [];
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userUid = user.uid;
      fetchUserNIMFromDatabase(userUid);
    }
    textController.addListener(_onTextChanged);
  }

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
                  .collection('dataMahasiswaPraktikum')
                  .where('nim', isEqualTo: userNim)
                  .get();

          if (mahasiswaSnapshot.docs.isNotEmpty) {
            Set<String> idKelasSet = {};
            for (var doc in mahasiswaSnapshot.docs) {
              String idKelas = doc['idKelas'] as String;
              idKelasSet.add(idKelas);
            }

            List<DataKelasPraktikan> data = [];
            for (String idKelas in idKelasSet) {
              QuerySnapshot<Map<String, dynamic>> kelasPraktikumSnapshot =
                  await FirebaseFirestore.instance
                      .collection('dataKelasPraktikum')
                      .where('idKelas', isEqualTo: idKelas)
                      .get();

              data.addAll(
                  kelasPraktikumSnapshot.docs.map((doc) => DataKelasPraktikan(
                        kode: doc['kodeMatakuliah'] ?? '',
                        idkelas: doc['idKelas'] ?? '',
                        matkul: doc['matakuliah'] ?? '',
                        tahunAjaran: doc['tahunAjaran'] ?? '',
                      )));
            }
//== Urutkan fetchedData berdasarkan nama matakuliah ==//
            data.sort((a, b) => a.matkul.compareTo(b.matkul));
            setState(() {
              demoKelasPraktikan = data;
              filteredKelasPraktikan = demoKelasPraktikan;
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

  void clearSearchField() {
    setState(() {
      textController.clear();
      filterData('');
    });
  }

  void filterData(String query) {
    setState(() {
      filteredKelasPraktikan = demoKelasPraktikan
          .where((data) =>
              data.matkul.toLowerCase().contains(query.toLowerCase()) ||
              data.kode.toLowerCase().contains(query.toLowerCase()) ||
              data.tahunAjaran.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = textController.text.isNotEmpty;
      filterData(textController.text);
    });
  }

  Future<void> _onRefresh() async {
    await fetchUserNIMFromDatabase(FirebaseAuth.instance.currentUser!.uid);
  }

  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
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
            child: Text('Data Matakuliah Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Search TextField
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
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                                labelStyle: const TextStyle(fontSize: 16.0),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
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
                    child: filteredKelasPraktikan.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Kode Matakuliah",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Matakuliah",
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
                            source: DataSource(filteredKelasPraktikan, context),
                            rowsPerPage: calculateRowsPerPage(
                                filteredKelasPraktikan.length),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Center(
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

class DataKelasPraktikan {
  String kode;
  String idkelas;
  String matkul;
  String tahunAjaran;

  DataKelasPraktikan(
      {required this.kode,
      required this.idkelas,
      required this.matkul,
      required this.tahunAjaran});
}

DataRow dataFileDataRow(
    DataKelasPraktikan fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(width: 120.0, child: Text(fileInfo.kode))),
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.matkul,
            style: TextStyle(
              color: Colors.lightBlue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LatihanPraktikanScreen(
                matkul: fileInfo.matkul,
                idkelas: fileInfo.idkelas,
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
      DataCell(SizedBox(width: 150.0, child: Text(fileInfo.tahunAjaran))),
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
  final List<DataKelasPraktikan> data;
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
