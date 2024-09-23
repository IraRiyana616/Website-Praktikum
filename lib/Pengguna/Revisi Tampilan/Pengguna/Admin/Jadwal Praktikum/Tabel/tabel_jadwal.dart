import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Edit Jadwal Praktikum/edit_jadwal.dart';
import '../Tambah Jadwal Praktikum/form_jadwal_praktikum_admin.dart';

class TabelJadwalPraktikum extends StatefulWidget {
  const TabelJadwalPraktikum({super.key});

  @override
  State<TabelJadwalPraktikum> createState() => _TabelJadwalPraktikumState();
}

class _TabelJadwalPraktikumState extends State<TabelJadwalPraktikum> {
  //= List Data Tabel ==//
  List<DataJadwal> demoDataJadwal = [];
  List<DataJadwal> filteredDataJadwal = [];

//== Fungsi Pada 'Search' ==//
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

//== Fungsi pada dropdownButton 'TahunAjaran' ==//
  String selectedYear = 'Tahun Ajaran';
  List<String> availableYears = [];

//== Menampilkan Tahun Ajaran Pada DropdownButton ==//
  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('JadwalPraktikum').get();
      Set<String> years = querySnapshot.docs
          .map((doc) => doc['tahunAjaran'].toString())
          .toSet();

      setState(() {
        availableYears = ['Tahun Ajaran', ...years.toList()];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching available years from firebase: $e');
      }
    }
  }

  void _onTextChanged() {
    _isTextFieldNotEmpty = _textController.text.isNotEmpty;
    filterData(_textController.text);
  }

  //== Filter Data ==//

  void filterData(String query) {
    setState(() {
      filteredDataJadwal = demoDataJadwal
          .where((data) =>
              data.kode.toLowerCase().contains(query.toLowerCase()) ||
              data.hari.toLowerCase().contains(query.toLowerCase()) ||
              data.matkul.toLowerCase().contains(query.toLowerCase()) ||
              data.ruang.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _onRefresh() async {
    fetchDataFromFirestore(selectedYear);
    filterData(_textController.text);
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    fetchAvailableYears();
    fetchDataFromFirestore(selectedYear);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

//== Menampilkan data dari Firestore ==//
  void fetchDataFromFirestore(String selectedYear) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      if (selectedYear != 'Tahun Ajaran') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('JadwalPraktikum')
            .where('tahunAjaran', isEqualTo: selectedYear)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('JadwalPraktikum')
            .get();
      }
      List<DataJadwal> fetchedData = querySnapshot.docs.map((doc) {
        return DataJadwal(
            id: doc.id,
            kode: doc['kodeMatakuliah'] ?? '',
            tahun: doc['tahunAjaran'] ?? '',
            hari: doc['hari'] ?? '',
            waktu: doc['waktuPraktikum'] ?? '',
            ruang: doc['ruangPraktikum'] ?? '',
            matkul: doc['matakuliah'] ?? '');
      }).toList();

      fetchedData.sort((a, b) => a.kode.compareTo(b.kode));

      if (mounted) {
        setState(() {
          demoDataJadwal = fetchedData;
          filteredDataJadwal = fetchedData;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

  void clearSearchField() {
    _textController.clear();
    filterData('');
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
            child: Text('Data Jadwal Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18, fontWeight: FontWeight.bold)),
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
                          fetchDataFromFirestore(selectedYear);
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
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0, top: 10.0),
                      child: SizedBox(
                        height: 40.0,
                        width: 145.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3CBEA9),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const FormJadwalPraktikum(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                          child: const Material(
                            color: Colors.transparent,
                            child: Text(
                              "+ Tambah Data",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                    child: filteredDataJadwal.isNotEmpty
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
                                  "Hari Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Waktu Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Ruang Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "       Aksi",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: DataSource(
                                filteredDataJadwal, deleteData, context),
                            rowsPerPage:
                                calculateRowsPerPage(filteredDataJadwal.length),
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

  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('JadwalPraktikum')
          .doc(id)
          .delete();
      fetchDataFromFirestore(selectedYear);
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data: $error');
      }
    }
  }
}

class DataJadwal {
  String id;
  String kode;
  String tahun;
  String hari;
  String ruang;
  String waktu;
  String matkul;

  DataJadwal(
      {required this.id,
      required this.kode,
      required this.tahun,
      required this.hari,
      required this.ruang,
      required this.waktu,
      required this.matkul});
}

DataRow dataFileDataRow(DataJadwal fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(width: 130.0, child: Text(fileInfo.kode))),
      DataCell(SizedBox(
        width: 220.0,
        child: Text(getLimitedText(fileInfo.matkul, 30)),
      )),
      DataCell(SizedBox(width: 130.0, child: Text(fileInfo.hari))),
      DataCell(SizedBox(width: 150.0, child: Text(fileInfo.waktu))),
      DataCell(SizedBox(width: 130.0, child: Text(fileInfo.ruang))),
      DataCell(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        EditJadwalPraktikum(
                            kode: fileInfo.kode,
                            tahun: fileInfo.tahun,
                            matkul: fileInfo.matkul),
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
              icon: const Icon(Icons.edit_document, color: Colors.grey),
              tooltip: 'Edit Data',
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Hapus Jadwal Praktikum',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0)),
                      content:
                          const Text('Apakah Anda yakin ingin menghapusnya?'),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: TextButton(
                              onPressed: () {
                                onDelete(fileInfo.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Hapus')),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Batal'),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              tooltip: 'Hapus Data',
            ),
          ],
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
  final List<DataJadwal> data;
  final Function(String) onDelete;
  final BuildContext context;

  DataSource(this.data, this.onDelete, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, onDelete, context);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
