import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabelDataMahasiswa extends StatefulWidget {
  const TabelDataMahasiswa({super.key});

  @override
  State<TabelDataMahasiswa> createState() => _TabelDataMahasiswaState();
}

class _TabelDataMahasiswaState extends State<TabelDataMahasiswa> {
  List<DataMahasiswa> demoDataMahasiswa = [];
  List<DataMahasiswa> filteredDataMahasiswa = [];
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;
  String selectedYear = 'Tampilkan Semua';
  List<String> availableYears = [];

  Future<void> fetchAvailableYears() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('akun_mahasiswa').get();
      Set<String> years =
          querySnapshot.docs.map((doc) => doc['angkatan'].toString()).toSet();

      setState(() {
        availableYears = ['Tampilkan Semua', ...years.toList()];
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching available years from Firebase: $error');
      }
    }
  }

  Future<void> fetchDataFromFirebase(String? selectedYear) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      if (selectedYear != null && selectedYear != 'Tampilkan Semua') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .where('angkatan', isEqualTo: selectedYear)
            .get();
      } else {
        querySnapshot =
            await FirebaseFirestore.instance.collection('akun_mahasiswa').get();
      }
      List<DataMahasiswa> data = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return DataMahasiswa(
            nama: data['nama'],
            nim: data['nim'],
            angkatan: data['angkatan'],
            email: data['email'],
            nohp: data['no_hp']);
      }).toList();
      setState(() {
        demoDataMahasiswa = data;
        filteredDataMahasiswa = demoDataMahasiswa;
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
      _isTextFieldNotEmpty = _textController.text.isNotEmpty;
      filterData(_textController.text);
    });
  }

  void filterData(String query) {
    setState(() {
      filteredDataMahasiswa = demoDataMahasiswa
          .where((data) => (data.nim.toString().contains(query) ||
              data.angkatan.toLowerCase().contains(query.toLowerCase()) ||
              data.nama.toLowerCase().contains(query.toLowerCase())))
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, left: 25.0),
                    child: Text(
                      'Data Mahasiswa Praktikum',
                      style: GoogleFonts.quicksand(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 25.0, bottom: 15.0, right: 25.0, left: 25.0),
                    child: Container(
                      height: 47.0,
                      width: 1000.0,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0)),
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
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.grey),
                        iconSize: 24,
                        elevation: 16,
                        isExpanded: true,
                        underline: Container(),
                      ),
                    ),
                  ),
                ],
              )),
          SizedBox(
            width: 250.0,
            height: 35.0,
            child: Row(
              children: [
                const Text("Search :", style: TextStyle(fontSize: 16)),
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
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 25.0, top: 15.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredDataMahasiswa.isNotEmpty
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
                            "Nama Lengkap",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Email",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Nomor Handphone",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredDataMahasiswa),
                      rowsPerPage:
                          calculateRowsPerPage(filteredDataMahasiswa.length),
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

class DataMahasiswa {
  int nim;
  String angkatan;
  String nama;
  String email;
  int nohp;

  DataMahasiswa({
    required this.nim,
    required this.angkatan,
    required this.nama,
    required this.email,
    required this.nohp,
  });
}

DataRow dataFileDataRow(DataMahasiswa fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.nim.toString())),
      DataCell(Text(fileInfo.nama)),
      DataCell(Text(fileInfo.email)),
      DataCell(Text(fileInfo.nohp.toString())),
    ],
  );
}

Color getRowColor(int index) {
  if (index % 2 == 0) {
    return Colors.grey.shade200; // Grey for even rows
  } else {
    return Colors.transparent; // Transparent for odd rows
  }
}

class DataSource extends DataTableSource {
  final List<DataMahasiswa> data;

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
