import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabelAksesAbsensiMahasiswa extends StatefulWidget {
  final String kodeKelas;
  final String kodeAsisten;
  final String mataKuliah;

  const TabelAksesAbsensiMahasiswa({
    Key? key,
    required this.kodeKelas,
    required this.kodeAsisten,
    required this.mataKuliah,
  }) : super(key: key);

  @override
  State<TabelAksesAbsensiMahasiswa> createState() =>
      _TabelAksesAbsensiMahasiswaState();
}

class _TabelAksesAbsensiMahasiswaState
    extends State<TabelAksesAbsensiMahasiswa> {
  //== List Data Tabel ==//
  List<AksesAbsensi> filteredAksesAbsensi = [];
  List<AksesAbsensi> demoAksesAbsensi = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  void fetchDataFromFirestore() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('AksesAbsensi')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .where('kodeAsisten', isEqualTo: widget.kodeAsisten)
        .where('mataKuliah', isEqualTo: widget.mataKuliah)
        .get();

    final data = querySnapshot.docs
        .map((doc) => AksesAbsensi.fromFirestore(doc))
        .toList();

    setState(() {
      filteredAksesAbsensi = data;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 33.0, right: 30.0, top: 25.0),
          child: Text(
            'Data Akses Absensi Mahasiswa',
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 25.0),
            child: SizedBox(
                width: 1250.0,
                child: filteredAksesAbsensi.isNotEmpty
                    ? PaginatedDataTable(
                        columnSpacing: 10,
                        columns: const [
                          DataColumn(
                              label: Text('Judul Modul',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Pertemuan Praktikum',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text(
                            'Tanggal Praktikum',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Akses Absensi Praktikum',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            '     Aksi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                        ],
                        source: DataSource(filteredAksesAbsensi, context,
                            deleteData),
                        rowsPerPage:
                            calculateRowsPerPage(filteredAksesAbsensi.length),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
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

  //== Fungsi untuk menghapus data ==//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance.doc(id).delete();
      fetchDataFromFirestore();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting: $error');
      }
    }
  }

 

  
}

class AksesAbsensi {
  String kode;
  String matkul;
  String asisten;
  String modul;
  String pertemuan;
  String waktu;
  String jadwal;
  String id;

  AksesAbsensi(
      {required this.kode,
      required this.matkul,
      required this.asisten,
      required this.modul,
      required this.pertemuan,
      required this.waktu,
      required this.jadwal,
      required this.id});

  factory AksesAbsensi.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AksesAbsensi(
      id: doc.id,
      kode: data['kodeKelas'] ?? '',
      matkul: data['mataKuliah'] ?? '',
      asisten: data['kodeAsisten'] ?? '',
      modul: data['judulMateri'] ?? '',
      pertemuan: data['pertemuan'] ?? '',
      waktu: data['waktuAbsensi'] ?? '',
      jadwal: data['jadwalPraktikum'] ?? '',
    );
  }
}

DataRow dataFileDataRow(AksesAbsensi fileInfo, int index, BuildContext context,
    Function(String) onDelete) {
  return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return getRowColor(index);
        },
      ),
      cells: [
        DataCell(SizedBox(
            width: 200.0, child: Text(getLimitedText(fileInfo.modul, 30)))),
        DataCell(SizedBox(
            width: 100.0,
            child: Text(
              fileInfo.pertemuan,
            ))),
        DataCell(SizedBox(
          width: 150.0,
          child: Text(fileInfo.jadwal),
        )),
        DataCell(SizedBox(
          width: 150.0,
          child: Text(fileInfo.waktu),
        )),
        DataCell(Row(
          children: [
            //== Edit Akses Absensi ==//
            IconButton(
              onPressed: () {
               
              },
              icon: const Icon(
                Icons.edit_document,
                color: Colors.grey,
              ),
              tooltip: 'Edit Akses Absensi',
            ),
            //== Hapus Akses Absensi ==//
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Hapus Akses Absensi',
                          style: GoogleFonts.quicksand(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        content: const SizedBox(
                          height: 30.0,
                          width: 260.0,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text('Anda yakin ingin menghapus data?'),
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                onDelete(fileInfo.id);
                                Navigator.of(context).pop();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text('Hapus'),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text('Batal'),
                              ))
                        ],
                      );
                    });
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              tooltip: 'Hapus Akses Absensi',
            )
          ],
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
  final List<AksesAbsensi> data;
  final BuildContext context;
  final Function(String) onDelete;

  DataSource(this.data, this.context, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, context, onDelete);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
