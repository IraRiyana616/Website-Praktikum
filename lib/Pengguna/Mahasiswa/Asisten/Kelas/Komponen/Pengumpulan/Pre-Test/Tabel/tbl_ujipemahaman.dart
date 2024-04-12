import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelPengumpulanUjiPemahaman extends StatefulWidget {
  final String kodeKelas;
  const TabelPengumpulanUjiPemahaman({super.key, required this.kodeKelas});

  @override
  State<TabelPengumpulanUjiPemahaman> createState() =>
      _TabelPengumpulanUjiPemahamanState();
}

class _TabelPengumpulanUjiPemahamanState
    extends State<TabelPengumpulanUjiPemahaman> {
  final TextEditingController _textController = TextEditingController();
  List<Pengumpulan> demoPengumpulan = [];
  List<Pengumpulan> filteredPengumpulan = [];
  bool _isTextFieldNotEmpty = false;
  //Judul Materi
  String selectedModul = 'Tampilkan Semua';
  List<String> availableModuls = ['Tampilkan Semua'];
  Future<void> deleteDataFromFirestore(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('pre-test')
          .doc(documentId)
          .delete();
      fetchDataFromFirestore();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document: $e');
      }
    }
  }

  Future<void> fetchDataFromFirestore() async {
    final QuerySnapshot silabusSnapshot = await FirebaseFirestore.instance
        .collection('latihan')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    final List<Pengumpulan> dataList = silabusSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final String kodeKelas = data['kodeKelas'];
      final String judulMateri = data['judulMateri'] ?? '';
      if (!availableModuls.contains(judulMateri)) {
        availableModuls.add(judulMateri);
      }
      return Pengumpulan(
        kode: kodeKelas,
        nama: data['nama'] ?? '',
        nim: data['nim'] ?? 0,
        file: data['namaFile'] ?? '',
        modul: judulMateri,
        waktu: data['waktuPengumpulan'] != null
            ? (data['waktuPengumpulan'] as Timestamp).toDate().toString()
            : '',
      );
    }).toList();

    setState(() {
      demoPengumpulan = dataList;
      filteredPengumpulan =
          dataList; // Initialize filteredDataSilabus with all data
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  void _filterData(String? modul) {
    if (modul != null) {
      setState(() {
        selectedModul = modul;
        if (modul == 'Tampilkan Semua') {
          filteredPengumpulan = demoPengumpulan;
        } else {
          filteredPengumpulan = demoPengumpulan
              .where((latihan) => latihan.modul == modul)
              .toList();
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
      if (selectedModul == 'Tampilkan Semua') {
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
      filteredPengumpulan.sort((a, b) => a.nama.compareTo(b.nama));
    });
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
            padding: const EdgeInsets.only(left: 70.0),
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
            padding: const EdgeInsets.only(top: 25.0, right: 80.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 250.0,
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
                        onChanged: (value) {
                          filterData(value, selectedModul);
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
    const int defaultRowsPerPage = 25;

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
          child: Text(getLimitedText(fileInfo.waktu, 19,
              style: const TextStyle(color: Colors.black))),
        ),
      ),
      DataCell(Text(fileInfo.nim.toString())),
      DataCell(
        SizedBox(
          width: 200.0,
          child: Text(getLimitedText(fileInfo.nama, 25,
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
