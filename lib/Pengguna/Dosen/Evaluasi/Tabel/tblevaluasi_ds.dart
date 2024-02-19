import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laksi/Pengguna/Dosen/Evaluasi/Komponen/Form%20Evaluasi/formevaluasi_ds.dart';

class TabelEvaluasiDosen extends StatefulWidget {
  const TabelEvaluasiDosen({super.key});

  @override
  State<TabelEvaluasiDosen> createState() => _TabelEvaluasiDosenState();
}

class _TabelEvaluasiDosenState extends State<TabelEvaluasiDosen> {
  List<DataEvaluasi> demoDataEvaluasi = [];
  List<DataEvaluasi> filteredDataEvaluasi = [];
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //Koneksi ke database
  CollectionReference dataEvaluasiCollection =
      FirebaseFirestore.instance.collection('data_evaluasi');

//Tahun Ajaran
  String selectedYear = 'Tampilkan Semua';
  List<String> availableYears = [];

  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('data_evaluasi').get();

      Set<String> years = querySnapshot.docs
          .map((doc) => doc['tahun_ajaran'].toString())
          .toSet();

      setState(() {
        availableYears = ['Tampilkan Semua', ...years.toList()];
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching available years from Firebase: $error');
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

  Future<void> fetchDataFromFirebase(String? selectedYear) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      if (selectedYear != null && selectedYear != 'Tampilkan Semua') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('data_evaluasi')
            .where('tahun_ajaran', isEqualTo: selectedYear)
            .get();
      } else {
        querySnapshot =
            await FirebaseFirestore.instance.collection('data_evaluasi').get();
      }

      List<DataEvaluasi> data = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return DataEvaluasi(
          documentId: doc.id,
          kode: data['kode_kelas'] ?? '', // default to empty string if null
          ta: data['tahun_ajaran'] ?? '', // default to empty string if null
          lulus: data['lulus'] ?? 0, // default to 0 if null
          tidak: data['tidak_lulus'] ?? 0, // default to 0 if null
          hasil:
              data['hasil_evaluasi'] ?? '', // default to empty string if null
        );
      }).toList();

      setState(() {
        // Prepend the new data to the existing list
        demoDataEvaluasi = data;
        filteredDataEvaluasi = demoDataEvaluasi;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = _textController.text.isNotEmpty;
      filterData(_textController.text);
    });
  }

  void filterData(String query) {
    setState(() {
      filteredDataEvaluasi = demoDataEvaluasi
          .where(
            (data) => data.kode.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      _textController.clear();
      filterData('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
                padding: const EdgeInsets.only(left: 25.0),
                child: SizedBox(
                  width: 250.0,
                  height: 35.0,
                  child: Row(
                    children: [
                      const Text("Search:", style: TextStyle(fontSize: 16)),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: filterData,
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
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
                      const SizedBox(
                        width: 27.0,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: SizedBox(
                  height: 35.0,
                  width: 130.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF3CBEA9),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormEvaluasiDosen(),
                        ),
                      );
                    },
                    child: const Text(
                      "+Tambah Data",
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredDataEvaluasi.isNotEmpty
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
                            "Lulus Praktikum",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Tidak Lulus Praktikum",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Hasil Evaluasi",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredDataEvaluasi, context),
                      rowsPerPage:
                          calculateRowsPerPage(filteredDataEvaluasi.length),
                    )
                  : const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 50; // Set your default value here

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      // You can adjust this logic based on your requirements
      return defaultRowsPerPage;
    }
  }
}

class DataEvaluasi {
  String kode;
  String ta;
  int lulus;
  int tidak;
  String hasil;
  String documentId;

  DataEvaluasi({
    required this.documentId,
    required this.kode,
    required this.ta,
    required this.lulus,
    required this.tidak,
    required this.hasil,
  });
}

DataRow dataFileDataRow(
    DataEvaluasi fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(
          Text(fileInfo.kode,
              style: TextStyle(
                  color: Colors.lightBlue[700],
                  fontWeight: FontWeight.bold)), onTap: () {
        //Navigate to detail evaluation screen with documentID
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => DetailEvaluationScreen(
        //               documentId: fileInfo.documentId,
        //             )));
      }),
      DataCell(Text(fileInfo.lulus.toString())),
      DataCell(Text(fileInfo.tidak.toString())),
      DataCell(Text(getLimitedText(fileInfo.hasil, 20))),
    ],
  );
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : '${text.substring(0, limit)}...';
}

Color getRowColor(int index) {
  return index.isEven ? Colors.grey.shade200 : Colors.transparent;
}

class DataSource extends DataTableSource {
  final List<DataEvaluasi> data;
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
