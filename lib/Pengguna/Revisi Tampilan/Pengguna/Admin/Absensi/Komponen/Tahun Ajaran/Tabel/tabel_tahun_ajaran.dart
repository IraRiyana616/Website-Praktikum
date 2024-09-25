import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Akses Absensi/Screen/akses_absensi.dart';

class TabelTahunAjaranAdmin extends StatefulWidget {
  final String mataKuliah;
  final String kode;
  const TabelTahunAjaranAdmin(
      {super.key, required this.mataKuliah, required this.kode});

  @override
  State<TabelTahunAjaranAdmin> createState() => _TabelTahunAjaranAdminState();
}

class _TabelTahunAjaranAdminState extends State<TabelTahunAjaranAdmin> {
  //== List Data Kelas Pada Tabel ==//
  List<DataTahunAjaran> demoDataTahunAjaran = [];
  List<DataTahunAjaran> filteredDataTahunAjaran = [];

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
      filteredDataTahunAjaran = demoDataTahunAjaran
          .where((data) =>
              data.tahun.toLowerCase().contains(query.toLowerCase()) ||
              data.idkelas.toLowerCase().contains(query.toLowerCase()))
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
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dataKelasPraktikum')
          .where('kodeMatakuliah', isEqualTo: widget.kode)
          .get();
      List<DataTahunAjaran> fetchedData = snapshot.docs.map((doc) {
        return DataTahunAjaran(
          id: doc.id,
          kode: widget.kode,
          matkul: widget.mataKuliah,
          idkelas: doc['idKelas'] ?? '',
          tahun: doc['tahunAjaran'] ?? '',
          semester: doc['semester'] ?? '',
        );
      }).toList();

      // Urutkan fetchedData berdasarkan kodeMatakuliah
      fetchedData.sort((a, b) => b.tahun.compareTo(a.tahun));

      if (mounted) {
        setState(() {
          demoDataTahunAjaran = fetchedData;
          filteredDataTahunAjaran = fetchedData;
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
            child: Text('Data Tahun Ajaran Praktikum',
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
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredDataTahunAjaran.isNotEmpty
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
                                  "Kode Kelas Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Semester",
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
                            source:
                                DataSource(filteredDataTahunAjaran, context),
                            rowsPerPage: calculateRowsPerPage(
                                filteredDataTahunAjaran.length),
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

class DataTahunAjaran {
  String id;
  String idkelas;
  String kode;
  String matkul;
  String tahun;
  String semester;

  DataTahunAjaran(
      {required this.id,
      required this.idkelas,
      required this.kode,
      required this.matkul,
      required this.tahun,
      required this.semester});
}

DataRow dataFileDataRow(
    DataTahunAjaran fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      //== Kode Matakuliah ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.kode,
          ),
        ),
      ),
      //== Kode Kelas Praktikum =//
      DataCell(SizedBox(
          width: 250.0,
          child: GestureDetector(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                fileInfo.idkelas,
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
                      AksesAbsensiAdmin(
                    mataKuliah: fileInfo.matkul,
                    idkelas: fileInfo.idkelas,
                    kode: fileInfo.kode,
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
          ))),
      //== Semester ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.semester,
          ),
        ),
      ),
      //== Tahun Ajaran ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.tahun,
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
  final List<DataTahunAjaran> data;
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
