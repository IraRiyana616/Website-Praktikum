import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Edit Data Asisten/edit_data_asisten.dart';

class TabelDataAsisten extends StatefulWidget {
  final String mataKuliah;
  final String idkelas;
  final String kode;
  const TabelDataAsisten({
    Key? key,
    required this.mataKuliah,
    required this.idkelas,
    required this.kode,
  }) : super(key: key);

  @override
  State<TabelDataAsisten> createState() => _TabelDataAsistenState();
}

class _TabelDataAsistenState extends State<TabelDataAsisten> {
  //== List Data Tabel ==//
  List<DataAsisten> demoDataAsisten = [];
  List<DataAsisten> filteredDataAsisten = [];

  //== Fungsi untuk mengaktifkan loading ==//
  bool isLoading = true;

//== Fungsi untuk memanggil Firestore ==//
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchDataAsisten();
  }

//== Fungsi untuk menampilkan data dari database ==//
  Future<void> _fetchDataAsisten() async {
    try {
      var akunSnapshot = await _firestore.collection('akun_mahasiswa').get();
      List<DataAsisten> dataAsistenList = [];

      if (akunSnapshot.docs.isNotEmpty) {
        for (var akunDoc in akunSnapshot.docs) {
          var nim = akunDoc['nim'];

          var dataAsistenSnapshotNim = await _firestore
              .collection('dataAsisten')
              .where('nim', isEqualTo: nim)
              .where('idKelas', isEqualTo: widget.idkelas)
              .get();

          var dataAsistenSnapshotNim2 = await _firestore
              .collection('dataAsisten')
              .where('nim2', isEqualTo: nim)
              .where('idKelas', isEqualTo: widget.idkelas)
              .get();

          var dataAsistenSnapshotNim3 = await _firestore
              .collection('dataAsisten')
              .where('nim3', isEqualTo: nim)
              .where('idKelas', isEqualTo: widget.idkelas)
              .get();

          var dataAsistenSnapshotNim4 = await _firestore
              .collection('dataAsisten')
              .where('nim4', isEqualTo: nim)
              .where('idKelas', isEqualTo: widget.idkelas)
              .get();

          var combinedDocs = [
            ...dataAsistenSnapshotNim.docs,
            ...dataAsistenSnapshotNim2.docs,
            ...dataAsistenSnapshotNim3.docs,
            ...dataAsistenSnapshotNim4.docs
          ];

          if (combinedDocs.isNotEmpty) {
            // ignore: unused_local_variable
            for (var dataAsistenDoc in combinedDocs) {
              dataAsistenList.add(
                DataAsisten(
                  nim: akunDoc['nim'] ?? 0,
                  nama: akunDoc['nama'] ?? '',
                  email: akunDoc['email'] ?? '',
                  nohp: akunDoc['no_hp'] ?? 0,
                  angkatan: akunDoc['angkatan'] ?? 0,
                  password: akunDoc['password'] ?? '',
                ),
              );
            }
          }
        }
      }
      dataAsistenList.sort((a, b) => a.nama.compareTo(b.nama));
      setState(() {
        demoDataAsisten = dataAsistenList;
        filteredDataAsisten = dataAsistenList;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //== ElevatedButton Edit Data ==//
        Padding(
          padding: const EdgeInsets.only(left: 1170.0),
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
                        FormEditDataAsisten(
                      mataKuliah: widget.mataKuliah,
                      idkelas: widget.idkelas,
                      kode: widget.kode,
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
                    Icon(
                      Icons.edit_document,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.0),
                    //== Text ==//
                    Text(
                      "Edit Data",
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

        //== Tabel ==//
        Padding(
          padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 25.0),
          child: SizedBox(
            width: double.infinity,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredDataAsisten.isNotEmpty
                    ? PaginatedDataTable(
                        columnSpacing: 10,
                        columns: const [
                          DataColumn(
                            label: Text(
                              "NIM",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Nama Lengkap",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Email",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Nomor Handphone",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        source: DataSource(filteredDataAsisten, context),
                        rowsPerPage:
                            calculateRowsPerPage(filteredDataAsisten.length),
                      )
                    : const Center(
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
      ],
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;

    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class DataAsisten {
  final int nim;
  final String nama;
  final String email;
  final int nohp;
  final int angkatan;
  final String password;

  DataAsisten({
    required this.nim,
    required this.nama,
    required this.email,
    required this.nohp,
    required this.angkatan,
    required this.password,
  });
}

DataRow dataFileDataRow(DataAsisten fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(width: 140.0, child: Text(fileInfo.nim.toString()))),
      DataCell(SizedBox(
          width: 250.0, child: Text(getLimitedText(fileInfo.nama, 30)))),
      DataCell(SizedBox(
          width: 250.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getLimitedText(fileInfo.email, 30)),
              IconButton(
                  onPressed: () {
                    copyToClipboard(fileInfo.email);
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.grey,
                  ))
            ],
          ))),
      DataCell(SizedBox(
          width: 145.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fileInfo.nohp.toString()),
              IconButton(
                  onPressed: () {
                    copyToClipboard(fileInfo.nohp.toString());
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.grey,
                  ))
            ],
          ))),
    ],
  );
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

//== Fungsi untuk menduplikasi data ==//
void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

//== Fungsi untuk membatasi text ==//
String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

class DataSource extends DataTableSource {
  final List<DataAsisten> data;
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
