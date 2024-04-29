import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PenilaianPercobaanAdmin extends StatefulWidget {
  final String kodeKelas;

  const PenilaianPercobaanAdmin({
    Key? key,
    required this.kodeKelas,
  }) : super(key: key);

  @override
  State<PenilaianPercobaanAdmin> createState() =>
      _PenilaianPercobaanAdminState();
}

class _PenilaianPercobaanAdminState extends State<PenilaianPercobaanAdmin> {
  List<PenilaianPercobaan> demoPenilaianPercobaan = [];
  List<PenilaianPercobaan> filteredPenilaianPercobaan = [];

  @override
  void initState() {
    super.initState();
    checkAndFetchData();
  }

  Future<void> checkAndFetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tokenKelas')
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      // ignore: avoid_function_literals_in_foreach_calls
      querySnapshot.docs.forEach((doc) async {
        PenilaianPercobaan data = PenilaianPercobaan(
          nama: doc['nama'] ?? '',
          nim: doc['nim'] ?? 0,
          kode: doc['kodeKelas'] ?? '',
        );

        // Check if data exists in 'nilaiHarian'
        QuerySnapshot<Map<String, dynamic>> nilaiSnapshot =
            await FirebaseFirestore.instance
                .collection('nilaiHarian')
                .where('nim', isEqualTo: data.nim)
                .where('kodeKelas', isEqualTo: widget.kodeKelas)
                .get();

        if (nilaiSnapshot.docs.isEmpty) {
          // Data doesn't exist, add it to 'nilaiHarian'
          await FirebaseFirestore.instance.collection('nilaiHarian').add({
            'nama': data.nama,
            'nim': data.nim,
            'kodeKelas': data.kode,
            //== Nilai Rata-Rata ==
            'modul1': 0.0,
            'modul2': 0.0,
            'modul3': 0.0,
            'modul4': 0.0,
            'modul5': 0.0,
            //== Laporan ==
            'laporan1': 0.0,
            'laporan2': 0.0,
            'laporan3': 0.0,
            'laporan4': 0.0,
            'laporan5': 0.0,
            //== Afektif ===
            'afektif1': 0.0,
            'afektif2': 0.0,
            'afektif3': 0.0,
            'afektif4': 0.0,
            'afektif5': 0.0,
            //== Tugas ===
            'tugas1': 0.0,
            'tugas2': 0.0,
            'tugas3': 0.0,
            'tugas4': 0.0,
            'tugas5': 0.0,
            //== Latihan ==
            'latihan1': 0.0,
            'latihan2': 0.0,
            'latihan3': 0.0,
            'latihan4': 0.0,
            'latihan5': 0.0,
          });
        }
      });

      // Call getDataFromFirebase to fetch data from 'nilaiHarian' after adding new data if needed
      await getDataFromFirebase();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> getDataFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('nilaiHarian')
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      setState(() {
        demoPenilaianPercobaan = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return PenilaianPercobaan(
            nim: data['nim'] ?? 0,
            nama: data['nama'] ?? '',
            kode: data['kodeKelas'] ?? '',
            rata1: data['modul1'] ?? 0.0,
            rata2: data['modul2'] ?? 0.0,
            rata3: data['modul3'] ?? 0.0,
            rata4: data['modul4'] ?? 0.0,
            rata5: data['modul5'] ?? 0.0,
          );
        }).toList();

