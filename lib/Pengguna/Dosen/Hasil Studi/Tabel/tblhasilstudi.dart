import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Hasil%20Studi/Komponen/Penulisan%20Laporan/Screen/penulisanlaporan_ds.dart';

class TabelHasilStudi extends StatefulWidget {
  const TabelHasilStudi({super.key});

  @override
  State<TabelHasilStudi> createState() => _TabelHasilStudiState();
}

class _TabelHasilStudiState extends State<TabelHasilStudi> {
  List<DataHasilStudi> demoDataHasilStudi = [];
  List<DataHasilStudi> filteredDataHasilStudi = [];
  final TextEditingController _textController = TextEditingController();
  String selectedYear = 'Tampilkan Semua';
  List<String> availableYears = [];

  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('data_kelas').get();
      Set<String> years = querySnapshot.docs
          .map((doc) => doc['tahun_ajaran'].toString())
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
            .collection('data_kelas')
            .where('tahun_ajaran', isEqualTo: selectedYear)
            .get();
      } else {
        querySnapshot =
            await FirebaseFirestore.instance.collection('data_kelas').get();
      }

      List<DataHasilStudi> data = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return DataHasilStudi(
          documentId: doc.id,
          kelas: data['kode_kelas'],
          asisten: data['kode_asisten'],
          tahun: data['tahun_ajaran'],
          matkul: data['matakuliah'],
          jmlhasisten: data['jumlah_asisten'],
          jmlhmhs: data['jumlah_mahasiswa'],
        );
      }).toList();
      setState(() {
        demoDataHasilStudi = data;
        filteredDataHasilStudi = demoDataHasilStudi;
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

  void _onTextChanged() {
    setState(() {
      filterData(_textController.text);
    });
  }

  void filterData(String query) {
    setState(() {
      filteredDataHasilStudi = demoDataHasilStudi
          .where((data) =>
              (data.kelas.toLowerCase().contains(query.toLowerCase()) ||
                  data.asisten.toLowerCase().contains(query.toLowerCase()) ||
                  data.tahun.toLowerCase().contains(query.toLowerCase()) ||
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0),
            child: Text('Data Hasil Studi',
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
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredDataHasilStudi.isNotEmpty
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
                                  "Jumlah Asisten",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Jumlah Mahasiswa",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: DataSource(filteredDataHasilStudi, context),
                            rowsPerPage: calculateRowsPerPage(
                                filteredDataHasilStudi.length),
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
    const int defaultRowsPerPage = 50;

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }
}

class DataHasilStudi {
  String kelas;
  String asisten;
  String tahun;
  String matkul;
  String jmlhasisten;
  String jmlhmhs;
  String documentId;
  DataHasilStudi(
      {required this.kelas,
      required this.asisten,
      required this.tahun,
      required this.matkul,
      required this.jmlhasisten,
      required this.jmlhmhs,
      required this.documentId});
}

DataRow dataFileDataRow(
    DataHasilStudi fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(
          Text(
            fileInfo.kelas,
            style: TextStyle(
                color: Colors.lightBlue[700], fontWeight: FontWeight.bold),
          ), onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PenulisanLaporanDosen(
                      documentId: fileInfo.documentId,
                    )));
      }),
      DataCell(Text(fileInfo.matkul)),
      DataCell(Text(fileInfo.jmlhasisten)),
      DataCell(Text(fileInfo.jmlhmhs)),
    ],
  );
}

Color getRowColor(int index) {
  if (index % 2 == 0) {
    return Colors.grey.shade200;
  } else {
    return Colors.transparent;
  }
}

class DataSource extends DataTableSource {
  final List<DataHasilStudi> data;
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
