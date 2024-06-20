import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:laksi/Pengguna/Admin/Jadwal%20Praktikum/Tabel/Form%20Edit%20Jadwal/form_edit_jadwal.dart';

import '../Form Jadwal/form_jadwal_praktikum_admin.dart';

class TabelJadwalPraktikumAdmin extends StatefulWidget {
  const TabelJadwalPraktikumAdmin({super.key});

  @override
  State<TabelJadwalPraktikumAdmin> createState() =>
      _TabelJadwalPraktikumAdminState();
}

class _TabelJadwalPraktikumAdminState extends State<TabelJadwalPraktikumAdmin> {
  //== List Tabel dan Filtering ==//
  List<DataClass> demoClassData = [];
  List<DataClass> filteredClassData = [];
  //== Fungsi Controller pada Search ==//
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;
  //== Filtering Dropdown Button ==//
  String selectedYear = 'Tahun Ajaran';
  List<String> availableYears = [];
  //== Fungsi Controller Waktu dan Hari ==//
  TextEditingController waktuPraktikumController = TextEditingController();
  TextEditingController hariPraktikumController = TextEditingController();

  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('dataJadwalPraktikum')
              .get();
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

  Future<void> fetchDataFromFirebase(String? selectedYear) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      if (selectedYear != null && selectedYear != 'Tahun Ajaran') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('dataJadwalPraktikum')
            .where('tahunAjaran', isEqualTo: selectedYear)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('dataJadwalPraktikum')
            .get();
      }

      List<DataClass> data = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return DataClass(
            id: doc.id,
            kelas: data['kodeKelas'],
            tahun: data['tahunAjaran'],
            matkul: data['mataKuliah'],
            jadwal: data['hariPraktikum'],
            waktu: data['waktuPraktikum'],
            semester: data['semester']);
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
    fetchAvailableYears().then((_) {
      fetchDataFromFirebase(selectedYear);
    });
  }

  Future<void> _onRefresh() async {
    await fetchDataFromFirebase(selectedYear);
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
              (data.jadwal.toLowerCase().contains(query.toLowerCase()) ||
                  data.matkul.toLowerCase().contains(query.toLowerCase())))
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

  //== Memilih Waktu ==//
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
        _updateTimeText();
      });
    }
  }

  void _updateTimeText() {
    if (startTime != null && endTime != null) {
      final format = DateFormat('hh:mm a');
      final startTimeFormatted = format.format(DateTime(
        0,
        0,
        0,
        startTime!.hour,
        startTime!.minute,
      ));
      final endTimeFormatted = format.format(DateTime(
        0,
        0,
        0,
        endTime!.hour,
        endTime!.minute,
      ));

      waktuPraktikumController.text = '$startTimeFormatted - $endTimeFormatted';
    }
  }

  //== Show Dialog Edit ==//
  void editJadwal(BuildContext context, DataClass data) async {
    //== TextController ==//
    TextEditingController waktuPraktikumController =
        TextEditingController(text: data.waktu);
    TextEditingController hariPraktikumController =
        TextEditingController(text: data.jadwal);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'Edit Jadwal Praktikum',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                child: Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          content: SizedBox(
            height: 150.0,
            width: 150.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //== Waktu Praktikum ==//
                TextField(
                  controller: waktuPraktikumController,
                  decoration: InputDecoration(
                    labelText: 'Waktu Praktikum',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              _selectTime(context, isStartTime: true),
                          icon: const Icon(Icons.access_time),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () =>
                              _selectTime(context, isStartTime: false),
                        ),
                      ],
                    ),
                  ),
                ),
                //== Hari Praktikum ==//
                TextField(
                  controller: hariPraktikumController,
                  decoration: const InputDecoration(
                    labelText: 'Hari Praktikum',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                // Update data di Firestore
                await FirebaseFirestore.instance
                    .collection('dataJadwalPraktikum')
                    .doc(data.id)
                    .update({
                  'waktuPraktikum': waktuPraktikumController.text,
                  'hariPraktikum': hariPraktikumController.text,
                });

                // Fetch data ulang setelah update
                fetchDataFromFirebase(selectedYear);

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
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
                        width: 170.0,
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
                                        const FormJadwalPraktikumAdmin(),
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
                              "+ Tambah Jadwal",
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
                                  "Matakuliah",
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
                                '     Aksi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
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

//== Fungsi Untuk Menghapus Data ==//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('dataJadwalPraktikum')
          .doc(id)
          .delete();
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
  String jadwal;
  String waktu;
  String tahun;
  String matkul;
  int semester;

  DataClass({
    required this.id,
    required this.kelas,
    required this.jadwal,
    required this.waktu, // Updated from Timestamp to String
    required this.tahun,
    required this.matkul,
    required this.semester,
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
      DataCell(SizedBox(width: 140.0, child: Text(fileInfo.kelas))),
      DataCell(
        SizedBox(
          width: 170.0,
          child: Text(
            fileInfo.matkul,
          ),
        ),
      ),
      DataCell(
          SizedBox(width: 120.0, child: Text(fileInfo.semester.toString()))),
      DataCell(
        SizedBox(
          width: 140.0,
          child: Text(
            getLimitedText(fileInfo.jadwal, 6),
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 170.0,
          child: Text(
            getLimitedText(fileInfo.waktu, 30),
          ),
        ),
      ),
      DataCell(Row(
        children: [
          //== IconButton Edit ==//
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FormEditJadwalAdmin(
                          kodeKelas: fileInfo.kelas,
                          mataKuliah: fileInfo.matkul),
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
          //== IconButton Delete ==//
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Hapus Jadwal Praktikum",
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    content: const SizedBox(
                      height: 30.0,
                      width: 100.0,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text("Anda yakin ingin menghapus data?"),
                      ),
                    ),
                    actions: [
                      //== Hapus ==//
                      TextButton(
                        onPressed: () {
                          onDelete(fileInfo.id);
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text("Hapus"),
                        ),
                      ),
                      //== Batal ==//
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text("Batal"),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete, color: Colors.grey),
            tooltip: 'Hapus Data',
          )
        ],
      ))
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
