import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabelDataKelasAsisten extends StatefulWidget {
  final String kodeKelas;
  const TabelDataKelasAsisten({super.key, required this.kodeKelas});

  @override
  State<TabelDataKelasAsisten> createState() => _TabelDataKelasAsistenState();
}

class _TabelDataKelasAsistenState extends State<TabelDataKelasAsisten> {
  List<DataMahasiswa> demoDataMahasiswa = [];
  List<DataMahasiswa> filteredDataMahasiswa = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Ambil data dari Firestore 'tokenKelas' berdasarkan kodeKelas
    QuerySnapshot tokenSnapshot = await FirebaseFirestore.instance
        .collection('tokenAsisten')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    // Ambil data dari Firestore 'akun_mahasiswa' berdasarkan NIM yang didapat dari tokenKelas
    for (QueryDocumentSnapshot tokenDoc in tokenSnapshot.docs) {
      int nim = tokenDoc['nim'];
      QuerySnapshot mahasiswaSnapshot = await FirebaseFirestore.instance
          .collection('akun_mahasiswa')
          .where('nim', isEqualTo: nim)
          .get();

      for (QueryDocumentSnapshot mahasiswaDoc in mahasiswaSnapshot.docs) {
        // Simpan data ke dalam list demoDataMahasiswa
        demoDataMahasiswa.add(DataMahasiswa(
          nim: nim,
          kode: widget.kodeKelas,
          nama: mahasiswaDoc['nama'],
          email: mahasiswaDoc['email'],
          nohp: mahasiswaDoc['no_hp'],
          angkatan: mahasiswaDoc['angkatan'],
        ));
      }
    }

    // Update state untuk merender data
    setState(() {
      filteredDataMahasiswa = List.from(demoDataMahasiswa);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25.0, left: 35.0),
          child: Text(
            'Data Asisten Praktikum',
            style: GoogleFonts.quicksand(
                fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 25.0),
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
                          "Angkatan",
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

class DataMahasiswa {
  final String kode;
  final int nim;
  final String nama;
  final String email;
  final int nohp;
  final String angkatan;

  DataMahasiswa({
    required this.nim,
    required this.nama,
    required this.email,
    required this.nohp,
    required this.kode,
    required this.angkatan,
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
      DataCell(Text(fileInfo.angkatan)),
      DataCell(SizedBox(
          width: 200.0, child: Text(getLimitedText(fileInfo.nama, 30)))),
      DataCell(SizedBox(
          width: 200.0, child: Text(getLimitedText(fileInfo.email, 30)))),
      DataCell(Text(fileInfo.nohp.toString())),
    ],
  );
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
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
