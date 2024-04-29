import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TabelNilaiAkhirAdmin extends StatefulWidget {
  final String kodeKelas;

  const TabelNilaiAkhirAdmin({
    Key? key,
    required this.kodeKelas,
  }) : super(key: key);

  @override
  State<TabelNilaiAkhirAdmin> createState() => _TabelNilaiAkhirAdminState();
}

class _TabelNilaiAkhirAdminState extends State<TabelNilaiAkhirAdmin> {
  List<PenilaianAkhir> demoPenilaianAkhir = [];
  List<PenilaianAkhir> filteredPenilaianAkhir = [];
  //== Dropdown Button ==
  String selectedKeterangan = 'Tampilkan Semua';

  @override
  void initState() {
    super.initState();
    checkAndFetchData();
  }

  Future<void> checkAndFetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('nilaiHarian')
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      await Future.forEach(querySnapshot.docs, (doc) async {
        // Ambil data yang diperlukan dari 'nilaiHarian'
        String nama = doc['nama'] ?? '';
        int nim = doc['nim'] ?? 0;
        double modul1 = doc['modul1'] ?? 0.0;
        double modul2 = doc['modul2'] ?? 0.0;
        double modul3 = doc['modul3'] ?? 0.0;
        double modul4 = doc['modul4'] ?? 0.0;
        double modul5 = doc['modul5'] ?? 0.0;

        // Periksa apakah data sudah ada di 'nilaiAkhir'
        QuerySnapshot<Map<String, dynamic>> nilaiSnapshot =
            await FirebaseFirestore.instance
                .collection('nilaiAkhir')
                .where('nim', isEqualTo: nim)
                .where('kodeKelas', isEqualTo: widget.kodeKelas)
                .get();

        if (nilaiSnapshot.docs.isEmpty) {
          // Jika data tidak ada, tambahkan ke 'nilaiAkhir'
          await FirebaseFirestore.instance.collection('nilaiAkhir').add({
            'nama': nama,
            'nim': nim,
            'kodeKelas': widget.kodeKelas,
            'modul1': modul1,
            'modul2': modul2,
            'modul3': modul3,
            'modul4': modul4,
            'modul5': modul5,
          });
        }
      });

      await getDataFromFirebase();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> getDataFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      if (selectedKeterangan != 'Tampilkan Semua') {
        // Jika keterangan yang akan difilter tidak kosong, lakukan query dengan filter
        querySnapshot = await FirebaseFirestore.instance
            .collection('nilaiAkhir')
            .where('kodeKelas', isEqualTo: widget.kodeKelas)
            .where('keterangan', isEqualTo: selectedKeterangan)
            .get();
      } else {
        // Jika keterangan yang akan difilter kosong, ambil semua data
        querySnapshot = await FirebaseFirestore.instance
            .collection('nilaiAkhir')
            .where('kodeKelas', isEqualTo: widget.kodeKelas)
            .get();
      }

