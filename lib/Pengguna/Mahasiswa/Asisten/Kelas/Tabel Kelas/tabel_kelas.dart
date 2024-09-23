import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Revisi Tampilan/Pengguna/Mahasiswa/Asisten/Dashboard/Komponen/Deskripsi Kelas/deskripsi_kelas_asisten.dart';
import '../Form Komponen/form_deskripsi.dart';

class TabelKelasAsisten extends StatefulWidget {
  const TabelKelasAsisten({Key? key}) : super(key: key);

  @override
  State<TabelKelasAsisten> createState() => _TabelKelasAsistenState();
}

class _TabelKelasAsistenState extends State<TabelKelasAsisten> {
  //== List Tabel ==//
  List<DataKelas> demoDataKelas = [];
  List<DataKelas> filteredDataKelas = [];

  //== Fungsi Controller pada Search ==//
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredDataKelas = demoDataKelas
          .where((data) =>
              (data.matkul.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      textController.clear();
      filterData('');
    });
  }

//== Fungsi Menampilkan Data dari Firebase ==//
  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userUid = user.uid;
      fetchDataFromFirebase(userUid);
    }
    textController.addListener(_onTextChanged);
  }

// Fungsi untuk mengambil data dari database
  Future<void> fetchDataFromFirebase(String userUid) async {
    try {
      if (userUid.isNotEmpty) {
        // Mendapatkan NIM user dari 'akun_mahasiswa'
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();

        if (userSnapshot.exists) {
          int userNim = userSnapshot['nim'] as int;

          // Mencari dokumen yang sesuai di 'dataAsisten'
          final dataAsistenSnapshots = await Future.wait([
            FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim', isEqualTo: userNim)
                .get(),
            FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim2', isEqualTo: userNim)
                .get(),
            FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim3', isEqualTo: userNim)
                .get(),
            FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim4', isEqualTo: userNim)
                .get()
          ]);

          // Menggabungkan hasil pencarian dataAsisten
          List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];
          for (var snapshot in dataAsistenSnapshots) {
            allDocs.addAll(snapshot.docs);
          }

          if (allDocs.isNotEmpty) {
            List<String> idKelasList =
                allDocs.map((doc) => doc['idKelas'] as String).toList();

            List<DataKelas> allDataKelas = [];

            for (String idKelas in idKelasList) {
              // Mengambil data dari 'dataKelasPraktikum'
              QuerySnapshot<Map<String, dynamic>> kelasPraktikumSnapshot =
                  await FirebaseFirestore.instance
                      .collection('dataKelasPraktikum')
                      .where('idKelas', isEqualTo: idKelas)
                      .get();

              List<DataKelas> data = kelasPraktikumSnapshot.docs
                  .map((doc) => DataKelas(
                        kode: doc['kodeMatakuliah'] ?? '',
                        idkelas: doc['idKelas'] ?? '',
                        matkul: doc['matakuliah'] ?? '',
                        tahunAjaran: doc['tahunAjaran'] ?? '',
                      ))
                  .toList();

              allDataKelas.addAll(data);
            }
            allDataKelas.sort((a, b) => a.matkul.compareTo(b.matkul));
            setState(() {
              demoDataKelas = allDataKelas;
              filteredDataKelas = demoDataKelas;
            });
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data from Firebase: $error');
      }
    }
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = textController.text.isNotEmpty;
      filterData(textController.text);
    });
  }

  Color getRowColor(int index) {
    if (index % 2 == 0) {
      return Colors.grey.shade200;
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0),
            child: Text('Data Kelas Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //== Search ==//
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 25.0),
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
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                child: SizedBox(
                  width: double.infinity,
                  child: filteredDataKelas.isNotEmpty
                      ? PaginatedDataTable(
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(
                                label: Text(
                              'Kode Matakuliah',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataColumn(
                              label: Text(
                                "MataKuliah",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Tahun Ajaran",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Informasi Jadwal",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Aksi",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          source: DataSource(filteredDataKelas, context),
                          rowsPerPage:
                              calculateRowsPerPage(filteredDataKelas.length),
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

class DataKelas {
  String kode;
  String idkelas;
  String matkul;
  String tahunAjaran;

  DataKelas(
      {required this.kode,
      required this.idkelas,
      required this.matkul,
      required this.tahunAjaran});
}

DataRow dataFileDataRow(DataKelas fileInfo, int index, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(width: 140.0, child: Text(fileInfo.kode))),
      DataCell(
          SizedBox(
            width: 250.0,
            child: Text(
              getLimitedText(fileInfo.matkul, 30),
              style: TextStyle(
                  color: Colors.lightBlue[700], fontWeight: FontWeight.bold),
            ),
          ), onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DeskripsiKelasAsisten(
              idkelas: fileInfo.idkelas,
              kode: fileInfo.kode,
              mataKuliah: fileInfo.matkul,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }),
      DataCell(SizedBox(width: 150.0, child: Text(fileInfo.tahunAjaran))),
      DataCell(SizedBox(
        width: 180.0,
        child: Row(
          children: [
            //== Icon Informasi ==//
            const Icon(
              Icons.info,
              color: Colors.grey,
            ),
            const SizedBox(width: 10.0),
            //== Text 'Detail' ==//
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () async {
                    try {
                      // Ambil data dari Firestore
                      var dataJadwalPraktikumSnapshot = await FirebaseFirestore
                          .instance
                          .collection('JadwalPraktikum')
                          .where('kodeMatakuliah', isEqualTo: fileInfo.kode)
                          .get();

                      if (dataJadwalPraktikumSnapshot.docs.isNotEmpty) {
                        // Ambil dokumen pertama dari hasil query
                        var dataJadwalPraktikum =
                            dataJadwalPraktikumSnapshot.docs.first.data();

                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Jadwal Praktikum',
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 13.0,
                                  ),

                                  //== Hari Praktikum ==//
                                  Row(
                                    children: [
                                      const Text(
                                        'Hari Praktikum      : ',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        '${dataJadwalPraktikum['hari']}',
                                        style: const TextStyle(fontSize: 14.0),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 18.0,
                                  ),

                                  //== Jam Praktikum ==//
                                  Row(
                                    children: [
                                      const Text(
                                        'Jam Praktikum     : ',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        '${dataJadwalPraktikum['waktuPraktikum']}',
                                        style: const TextStyle(fontSize: 14.0),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 18.0,
                                  ),
                                  //== Ruang Praktikum ==//
                                  Row(
                                    children: [
                                      const Text(
                                        'Ruang Praktikum  : ',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        '${dataJadwalPraktikum['ruangPraktikum']}',
                                        style: const TextStyle(fontSize: 14.0),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 18.0,
                                  ),
                                ],
                              ),
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextButton(
                                    child: const Text('Tutup'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Error',
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                'Jadwal praktikum tidak ditemukan',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextButton(
                                    child: const Text('Tutup'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('error:$e');
                      }
                    }
                  },
                  child: const Text(
                    'Detail',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  )),
            )
          ],
        ),
      )),
      DataCell(Row(
        children: [
          IconButton(
            onPressed: () async {
              final firestore = FirebaseFirestore.instance;

              // Mengambil idKelas dari fileInfo
              final idKelas = fileInfo.idkelas;

              // Mengambil koleksi dataAsisten dan memeriksa keberadaan idKelas
              final snapshot = await firestore
                  .collection('deskripsiKelas')
                  .where('idKelas', isEqualTo: idKelas)
                  .get();

              // Memeriksa apakah data dengan idKelas sudah ada
              if (snapshot.docs.isNotEmpty) {
                // Menampilkan dialog jika data sudah ada
                // ignore: use_build_context_synchronously
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'Data Sudah Ada',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22.0),
                    ),
                    content: const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Anda telah memasukkan data pada database.\n\nLakukan perubahan data pada Edit Deskripsi Kelas.'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                // Navigasi ke FormDataAsisten jika data belum ada
                // ignore: use_build_context_synchronously
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FormDeskripsiKelas(
                      idkelas: fileInfo.idkelas,
                      kodeKelas: fileInfo.kode,
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
              }
              // Navigator.push(
              //   context,
              //   PageRouteBuilder(
              //     pageBuilder: (context, animation, secondaryAnimation) =>
              //
              //     transitionsBuilder:
              //         (context, animation, secondaryAnimation, child) {
              //       const begin = Offset(0.0, 0.0);
              //       const end = Offset.zero;
              //       const curve = Curves.ease;

              //       var tween = Tween(begin: begin, end: end)
              //           .chain(CurveTween(curve: curve));

              //       return SlideTransition(
              //         position: animation.drive(tween),
              //         child: child,
              //       );
              //     },
              //   ),
              // );
            },
            icon: const Icon(
              Icons.add_box,
              color: Colors.grey,
            ),
            tooltip: 'Tambah Data',
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
  if (index % 2 == 0) {
    return Colors.grey.shade200;
  } else {
    return Colors.transparent;
  }
}

class DataSource extends DataTableSource {
  final List<DataKelas> data;
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
