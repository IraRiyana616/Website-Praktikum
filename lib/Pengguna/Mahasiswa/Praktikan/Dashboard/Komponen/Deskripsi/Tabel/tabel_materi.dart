import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TabelMateriPraktikum extends StatefulWidget {
  const TabelMateriPraktikum({super.key});

  @override
  State<TabelMateriPraktikum> createState() => _TabelMateriPraktikumState();
}

class _TabelMateriPraktikumState extends State<TabelMateriPraktikum> {
  List<MateriModul> demoMateriModul = [];
  List<MateriModul> filteredMateriModul = [];
  final TextEditingController _textController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    fetchDataFromFirebase();
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('materi_kelas').get();
      setState(() {
        demoMateriModul = querySnapshot.docs
            .map((doc) => MateriModul(
                  kode: doc['kode_asisten'],
                  judul: doc['judulMateri'],
                  jadwal: doc['jadwal'],
                  waktu: doc['waktuPraktikum'],
                ))
            .toList();
        filteredMateriModul = demoMateriModul
            .where((data) => data.kode != 'kode_asisten')
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await fetchDataFromFirebase();
  }

  void _onTextChanged() {
    setState(() {
      filterData(_textController.text);
    });
  }

  void filterData(String query) {
    setState(() {
      filteredMateriModul =
          demoMateriModul.where((data) => data.kode != 'kode_asisten').toList();
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
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredMateriModul.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Modul Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Jadwal Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Waktu",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: DataSource(filteredMateriModul),
                            rowsPerPage: calculateRowsPerPage(
                                filteredMateriModul.length),
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

class MateriModul {
  String kode;
  String judul;
  String jadwal;
  String waktu;

  MateriModul({
    required this.kode,
    required this.judul,
    required this.jadwal,
    required this.waktu,
  });
}

DataRow dataFileDataRow(MateriModul fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.judul)),
      DataCell(Text(fileInfo.jadwal)),
      DataCell(Text(fileInfo.waktu)),
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
  final List<MateriModul> data;

  DataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
