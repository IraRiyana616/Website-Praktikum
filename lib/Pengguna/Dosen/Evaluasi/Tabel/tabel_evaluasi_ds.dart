import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Komponen/Grafik/Penilaian Huruf/detail_evaluasi.dart';

class TabelEvaluasiDosen extends StatefulWidget {
  const TabelEvaluasiDosen({Key? key}) : super(key: key);

  @override
  State<TabelEvaluasiDosen> createState() => _TabelEvaluasiDosenState();
}

class _TabelEvaluasiDosenState extends State<TabelEvaluasiDosen> {
  List<DataClass> demoClassData = [];
  List<DataClass> filteredClassData = [];

  String selectedYear = 'Tampilkan Semua';
  List<String> availableYears = [];

  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('dataKelas').get();
      Set<String> years = querySnapshot.docs
          .map((doc) => doc['tahunAjaran'].toString())
          .toSet();

      setState(() {
        availableYears = ['Tampilkan Semua', ...years.toList()];
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

      if (selectedYear != null && selectedYear != 'Tampilkan Semua') {
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
            child: Text('Data Evaluasi Praktikum',
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
                    width: 1000.0,
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
                                  "Kode Kelas",
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
                                  label: Text('Aksi',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)))
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
      DataCell(
          Text(fileInfo.kelas,
              style: TextStyle(
                  color: Colors.lightBlue[700],
                  fontWeight: FontWeight.bold)), onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PieChartNilaiHuruf(kodeKelas: fileInfo.kelas)));
      }),
      DataCell(
        Text(
          fileInfo.matkul,
        ),
      ),
      DataCell(
        SizedBox(
          width: 180.0,
          child: Text(
            getLimitedText(fileInfo.dosenpengampu, 30),
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 180.0,
          child: Text(
            getLimitedText(fileInfo.dosenpengampu2, 30),
          ),
        ),
      ),
      DataCell(
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Evaluasi Kegiatan Praktikum",
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: SizedBox(
                        width: 650.0,
                        height: 750.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(
                                "Masukkan evaluasi dari kegiatan praktikum yang telah berlangsung",
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ),
                            //== Mulai dan Berakhir ==//
                            const Padding(
                              padding: EdgeInsets.only(top: 35.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Mulai Praktikum',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 350.0),
                                    child: Text(
                                      'Berakhir Praktikum',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 15.0),
                            //   child: SizedBox(
                            //     width: 220.0,
                            //     child: TextField(
                            //       decoration: InputDecoration(
                            //         hintText: 'Waktu Praktikum dimulai',
                            //         border: OutlineInputBorder(
                            //           borderRadius: BorderRadius.circular(10.0),
                            //         ),
                            //         fillColor: Colors.white,
                            //         filled: true,
                            //       ),
                            //       style: const TextStyle(
                            //         fontSize: 16.0,
                            //         color: Colors.black,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // //== Tanggal Praktikum berakhir ==//
                            // const Padding(
                            //   padding: EdgeInsets.only(top: 25.0),
                            //   child: Text(
                            //     'Praktikum berakhir',
                            //     style: TextStyle(
                            //       fontSize: 16.0,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 15.0),
                            //   child: SizedBox(
                            //     width: 420.0,
                            //     child: TextField(
                            //       decoration: InputDecoration(
                            //         hintText: 'Waktu Praktikum berakhir',
                            //         border: OutlineInputBorder(
                            //           borderRadius: BorderRadius.circular(10.0),
                            //         ),
                            //         fillColor: Colors.white,
                            //         filled: true,
                            //       ),
                            //       style: const TextStyle(
                            //         fontSize: 16.0,
                            //         color: Colors.black,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            //== Evaluasi Praktikum ==//
                            const Padding(
                              padding: EdgeInsets.only(top: 25.0),
                              child: Text(
                                'Evaluasi Praktikum',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextField(
                                maxLines: 10,
                                decoration: InputDecoration(
                                  hintText: 'Evaluasi',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(
            Icons.add_box,
            color: Colors.grey,
          ),
        ),
      )
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