        filteredPenilaianPercobaan = List.from(demoPenilaianPercobaan);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

//==Show Dialog ==
  void editNilai(PenilaianPercobaan nilai) async {
    try {
      // Mengambil data dari database berdasarkan nim
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('nilaiHarian')
              .where('nim', isEqualTo: nilai.nim)
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      // Jika data ditemukan, isi nilai-nilai default
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = querySnapshot.docs[0].data();
        //
        //== Modul 1 ==
        nilai.latihan1 = data['latihan1'] ?? 0.0;
        nilai.tugas1 = data['tugas1'] ?? 0.0;
        nilai.afektif1 = data['afektif1'] ?? 0.0;
        nilai.laporan1 = data['laporan1'] ?? 0.0;
        nilai.rata1 = data['modul1'] ?? 0.0;
        //
        //== Modul 2 ==
        nilai.latihan2 = data['latihan2'] ?? 0.0;
        nilai.tugas2 = data['tugas2'] ?? 0.0;
        nilai.afektif2 = data['afektif2'] ?? 0.0;
        nilai.laporan2 = data['laporan2'] ?? 0.0;
        nilai.rata2 = data['modul2'] ?? 0.0;
        //
        //== Modul 3 ==
        nilai.latihan3 = data['latihan3'] ?? 0.0;
        nilai.tugas3 = data['tugas3'] ?? 0.0;
        nilai.afektif3 = data['afektif3'] ?? 0.0;
        nilai.laporan3 = data['laporan3'] ?? 0.0;
        nilai.rata3 = data['modul3'] ?? 0.0;
        //
        //== Modul 4 ==
        nilai.latihan4 = data['latihan4'] ?? 0.0;
        nilai.tugas4 = data['tugas4'] ?? 0.0;
        nilai.afektif4 = data['afektif4'] ?? 0.0;
        nilai.laporan4 = data['laporan4'] ?? 0.0;
        nilai.rata4 = data['modul4'] ?? 0.0;
        //
        //== Modul 5 ==
        nilai.latihan5 = data['latihan5'] ?? 0.0;
        nilai.tugas5 = data['tugas5'] ?? 0.0;
        nilai.afektif5 = data['afektif5'] ?? 0.0;
        nilai.laporan5 = data['laporan5'] ?? 0.0;
        nilai.rata5 = data['modul5'] ?? 0.0;
      }
    } catch (e) {
      // Handle errors if any
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
    //== Modul 1 ==
    TextEditingController latihan1Controller =
        TextEditingController(text: nilai.latihan1.toString());
    TextEditingController tugas1Controller =
        TextEditingController(text: nilai.tugas1.toString());
    TextEditingController afektif1Controller =
        TextEditingController(text: nilai.afektif1.toString());
    TextEditingController laporan1Controller =
        TextEditingController(text: nilai.laporan1.toString());
    TextEditingController rata1Controller =
        TextEditingController(text: nilai.rata1.toString());
    //
    //== Modul 2 ==
    TextEditingController latihan2Controller =
        TextEditingController(text: nilai.latihan2.toString());
    TextEditingController tugas2Controller =
        TextEditingController(text: nilai.tugas2.toString());
    TextEditingController afektif2Controller =
        TextEditingController(text: nilai.afektif2.toString());
    TextEditingController laporan2Controller =
        TextEditingController(text: nilai.laporan2.toString());
    TextEditingController rata2Controller =
        TextEditingController(text: nilai.rata2.toString());
    //
    //== Modul 3 ==
    TextEditingController latihan3Controller =
        TextEditingController(text: nilai.latihan3.toString());
    TextEditingController tugas3Controller =
        TextEditingController(text: nilai.tugas3.toString());
    TextEditingController afektif3Controller =
        TextEditingController(text: nilai.afektif3.toString());
    TextEditingController laporan3Controller =
        TextEditingController(text: nilai.laporan3.toString());
    TextEditingController rata3Controller =
        TextEditingController(text: nilai.rata3.toString());
    //
    //== Modul 4 ==
    TextEditingController latihan4Controller =
        TextEditingController(text: nilai.latihan4.toString());
    TextEditingController tugas4Controller =
        TextEditingController(text: nilai.tugas4.toString());
    TextEditingController afektif4Controller =
        TextEditingController(text: nilai.afektif4.toString());
    TextEditingController laporan4Controller =
        TextEditingController(text: nilai.laporan4.toString());
    TextEditingController rata4Controller =
        TextEditingController(text: nilai.rata4.toString());
    //
    //== Modul 5 ==
    TextEditingController latihan5Controller =
        TextEditingController(text: nilai.latihan5.toString());
    TextEditingController tugas5Controller =
        TextEditingController(text: nilai.tugas5.toString());
    TextEditingController afektif5Controller =
        TextEditingController(text: nilai.afektif5.toString());
    TextEditingController laporan5Controller =
        TextEditingController(text: nilai.laporan5.toString());
    TextEditingController rata5Controller =
        TextEditingController(text: nilai.rata5.toString());

    //==
    // ignore: use_build_context_synchronously
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
                  'Formulir Nilai Harian',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                child: Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          content: SizedBox(
            height: 320.0,
            width: 800.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //== Modul 1 ==
                Row(
                  children: [
                    //== Nama Modul ==
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0, left: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Modul 1',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // == Latihan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: latihan1Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.latihan1 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata1 = _hitungRataRata1(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata1 = newRata1;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata1Controller.text = newRata1.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Latihan'),
                        ),
                      ),
                    ),
                    // == Tugas ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: tugas1Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.tugas1 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata1 = _hitungRataRata1(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata1 = newRata1;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata1Controller.text = newRata1.toString();
                              }
                            });
                          },
                          decoration: const InputDecoration(hintText: 'Tugas'),
                        ),
                      ),
                    ),
                    // == Afektif ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: afektif1Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.afektif1 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata1 = _hitungRataRata1(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata1 = newRata1;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata1Controller.text = newRata1.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Afektif'),
                        ),
                      ),
                    ),
                    // == Laporan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: laporan1Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.laporan1 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata1 = _hitungRataRata1(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata1 = newRata1;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata1Controller.text = newRata1.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Laporan'),
                        ),
                      ),
                    ),
                    // == Rata - rata ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: rata1Controller,
                          readOnly: true,
                          decoration:
                              const InputDecoration(hintText: 'Rata-Rata'),
                        ),
                      ),
                    ),
                  ],
                ),
                // == Modul 2 ==
                Row(
                  children: [
                    //== Nama Modul ==
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0, left: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Modul 2',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // == Latihan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: latihan2Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.latihan2 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata2 = _hitungRataRata2(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata2 = newRata2;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata2Controller.text = newRata2.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Latihan'),
                        ),
                      ),
                    ),
                    // == Tugas ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: tugas2Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.tugas2 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata2 = _hitungRataRata2(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata2 = newRata2;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata2Controller.text = newRata2.toString();
                              }
                            });
                          },
                          decoration: const InputDecoration(hintText: 'Tugas'),
                        ),
                      ),
                    ),
                    // == Afektif ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: afektif2Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.afektif2 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata2 = _hitungRataRata2(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata2 = newRata2;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata2Controller.text = newRata2.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Afektif'),
                        ),
                      ),
                    ),
                    // == Laporan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: laporan2Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.laporan2 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata2 = _hitungRataRata2(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata2 = newRata2;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata2Controller.text = newRata2.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Laporan'),
                        ),
                      ),
                    ),
                    // == Rata - rata ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: rata2Controller,
                          readOnly: true,
                          decoration:
                              const InputDecoration(hintText: 'Rata-Rata'),
                        ),
                      ),
                    ),
                  ],
                ),
                // == Modul 3 ==
                Row(
                  children: [
                    //== Nama Modul ==
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0, left: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Modul 3',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // == Latihan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: latihan3Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.latihan3 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata3 = _hitungRataRata3(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata3 = newRata3;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata3Controller.text = newRata3.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Latihan'),
                        ),
                      ),
                    ),
                    // == Tugas ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: tugas3Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.tugas3 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata3 = _hitungRataRata3(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata3 = newRata3;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata3Controller.text = newRata3.toString();
                              }
                            });
                          },
                          decoration: const InputDecoration(hintText: 'Tugas'),
                        ),
                      ),
                    ),
                    // == Afektif ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: afektif3Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.afektif3 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata3 = _hitungRataRata2(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata3 = newRata3;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata3Controller.text = newRata3.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Afektif'),
                        ),
                      ),
                    ),
                    // == Laporan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: laporan3Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.laporan3 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata3 = _hitungRataRata3(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata3 = newRata3;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata3Controller.text = newRata3.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Laporan'),
                        ),
                      ),
                    ),
                    // == Rata - rata ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: rata3Controller,
                          readOnly: true,
                          decoration:
                              const InputDecoration(hintText: 'Rata-Rata'),
                        ),
                      ),
                    ),
                  ],
                ),
                // == Modul 4 ==
                Row(
                  children: [
                    //== Nama Modul ==
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0, left: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Modul 3',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // == Latihan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: latihan4Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.latihan4 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata4 = _hitungRataRata4(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata4 = newRata4;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata4Controller.text = newRata4.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Latihan'),
                        ),
                      ),
                    ),
                    // == Tugas ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: tugas4Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.tugas4 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata4 = _hitungRataRata4(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata4 = newRata4;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata4Controller.text = newRata4.toString();
                              }
                            });
                          },
                          decoration: const InputDecoration(hintText: 'Tugas'),
                        ),
                      ),
                    ),
                    // == Afektif ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: afektif4Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.afektif4 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata4 = _hitungRataRata4(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata4 = newRata4;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata4Controller.text = newRata4.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Afektif'),
                        ),
                      ),
                    ),
                    // == Laporan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: laporan4Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.laporan4 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata4 = _hitungRataRata4(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata4 = newRata4;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata4Controller.text = newRata4.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Laporan'),
                        ),
                      ),
                    ),
                    // == Rata - rata ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: rata4Controller,
                          readOnly: true,
                          decoration:
                              const InputDecoration(hintText: 'Rata-Rata'),
                        ),
                      ),
                    ),
                  ],
                ),
                // == Modul 5 ==
                Row(
                  children: [
                    //== Nama Modul ==
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0, left: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Modul 3',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // == Latihan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: latihan5Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.latihan5 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata5 = _hitungRataRata5(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata5 = newRata5;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata5Controller.text = newRata5.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Latihan'),
                        ),
                      ),
                    ),
                    // == Tugas ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: tugas5Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.tugas5 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata5 = _hitungRataRata5(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata5 = newRata5;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata5Controller.text = newRata5.toString();
                              }
                            });
                          },
                          decoration: const InputDecoration(hintText: 'Tugas'),
                        ),
                      ),
                    ),
                    // == Afektif ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: afektif5Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.afektif5 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata5 = _hitungRataRata5(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata5 = newRata5;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata5Controller.text = newRata5.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Afektif'),
                        ),
                      ),
                    ),
                    // == Laporan ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: laporan5Controller,
                          onChanged: (newValue) {
                            setState(() {
                              double? parsedValue = double.tryParse(newValue);
                              if (parsedValue != null) {
                                // Perbarui nilai dalam objek PenilaianPercobaan
                                nilai.laporan5 = parsedValue;

                                // Hitung ulang nilai rata-rata
                                double newRata5 = _hitungRataRata5(nilai);

                                // Perbarui nilai rata1 dalam objek PenilaianPercobaan
                                nilai.rata5 = newRata5;

                                // Perbarui nilai dalam TextField rata1Controller untuk menampilkan hasil perhitungan yang baru
                                rata5Controller.text = newRata5.toString();
                              }
                            });
                          },
                          decoration:
                              const InputDecoration(hintText: 'Laporan'),
                        ),
                      ),
                    ),
                    // == Rata - rata ==
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 40.0),
                      child: SizedBox(
                        width: 95.0,
                        child: TextField(
                          controller: rata5Controller,
                          readOnly: true,
                          decoration:
                              const InputDecoration(hintText: 'Rata-Rata'),
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
                    // Check if data already exists
                    QuerySnapshot<Map<String, dynamic>> querySnapshot =
                        await FirebaseFirestore.instance
                            .collection('nilaiHarian')
                            .where('nim', isEqualTo: nilai.nim)
                            .where('kodeKelas', isEqualTo: widget.kodeKelas)
                            .get();

// If data does not exist, add it
                    if (querySnapshot.docs.isEmpty) {
                      await FirebaseFirestore.instance
                          .collection('nilaiHarian')
                          .add({
                        'nim': nilai.nim,
                        'kodeKelas': widget.kodeKelas,
                        //== Modul 1 ==
                        'latihan1': nilai.latihan1,
                        'tugas1': nilai.tugas1,
                        'afektif1': nilai.afektif1,
                        'laporan1': nilai.laporan1,
                        'modul1': nilai.rata1,
                        //
                        //== Modul 2 ==
                        'latihan2': nilai.latihan2,
                        'tugas2': nilai.tugas2,
                        'afektif2': nilai.afektif2,
                        'laporan2': nilai.laporan2,
                        'modul2': nilai.rata2,
                        //== Modul 3 ==
                        'latihan3': nilai.latihan3,
                        'tugas3': nilai.tugas3,
                        'afektif3': nilai.afektif3,
                        'laporan3': nilai.laporan3,
                        'modul3': nilai.rata3,
                        //
                        //== Modul 4 ==
                        'latihan4': nilai.latihan4,
                        'tugas4': nilai.tugas4,
                        'afektif4': nilai.afektif4,
                        'laporan4': nilai.laporan4,
                        'modul4': nilai.rata4,
                        //
                        //== Modul 5 ==
                        'latihan5': nilai.latihan5,
                        'tugas5': nilai.tugas5,
                        'afektif5': nilai.afektif5,
                        'laporan5': nilai.laporan5,
                        'modul5': nilai.rata5,
                      });
                    } else {
                      // If data exists, update it
                      await querySnapshot.docs[0].reference.update({
                        //== Modul 1 ===
                        'latihan1': nilai.latihan1,
                        'tugas1': nilai.tugas1,
                        'afektif1': nilai.afektif1,
                        'laporan1': nilai.laporan1,
                        'modul1': nilai.rata1,
                        //
                        //== Modul 2 ==
                        'latihan2': nilai.latihan2,
                        'tugas2': nilai.tugas2,
                        'afektif2': nilai.afektif2,
                        'laporan2': nilai.laporan2,
                        'modul2': nilai.rata2,
                        //
                        //== Modul 3 ===
                        'latihan3': nilai.latihan3,
                        'tugas3': nilai.tugas3,
                        'afektif3': nilai.afektif3,
                        'laporan3': nilai.laporan3,
                        'modul3': nilai.rata3,
                        //
                        //== Modul 4 ==
                        'latihan4': nilai.latihan4,
                        'tugas4': nilai.tugas4,
                        'afektif4': nilai.afektif4,
                        'laporan4': nilai.laporan4,
                        'modul4': nilai.rata4,
                        //
                        //== Modul 5 ==
                        'latihan5': nilai.latihan5,
                        'tugas5': nilai.tugas5,
                        'afektif5': nilai.afektif5,
                        'laporan5': nilai.laporan5,
                        'modul5': nilai.rata5,
                      });
                    }

                    // Update UI
                    setState(() {
                      // Update the value in state
                      demoPenilaianPercobaan =
                          demoPenilaianPercobaan.map((item) {
                        if (item.nim == nilai.nim) {
                          return nilai;
                        } else {
                          return item;
                        }
                      }).toList();
                      // Filter the data again
                      filteredPenilaianPercobaan =
                          List.from(demoPenilaianPercobaan);
                    });
                  } catch (e) {
                    // Handle errors if any
                    if (kDebugMode) {
                      print('Error updating data: $e');
                    }
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
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
            ),
          ],
        );
      },
    );
  }

  //== Rumus menghitung rata-rata
  //== Modul 1 ==
  double _hitungRataRata1(PenilaianPercobaan nilai) {
    return ((nilai.latihan1 * 0.2) +
        (nilai.tugas1 * 0.2) +
        (nilai.afektif1 * 0.3) +
        (nilai.laporan1 * 0.3));
  }

  //
  //== Modul 2 ==
  double _hitungRataRata2(PenilaianPercobaan nilai) {
    return ((nilai.latihan2 * 0.2) +
        (nilai.tugas2 * 0.2) +
        (nilai.afektif2 * 0.3) +
        (nilai.laporan2 * 0.3));
  }

