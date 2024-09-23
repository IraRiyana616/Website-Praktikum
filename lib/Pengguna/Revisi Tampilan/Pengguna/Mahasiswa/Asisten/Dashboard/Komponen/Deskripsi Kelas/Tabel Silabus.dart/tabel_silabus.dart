import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Revisi%20Tampilan/Pengguna/Mahasiswa/Asisten/Dashboard/Komponen/Deskripsi%20Kelas/Tabel%20Silabus.dart/Tambah%20Data/tambah.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Pengumpulan/pengumpulan.dart';
import '../Tampilan Pengumpulan/Latihan/latihan.dart';
import 'Edit Data/edit.dart';

class SilabusPraktikumAsisten extends StatefulWidget {
  final String idkelas;
  final String kodeMatakuliah;
  final String mataKuliah;
  const SilabusPraktikumAsisten(
      {super.key,
      required this.idkelas,
      required this.kodeMatakuliah,
      required this.mataKuliah});

  @override
  State<SilabusPraktikumAsisten> createState() =>
      _SilabusPraktikumAsistenState();
}

class _SilabusPraktikumAsistenState extends State<SilabusPraktikumAsisten> {
  //== List Data Tabel ==//
  List<DataSilabus> demoDataSilabus = [];
  List<DataSilabus> filteredDataSilabus = [];
  //== Loading ==//
  bool isLoading = false;

//== Fungsi untuk menampilkan data dari Firestore ==//
  Future<void> fetchDataFromFirestore() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('silabusMatakuliah')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      List<DataSilabus> loadedData = [];
      for (var doc in snapshot.docs) {
        loadedData.add(DataSilabus(
            id: doc.id,
            idkelas: widget.idkelas,
            idModul: doc['idModul'] ?? '',
            judulModul: doc['judulModul'] ?? '',
            namaFile: doc['namaFile'] ?? '',
            pertemuan: doc['pertemuan'] ?? '',

            ///=======///
            kode: widget.kodeMatakuliah,
            matakuliah: widget.mataKuliah));
      }
      // Urutkan data berdasarkan field 'pertemuan'
      loadedData.sort((a, b) => a.pertemuan.compareTo(b.pertemuan));

      updateTableData(loadedData);
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //== ElevatedButton Tambah Data ==//
            Padding(
              padding: const EdgeInsets.only(right: 40.0),
              child: SizedBox(
                height: 45.0,
                width: 145.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3CBEA9),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TambahSilabusPraktikum(
                          idKelas: widget.idkelas,
                          kodeMatakuliah: widget.kodeMatakuliah,
                          mataKuliah: widget.mataKuliah,
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
                  child: const Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 3.0,
                        ),
                        //== Icon ==//

                        Text(
                          " +  Tambah Data",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredDataSilabus.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                            label: Text(
                          'id Modul',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                          label: Text(
                            'Judul Modul',
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
                            'File Modul',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                            label: Text(
                          '          Aksi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                      ],
                      source:
                          DataSource(filteredDataSilabus, deleteData, context),
                      rowsPerPage:
                          calculateRowsPerPage(filteredDataSilabus.length),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
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
        )
      ],
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 15;

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }

  //== Fungsi Untuk Menghapus Data ==//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('silabusMatakuliah')
          .doc(id)
          .delete();
      fetchDataFromFirestore();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data: $error');
      }
    }
  }

  //== Fungsi Update Data ==//
  void updateTableData(List<DataSilabus> newData) {
    setState(() {
      demoDataSilabus.clear();
      filteredDataSilabus.clear();
      demoDataSilabus.addAll(newData);
      filteredDataSilabus.addAll(newData);
    });
  }
}

class DataSilabus {
  String id;
  String idkelas;
  String idModul;
  String pertemuan;
  String judulModul;
  String namaFile;

  //========//
  String kode;
  String matakuliah;

  DataSilabus({
    required this.id,
    required this.idkelas,
    required this.judulModul,
    required this.namaFile,
    required this.idModul,
    required this.pertemuan,

    //=======//
    required this.matakuliah,
    required this.kode,
  });
}

DataRow dataFileDataRow(DataSilabus fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  // Pass onDelete function
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      //== idModul ==//
      DataCell(SizedBox(width: 100.0, child: Text(fileInfo.idModul))),
      //== Nama Modul ==//
      DataCell(
        SizedBox(
          width: 300.0,
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PengumpulanLatihan(
                      idkelas: fileInfo.idkelas,
                      judulModul: fileInfo.judulModul,
                      kode: fileInfo.kode,
                      matkul: fileInfo.matakuliah,
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
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(getLimitedText(fileInfo.judulModul, 50)))),
        ),
      ),

      //== Pertemuan ==//
      DataCell(
        SizedBox(
            width: 250, child: Text(getLimitedText(fileInfo.pertemuan, 30))),
      ),
      //== Nama File ==//
      DataCell(Row(
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
                    fileInfo.idkelas, fileInfo.judulModul, fileInfo.namaFile);
              },
              child: Text(
                fileInfo.namaFile,
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      )),
      //== Icon ==//
      DataCell(Row(
        children: [
          //== IconButton Pengumpulan ===//
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      PengumpulanAsisten(
                    idkelas: fileInfo.idkelas,
                    modul: fileInfo.judulModul,
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
            icon: const Icon(
              Icons.add_box,
              color: Colors.grey,
            ),
            tooltip: 'Data Pengumpulan',
          ),
          //== IconButton Edit Data ==//
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      EditDataSilabus(
                    idkelas: fileInfo.idkelas,
                    modul: fileInfo.judulModul,
                    matakuliah: fileInfo.matakuliah,
                    kodeMatakuliah: fileInfo.kode,
                    idModul: fileInfo.idModul,
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
            icon: const Icon(
              Icons.edit_document,
              color: Colors.grey,
            ),
            tooltip: 'Edit Data',
          ),
          //== IconButton Delete ==//
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Hapus Materi Modul Praktikum",
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    content: const SizedBox(
                      height: 30.0,
                      width: 130.0,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text("Anda yakin ingin menghapus data?"),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text("Batal"),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onDelete(fileInfo.id);
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text("Hapus"),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete, color: Colors.grey),
            tooltip: 'Hapus Data',
          ),
        ],
      ))
    ],
  );
}

void downloadFile(String idTA, String judulModul, String fileName) async {
  final ref =
      FirebaseStorage.instance.ref().child('$idTA/$judulModul/$fileName');

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
  if (index % 2 == 0) {
    return Colors.grey.shade200; // Grey for even rows
  } else {
    return Colors.transparent; // Transparent for odd rows
  }
}

class DataSource extends DataTableSource {
  final List<DataSilabus> data;
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

  // Function to update data after deletion
  void updateData(List<DataSilabus> newData) {
    data.clear();
    data.addAll(newData);
    notifyListeners();
  }
}
