import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Navigation/hasil_studi_ds.dart';
import '../Nilai Harian/nilai_harian_ds.dart';

class NilaiAkhirDosen extends StatefulWidget {
  final String kodeKelas;
  final String matkul;
  const NilaiAkhirDosen(
      {Key? key, required this.kodeKelas, required this.matkul})
      : super(key: key);

  @override
  State<NilaiAkhirDosen> createState() => _NilaiAkhirDosenState();
}

class _NilaiAkhirDosenState extends State<NilaiAkhirDosen> {
  final ScrollController _controller = ScrollController();
  String selectedKeterangan = 'Tampilkan Semua';

//== Pre-Test ==//
  TextEditingController pretestController = TextEditingController();
  //== Project Akhir ==//
  TextEditingController projectAkhirController = TextEditingController();
  //== Laporan Resmi ==//
  TextEditingController laporanResmiController = TextEditingController();

  late StreamSubscription<QuerySnapshot> _penilaianStreamSubscription;
  late StreamSubscription<QuerySnapshot> _nilaiHarianStreamSubscription;

  List<PenilaianAkhir> _penilaianList = [];

  @override
  void initState() {
    super.initState();
    _subscribeToNilaiAkhir();
    _subscribeToNilaiHarian(); // Tambahkan listener untuk nilaiHarian
  }

  void _subscribeToNilaiHarian() {
    _nilaiHarianStreamSubscription = FirebaseFirestore.instance
        .collection('nilaiHarian')
        .snapshots()
        .listen((snapshot) async {
      try {
        for (var document in snapshot.docs) {
          var data = document.data();
          String kodeKelas = data['kodeKelas'];
          int nim = data['nim'];
          double modul1 = (data['modul1'] ?? 0).toDouble();
          double modul2 = (data['modul2'] ?? 0).toDouble();

          // Update nilaiAkhir berdasarkan perubahan di nilaiHarian
          await _updateNilaiAkhir(modul1, modul2, kodeKelas, nim);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    });
  }

  Future<void> _updateNilaiAkhir(
      double newModul1, double newModul2, String kodeKelas, int nim) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('nilaiAkhir')
          .where('kodeKelas', isEqualTo: kodeKelas)
          .where('nim', isEqualTo: nim)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs.first;
        var data = documentSnapshot.data();

        var penilaian = PenilaianAkhir(
          nim: nim,
          nama: data['nama'] ?? '',
          kode: kodeKelas,
          modul1: newModul1,
          modul2: newModul2,
          pretest: (data['pretest'] ?? 0).toDouble(),
          project: (data['projectAkhir'] ?? 0).toDouble(),
          resmi: (data['laporanResmi'] ?? 0).toDouble(),
          akhir: (data['nilaiAkhir'] ?? 0).toDouble(),
          huruf: data['nilaiHuruf'] ?? '',
          status: data['status'] ?? '',
        );

        var hasil = calculateHuruf(penilaian.modul1, penilaian.modul2,
            penilaian.pretest, penilaian.project, penilaian.resmi);
        penilaian.akhir = calculateNilaiAkhir(
            penilaian.modul1,
            penilaian.modul2,
            penilaian.pretest,
            penilaian.project,
            penilaian.resmi);
        penilaian.huruf = hasil['nilaiHuruf']!;
        penilaian.status = hasil['status']!;

        await documentSnapshot.reference.update({
          'modul1': penilaian.modul1,
          'modul2': penilaian.modul2,
          'nilaiAkhir': penilaian.akhir,
          'nilaiHuruf': penilaian.huruf,
          'status': penilaian.status,
        });

        if (kDebugMode) {
          print('Nilai akhir updated based on nilai harian changes');
        }
      } else {
        if (kDebugMode) {
          print(
              'Document in nilaiAkhir does not exist for provided kodeKelas and nim');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating nilaiAkhir: $e');
      }
    }
  }

