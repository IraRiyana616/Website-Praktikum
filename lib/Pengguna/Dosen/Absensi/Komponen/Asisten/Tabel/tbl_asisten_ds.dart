import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabelAbsensiAsistenDosen extends StatefulWidget {
  final String kodeAsisten;
  const TabelAbsensiAsistenDosen({super.key, required this.kodeAsisten});

  @override
  State<TabelAbsensiAsistenDosen> createState() =>
      _TabelAbsensiAsistenDosenState();
}

class _TabelAbsensiAsistenDosenState extends State<TabelAbsensiAsistenDosen> {
  List<AbsensiMahasiswa> demoAbsensiMahasiswa = [];
  List<AbsensiMahasiswa> filteredAbsensiMahasiswa = [];

  //Judul Materi
  String selectedModul = 'Tampilkan Semua';
  List<String> availableModuls = ['Tampilkan Semua'];

  @override
  void initState() {
    super.initState();
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
        ));
      }

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
        if (modul == 'Tampilkan Semua') {
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
          padding: const EdgeInsets.only(top: 25.0, left: 35.0),
          child: Text(
            'Data Absensi Asisten',
            style: GoogleFonts.quicksand(
                fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35.0, top: 20.0),
          child: Container(
            height: 47.0,
            width: 1250.0,
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
  final DateTime timestamp; // Mengubah tipe data timestamp menjadi DateTime
  final String tanggal;
  final String keterangan;

  AbsensiMahasiswa({
    required this.kode,
    required this.nama,
    required this.nim,
    required this.modul,
    required this.timestamp, // Mengubah tipe data timestamp menjadi DateTime
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
