import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Komponen/Tahun Ajaran/Screen/arsip_ta.dart';

class TabelArsipPraktikum extends StatefulWidget {
  const TabelArsipPraktikum({super.key});

  @override
  State<TabelArsipPraktikum> createState() => _TabelArsipPraktikumState();
}

class _TabelArsipPraktikumState extends State<TabelArsipPraktikum> {
  //== List Data Kelas Pada Tabel ==//
  List<DataClass> demoClassData = [];
  List<DataClass> filteredClassData = [];

//== Fungsi Controller 'Search' ==//
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

//== Fungsi Pada 'Search' ==//
  void _onTextChanged() {
    _isTextFieldNotEmpty = _textController.text.isNotEmpty;
    filterData(_textController.text);
  }

//== Fungsi Untuk Filtering Data ==//
  void filterData(String query) {
    setState(() {
      filteredClassData = demoClassData
          .where((data) =>
              data.kelas.toLowerCase().contains(query.toLowerCase()) ||
              data.namaDosen.toLowerCase().contains(query.toLowerCase()) ||
              data.namaDosen2.toLowerCase().contains(query.toLowerCase()) ||
              data.matkul.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

//== Loading Perbaharui Data ==//
  Future<void> _onRefresh() async {
    fetchDataFromFirestore();
  }

//== Fungsi untuk menampilkan data dari firestore 'dataMatakuliah' ==//
  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    fetchDataFromFirestore();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

//== Firestore 'dataMatakuliah' ==//
  void fetchDataFromFirestore() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('dataMatakuliah').get();
      List<DataClass> fetchedData = snapshot.docs.map((doc) {
        return DataClass(
            id: doc.id,
            kelas: doc['kodeMatakuliah'] ?? '',
            matkul: doc['matakuliah'] ?? '',
            namaDosen: doc['namaDosen'] ?? '',
            namaDosen2: doc['namaDosen2'] ?? '',
            nipDosen: doc['nipDosen'] ?? '',
            nipDosen2: doc['nipDosen2'] ?? '');
      }).toList();

      // Urutkan fetchedData berdasarkan kodeMatakuliah
      fetchedData.sort((a, b) => a.matkul.compareTo(b.matkul));

      if (mounted) {
        setState(() {
          demoClassData = fetchedData;
          filteredClassData = fetchedData;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

//== Fungsi 'Search' ==//
  void clearSearchField() {
    _textController.clear();
    filterData('');
  }

//== Fungsi Untuk Menambahkan Warna Pada Tabel ==//
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
            child: Text('Data Absensi Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  //== Search ==//
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

                  //== == == ==//
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 18.0, right: 25.0, top: 45.0),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
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
                                  "Nama Matakuliah",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Nama Dosen Pengampu",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Nama Dosen Pengampu 2",
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
  String id;
  String kelas;
  String namaDosen;
  String namaDosen2;
  String nipDosen;
  String nipDosen2;
  String matkul;
  DataClass({
    required this.id,
    required this.kelas,
    required this.namaDosen,
    required this.namaDosen2,
    required this.nipDosen,
    required this.nipDosen2,
    required this.matkul,
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
      //== kodeMatakuliah =//
      DataCell(SizedBox(width: 125.0, child: Text(fileInfo.kelas))),
      //== Nama Matakuliah ==//
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
                  ArsipTahunAjaran(
                mataKuliah: fileInfo.matkul,
                kode: fileInfo.kelas,
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
      //== Nama Dosen Pengampu ==//
      DataCell(
        SizedBox(
          width: 230.0,
          child: Text(
            getLimitedText(fileInfo.namaDosen, 33),
          ),
        ),
      ),
      //== Nama Dosen Pengampu 2 ==//
      DataCell(
        SizedBox(
          width: 230.0,
          child: Text(
            getLimitedText(fileInfo.namaDosen2, 33),
          ),
        ),
      ),
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
