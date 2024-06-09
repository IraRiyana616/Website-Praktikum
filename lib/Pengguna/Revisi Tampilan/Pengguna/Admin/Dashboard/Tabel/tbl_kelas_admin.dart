import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Komponen/Kelas Praktikum/Deskripsi Kelas/deskripsi_admin.dart';
import '../Komponen/Tambah Data Asisten/form_asisten.dart';
import '../Komponen/Tambah Kelas/form_kelas.dart';

class TabelKelasAdmin extends StatefulWidget {
  const TabelKelasAdmin({super.key});

  @override
  State<TabelKelasAdmin> createState() => _TabelKelasAdminState();
}

class _TabelKelasAdminState extends State<TabelKelasAdmin> {
  //== List Data Kelas Pada Tabel ==//
  List<DataClass> demoClassData = [];
  List<DataClass> filteredClassData = [];

  //== Fungsi Controller 'Search' ==//
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi DropdownButton 'Tahun Ajaran' ==//
  String selectedYear = 'Tahun Ajaran';
  List<String> availableYears = [];

  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('dataKelas').get();
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

//== Fungsi Untuk Menampilkan Data dari Firestore 'dataKelas' ==//
  Future<void> fetchDataFromFirebase(String? selectedYear) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      if (selectedYear != null && selectedYear != 'Tahun Ajaran') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('dataKelas')
            .where('tahunAjaran', isEqualTo: selectedYear)
            .get();
      } else {
        querySnapshot =
            await FirebaseFirestore.instance.collection('dataKelas').get();
      }

      List<DataClass> data = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return DataClass(
          id: doc.id,
          kelas: data['kodeKelas'],
          asisten: data['kodeAsisten'],
          tahun: data['tahunAjaran'],
          matkul: data['mataKuliah'],
          dosenpengampu: data['dosenPengampu'],
          dosenpengampu2: data['dosenPengampu2'],
        );
      }).toList();
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
    // Ambil tahun ajaran yang tersedia
    fetchAvailableYears().then((_) {
      // Mengambil data dari Firebase
      fetchDataFromFirebase(selectedYear);
    });
  }

  Future<void> _onRefresh() async {
    await fetchDataFromFirebase(selectedYear);
  }

//== Fungsi Pada 'Search' ==//
  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = _textController.text.isNotEmpty;
      filterData(_textController.text);
    });
  }

//== Fungsi Untuk Filtering Data ==//
  void filterData(String query) {
    setState(() {
      filteredClassData = demoClassData
          .where((data) =>
              (data.kelas.toLowerCase().contains(query.toLowerCase()) ||
                  data.asisten.toLowerCase().contains(query.toLowerCase()) ||
                  data.tahun.toLowerCase().contains(query.toLowerCase()) ||
                  data.matkul.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

//== Fungsi 'Search' ==//
  void clearSearchField() {
    setState(() {
      _textController.clear();
      filterData('');
    });
  }

//== Fungsi Untuk Menambahkan Warna Pada Tabel ==//
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
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                //== DropdownButton Tahun Ajaran ==//
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
                    //== ElevatedButton Tambah Kelas ==//
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0, top: 10.0),
                      child: SizedBox(
                        height: 40.0,
                        width: 140.0,
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
                                        const FormDataKelas(),
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
                              "+ Tambah Kelas",
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

                    //== == == ==//
                  ],
                ),
                const SizedBox(
                  height: 15,
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
                                  "Kode Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Kode Asisten",
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
                              DataColumn(
                                label: Text(
                                  "       Aksi",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: DataSource(
                                filteredClassData, deleteData, context),
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
      await FirebaseFirestore.instance.collection('dataKelas').doc(id).delete();
      fetchDataFromFirebase(selectedYear);
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data: $error');
      }
    }
  }
}

class DataClass {
  String id;
  String kelas;
  String asisten;
  String tahun;
  String matkul;
  String dosenpengampu;
  String dosenpengampu2;
  DataClass({
    required this.id,
    required this.kelas,
    required this.asisten,
    required this.tahun,
    required this.matkul,
    required this.dosenpengampu,
    required this.dosenpengampu2,
  });
}

DataRow dataFileDataRow(DataClass fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(width: 115.0, child: Text(fileInfo.kelas))),
      DataCell(SizedBox(width: 115.0, child: Text(fileInfo.asisten))),
      DataCell(
        SizedBox(
          width: 185.0,
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
                  DeskripsiKelasAdmin(
                kodeKelas: fileInfo.kelas,
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
      DataCell(
        SizedBox(
          width: 195.0,
          child: Text(
            getLimitedText(fileInfo.dosenpengampu, 30),
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 195.0,
          child: Text(
            getLimitedText(fileInfo.dosenpengampu2, 30),
          ),
        ),
      ),
      DataCell(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //== TAMBAH DATA ==//
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FormDataAsisten(
                          kodeAsisten: fileInfo.asisten,
                          mataKuliah: fileInfo.matkul,
                          kodeKelas: fileInfo.kelas,
                          dosenPengampu: fileInfo.dosenpengampu,
                          dosenPengampu2: fileInfo.dosenpengampu2,
                          tahunAjaran: fileInfo.tahun),
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
              Icons.edit_document,
              color: Colors.grey,
            ),
            tooltip: 'Tambah Data Asisten',
          ),

          //== REMOVE DATA ==//
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Hapus Kelas',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0)),
                      content:
                          const Text('Apakah Anda yakin ingin menghapusnya?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              onDelete(fileInfo.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Hapus')),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Batal'),
                        )
                      ],
                    );
                  });
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.grey,
            ),
            tooltip: 'Hapus Data',
          ),
        ],
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
