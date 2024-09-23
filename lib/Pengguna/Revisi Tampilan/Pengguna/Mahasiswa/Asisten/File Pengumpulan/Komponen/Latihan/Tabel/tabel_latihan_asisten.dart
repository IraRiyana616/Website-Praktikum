import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelLatihanAsistenScreen extends StatefulWidget {
  final String idkelas;
  final String mataKuliah;
  const TabelLatihanAsistenScreen(
      {super.key, required this.idkelas, required this.mataKuliah});

  @override
  State<TabelLatihanAsistenScreen> createState() =>
      _TabelLatihanAsistenScreenState();
}

class _TabelLatihanAsistenScreenState extends State<TabelLatihanAsistenScreen> {
  final TextEditingController _textController = TextEditingController();
  //== List Data Tabel ==//
  List<Pengumpulan> demoPengumpulan = [];
  List<Pengumpulan> filteredPengumpulan = [];

  //== Search Field =//
  bool _isTextFieldNotEmpty = false;

  //== Judul Modul =//
  String selectedModul = 'Judul Modul';
  List<String> availableModuls = ['Judul Modul'];

  //== Fungsi Menampilkan Data dari Database  ==//
  Future<void> fetchDataFromFirestore() async {
    final QuerySnapshot silabusSnapshot = await FirebaseFirestore.instance
        .collection('dataPengumpulan')
        .where('idKelas', isEqualTo: widget.idkelas)
        .where('jenisPengumpulan', isEqualTo: 'Latihan')
        .get();

    final List<Pengumpulan> dataList = silabusSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final String idkelas = data['idKelas'];
      final String judulModul = data['judulModul'] ?? '';
      if (!availableModuls.contains(judulModul)) {
        availableModuls.add(judulModul);
      }
      return Pengumpulan(
        id: doc.id,
        kode: idkelas,
        nama: data['nama'] ?? '',
        nim: data['nim'] ?? 0,
        file: data['namaFile'] ?? '',
        jenis: data['jenisPengumpulan'] ?? '',
        modul: judulModul,
        waktu: data['waktuPengumpulan'] ?? '',
      );
    }).toList();
// Mengurutkan data berdasarkan nama secara ascending
    demoPengumpulan.sort((a, b) => a.nama.compareTo(b.nama));
    setState(() {
      demoPengumpulan = dataList;
      filteredPengumpulan = dataList;
    });
  }

  void _filterData(String? modul) {
    if (modul != null) {
      setState(() {
        selectedModul = modul;
        if (modul == 'Judul Modul') {
          filteredPengumpulan = demoPengumpulan;
        } else {
          filteredPengumpulan =
              demoPengumpulan.where((tugas) => tugas.modul == modul).toList();
        }
      });
    }
  }

  void _onTextChanged(String value) {
    setState(() {
      _isTextFieldNotEmpty = value.isNotEmpty;
      filterData(value,
          selectedModul); // Filter based on both query and selected module
    });
  }

  void filterData(String query, String selectedModul) {
    setState(() {
      if (selectedModul == 'Judul Modul') {
        filteredPengumpulan = demoPengumpulan
            .where((data) => (data.nim.toString().contains(query) ||
                data.nama.toLowerCase().contains(query.toLowerCase())))
            .toList();
      } else {
        filteredPengumpulan = demoPengumpulan
            .where((data) =>
                (data.modul == selectedModul) &&
                (data.nim.toString().contains(query) ||
                    data.nama.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  void clearSearchField() {
    setState(() {
      _textController.clear();
      filterData('', selectedModul);
    });
  }

  void _sortDataByName() {
    setState(() {
      filteredPengumpulan.sort((a, b) => a.nim.compareTo(b.nim));
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    _sortDataByName(); // Panggil fungsi untuk mengurutkan data berdasarkan nama
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 40.0),
            child: Container(
              height: 47.0,
              width: 1280.0,
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
            padding: const EdgeInsets.only(top: 25.0, right: 10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 300.0,
                height: 35.0,
                child: Row(
                  children: [
                    const Text("Search :",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: _onTextChanged,
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 18),
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
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
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
    const int defaultRowsPerPage = 50;

    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class Pengumpulan {
  final String kode;
  final String nama;
  final int nim;
  final String file;
  final String waktu;
  final String modul;
  final String id;
  final String jenis;

  Pengumpulan(
      {required this.kode,
      required this.nama,
      required this.nim,
      required this.file,
      required this.waktu,
      required this.modul,
      required this.id,
      required this.jenis});
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
          width: 160.0,
          child: Text(
              getLimitedText(
                fileInfo.waktu,
                25,
              ),
              style: const TextStyle(color: Colors.black)),
        ),
      ),
      DataCell(Text(fileInfo.nim.toString())),
      DataCell(
        SizedBox(
          width: 200.0,
          child: Text(
              getLimitedText(
                fileInfo.nama,
                25,
              ),
              style: const TextStyle(color: Colors.black)),
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
              child: Text(
                getLimitedText(fileInfo.file, 30),
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
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

String getLimitedText(String text, int limit) {
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
