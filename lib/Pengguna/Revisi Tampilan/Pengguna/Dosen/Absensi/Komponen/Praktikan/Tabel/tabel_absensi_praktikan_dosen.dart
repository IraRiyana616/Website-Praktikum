import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TabelAbsensiPraktikanScreenDosen extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const TabelAbsensiPraktikanScreenDosen(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<TabelAbsensiPraktikanScreenDosen> createState() =>
      _TabelAbsensiPraktikanScreenDosenState();
}

class _TabelAbsensiPraktikanScreenDosenState
    extends State<TabelAbsensiPraktikanScreenDosen> {
  List<AbsensiMahasiswa> demoAbsensiMahasiswa = [];
  List<AbsensiMahasiswa> filteredAbsensiMahasiswa = [];

  //Judul Materi
  String selectedModul = 'Judul Modul';
  List<String> availableModuls = ['Judul Modul'];

  @override
  void initState() {
    super.initState();
    textController.addListener(_onTextChanged);
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('absensiMahasiswa')
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      List<AbsensiMahasiswa> absensiMahasiswaList = querySnapshot.docs.map(
        (DocumentSnapshot<Map<String, dynamic>> doc) {
          Map<String, dynamic>? data = doc.data();
          String modul = data?['judulMateri'] ?? '';
          if (!availableModuls.contains(modul)) {
            availableModuls.add(modul);
          }
          Timestamp? waktuAbsensiTimestamp =
              data?['waktuAbsensi'] as Timestamp?;
          DateTime waktuAbsensi = waktuAbsensiTimestamp != null
              ? waktuAbsensiTimestamp.toDate()
              : DateTime.now();
          return AbsensiMahasiswa(
              kode: data?['kodeKelas'] ?? '',
              nama: data?['nama'] ?? '',
              nim: data?['nim'] ?? 0,
              modul: modul,
              timestamp: waktuAbsensi,
              matkul: data?['mataKuliah'] ?? '',
              pertemuan: data?['pertemuan'] ?? '',
              keterangan: data?['keterangan'] ?? '',
              file: data?['namaFile'] ?? '');
        },
      ).toList();

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

  //== Fungsi Controller pada Search ==//
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredAbsensiMahasiswa = demoAbsensiMahasiswa
          .where((data) =>
              (data.nama.toLowerCase().contains(query.toLowerCase()) ||
                  data.keterangan.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      textController.clear();
      filterData('');
    });
  }

  void _sortDataByName() {
    setState(() {
      filteredAbsensiMahasiswa.sort((a, b) => a.nama.compareTo(b.nama));
    });
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = textController.text.isNotEmpty;
      filterData(textController.text);
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
            padding: const EdgeInsets.only(left: 30.0, top: 35.0, right: 30.0),
            child: Container(
              height: 47.0,
              width: 1300.0,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //== Search ==//
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 1000.0),
                child: SizedBox(
                  width: 300.0,
                  height: 35.0,
                  child: Row(children: [
                    const Text(
                      'Search :',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                        child: TextField(
                      onChanged: (value) {
                        filterData(value);
                      },
                      controller: textController,
                      decoration: InputDecoration(
                          hintText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10.0),
                          suffixIcon: Visibility(
                              visible: _isTextFieldNotEmpty,
                              child: IconButton(
                                  onPressed: clearSearchField,
                                  icon: const Icon(Icons.clear))),
                          labelStyle: const TextStyle(fontSize: 16.0),
                          filled: true,
                          fillColor: Colors.white),
                    )),
                    const SizedBox(
                      width: 27.0,
                    )
                  ]),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 25.0),
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
                          'Bukti Foto',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                      ],
                      source: DataSource(filteredAbsensiMahasiswa),
                      rowsPerPage:
                          calculateRowsPerPage(filteredAbsensiMahasiswa.length),
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

class AbsensiMahasiswa {
  final String kode;
  final String nama;
  final int nim;
  final String modul;
  final DateTime timestamp;
  final String matkul;
  final String keterangan;
  final String file;
  final String pertemuan;

  AbsensiMahasiswa(
      {required this.kode,
      required this.file,
      required this.nama,
      required this.nim,
      required this.modul,
      required this.timestamp,
      required this.matkul,
      required this.keterangan,
      required this.pertemuan});
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
      DataCell(Row(
        children: [
          const Icon(
            Icons.download,
            color: Colors.grey,
          ),
          GestureDetector(
            onTap: () => downloadFile(
              fileInfo.kode,
              fileInfo.file,
              fileInfo.nim,
            ),
            child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Download',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                )),
          )
        ],
      ))
    ],
  );
}

Future<void> downloadFile(String kodeKelas, String fileName, int nim) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('$kodeKelas/Absensi Mahasiswa/$nim/$fileName');

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
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      print('Tried path: $kodeKelas/Absensi Mahasiswa/$nim/$fileName');
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
