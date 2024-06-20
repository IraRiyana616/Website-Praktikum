import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelAbsensiAsistenAdmin extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const TabelAbsensiAsistenAdmin(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<TabelAbsensiAsistenAdmin> createState() =>
      _TabelAbsensiAsistenAdminState();
}

class _TabelAbsensiAsistenAdminState extends State<TabelAbsensiAsistenAdmin> {
  //== List Tabel ==//
  List<AbsensiMahasiswa> demoAbsensiMahasiswa = [];
  List<AbsensiMahasiswa> filteredAbsensiMahasiswa = [];

  //== Judul Materi ==//
  String selectedModul = 'Judul Modul';
  List<String> availableModuls = ['Judul Modul'];

  //== Search Komponen ==//
  bool _isTextFieldNotEmpty = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _fetchDataFromFirestore();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = _textController.text.isNotEmpty;
      _filterData();
    });
  }

  //== Filtering data ==//
  void _filterData() {
    String query = _textController.text.toLowerCase();
    List<AbsensiMahasiswa> tempList = demoAbsensiMahasiswa.where((data) {
      bool matchesText = data.nama.toLowerCase().contains(query) ||
          data.keterangan.toLowerCase().contains(query) ||
          data.nim.toString().toLowerCase().contains(query);
      bool matchesModul =
          selectedModul == 'Judul Modul' || data.modul == selectedModul;
      return matchesText && matchesModul;
    }).toList();
    setState(() {
      filteredAbsensiMahasiswa = tempList;
    });
  }

  //== Menampilkan data dari database 'absensiAsisten' ==//
  Future<void> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('absensiAsisten')
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      List<AbsensiMahasiswa> absensiMahasiswaList = [];

      for (DocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        Map<String, dynamic>? data = doc.data();
        String modul = data?['judulMateri'] ?? '';
        if (!availableModuls.contains(modul)) {
          availableModuls.add(modul);
        }
        absensiMahasiswaList.add(AbsensiMahasiswa(
          id: doc.id,
          kode: data?['kodeKelas'] ?? '',
          nama: data?['nama'] ?? '',
          nim: data?['nim'] ?? 0,
          modul: modul,
          timestamp: (data?['waktuAbsensi'] as Timestamp).toDate(),
          matakuliah: data?['mataKuliah'] ?? '',
          pertemuan: data?['pertemuan'] ?? '',
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

  void clearSearchField() {
    setState(() {
      _textController.clear();
      _filterData();
    });
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
          padding: const EdgeInsets.only(top: 35.0, left: 35.0),
          child: Text(
            'Data Absensi Praktikum',
            style: GoogleFonts.quicksand(
                fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35.0, top: 20.0),
          child: Container(
            height: 47.0,
            width: 1235.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton<String>(
              value: selectedModul,
              onChanged: (modul) {
                setState(() {
                  selectedModul = modul!;
                  _filterData();
                });
              },
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
                        _filterData();
                      },
                      controller: _textController,
                      decoration: InputDecoration(
                          hintText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
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
                          'Pertemuan',
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
                    source: DataSource(
                        filteredAbsensiMahasiswa, deleteData, context),
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

  //== Menghapus Data dari database 'absensiAsisten' ==//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('absensiAsisten')
          .doc(id)
          .delete();
      _fetchDataFromFirestore();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data:$error');
      }
    }
  }
}

class AbsensiMahasiswa {
  final String id;
  final String kode;
  final String nama;
  final int nim;
  final String modul;
  final DateTime timestamp;
  final String matakuliah;
  final String pertemuan;
  final String keterangan;
  final String file;

  AbsensiMahasiswa({
    required this.id,
    required this.kode,
    required this.file,
    required this.nama,
    required this.nim,
    required this.modul,
    required this.timestamp,
    required this.matakuliah,
    required this.pertemuan,
    required this.keterangan,
  });
}

DataRow dataFileDataRow(AbsensiMahasiswa fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
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
      DataCell(Text(fileInfo.pertemuan)),
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
                  downloadFile(
                    fileInfo.kode,
                    fileInfo.matakuliah,
                    fileInfo.file,
                  );
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
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'Hapus Data',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  content: const Text('Apakah Anda yakin ingin menghapusnya?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          onDelete(fileInfo.id);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Hapus')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Batal'))
                  ],
                );
              });
        },
        icon: const Icon(
          Icons.delete,
          color: Colors.grey,
        ),
        tooltip: 'Hapus Data',
      ))
    ],
  );
}

void downloadFile(String kodeKelas, String matakuliah, String fileName) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('absensiAsisten/$kodeKelas/$matakuliah/$fileName');

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
  final List<AbsensiMahasiswa> data;
  final Function(String) onDelete;
  final BuildContext context;

  DataSource(this.data, this.onDelete, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, onDelete, context);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
