import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  final String kodeKelas;

  const MyHomePage({Key? key, required this.kodeKelas}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _controller = ScrollController();

  String selectedKeterangan = 'Tampilkan Semua';
  late Stream<List<PenilaianAkhir>> penilaianStream = Stream.value([]);

  List<PenilaianAkhir> demoPenilaianAkhir = [];
  List<PenilaianAkhir> filteredPenilaianAkhir = [];

  @override
  void initState() {
    super.initState();
    checkAndFetchData();
  }

  Future<void> checkAndFetchData() async {
    try {
      final nilaiAkhirSnapshots = await FirebaseFirestore.instance
          .collection('nilaiAkhir')
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .get();

      if (nilaiAkhirSnapshots.docs.isNotEmpty) {
        final List<PenilaianAkhir> data = nilaiAkhirSnapshots.docs.map((doc) {
          final data = doc.data();
          final nilaiAkhirData = calculateHuruf(
            data['modul1'] ?? 0.0,
            data['modul2'] ?? 0.0,
            data['pretest'] ?? 0.0,
          );
          return PenilaianAkhir(
            nim: data['nim'] ?? '',
            nama: data['nama'] ?? '',
            kode: widget.kodeKelas,
            modul1: data['modul1'] ?? 0.0,
            modul2: data['modul2'] ?? 0.0,
            pretest: data['pretest'] ?? 0.0,
            akhir: calculateNilaiAkhir(
              data['modul1'] ?? 0.0,
              data['modul2'] ?? 0.0,
              data['pretest'] ?? 0.0,
            ),
            huruf: nilaiAkhirData['huruf'] ?? '',
            status: nilaiAkhirData['status'] ?? '',
          );
        }).toList();

        setState(() {
          penilaianStream = Stream.value(data);
        });
      } else {
        await addDataFromNilaiHarian();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> addDataFromNilaiHarian() async {
    final nilaiHarianSnapshot = await FirebaseFirestore.instance
        .collection('nilaiHarian')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    if (nilaiHarianSnapshot.docs.isNotEmpty) {
      // Ambil data dari nilaiHarian dan tambahkan ke nilaiAkhir
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in nilaiHarianSnapshot.docs) {
        final data = doc.data();
        final nilaiAkhirData = calculateHuruf(
          data['modul1'] ?? 0.0,
          data['modul2'] ?? 0.0,
          data['pretest'] ?? 0.0,
        );
        final nilaiAkhir = calculateNilaiAkhir(
          data['modul1'] ?? 0.0,
          data['modul2'] ?? 0.0,
          data['pretest'] ?? 0.0,
        );
        final penilaianAkhirRef =
            FirebaseFirestore.instance.collection('nilaiAkhir').doc();
        batch.set(penilaianAkhirRef, {
          'nim': data['nim'] ?? 0,
          'nama': data['nama'] ?? '',
          'kodeKelas': widget.kodeKelas,
          'modul1': data['modul1'] ?? 0.0,
          'modul2': data['modul2'] ?? 0.0,
          'pretest': data['pretest'] ?? 0.0,
          'status': nilaiAkhirData['status'] ?? '',
          'nilaiAkhir': nilaiAkhir,
          'huruf': nilaiAkhirData['huruf'] ?? '',
        });
      }

      await batch.commit();
    }
  }

  Future<void> getDataFromFirebase() async {
    try {
      penilaianStream = FirebaseFirestore.instance
          .collection('nilaiHarian')
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                final nilaiAkhirData = calculateHuruf(data['modul1'] ?? 0.0,
                    data['modul2'] ?? 0.0, data['pretest'] ?? 0.0);
                return PenilaianAkhir(
                  nim: data['nim'] ?? 0,
                  nama: data['nama'] ?? '',
                  kode: widget.kodeKelas,
                  modul1: data['modul1'] ?? 0.0,
                  modul2: data['modul2'] ?? 0.0,
                  pretest: data['pretest'] ?? 0.0,
                  akhir: calculateNilaiAkhir(data['modul1'] ?? 0.0,
                      data['modul2'] ?? 0.0, data['pretest'] ?? 0.0),
                  huruf: nilaiAkhirData['huruf'] ?? '',
                  status: nilaiAkhirData['status'] ?? '',
                );
              }).toList());
    } catch (e) {
      if (kDebugMode) {
        print('Error:$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
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
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    'Penilaian Praktikum',
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
                                top: 8.0, bottom: 30.0, left: 880.0),
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
                              child: StreamBuilder<List<PenilaianAkhir>>(
                                stream: penilaianStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (!snapshot.hasData) {
                                    return const Text('No data available');
                                  }

                                  // Filter data berdasarkan nilai yang dipilih
                                  List<PenilaianAkhir> filteredData =
                                      snapshot.data!;
                                  if (selectedKeterangan != 'Tampilkan Semua') {
                                    filteredData = filteredData.where((data) {
                                      if (selectedKeterangan == 'Lulus') {
                                        return data.status == 'Lulus';
                                      } else {
                                        return data.status == 'Tidak Lulus';
                                      }
                                    }).toList();
                                  }

                                  return DataTable(
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
                                        label: Text('Aksi',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    rows: filteredData.isEmpty
                                        ? [
                                            DataRow(
                                              color: MaterialStateColor.resolveWith(
                                                  (states) => getRowColor(
                                                      0)), // Menggunakan nilai default 0
                                              cells: const [
                                                DataCell(SizedBox(
                                                  width: 150.0,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                                DataCell(SizedBox(
                                                  width: 200.0,
                                                  child: Text(
                                                      'No data Available',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                                DataCell(SizedBox(
                                                  width: 100.0,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                                DataCell(SizedBox(
                                                  width: 100.0,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                                DataCell(SizedBox(
                                                  width: 100.0,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                                DataCell(SizedBox(
                                                  width: 100.0,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                                DataCell(SizedBox(
                                                  width: 100.0,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                                DataCell(SizedBox(
                                                  width: 80.0,
                                                  child: Text('',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                              ],
                                            )
                                          ]
                                        : filteredData.asMap().entries.map(
                                            (entry) {
                                              int index = entry.key;
                                              PenilaianAkhir data = entry.value;
                                              return DataRow(
                                                color: MaterialStateColor
                                                    .resolveWith((states) =>
                                                        getRowColor(index)),
                                                cells: [
                                                  DataCell(SizedBox(
                                                      width: 150.0,
                                                      child: Text(data.nim
                                                          .toString()))),
                                                  DataCell(SizedBox(
                                                      width: 200.0,
                                                      child: Text(data.nama))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.pretest
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.modul1
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.modul2
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.akhir
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 80.0,
                                                      child: Text(data.huruf))),
                                                  DataCell(SizedBox(
                                                    child: IconButton(
                                                      onPressed: () {
                                                        editNilai(data);
                                                      },
                                                      icon: const Icon(
                                                          Icons.add_box,
                                                          color: Colors.grey),
                                                    ),
                                                  ))
                                                ],
                                              );
                                            },
                                          ).toList(),
                                  );
                                },
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
              )
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
              child: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }

  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.withOpacity(0.3) : Colors.white;
  }

  String getLimitedText(String text, int limit) {
    return text.length <= limit ? text : text.substring(0, limit);
  }

  void editNilai(PenilaianAkhir nilai) {
    TextEditingController pretestController =
        TextEditingController(text: nilai.pretest.toString());
    TextEditingController modul1Controller =
        TextEditingController(text: nilai.modul1.toString());
    TextEditingController modul2Controller =
        TextEditingController(text: nilai.modul2.toString());

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
            width: 600.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //=== Pretest, Modul 1, Modul 2 dan Modul 3
//== Pre-Test
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                      child: SizedBox(
                        width: 130.0,
                        child: TextField(
                          controller: pretestController,
                          onChanged: (value) {
                            nilai.pretest = double.parse(value);
                          },
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Pre-Test'),
                        ),
                      ),
                    ),
                    //== Modul 1
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                      child: SizedBox(
                        width: 130.0,
                        child: TextField(
                          controller: modul1Controller,
                          onChanged: (value) {
                            nilai.modul1 = double.parse(value);
                          },
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Modul 1'),
                        ),
                      ),
                    ),
                    //== Modul 2
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                      child: SizedBox(
                        width: 130.0,
                        child: TextField(
                          controller: modul2Controller,
                          onChanged: (value) {
                            nilai.modul2 = double.parse(value);
                          },
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Modul 2'),
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
                  try {
                    String? namaAsisten = await getNamaAsisten();
                    final nilaiAkhirData = calculateHuruf(
                        nilai.modul1,
                        nilai.modul2,
                        nilai.pretest); // Hitung kembali huruf dan status

                    QuerySnapshot<Map<String, dynamic>> querySnapshot =
                        await FirebaseFirestore.instance
                            .collection('nilaiAkhir')
                            .where('nim', isEqualTo: nilai.nim)
                            .where('nama', isEqualTo: nilai.nama)
                            .where('kodeKelas', isEqualTo: widget.kodeKelas)
                            .get();

                    if (querySnapshot.docs.isEmpty) {
                      await FirebaseFirestore.instance
                          .collection('nilaiAkhir')
                          .add({
                        'nim': nilai.nim,
                        'nama': nilai.nama,
                        'kodeKelas': widget.kodeKelas,
                        'modul1': nilai.modul1,
                        'modul2': nilai.modul2,
                        'pretest': nilai.pretest,
                        'status': nilaiAkhirData[
                            'status'], // Gunakan nilai status yang baru
                        'huruf': nilaiAkhirData[
                            'huruf'], // Gunakan nilai huruf yang baru
                        'namaAsisten': namaAsisten ?? "",
                      });
                    } else {
                      await querySnapshot.docs[0].reference.update({
                        'modul1': nilai.modul1,
                        'modul2': nilai.modul2,
                        'pretest': nilai.pretest,
                        'status': nilaiAkhirData[
                            'status'], // Gunakan nilai status yang baru
                        'huruf': nilaiAkhirData[
                            'huruf'], // Gunakan nilai huruf yang baru
                        'namaAsisten': namaAsisten ?? "",
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

                    await getDataFromFirebase();

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
      },
    );
  }

  Future<String?> getNamaAsisten() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('akun_mahasiswa')
          .doc(uid)
          .get();
      if (snapshot.exists) {
        String? namaAsisten = snapshot.data()?['nama'];
        return namaAsisten;
      }
    }
    return null;
  }

  double calculateNilaiAkhir(double modul1, double modul2, double pretest) {
    return ((modul1 * 0.3) + (modul2 * 0.3) + (pretest * 0.4));
  }

  Map<String, String> calculateHuruf(
      double modul1, double modul2, double pretest) {
    double nilaiAkhir = calculateNilaiAkhir(modul1, modul2, pretest);
    String huruf;
    String status;
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

    return {'huruf': huruf, 'status': status};
  }
}

class PenilaianAkhir {
  final int nim;
  final String nama;
  final String kode;
  double modul1;
  double modul2;
  double pretest;
  late double akhir;
  late String status;
  late String huruf;

  PenilaianAkhir({
    required this.nim,
    required this.nama,
    required this.kode,
    required this.modul1,
    required this.modul2,
    this.pretest = 0.0,
    this.akhir = 0.0,
    this.status = '',
    this.huruf = '',
  });
}
