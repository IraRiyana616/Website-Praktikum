import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../File Laporan/Screen/file_laporan_admin.dart';

class TabelDataMahasiswaAsistensiLaporan extends StatefulWidget {
  final String idkelas;
  final String matkul;

  const TabelDataMahasiswaAsistensiLaporan(
      {super.key, required this.idkelas, required this.matkul});

  @override
  State<TabelDataMahasiswaAsistensiLaporan> createState() =>
      _TabelDataMahasiswaAsistensiLaporanState();
}

class _TabelDataMahasiswaAsistensiLaporanState
    extends State<TabelDataMahasiswaAsistensiLaporan> {
  //== List Data Tabel ==//
  List<DataPraktikan> filteredDataPraktikan = [];
  List<DataPraktikan> demoDataPraktikan = [];

  //== Fungsi untuk mengaktifkan loading ==//
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    textController.addListener(_onTextChanged);
    fetchDataFromFirestore();
  }

//== Fungsi untuk menampilkan data dari database ==//

//== Fungsi untuk memanggil Firestore ==//
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> fetchDataFromFirestore() async {
    try {
      var akunSnapshot = await _firestore.collection('akun_mahasiswa').get();
      List<DataPraktikan> dataMahasiswaList = [];

      if (akunSnapshot.docs.isNotEmpty) {
        for (var akunDoc in akunSnapshot.docs) {
          var nim = akunDoc['nim'];

          var dataMahasiswaSnapshot = await _firestore
              .collection('dataMahasiswaPraktikum')
              .where('nim', isEqualTo: nim)
              .where('idKelas', isEqualTo: widget.idkelas)
              .get();

          if (dataMahasiswaSnapshot.docs.isNotEmpty) {
            var combinedDocs = dataMahasiswaSnapshot.docs;

            // Memperbaiki iterasi untuk memasukkan dataMahasiswa ke dalam list
            // ignore: unused_local_variable
            for (var dataMahasiswaDoc in combinedDocs) {
              dataMahasiswaList.add(
                DataPraktikan(
                    nim: akunDoc['nim'] ?? 0,
                    nama: akunDoc['nama'] ?? '',
                    email: akunDoc['email'] ?? '',
                    nohp: akunDoc['no_hp'] ?? 0,
                    angkatan: akunDoc['angkatan'] ?? 0,
                    password: akunDoc['password'] ?? '',
                    //==//
                    idkelas: widget.idkelas,
                    matkul: widget.matkul),
              );
            }
          }
        }
      }

      dataMahasiswaList.sort((a, b) => a.nama.compareTo(b.nama));
      setState(() {
        demoDataPraktikan = dataMahasiswaList;
        filteredDataPraktikan = dataMahasiswaList;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  //== Fungsi Controller pada Search ==//
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredDataPraktikan = demoDataPraktikan
          .where(
              (data) => (data.nama.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      textController.clear();
      filterData('');
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //== Search ==//
            Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 10.0),
              child: SizedBox(
                width: 300.0,
                height: 35.0,
                child: Row(children: [
                  Text(
                    'Search :',
                    style: GoogleFonts.quicksand(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
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
        Center(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 30.0, right: 30.0, top: 15.0, bottom: 10.0),
            child: SizedBox(
                width: 1250.0,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : filteredDataPraktikan.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                  label: Text('NIM',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Nama',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text(
                                '',
                              )),
                            ],
                            source: DataSource(filteredDataPraktikan, context),
                            rowsPerPage: calculateRowsPerPage(
                                filteredDataPraktikan.length),
                          )
                        : const Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          )),
          ),
        )
      ],
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;
    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }
}

class DataPraktikan {
  int nim;
  String nama;
  String email;
  int nohp;
  int angkatan;
  String password;

  //==//
  String idkelas;
  String matkul;

  DataPraktikan(
      {required this.nim,
      required this.nama,
      required this.email,
      required this.nohp,
      required this.angkatan,
      required this.password,

      //==//
      required this.idkelas,
      required this.matkul});
}

DataRow dataFileDataRow(
    DataPraktikan fileInfo, int index, BuildContext context) {
  return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return getRowColor(index);
        },
      ),
      cells: [
        DataCell(Text(fileInfo.nim.toString())),
        DataCell(SizedBox(
            width: 250.0, child: Text(getLimitedText(fileInfo.nama, 40)))),
        DataCell(GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FileLaporanPraktikanAdmin(
                  idkelas: fileInfo.idkelas,
                  nama: fileInfo.nama,
                  nim: fileInfo.nim,
                  mataKuliah: fileInfo.matkul,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  'Lihat Detail',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
        ))
      ]);
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  if (index % 2 == 0) {
    return Colors.grey.shade200;
  } else {
    return Colors.transparent;
  }
}

class DataSource extends DataTableSource {
  final List<DataPraktikan> data;
  final BuildContext context;

  DataSource(this.data, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, context);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