  void _subscribeToNilaiAkhir() {
    _penilaianStreamSubscription = FirebaseFirestore.instance
        .collection('nilaiAkhir')
        .snapshots()
        .listen((snapshot) async {
      List<PenilaianAkhir> penilaianList = [];

      try {
        for (var document in snapshot.docs) {
          var data = document.data();
          var modul1 = (data['modul1'] ?? 0).toDouble();
          var modul2 = (data['modul2'] ?? 0).toDouble();
          var nilaiAkhir = (modul1 + modul2) / 2; // Hitung nilaiAkhir

          var penilaian = PenilaianAkhir(
              nim: data['nim'] ?? 0,
              nama: data['nama'] ?? '',
              kode: data['kodeKelas'] ?? '',
              modul1: modul1,
              modul2: modul2,
              pretest: (data['pretest'] ?? 0).toDouble(),
              project: (data['projectAkhir'] ?? 0).toDouble(),
              resmi: (data['laporanResmi'] ?? 0).toDouble(),
              akhir: nilaiAkhir,
              huruf: data['nilaiHuruf'] ?? '',
              status: data['status'] ?? '');

          penilaianList.add(penilaian);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
      }

      setState(() {
        _penilaianList = penilaianList;
      });
    });
  }

  @override
  void dispose() {
    _penilaianStreamSubscription.cancel();
    _nilaiHarianStreamSubscription.cancel(); // Tambahkan ini
    super.dispose();
  }

  void _updatePretest(double newPretest, double newProject, double newResmi,
      String kodeKelas, int nim) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('nilaiAkhir')
          .where('kodeKelas', isEqualTo: kodeKelas)
          .where('nim', isEqualTo: nim)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs.first;
        var data = documentSnapshot.data();

        // Check if nilai harian exists
        if (data.containsKey('pretest')) {
          var penilaian = PenilaianAkhir(
            nim: nim,
            nama: data['nama'] ?? '',
            kode: kodeKelas,
            modul1: (data['modul1'] ?? 0).toDouble(),
            modul2: (data['modul2'] ?? 0).toDouble(),
            pretest: newPretest,
            project: newProject,
            resmi: newResmi,
            akhir: calculateNilaiAkhir(
                (data['modul1'] ?? 0).toDouble(),
                (data['modul2'] ?? 0).toDouble(),
                newPretest,
                newProject,
                newResmi),
            huruf: data['nilaiHuruf'] ?? '',
            status: data['status'] ?? '',
          );

          var hasil = calculateHuruf(penilaian.modul1, penilaian.modul2,
              penilaian.pretest, penilaian.project, penilaian.resmi);
          penilaian.huruf = hasil['nilaiHuruf']!;
          penilaian.status = hasil['status']!;

          await documentSnapshot.reference.update({
            'nim': penilaian.nim,
            'nama': penilaian.nama,
            'kodeKelas': penilaian.kode,
            'modul1': penilaian.modul1,
            'modul2': penilaian.modul2,
            'pretest': penilaian.pretest,
            'projectAkhir': penilaian.project,
            'laporanResmi': penilaian.resmi,
            'nilaiAkhir': penilaian.akhir,
            'nilaiHuruf': penilaian.huruf,
            'status': penilaian.status,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating pretest: $e');
      }
    }
  }

  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NilaiPercobaanDosen(
                      kodeKelas: widget.kodeKelas,
                      matkul: widget.matkul,
                    )));
      } else if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NilaiAkhirDosen(
                      kodeKelas: widget.kodeKelas,
                      matkul: widget.matkul,
                    )));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Nilai Harian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Nilai Akhir',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3CBEA9),
        onTap: _onItemTapped,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HasilStudiDosenNav()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.matkul,
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE3E8EF),
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 45.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 20.0, color: Colors.white)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 25.0, bottom: 20.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 30.0,
                                left: 8.0), // Ubah left menjadi 8.0
                            child: Row(
                              children: [
                                const Text(
                                  'Search :',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
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
                                      style:
                                          const TextStyle(color: Colors.black),
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.grey),
                                      iconSize: 24,
                                      elevation: 16,
                                      value: selectedKeterangan,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedKeterangan = newValue!;
                                        });
                                      },
                                      underline: Container(),
                                      items: <String>[
                                        'Tampilkan Semua',
                                        'Lulus',
                                        'Tidak Lulus'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
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
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.075, color: Colors.grey),
                                borderRadius: BorderRadius.circular(7.0)),
                            child: SingleChildScrollView(
                              controller: _controller,
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 10,
                                columns: const [
                                  DataColumn(
                                    label: Text('NIM',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Nama',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Pre-Test',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Modul 1',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Modul 2',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Project Akhir',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Laporan Resmi',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Nilai Akhir',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Nilai Huruf',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Status',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Aksi',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                rows: _penilaianList
                                    .where((penilaian) =>
                                        selectedKeterangan ==
                                            'Tampilkan Semua' ||
                                        penilaian.status ==
                                            (selectedKeterangan == 'Lulus'
                                                ? 'Lulus'
                                                : 'Tidak Lulus'))
                                    .map((penilaian) {
                                  int index = _penilaianList.indexOf(penilaian);
                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith<
                                        Color>(
                                      (Set<MaterialState> states) {
                                        return getRowColor(index);
                                      },
                                    ),
                                    cells: [
                                      DataCell(SizedBox(
                                        width: 100.0,
                                        child: Text(penilaian.nim.toString()),
                                      )),
                                      DataCell(SizedBox(
                                        width: 180.0,
                                        child: Text(penilaian.nama),
                                      )),
                                      DataCell(SizedBox(
                                        width: 80.0,
                                        child: Text(getLimitedText(
                                            penilaian.pretest.toString(), 5)),
                                      )),
                                      DataCell(SizedBox(
                                        width: 80.0,
                                        child: Text(getLimitedText(
                                            penilaian.modul1.toString(), 5)),
                                      )),
                                      DataCell(SizedBox(
                                        width: 80.0,
                                        child: Text(getLimitedText(
                                            penilaian.modul2.toString(), 5)),
                                      )),
                                      DataCell(SizedBox(
                                        width: 120.0,
                                        child: Text(getLimitedText(
                                            penilaian.project.toString(), 5)),
                                      )),
                                      DataCell(SizedBox(
                                        width: 120.0,
                                        child: Text(getLimitedText(
                                            penilaian.resmi.toString(), 5)),
                                      )),
                                      DataCell(SizedBox(
                                        width: 120.0,
                                        child: Text(getLimitedText(
                                            penilaian.akhir.toString(), 5)),
                                      )),
                                      DataCell(SizedBox(
                                        width: 100.0,
                                        child: Text(penilaian.huruf),
                                      )),
                                      DataCell(SizedBox(
                                        width: 150.0,
                                        child: Text(penilaian.status),
                                      )),
                                      DataCell(IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Formulir Nilai Akhir'),
                                                content: SizedBox(
                                                  height: 160.0,
                                                  width: 140.0,
                                                  child: Column(
                                                    children: [
                                                      //== PreTest ==//

                                                      TextField(
                                                        controller:
                                                            pretestController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Pretest'),
                                                      ),
                                                      //== Projek Akhir ==//

                                                      TextField(
                                                        controller:
                                                            projectAkhirController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Project Akhir'),
                                                      ),
                                                      //== Laporan Resmi ==//

                                                      TextField(
                                                        controller:
                                                            laporanResmiController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Laporan Resmi'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      //== SIMPAN ==//
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 8.0),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            if (pretestController.text.isNotEmpty &&
                                                                projectAkhirController
                                                                    .text
                                                                    .isNotEmpty &&
                                                                laporanResmiController
                                                                    .text
                                                                    .isNotEmpty) {
                                                              double
                                                                  newPretest =
                                                                  double.tryParse(
                                                                          pretestController
                                                                              .text) ??
                                                                      0.0;
                                                              double
                                                                  newProject =
                                                                  double.tryParse(
                                                                          projectAkhirController
                                                                              .text) ??
                                                                      0.0;
                                                              double newResmi =
                                                                  double.tryParse(
                                                                          laporanResmiController
                                                                              .text) ??
                                                                      0.0;

                                                              _updatePretest(
                                                                  newPretest,
                                                                  newProject,
                                                                  newResmi,
                                                                  widget
                                                                      .kodeKelas,
                                                                  penilaian
                                                                      .nim);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            } else {
                                                              if (kDebugMode) {
                                                                print(
                                                                    'Pretest value is empty');
                                                              }
                                                            }
                                                          },
                                                          child: const Text(
                                                              'Simpan'),
                                                        ),
                                                      ),
                                                      //== Batal ==//
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 8.0),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Batal'),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.add_box),
                                        tooltip: 'Tambah Nilai',
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 359.0,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 35.0,
            height: 35.0,
            child: FloatingActionButton(
              onPressed: () {
                _controller.animateTo(
                  _controller.offset - 200,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: const Color(0xFF3CBEA9),
              child: const Icon(Icons.arrow_back),
            ),
          ),
          const SizedBox(width: 16), // Spacer between buttons
          SizedBox(
            width: 35.0,
            height: 35.0,
            child: FloatingActionButton(
              onPressed: () {
                _controller.animateTo(
                  _controller.offset + 200,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: const Color(0xFF3CBEA9),
              child: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> calculateHuruf(double modul1, double modul2,
      double pretest, double resmi, double project) {
    double rataRata = (modul1 + modul2 + pretest + resmi + project) / 5;
    String nilaiHuruf;
    String status;

    if (rataRata >= 80) {
      nilaiHuruf = 'A';
      status = 'Lulus';
    } else if (rataRata >= 70) {
      nilaiHuruf = 'B';
      status = 'Lulus';
    } else if (rataRata >= 60) {
      nilaiHuruf = 'C';
      status = 'Lulus';
    } else if (rataRata >= 50) {
      nilaiHuruf = 'D';
      status = 'Tidak Lulus';
    } else {
      nilaiHuruf = 'E';
      status = 'Tidak Lulus';
    }

    return {'nilaiHuruf': nilaiHuruf, 'status': status};
  }

  double calculateNilaiAkhir(double modul1, double modul2, double pretest,
      double project, double resmi) {
    return (modul1 + modul2 + pretest + resmi + project) / 5;
  }
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.withOpacity(0.3) : Colors.white;
}

class PenilaianAkhir {
  final int nim;
  final String nama;
  final String kode;
  final double modul1;
  final double modul2;
  final double pretest;
  final double project;
  final double resmi;
  double akhir;
  String huruf;
  String status;

  PenilaianAkhir(
      {required this.nim,
      required this.nama,
      required this.kode,
      required this.modul1,
      required this.modul2,
      required this.pretest,
      required this.project,
      required this.resmi,
      this.akhir = 0.0,
      this.huruf = '',
      this.status = ''});
}
