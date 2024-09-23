import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelDataAsistensiLaporan extends StatefulWidget {
  final String idkelas;
  final String matkul;
  const TabelDataAsistensiLaporan(
      {super.key, required this.idkelas, required this.matkul});

  @override
  State<TabelDataAsistensiLaporan> createState() =>
      _TabelDataAsistensiLaporanState();
}

class _TabelDataAsistensiLaporanState extends State<TabelDataAsistensiLaporan> {
  List<Asistensi> demoAsistensi = [];
  List<Asistensi> filteredAsistensi = [];
  int nim = 0;
  //Judul Materi
  String selectedModul = 'Judul Modul';
  List<String> availableModuls = ['Judul Modul'];

  void _filterData(String? modul) {
    if (modul != null) {
      setState(() {
        selectedModul = modul;
        if (modul == 'Judul Modul') {
          filteredAsistensi = List.from(demoAsistensi);
        } else {
          filteredAsistensi = demoAsistensi
              .where((asistensi) => asistensi.modul == modul)
              .toList();
        }
      });
    }
  }

  Future<void> fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .get();
        nim = userDoc['nim'];

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('asistensiLaporan')
            .where('nim', isEqualTo: nim)
            .where('idKelas', isEqualTo: widget.idkelas)
            .get();

        setState(() {
          demoAsistensi = querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Asistensi(
              kode: data['idKelas'] ?? '',
              asistensi: data['namaAsisten'] ?? '',
              nim: data['nim'] ?? 0,
              modul: data['judulModul'] ?? '',
              file: data['namaFile'] ?? '',
              waktu: (data['waktuAsistensi'] as Timestamp),
              status: data['statusRevisi'] ?? '',
            );
          }).toList();

          filteredAsistensi = List.from(demoAsistensi);
          // Menambahkan modul ke availableModuls
          availableModuls = ['Judul Modul'] +
              demoAsistensi
                  .map((asistensi) => asistensi.modul)
                  .toSet()
                  .toList();
          // Memastikan selectedModul ada di availableModuls
          if (!availableModuls.contains(selectedModul)) {
            selectedModul = 'Judul Modul';
          }
          _filterData(
              selectedModul); // Memanggil _filterData setelah data diambil
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching data: $e');
        }
        // Handle error (show error message, retry, etc.)
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 35.0),
            child: Container(
              height: 47.0,
              width: 1230.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<String>(
                value: selectedModul,
                onChanged: (modul) => _filterData(modul),
                items: availableModuls
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
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredAsistensi.isNotEmpty
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
                            'Judul Materi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama Asisten',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama File',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredAsistensi),
                      rowsPerPage:
                          calculateRowsPerPage(filteredAsistensi.length),
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
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
          ),
        ],
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;

    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class Asistensi {
  final String kode;
  final int nim;
  final String asistensi;
  final String status;
  final String file;
  final Timestamp waktu;
  final String modul;

  Asistensi({
    required this.kode,
    required this.nim,
    required this.asistensi,
    required this.status,
    required this.file,
    required this.waktu,
    required this.modul,
  });
}

DataRow dataFileDataRow(Asistensi fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(
        SizedBox(
          width: 130.0,
          child: Text(getLimitedText(fileInfo.waktu.toDate().toString(), 19,
              style: const TextStyle(color: Colors.black))),
        ),
      ),
      DataCell(
        SizedBox(
          width: 275.0,
          child: Text(getLimitedText(fileInfo.modul, 25,
              style: const TextStyle(color: Colors.black))),
        ),
      ),
      DataCell(
        SizedBox(
          width: 230.0,
          child: Text(getLimitedText(fileInfo.asistensi, 25,
              style: const TextStyle(color: Colors.black))),
        ),
      ),
      DataCell(
        SizedBox(width: 100.0, child: Text(fileInfo.status)),
      ),
      DataCell(Row(
        children: [
          const Icon(
            Icons.download,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 5.0,
          ),
          GestureDetector(
            onTap: () {
              downloadFile(fileInfo.kode, fileInfo.file, fileInfo.modul);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(getLimitedText(
                  fileInfo.file,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                  20)),
            ),
          )
        ],
      )),
    ],
  );
}

void downloadFile(String kodeKelas, String fileName, String judulMateri) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('latihan/$kodeKelas/$judulMateri/$fileName');

  try {
    final url = await ref.getDownloadURL();
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error downloading file: $e');
    }
  }
}

String getLimitedText(String text, int limit, {required TextStyle style}) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

class DataSource extends DataTableSource {
  final List<Asistensi> data;

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
