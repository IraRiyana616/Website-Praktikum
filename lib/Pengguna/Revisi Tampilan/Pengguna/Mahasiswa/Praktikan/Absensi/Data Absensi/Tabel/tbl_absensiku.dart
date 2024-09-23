import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TabelAbsensiPraktikan extends StatefulWidget {
  final String idkelas;
  const TabelAbsensiPraktikan({super.key, required this.idkelas});

  @override
  State<TabelAbsensiPraktikan> createState() => _TabelAbsensiPraktikanState();
}

class _TabelAbsensiPraktikanState extends State<TabelAbsensiPraktikan> {
  List<DataAbsensi> demoDataAbsensi = [];
  List<DataAbsensi> filteredDataAbsensi = [];

  Future<void> _onRefresh() async {
    await fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      QuerySnapshot silabusSnapshot = await FirebaseFirestore.instance
          .collection('silabusMatakuliah')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      List<DataAbsensi> fetchedData = [];

      for (var silabusDoc in silabusSnapshot.docs) {
        String idModul = silabusDoc['idModul'] ?? '';
        QuerySnapshot aksesAbsenSnapshot = await FirebaseFirestore.instance
            .collection('aksesAbsen')
            .where('idKelas', isEqualTo: widget.idkelas)
            .where('idModul', isEqualTo: idModul)
            .get();

        if (aksesAbsenSnapshot.docs.isNotEmpty) {
          var aksesAbsenDoc = aksesAbsenSnapshot.docs.first;

          DateTime? waktuAkses;
          DateTime? waktuTutupAkses;

          if (aksesAbsenDoc['waktuAkses'] != null) {
            if (aksesAbsenDoc['waktuAkses'] is Timestamp) {
              waktuAkses = (aksesAbsenDoc['waktuAkses'] as Timestamp).toDate();
            } else if (aksesAbsenDoc['waktuAkses'] is String) {
              waktuAkses = DateFormat("dd MMMM yyyy HH:mm a")
                  .parse(aksesAbsenDoc['waktuAkses']);
            }
          }
          if (aksesAbsenDoc['waktuTutupAkses'] != null) {
            if (aksesAbsenDoc['waktuTutupAkses'] is Timestamp) {
              waktuTutupAkses =
                  (aksesAbsenDoc['waktuTutupAkses'] as Timestamp).toDate();
            } else if (aksesAbsenDoc['waktuTutupAkses'] is String) {
              waktuTutupAkses = DateFormat("dd MMMM yyyy HH:mm a")
                  .parse(aksesAbsenDoc['waktuTutupAkses']);
            }
          }

          bool sudahAbsen = await checkIfAlreadyAbsen(idModul);

          fetchedData.add(DataAbsensi(
            id: silabusDoc.id,
            idkelas: widget.idkelas,
            idModul: idModul,
            modul: silabusDoc['judulModul'] ?? '',
            file: silabusDoc['namaFile'] ?? '',
            pertemuan: silabusDoc['pertemuan'] ?? '',
            waktuAkses: waktuAkses,
            waktuTutupAkses: waktuTutupAkses,
            sudahAbsen: sudahAbsen,
          ));
        }
      }

      fetchedData.sort((a, b) => a.pertemuan.compareTo(b.pertemuan));

      if (mounted) {
        setState(() {
          demoDataAbsensi = fetchedData;
          filteredDataAbsensi = fetchedData;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(user.uid)
                .get();
        if (userSnapshot.exists) {
          int userNim = userSnapshot['nim'];
          String userNama = userSnapshot['nama'];
          return {
            'nim': userNim,
            'nama': userNama,
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data from Firebase: $e');
      }
    }
    return null;
  }

  Future<void> addAbsensi(DataAbsensi fileInfo) async {
    Map<String, dynamic>? userData = await getCurrentUserData();
    if (userData != null) {
      int nim = userData['nim'];
      String nama = userData['nama'];
      String waktuAbsensi =
          DateFormat("dd MMMM yyyy HH:mm a").format(DateTime.now());

      try {
        await FirebaseFirestore.instance.collection('absenMahasiswa').add({
          'nim': nim,
          'nama': nama,
          'judulModul': fileInfo.modul,
          'waktuAbsensi': waktuAbsensi,
          'idKelas': widget.idkelas,
          'pertemuan': fileInfo.pertemuan,
          'idAbsensi': fileInfo.idModul,
        });

        setState(() {
          fileInfo.sudahAbsen = true;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    }
  }

  Future<bool> checkIfAlreadyAbsen(String idAbsensi) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .get();
    if (!userSnapshot.exists) return false;

    int nim = userSnapshot['nim'];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('absenMahasiswa')
        .where('nim', isEqualTo: nim)
        .where('idAbsensi', isEqualTo: idAbsensi)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

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
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0, left: 20.0),
            child: Text('Absensi Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 15.0, left: 18.0, right: 25.0),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredDataAbsensi.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Nama Matakuliah",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Pertemuan",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Absensi Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: DataSource(
                                filteredDataAbsensi, context, addAbsensi),
                            rowsPerPage: calculateRowsPerPage(
                                filteredDataAbsensi.length),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(15.0),
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
}

class DataAbsensi {
  String id;
  String idkelas;
  String idModul;
  String modul;
  String file;
  String pertemuan;
  DateTime? waktuAkses;
  DateTime? waktuTutupAkses;
  bool sudahAbsen;

  DataAbsensi({
    required this.id,
    required this.idkelas,
    required this.idModul,
    required this.modul,
    required this.file,
    required this.pertemuan,
    this.waktuAkses,
    this.waktuTutupAkses,
    this.sudahAbsen = false,
  });
}

class DataSource extends DataTableSource {
  final List<DataAbsensi> _data;
  final BuildContext _context;
  final Future<void> Function(DataAbsensi) _addAbsensi;

  DataSource(this._data, this._context, this._addAbsensi);

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= _data.length) return null;
    final data = _data[index];

    return DataRow.byIndex(
      index: index,
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return getRowColor(index);
        },
      ),
      cells: [
        DataCell(
          Text(data.modul),
        ),
        DataCell(
          Text(data.pertemuan),
        ),
        DataCell(
          Builder(
            builder: (context) {
              if (data.waktuAkses != null && data.waktuTutupAkses != null) {
                DateTime currentTime = DateTime.now();
                if (currentTime.isAfter(data.waktuAkses!) &&
                    currentTime.isBefore(data.waktuTutupAkses!)) {
                  return data.sudahAbsen
                      ? const Text(
                          'Sudah Absen',
                        )
                      : SizedBox(
                          width: 130.0,
                          height: 32.0,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _addAbsensi(data);
                            },
                            child: const Text('Absen'),
                          ),
                        );
                } else if (currentTime.isBefore(data.waktuAkses!)) {
                  return const Text(
                    'Absen Belum Tersedia',
                  );
                } else {
                  return const Text(
                    'Waktu Absen Selesai',
                  );
                }
              } else {
                return const Text(
                  'Jadwal Tidak Tersedia',
                  style: TextStyle(fontWeight: FontWeight.bold),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Color getRowColor(int index) {
    if (index % 2 == 0) {
      return Colors.grey.shade200;
    } else {
      return Colors.transparent;
    }
  }

  @override
  int get rowCount => _data.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}