//== Modul 3 ==
  double _hitungRataRata3(PenilaianPercobaan nilai) {
    return ((nilai.latihan3 * 0.2) +
        (nilai.tugas3 * 0.2) +
        (nilai.afektif3 * 0.3) +
        (nilai.laporan3 * 0.3));
  }

  //
  //== Modul 4 ==
  double _hitungRataRata4(PenilaianPercobaan nilai) {
    return ((nilai.latihan4 * 0.2) +
        (nilai.tugas4 * 0.2) +
        (nilai.afektif4 * 0.3) +
        (nilai.laporan4 * 0.3));
  }

  //
  //== Modul 5 ==
  double _hitungRataRata5(PenilaianPercobaan nilai) {
    return ((nilai.latihan5 * 0.2) +
        (nilai.tugas5 * 0.2) +
        (nilai.afektif5 * 0.3) +
        (nilai.laporan5 * 0.3));
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
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredPenilaianPercobaan.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'NIM',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama',
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
                      ],
                      source: DataSource(
                        data: filteredPenilaianPercobaan,
                        context: context,
                        editNilai: editNilai,
                      ),
                      rowsPerPage: calculateRowsPerPage(
                          filteredPenilaianPercobaan.length))
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

class PenilaianPercobaan {
  String kode;
  int nim;
  String nama;
  //==Rata-Rata
  double rata1;
  double rata2;
  double rata3;
  double rata4;
  double rata5;

