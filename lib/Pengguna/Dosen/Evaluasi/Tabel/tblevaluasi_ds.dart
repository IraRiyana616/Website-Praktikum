import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laksi/Pengguna/Dosen/Evaluasi/Komponen/Detail%20Evaluasi/detail_evaluasids.dart';
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
      FirebaseFirestore.instance.collection('dataEvaluasi');

//Tahun Ajaran
  String selectedYear = 'Tampilkan Semua';
  List<String> availableYears = [];

  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('dataEvaluasi').get();

      Set<String> years = querySnapshot.docs
          .map((doc) => doc['tahunAjaran'].toString())
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
            .collection('dataEvaluasi')
            .where('tahunAjaran', isEqualTo: selectedYear)
            .get();
      } else {
        querySnapshot =
            await FirebaseFirestore.instance.collection('dataEvaluasi').get();
      }

      List<DataEvaluasi> data = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return DataEvaluasi(
          documentId: doc.id,
          kode: data['kodeKelas'] ?? '', // default to empty string if null
          ta: data['tahunAjaran'] ?? '', // default to empty string if null
          lulus: int.parse(data['jumlahLulus'] ?? '0'), // Konversi ke integer
          tidak: int.parse(
              data['jumlahTidak_lulus'] ?? '0'), // Konversi ke integer
          hasil: data['hasilEvaluasi'] ?? '', // default to empty string if null
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

  Future<void> deleteData(String documentId) async {
    try {
      await dataEvaluasiCollection.doc(documentId).delete();
      // Hapus data dari tampilan setelah berhasil dihapus dari Firestore
      setState(() {
        demoDataEvaluasi.removeWhere((data) => data.documentId == documentId);
        filteredDataEvaluasi
            .removeWhere((data) => data.documentId == documentId);
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data: $error');
      }
    }
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
          const SizedBox(
            height: 10.0,
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
                        DataColumn(
                          label: Text(
                            "Aksi",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source:
                          DataSource(filteredDataEvaluasi, context, deleteData),
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

DataRow dataFileDataRow(DataEvaluasi fileInfo, int index, BuildContext context,
    Function(String p1) onDelete) {
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailEvaluasiDosen(
                      documentId: fileInfo.documentId,
                    )));
      }),
      DataCell(Text(fileInfo.lulus.toString())),
      DataCell(Text(fileInfo.tidak.toString())),
      DataCell(Text(getLimitedText(fileInfo.hasil, 20))),
      DataCell(IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus data ini?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Batal')),
                      TextButton(
                          onPressed: () {
                            onDelete(fileInfo.documentId);
                            Navigator.pop(context);
                          },
                          child: const Text('Hapus'))
                    ],
                  );
                });
          },
          icon: const Icon(Icons.delete)))
    ],
  );
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index.isEven ? Colors.grey.shade200 : Colors.transparent;
}

class DataSource extends DataTableSource {
  final List<DataEvaluasi> data;
  final BuildContext context;
  final Function(String) onDelete;

  DataSource(this.data, this.context, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, context, onDelete);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