      setState(() {
        demoPenilaianAkhir = querySnapshot.docs.map((docs) {
          Map<String, dynamic> data = docs.data();
          return PenilaianAkhir(
            nim: data['nim'] ?? 0,
            nama: data['nama'] ?? '',
            kode: data['kodeKelas'] ?? '',
            //== Rata - Rata Modul ==
            modul1: data['modul1'] ?? 0.0,
            modul2: data['modul2'] ?? 0.0,
            modul3: data['modul3'] ?? 0.0,
            modul4: data['modul4'] ?? 0.0,
            modul5: data['modul5'] ?? 0.0,
            //== Komponen Nilai Akhir
            pretest: data['pretest'] ?? 0.0,
            project: data['projectAkhir'] ?? 0.0,
            resmi: data['laporanResmi'] ?? 0.0,
            akhir: data['nilaiAkhir'] ?? 0.0,
            //== Penentuan Nilai Akhir ==
            status: data['keterangan'] ?? '',
            huruf: data['nilaiHuruf'] ?? '',
          );
        }).toList();
        filteredPenilaianAkhir = List.from(demoPenilaianAkhir);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error:$e');
      }
    }
  }

  //== Tampilan Dialog ==
  void editNilai(PenilaianAkhir nilai) {
    // == Pre-Test ==
    TextEditingController pretestController =
        TextEditingController(text: nilai.pretest.toString());
    //
    //== Komponen Nilai Rata - Rata
    TextEditingController modul1Controller =
        TextEditingController(text: nilai.modul1.toString());
    TextEditingController modul2Controller =
        TextEditingController(text: nilai.modul2.toString());
    TextEditingController modul3Controller =
        TextEditingController(text: nilai.modul3.toString());
    TextEditingController modul4Controller =
        TextEditingController(text: nilai.modul4.toString());
    TextEditingController modul5Controller =
        TextEditingController(text: nilai.modul5.toString());
//
// == Projek Akhir dan Laporan Resmi
    TextEditingController projectController =
        TextEditingController(text: nilai.project.toString());
    TextEditingController resmiController =
        TextEditingController(text: nilai.resmi.toString());

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Formulir Nilai Akhir',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                  child: Divider(
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              height: 240.0,
              width: 400.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //== Pre-Test, Modul 1, Modul 2 dan Modul 3
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // == PreTest
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: pretestController,
                            decoration:
                                const InputDecoration(labelText: 'Pre-Test'),
                          ),
                        ),
                      ),
                      // == Modul 1
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul1Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 1'),
                          ),
                        ),
                      ),
                      // == Modul 2
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul2Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 2'),
                          ),
                        ),
                      ),
                      // == Modul 3
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul3Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 3'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //== Modul 4, Modul 5, Projek Akhir, Laporan Resmi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // == Modul 4
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul4Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 4'),
                          ),
                        ),
                      ),
                      // == Modul 5
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul5Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 5'),
                          ),
                        ),
                      ),
                      // == Project Resmi
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: projectController,
                            decoration: const InputDecoration(
                                labelText: 'Project Resmi'),
                          ),
                        ),
                      ),
                      // == Laporan Resmi
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: resmiController,
                            decoration: const InputDecoration(
                                labelText: 'Laporan Resmi'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextButton(
                  onPressed: () async {
                    // Dalam bagian onPressed dari TextButton:
                    double pretest =
                        double.tryParse(pretestController.text) ?? 0.0;
                    double project =
                        double.tryParse(projectController.text) ?? 0.0;
                    double resmi = double.tryParse(resmiController.text) ?? 0.0;

                    // Update nilai pretest, project, dan resmi pada objek nilai
                    nilai.pretest = pretest;
                    nilai.project = project;
                    nilai.resmi = resmi;

                    try {
                      // Dapatkan nama asisten
                      String? namaAsisten = await getNamaAsisten();

                      QuerySnapshot<Map<String, dynamic>> querySnapshot =
                          await FirebaseFirestore.instance
                              .collection('nilaiAkhir')
                              .where('nim', isEqualTo: nilai.nim)
                              .where('kodeKelas', isEqualTo: widget.kodeKelas)
                              .get();

                      if (querySnapshot.docs.isEmpty) {
                        await FirebaseFirestore.instance
                            .collection('nilaiAkhir')
                            .add({
                          'nim': nilai.nim,
                          'kodeKelas': widget.kodeKelas,
                          'modul1': nilai.modul1,
                          'modul2': nilai.modul2,
                          'modul3': nilai.modul3,
                          'modul4': nilai.modul4,
                          'modul5': nilai.modul5,
                          'pretest': pretest,
                          'projectAkhir': project,
                          'laporanResmi': resmi,
                          'keterangan': nilai.status,
                          'nilaiHuruf': nilai.huruf,
                          'namaAsisten':
                              namaAsisten ?? "", // Pastikan tidak null
                        });
                      } else {
                        await querySnapshot.docs[0].reference.update({
                          'modul1': nilai.modul1,
                          'modul2': nilai.modul2,
                          'modul3': nilai.modul3,
                          'modul4': nilai.modul4,
                          'modul5': nilai.modul5,
                          'pretest': pretest,
                          'projectAkhir': project,
                          'laporanResmi': resmi,
                          'keterangan': nilai.status,
                          'nilaiHuruf': nilai.huruf,
                          'namaAsisten':
                              namaAsisten ?? "", // Pastikan tidak null
                        });
                      }

                      setState(() {
                        demoPenilaianAkhir = demoPenilaianAkhir.map((item) {
                          if (item.nim == nilai.nim) {
                            return nilai;
                          } else {
                            return item;
                          }
                        }).toList();
                        filteredPenilaianAkhir = List.from(demoPenilaianAkhir);
                      });

                      // Perbarui data yang ditampilkan setelah menyimpan ke Firestore
                      await getDataFromFirebase();

                      // Hitung dan simpan nilai akhir
                      await _calculateAndSaveNilaiAkhir(nilai);

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error updating data:$e');
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, right: 20.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
              )
            ],
          );
        });
  }

