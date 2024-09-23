import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Komponen/Edit Data/edit_akses.dart';
import '../Komponen/Tambah Data/tambah_akses.dart';

class TabelAksesAbsensi extends StatefulWidget {
  final String mataKuliah;
  final String idkelas;
  final String kode;
  const TabelAksesAbsensi(
      {super.key,
      required this.mataKuliah,
      required this.idkelas,
      required this.kode});

  @override
  State<TabelAksesAbsensi> createState() => _TabelAksesAbsensiState();
}

class _TabelAksesAbsensiState extends State<TabelAksesAbsensi> {
  //== List Data Kelas Pada Tabel ==//
  List<DataAksesAbsensi> demoDataAksesAbsensi = [];
  List<DataAksesAbsensi> filteredDataAksesAbsensi = [];

//== Loading Perbaharui Data ==//
  Future<void> _onRefresh() async {
    fetchDataFromFirestore();
  }

//== Fungsi untuk menampilkan data dari firestore 'dataMatakuliah' ==//
  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

//== Firestore 'aksesAbsensi' ==//

  void fetchDataFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('aksesAbsen')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      List<DataAksesAbsensi> fetchedData = snapshot.docs.map((doc) {
        return DataAksesAbsensi(
          id: doc.id,
          idModul: doc['idModul'] ?? '',
          waktuAkses: doc['waktuAkses'] ?? '',
          tutupAkses: doc['waktuTutupAkses'] ?? '',
          idkelas: widget.idkelas,
          mataKuliah: widget.mataKuliah,
        );
      }).toList();
      fetchedData.sort((a, b) => a.waktuAkses.compareTo(b.waktuAkses));
      if (mounted) {
        setState(() {
          demoDataAksesAbsensi = fetchedData;
          filteredDataAksesAbsensi = fetchedData;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

//== Fungsi Untuk Menambahkan Warna Pada Tabel ==//
  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //== Elevated Button Tambah Data ==//
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //== Judul ==//
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 10.0),
                  child: Text(
                    'Akses Absensi Praktikum',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                //== ElevatedButton Tambah Data ==//
                Padding(
                  padding: const EdgeInsets.only(left: 855.0),
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
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    TambahAksesAbsensi(
                              idkelas: widget.idkelas,
                              mataKuliah: widget.mataKuliah,
                              kode: widget.kode,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
          ),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, right: 15.0, top: 15.0),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredDataAksesAbsensi.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "idModul",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Waktu Akses Absensi",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                  label: Text(
                                'Waktu Tutup Akses Absensi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                '       Aksi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
                            ],
                            source: DataSource(
                                filteredDataAksesAbsensi, deleteData, context),
                            rowsPerPage: calculateRowsPerPage(
                                filteredDataAksesAbsensi.length),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(35.0),
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
              ),
            ],
          ),
        ],
      ),
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

//== Fungsi menghapus data ==//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('aksesAbsen')
          .doc(id)
          .delete();
      fetchDataFromFirestore();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data: $error');
      }
    }
  }
}

class DataAksesAbsensi {
  String id;
  String idModul;
  String idkelas;
  String waktuAkses;
  String tutupAkses;
  String mataKuliah;
  DataAksesAbsensi(
      {required this.id,
      required this.idModul,
      required this.idkelas,
      required this.mataKuliah,
      required this.waktuAkses,
      required this.tutupAkses});
}

DataRow dataFileDataRow(DataAksesAbsensi fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      //== idModul =//
      DataCell(
        SizedBox(
          width: 200.0,
          child: Text(
            fileInfo.idModul,
          ),
        ),
      ),
      //== Waktu Akses Praktikum ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.waktuAkses,
          ),
        ),
      ),
      //== Waktu Tutup Akses ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.tutupAkses,
          ),
        ),
      ),
      DataCell(Row(
        children: [
          //== Icon Edit ==//
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      EditAksesAbsen(
                    mataKuliah: fileInfo.mataKuliah,
                    idkelas: fileInfo.idkelas,
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
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Text('Hapus Akses Absensi',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0)),
                    ),
                    content:
                        const Text('Apakah Anda yakin ingin menghapusnya?'),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextButton(
                            onPressed: () {
                              onDelete(fileInfo.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Hapus')),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Batal'),
                        ),
                      )
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.grey,
            ),
            tooltip: 'Hapus Data',
          )
        ],
      ))
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
  final List<DataAksesAbsensi> data;
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
