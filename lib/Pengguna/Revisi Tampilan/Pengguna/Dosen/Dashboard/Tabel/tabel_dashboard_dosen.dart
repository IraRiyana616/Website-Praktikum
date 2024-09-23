import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Komponen/Data Tahun Ajaran/Screen/data_dashboard.dart';

class TabelDashboardDosen extends StatefulWidget {
  const TabelDashboardDosen({super.key});

  @override
  State<TabelDashboardDosen> createState() => _TabelDashboardDosenState();
}

class _TabelDashboardDosenState extends State<TabelDashboardDosen> {
  //== List Data Tabel ==//
  List<DataClass> demoClassData = [];
  List<DataClass> filteredClassData = [];

  //== Fungsi Search ==//
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Authentikasi ==//
  String nip = '';
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> fetchUserNIPFromDatabase(String userUid) async {
    try {
      if (userUid.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_dosen')
                .doc(userUid)
                .get();
        if (userSnapshot.exists) {
          String? userNip = userSnapshot['nip'] as String?;
          nip = userNip ?? '';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data from Firebase: $e');
      }
    }
  }

  Future<void> fetchDataFromFirebase(String nip) async {
    try {
      // Query pertama untuk mengambil 'nip' dari koleksi 'akun_dosen'
      QuerySnapshot<Map<String, dynamic>> nipSnapshot =
          await FirebaseFirestore.instance.collection('akun_dosen').get();

      // Simpan 'nip' dalam sebuah Set
      Set<String> availableNips =
          nipSnapshot.docs.map((doc) => doc['nip'].toString()).toSet();

      if (kDebugMode) {
        print('Available NIPs: $availableNips');
      }

      // Query kedua untuk mengambil data 'dataTahunAjaran' berdasarkan 'tahunAjaran'
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      querySnapshot =
          await FirebaseFirestore.instance.collection('dataMatakuliah').get();

      List<DataClass> data = querySnapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data();
            // Cocokkan 'nip' yang diambil dengan nip yang sesuai dengan akun yang login
            if (nip == data['nipDosen'] || nip == data['nipDosen2']) {
              if (kDebugMode) {
                print('Match found for NIP: $nip');
              }
              return DataClass(
                kode: data['kodeMatakuliah'],
                matkul: data['matakuliah'],
                nip: data['nipDosen'] ??
                    data[
                        'nipDosen2'], // Gunakan nipDosenPengampu atau nipDosenPengampu2, jika salah satu kosong
                dosenPengampu: data['namaDosen'],
                dosenPengampu2: data['namaDosen2'],
              );
            } else {
              //== Jika 'nip' tidak valid, kembalikan null ===//
              return null;
            }
          })
          .whereType<DataClass>() //== Hapus elemen null dari daftar ==//
          .toList(); //== Konversi ke List<DataClass> ==//

      setState(() {
        demoClassData = data;
        filteredClassData = demoClassData;
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
    _textController.addListener(_onTextChanged);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userUid = user.uid;
      fetchUserNIPFromDatabase(userUid).then((_) {
        fetchDataFromFirebase(nip);
      });
    }
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = _textController.text.isNotEmpty;
      filterData(_textController.text);
    });
  }

  void filterData(String query) {
    setState(() {
      filteredClassData = demoClassData
          .where((data) =>
              data.kode.toLowerCase().contains(query.toLowerCase()) ||
              data.dosenPengampu.toLowerCase().contains(query.toLowerCase()) ||
              data.dosenPengampu2.toLowerCase().contains(query.toLowerCase()) ||
              data.matkul.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      _textController.clear();
      filterData('');
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
            child: Text('Data Matakuliah Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 25.0),
                    child: SizedBox(
                      width: 300.0,
                      height: 35.0,
                      child: Row(
                        children: [
                          const Text("Search :",
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                filterData(value);
                              },
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                suffixIcon: Visibility(
                                  visible: _isTextFieldNotEmpty,
                                  child: IconButton(
                                    onPressed: clearSearchField,
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 27.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                child: SizedBox(
                  width: double.infinity,
                  child: filteredClassData.isNotEmpty
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
                          source: DataSource(filteredClassData, context),
                          rowsPerPage:
                              calculateRowsPerPage(filteredClassData.length),
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

class DataClass {
  String kode;
  String matkul;
  String nip;
  String dosenPengampu;
  String dosenPengampu2;
  DataClass({
    required this.kode,
    required this.matkul,
    required this.nip,
    required this.dosenPengampu,
    required this.dosenPengampu2,
  });
}

DataRow dataFileDataRow(DataClass fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.kode)),
      DataCell(
        SizedBox(
          width: 230.0,
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
                  TAKelasPraktikum(
                kode: fileInfo.kode,
                matakuliah: fileInfo.matkul,
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
        width: 230.0,
        child: Text(
          getLimitedText(fileInfo.dosenPengampu, 33),
        ),
      )),
      DataCell(SizedBox(
        width: 230.0,
        child: Text(
          getLimitedText(fileInfo.dosenPengampu2, 33),
        ),
      )),
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
  final List<DataClass> data;
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