//== Nama Pengoreksi
  Future<String?> getNamaAsisten() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      // Kueri Firestore untuk mendapatkan data mahasiswa
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('akun_mahasiswa')
          .doc(uid)
          .get();
      if (snapshot.exists) {
        // Jika dokumen ditemukan, ambil nilai dari field 'nama'
        String? namaAsisten = snapshot.data()?['nama'];
        return namaAsisten;
      }
    }
    return null;
  }

  Future<void> _calculateAndSaveNilaiAkhir(PenilaianAkhir nilai) async {
    // Perhitungan nilai akhir
    double nilaiAkhir = ((nilai.pretest * 0.15) +
            (nilai.modul1 * 0.05) +
            (nilai.modul2 * 0.05) +
            (nilai.modul3 * 0.05) +
            (nilai.modul4 * 0.05) +
            (nilai.modul5 * 0.05) +
            (nilai.project * 0.3) +
            (nilai.resmi * 0.3))
        .toDouble();

    // Inisialisasi variabel huruf dan status
    String huruf;
    String status;

    // Penentuan huruf dan status berdasarkan nilai akhir
    if (nilaiAkhir >= 80) {
      huruf = 'A';
      status = 'Lulus';
    } else if (nilaiAkhir >= 70) {
      huruf = 'B';
      status = 'Lulus';
    } else if (nilaiAkhir >= 60) {
      huruf = 'C';
      status = 'Lulus';
    } else if (nilaiAkhir >= 40) {
      huruf = 'D';
      status = 'Tidak Lulus';
    } else {
      huruf = 'E';
      status = 'Tidak Lulus';
    }

    // Update nilai huruf dan status pada objek nilai
    nilai.huruf = huruf;
    nilai.status = status;
    nilai.akhir = nilaiAkhir;

    // Simpan nilai akhir ke Firestore
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('nilaiAkhir')
              .where('nim', isEqualTo: nilai.nim)
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('nilaiAkhir').add({
          'nim': nilai.nim,
          'kodeKelas': widget.kodeKelas,
          'modul1': nilai.modul1,
          'modul2': nilai.modul2,
          'modul3': nilai.modul3,
          'modul4': nilai.modul4,
          'modul5': nilai.modul5,
          'pretest': nilai.pretest,
          'projectAkhir': nilai.project,
          'laporanResmi': nilai.resmi,
          'keterangan': nilai.status,
          'nilaiHuruf': nilai.huruf,
          'nilaiAkhir': nilai.akhir,
        });
      } else {
        await querySnapshot.docs[0].reference.update({
          'modul1': nilai.modul1,
          'modul2': nilai.modul2,
          'modul3': nilai.modul3,
          'modul4': nilai.modul4,
          'modul5': nilai.modul5,
          'pretest': nilai.pretest,
          'projectAkhir': nilai.project,
          'laporanResmi': nilai.resmi,
          'keterangan': nilai.status,
          'nilaiHuruf': nilai.huruf,
          'nilaiAkhir': nilai.akhir,
        });
      }

      setState(() {
        demoPenilaianAkhir = demoPenilaianAkhir.map((item) {
          if (item.nim == nilai.nim) {
            return nilai;
          } else {
            return item;
          }
        }).toList();
        filteredPenilaianAkhir = List.from(demoPenilaianAkhir);
      });

      // Perbarui data yang ditampilkan setelah menyimpan ke Firestore
      await getDataFromFirebase();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating data:$e');
      }
    }
  }

  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 20.0, left: 920.0),
            child: Row(
              children: [
//== Text ==
                const Text(
                  'Search :',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Container(
                    width: 260.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      style: const TextStyle(color: Colors.black),
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      iconSize: 24,
                      elevation: 16,

                      value: selectedKeterangan,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedKeterangan = newValue!;
                          getDataFromFirebase();
                        });
                      },
                      underline: Container(), // Menjadikan garis bawah kosong
                      items: <String>['Tampilkan Semua', 'Lulus', 'Tidak Lulus']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredPenilaianAkhir.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Nama',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Pre-Test',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Modul 1',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Modul 2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Modul 3',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Modul 4',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Modul 5',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Projek Akhir',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Laporan Resmi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nilai Akhir',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(
                        data: filteredPenilaianAkhir,
                        context: context,
                        editNilai: editNilai,
                      ),
                      rowsPerPage:
                          calculateRowsPerPage(filteredPenilaianAkhir.length))
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
          )
        ],
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;
    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class PenilaianAkhir {
  String kode;
  int nim;
  String nama;
  // //== Pre-Test ==
  double pretest;
  //== Modul 1-5 (diambil dari rata-rata permodul) ===
  double modul1;
  double modul2;
  double modul3;
  double modul4;
  double modul5;
  //== Final Project ==
  double project;
  // //== Laporan Resmi ==
  double resmi;
  // //== Nilai Akhir ==
  double akhir;
  //== Status ==
  String status;
  // //== Nilai Huruf ==
  String huruf;

  //
  PenilaianAkhir({
    required this.nim,
    required this.nama,
    required this.kode,
    //== Pre-Test ==
    this.pretest = 0.0,
    //== Modul 1-5 (diambil dari rata-rata permodul) ===
    this.modul1 = 0.0,
    this.modul2 = 0.0,
    this.modul3 = 0.0,
    this.modul4 = 0.0,
    this.modul5 = 0.0,
    //== Final Project ==
    this.project = 0.0,
    //== Laporan Resmi ==
    this.resmi = 0.0,
    //== Nilai Akhir ==
    this.akhir = 0.0,
    //== Status ==
    required this.status,
    //== Nilai Huruf ==
    required this.huruf,
  });
}

DataRow dataFileDataRow(PenilaianAkhir fileInfo, int index,
    void Function(PenilaianAkhir) editNilai) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(
        width: 160.0,
        child: Text(getLimitedText(fileInfo.nama, 30)),
      )),
      DataCell(
        Text(getLimitedText(fileInfo.pretest.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.modul1.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.modul2.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.modul3.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.modul4.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.modul5.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.project.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.resmi.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.akhir.toString(), 5)),
      ),
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
  final List<PenilaianAkhir> data;
  final BuildContext context;
  final void Function(PenilaianAkhir) editNilai;

  DataSource(
      {required this.data, required this.context, required this.editNilai});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, editNilai);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
