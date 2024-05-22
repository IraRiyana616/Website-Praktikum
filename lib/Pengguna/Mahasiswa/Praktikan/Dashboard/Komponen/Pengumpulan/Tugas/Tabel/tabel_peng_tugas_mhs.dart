import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelKTugasPraktikan extends StatefulWidget {
  final String kodeKelas;
  const TabelKTugasPraktikan({super.key, required this.kodeKelas});

  @override
  State<TabelKTugasPraktikan> createState() => _TabelKTugasPraktikanState();
}

class _TabelKTugasPraktikanState extends State<TabelKTugasPraktikan> {
  List<Pengumpulan> demoPengumpulan = [];
  List<Pengumpulan> filteredPengumpulan = [];
  //Judul Materi
  String selectedModul = 'Judul Modul';
  List<String> availableModuls = ['Judul Modul'];
  int nim = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('akun_mahasiswa')
          .doc(user.uid)
          .get();
      nim = userDoc['nim'];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tugas')
          .where('nim', isEqualTo: nim)
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .get();

      Set<String> modulSet = {'Judul Modul'};
      List<Pengumpulan> pengumpulanList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String modul = data['judulMateri'] ?? '';
        modulSet.add(modul);
        return Pengumpulan(
          kode: data['kodeKelas'] ?? '',
          nama: data['nama'] ?? '',
          nim: data['nim'] ?? 0,
          modul: modul,
          file: data['namaFile'] ?? '',
          waktu: data['waktuPengumpulan'] ?? Timestamp.now(),
        );
      }).toList();

      setState(() {
        demoPengumpulan = pengumpulanList;
        filteredPengumpulan = List.from(demoPengumpulan);
        availableModuls = modulSet.toList();
      });
    }
  }

  void _filterData(String? modul) {
    if (modul != null) {
      setState(() {
        selectedModul = modul;
        if (modul == 'Judul Modul') {
          filteredPengumpulan = demoPengumpulan;
        } else {
          filteredPengumpulan = demoPengumpulan
              .where((latihan) => latihan.modul == modul)
              .toList();
        }
      });
    }
  }

  void _sortDataByName() {
    setState(() {
      filteredPengumpulan.sort((a, b) => a.nama.compareTo(b.nama));
    });
  }

  @override
  Widget build(BuildContext context) {
    _sortDataByName();
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 70.0, top: 20.0),
            child: Container(
              height: 47.0,
              width: 1195.0,
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
            padding: const EdgeInsets.only(left: 70.0, right: 100.0, top: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredPengumpulan.isNotEmpty
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
                            'Nama File',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredPengumpulan),
                      rowsPerPage:
                          calculateRowsPerPage(filteredPengumpulan.length),
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

class Pengumpulan {
  final String kode;
  final String nama;
  final int nim;
  final String file;
  final Timestamp waktu;
  final String modul;

  Pengumpulan({
    required this.kode,
    required this.nama,
    required this.nim,
    required this.file,
    required this.waktu,
    required this.modul,
  });
}

DataRow dataFileDataRow(Pengumpulan fileInfo, int index) {
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
          width: 200.0,
          child: Text(getLimitedText(fileInfo.modul, 25,
              style: const TextStyle(color: Colors.black))),
        ),
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
      .child('tugas/$kodeKelas/$judulMateri/$fileName');

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
  final List<Pengumpulan> data;

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