  //== Fungsi Per Modul ==
  //== Modul 1 ==
  double latihan1;
  double tugas1;
  double afektif1;
  double laporan1;
  //
  //== Modul 2 ==
  double latihan2;
  double tugas2;
  double afektif2;
  double laporan2;
  //
  //== Modul 3 ==
  double latihan3;
  double tugas3;
  double afektif3;
  double laporan3;
  //
  //== Modul 4 ==
  double latihan4;
  double tugas4;
  double afektif4;
  double laporan4;
  //
  //== Modul 5 ==
  double latihan5;
  double tugas5;
  double afektif5;
  double laporan5;
  //
  PenilaianPercobaan({
    required this.nim,
    required this.nama,
    required this.kode,
    //==Rata-Rata
    this.rata1 = 0.0,
    this.rata2 = 0.0,
    this.rata3 = 0.0,
    this.rata4 = 0.0,
    this.rata5 = 0.0,
    //
    //== Fungsi Per Modul ==
    //== Modul 1 ==
    this.latihan1 = 0.0,
    this.tugas1 = 0.0,
    this.afektif1 = 0.0,
    this.laporan1 = 0.0,
    //
    //== Modul 2 ==
    this.latihan2 = 0.0,
    this.tugas2 = 0.0,
    this.afektif2 = 0.0,
    this.laporan2 = 0.0,
    //
    //== Modul 3 ==
    this.latihan3 = 0.0,
    this.tugas3 = 0.0,
    this.afektif3 = 0.0,
    this.laporan3 = 0.0,
    //
    //== Modul 4 ==
    this.latihan4 = 0.0,
    this.tugas4 = 0.0,
    this.afektif4 = 0.0,
    this.laporan4 = 0.0,
    //
    //== Modul 5 ==
    this.latihan5 = 0.0,
    this.tugas5 = 0.0,
    this.afektif5 = 0.0,
    this.laporan5 = 0.0,
  });
}

DataRow dataFileDataRow(PenilaianPercobaan fileInfo, int index,
    void Function(PenilaianPercobaan) editNilai) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.nim.toString())),
      DataCell(SizedBox(
        width: 200.0,
        child: Text(getLimitedText(fileInfo.nama, 30)),
      )),
      DataCell(
        Text(getLimitedText(fileInfo.rata1.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.rata2.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.rata3.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.rata4.toString(), 5)),
      ),
      DataCell(
        Text(getLimitedText(fileInfo.rata5.toString(), 5)),
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
  final List<PenilaianPercobaan> data;
  final BuildContext context;
  final void Function(PenilaianPercobaan) editNilai;

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
