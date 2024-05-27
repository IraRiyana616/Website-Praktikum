import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabelAbsensiAsistenAdmin extends StatefulWidget {
  final String kodeAsisten;
  final String mataKuliah;
  const TabelAbsensiAsistenAdmin(
      {super.key, required this.kodeAsisten, required this.mataKuliah});

  @override
  State<TabelAbsensiAsistenAdmin> createState() =>
      _TabelAbsensiAsistenAdminState();
}

class _TabelAbsensiAsistenAdminState extends State<TabelAbsensiAsistenAdmin> {
  List<AbsensiMahasiswa> demoAbsensiMahasiswa = [];
  List<AbsensiMahasiswa> filteredAbsensiMahasiswa = [];

  //Judul Materi
  String selectedModul = 'Judul Modul';
  List<String> availableModuls = ['Judul Modul'];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('absensiAsisten')
              .where('kodeAsisten', isEqualTo: widget.kodeAsisten)
              .get();

      List<AbsensiMahasiswa> absensiMahasiswaList = [];

      for (DocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        Map<String, dynamic>? data = doc.data();
        String modul = data?['judulMateri'] ?? '';
        if (!availableModuls.contains(modul)) {
          availableModuls.add(modul);
        }
        absensiMahasiswaList.add(AbsensiMahasiswa(
          kode: data?['kodeAsisten'] ?? '',
          nama: data?['nama'] ?? '',
          nim: data?['nim'] ?? 0,
          modul: modul,
          timestamp: (data?['timestamp'] as Timestamp).toDate(),
          tanggal: data?['tanggal'] ?? '',
          keterangan: data?['keterangan'] ?? '',
          file: data?['namaFile'] ?? '',
        ));
      }

      // Mengurutkan data berdasarkan nama secara ascending
      absensiMahasiswaList.sort((a, b) => a.nama.compareTo(b.nama));

      setState(() {
        demoAbsensiMahasiswa = absensiMahasiswaList;
        filteredAbsensiMahasiswa = demoAbsensiMahasiswa;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

  void _filterData(String? modul) {
    if (modul != null) {
      setState(() {
        selectedModul = modul;
        if (modul == 'Judul Modul') {
          filteredAbsensiMahasiswa = demoAbsensiMahasiswa;
        } else {
          filteredAbsensiMahasiswa = demoAbsensiMahasiswa
              .where((absensi) => absensi.modul == modul)
              .toList();
        }
      });
    }
  }

  void _sortDataByName() {
    setState(() {
      filteredAbsensiMahasiswa.sort((a, b) => a.nama.compareTo(b.nama));
    });
  }

  //== Search Komponen ==//
  bool _isTextFieldNotEmpty = false;
  final TextEditingController _textController = TextEditingController();
  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = _textController.text.isNotEmpty;
      _filterData(_textController.text);
    });
  }

  void filterData(String query) {
    setState(() {
      filteredAbsensiMahasiswa = demoAbsensiMahasiswa
          .where((data) => (data.nama
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              data.nim.toString().toLowerCase().contains(query.toLowerCase())))
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
    _sortDataByName();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 35.0),
          child: Text(
            'Data Absensi',
            style: GoogleFonts.quicksand(
                fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35.0, top: 20.0),
          child: Container(
            height: 47.0,
            width: 1180.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton<String>(
              value: selectedModul,
              onChanged: (modul) => _filterData(modul),
              items:
                  availableModuls.map<DropdownMenuItem<String>>((String value) {
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //== Text Search ==//
            Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 40.0),
              child: SizedBox(
                width: 270.0,
                height: 35.0,
                child: Row(
                  children: [
                    const Text(
                      'Search :',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
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
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10),
                          suffixIcon: Visibility(
                              visible: _isTextFieldNotEmpty,
                              child: IconButton(
                                  onPressed: clearSearchField,
                                  icon: const Icon(Icons.clear))),
                          labelStyle: const TextStyle(fontSize: 16.0),
                          filled: true,
                          fillColor: Colors.white),
                    ))
                  ],
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 25.0),
          child: SizedBox(
            width: double.infinity,
            child: filteredAbsensiMahasiswa.isNotEmpty
                ? PaginatedDataTable(
                    columnSpacing: 10,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Timestamp',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'NIM',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nama',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Keterangan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                          label: Text(
                        'Bukti Absensi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                        label: Text(
                          'Aksi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    source: DataSource(filteredAbsensiMahasiswa),
                    rowsPerPage:
                        calculateRowsPerPage(filteredAbsensiMahasiswa.length),
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
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25; // Set your default value here

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      // You can adjust this logic based on your requirements
      return defaultRowsPerPage;
    }
  }
}

class AbsensiMahasiswa {
  final String kode;
  final String nama;
  final int nim;
  final String modul;
  final DateTime timestamp;
  final String tanggal;
  final String keterangan;
  final String file;

  AbsensiMahasiswa({
    required this.kode,
    required this.file,
    required this.nama,
    required this.nim,
    required this.modul,
    required this.timestamp,
    required this.tanggal,
    required this.keterangan,
  });
}

DataRow dataFileDataRow(AbsensiMahasiswa fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(
        SizedBox(
          width: 140.0,
          child: Text(getLimitedText(
              fileInfo.timestamp.toString(), 19)), // Menggunakan timestamp
        ),
      ),
      DataCell(SizedBox(width: 80.0, child: Text(fileInfo.nim.toString()))),
      DataCell(
        SizedBox(
          width: 200.0,
          child: Text(getLimitedText(fileInfo.nama, 30)),
        ),
      ),
      DataCell(Text(fileInfo.keterangan)),
      DataCell(
        Row(
          children: [
            const Icon(
              Icons.download,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 5.0,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // downloadFile(fileInfo.kode, fileInfo.file, fileInfo.nim);
                },
                child: const Text(
                  'Download',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      DataCell(IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.delete,
          color: Colors.grey,
        ),
        tooltip: 'Hapus Data',
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
  final List<AbsensiMahasiswa> data;

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
