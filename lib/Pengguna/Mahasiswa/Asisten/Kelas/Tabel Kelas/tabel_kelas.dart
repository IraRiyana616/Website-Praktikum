import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Form%20Komponen/Deskripsi/form_deskripsi.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Tabel%20Kelas/Komponen/token_asisten.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Dashboard/Komponen/Deskripsi/Screen/deskripsi_kelas.dart';

class TabelKelasAsisten extends StatefulWidget {
  const TabelKelasAsisten({Key? key}) : super(key: key);

  @override
  State<TabelKelasAsisten> createState() => _TabelKelasAsistenState();
}

class _TabelKelasAsistenState extends State<TabelKelasAsisten> {
  List<DataKelas> demoDataKelas = [];
  List<DataKelas> filteredDataKelas = [];

  CollectionReference dataKelasCollection =
      FirebaseFirestore.instance.collection('tokenAsisten');

  //TahunAjaran
  String selectedYear = 'Tampilkan Semua';
  List<String> availableYears = [];

  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tokenAsisten').get();

      Set<String> years = querySnapshot.docs
          .map((doc) => doc['tahunAjaran'].toString())
          .toSet();

      setState(() {
        availableYears = ['Tampilkan Semua', ...years.toList()];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching availbale years from Firebase: $e');
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

  Future<void> fetchDataFromFirebase(String? selectedYear) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      if (selectedYear != null && selectedYear != 'Tampilkan Semua') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('tokenAsisten')
            .where('tahunAjaran', isEqualTo: selectedYear)
            .get();
      } else {
        querySnapshot =
            await FirebaseFirestore.instance.collection('tokenAsisten').get();
      }
      List<DataKelas> data = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return DataKelas(
          asisten: data['kodeAsisten'] ?? '',
          kode: data['kodeKelas'] ?? '',
          tahun: data['tahunAjaran'] ?? '',
          matkul: data['mataKuliah'] ?? '',
          dosenpengampu: data['dosenPengampu'] ?? '',
          dosenpengampu2: data['dosenPengampu2'] ?? '',
        );
      }).toList();

      setState(() {
        demoDataKelas = data;
        filteredDataKelas = demoDataKelas;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> _onRefresh() async {
    await fetchDataFromFirebase(selectedYear);
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
            child: Text('Data Kelas Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 20.0, fontWeight: FontWeight.bold)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TokenAsisten()));
                          },
                          child: const Text(
                            "+ Tambah Kelas",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredDataKelas.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                  label: Text(
                                'Kode Asisten',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
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
                                  "",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: DataSource(filteredDataKelas, context),
                            rowsPerPage:
                                calculateRowsPerPage(filteredDataKelas.length),
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

class DataKelas {
  String asisten;
  String kode;
  String matkul;
  String tahun;
  String dosenpengampu;
  String dosenpengampu2;

  DataKelas({
    required this.asisten,
    required this.kode,
    required this.tahun,
    required this.matkul,
    required this.dosenpengampu,
    required this.dosenpengampu2,
  });
}

DataRow dataFileDataRow(DataKelas fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.asisten)),
      DataCell(
          Text(fileInfo.matkul,
              style: TextStyle(
                  color: Colors.lightBlue[700],
                  fontWeight: FontWeight.bold)), onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeskripsiKelas(
                      kodeKelas: fileInfo.kode,
                    )));
      }),
      DataCell(SizedBox(
          width: 180.0,
          child: Text(getLimitedText(fileInfo.dosenpengampu, 30)))),
      DataCell(SizedBox(
          width: 180.0,
          child: Text(getLimitedText(fileInfo.dosenpengampu2, 30)))),
      DataCell(Row(
        children: [
          const Icon(
            Icons.edit,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 5.0,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FormDeskripsiKelas()));
            },
            child: const Text(
              'Edit Data',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          )
        ],
      )),
    ],
  );
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  if (index % 2 == 0) {
    return Colors.grey.shade200;
  } else {
    return Colors.transparent;
  }
}

class DataSource extends DataTableSource {
  final List<DataKelas> data;
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
