import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Revisi Tampilan/Pengguna/Admin/Absensi/Komponen/Praktikan/absensi_praktikan.dart';

class TabelDataAbsensiAdmin extends StatefulWidget {
  const TabelDataAbsensiAdmin({Key? key}) : super(key: key);

  @override
  State<TabelDataAbsensiAdmin> createState() => _TabelDataAbsensiAdminState();
}

class _TabelDataAbsensiAdminState extends State<TabelDataAbsensiAdmin> {
  List<DataClass> demoClassData = [];
  List<DataClass> filteredClassData = [];

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

    fetchAvailableYears().then((_) {
      fetchDataFromFirebase(selectedYear);
    });
  }

  Future<void> _onRefresh() async {
    await fetchDataFromFirebase(selectedYear);
  }

  void filterData(String query) {
    setState(() {
      filteredClassData = demoClassData
          .where((data) =>
              (data.tahun.toLowerCase().contains(query.toLowerCase())))
          .toList();
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
            child: Text('Data Absensi Praktikum',
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

DataRow dataFileDataRow(DataClass fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.kelas)),
      DataCell(
          SizedBox(
            width: 170.0,
            child: Text(fileInfo.matkul,
                style: TextStyle(
                    color: Colors.lightBlue[700], fontWeight: FontWeight.bold)),
          ), onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AbsensiPraktikanScreen(
              kodeKelas: fileInfo.kelas,
              mataKuliah: fileInfo.matkul,
              kodeAsisten: fileInfo.asisten,
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
      DataCell(
        SizedBox(
          width: 225.0,
          child: Text(
            getLimitedText(fileInfo.dosenpengampu, 37),
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 225.0,
          child: Text(
            getLimitedText(fileInfo.dosenpengampu2, 37),
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
