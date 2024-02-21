import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TabelAbsensiMahasiswa extends StatefulWidget {
  const TabelAbsensiMahasiswa({super.key});

  @override
  State<TabelAbsensiMahasiswa> createState() => _TabelAbsensiMahasiswaState();
}

class _TabelAbsensiMahasiswaState extends State<TabelAbsensiMahasiswa> {
  List<DataAbsensi> demoDataAbsensi = [];
  List<DataAbsensi> filteredDataAbsensi = [];
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;
  String selectedKode = 'Tampilkan Semua';
  List<String> availableKode = [];

  Future<void> fetchAvailableKode() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('absensi_mahasiswa')
              .get();

      Set<String> kode =
          querySnapshot.docs.map((doc) => doc['kode_kelas'].toString()).toSet();
      setState(() {
        availableKode = ['Tampilkan Semua', ...kode.toList()];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching available years from Firebase: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    fetchAvailableKode().then((_) {
      fetchDataFromFirestore(selectedKode);
    });
    // Replace this with fetching data from Firebase
  }

  void fetchDataFromFirestore(String? selectedKode) async {
    try {
      // Replace this with fetching data from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      if (selectedKode != null && selectedKode != 'Tampilkan Semua') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('absensi_mahasiswa')
            .where('kode_kelas', isEqualTo: selectedKode)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('absensi_mahasiswa')
            .get();
      }

      List<DataAbsensi> data = querySnapshot.docs.map((doc) {
        Map<String, dynamic> docData = doc.data();
        return DataAbsensi(
            kode: docData['kode_kelas'] ?? '',
            nim: docData['nim'] ?? '',
            modul: docData['modul'] ?? '',
            waktu: docData['timestamp'] ??
                Timestamp
                    .now(), // Gantilah dengan nilai default sesuai kebutuhan Anda
            keterangan: docData['keterangan'] ?? '');
      }).toList();
      setState(() {
        demoDataAbsensi = data;
        filteredDataAbsensi = demoDataAbsensi;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
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
      filteredDataAbsensi = demoDataAbsensi
          .where(
              (data) => (data.nim.toLowerCase().contains(query.toLowerCase())))
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
    // Define your conditions for different colors here
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
          const SizedBox(
            height: 35.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: SizedBox(
              width: 250.0,
              height: 35.0,
              child: Row(
                children: [
                  const Text("NIM :",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        filterData(value);
                      },
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
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
                  const SizedBox(
                    width: 27.0,
                  )
                ],
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
              child: filteredDataAbsensi.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: Text(
                            "NIM",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Modul",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Waktu Absensi",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Keterangan",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredDataAbsensi),
                      rowsPerPage:
                          calculateRowsPerPage(filteredDataAbsensi.length),
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          'No data available',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
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

class DataAbsensi {
  String kode;
  String nim;
  String modul;
  Timestamp waktu;
  String keterangan;

  DataAbsensi(
      {required this.nim,
      required this.kode,
      required this.modul,
      required this.waktu,
      required this.keterangan});
}

DataRow dataFileDataRow(DataAbsensi fileInfo, int index) {
  Color rowColor = getRowColor(index); // Get row background color
  // Choose the appropriate pertemuan field

  // Define conditions for text color and container decoration

  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return rowColor;
      },
    ),
    cells: [
      DataCell(Text(fileInfo.nim)),
      DataCell(Text(getLimitedText(fileInfo.modul, 10))),
      DataCell(Text(fileInfo.waktu.toDate().toString())),
      DataCell(Text(fileInfo.keterangan))
    ],
  );
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : '${text.substring(0, limit)}...';
}

Color getRowColor(int index) {
  if (index % 2 == 0) {
    return Colors.grey.shade200; // Grey for even rows
  } else {
    return Colors.transparent; // Transparent for odd rows
  }
}

class DataSource extends DataTableSource {
  final List<DataAbsensi> data;

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
