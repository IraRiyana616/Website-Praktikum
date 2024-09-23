import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import '../../Navigasi/hasil_studi_nav_dosen.dart';
import '../Nilai Harian/nilaiharian_dosen.dart';

class NilaiAkhirScreenDosen extends StatefulWidget {
  final String idkelas;
  final String mataKuliah;
  const NilaiAkhirScreenDosen(
      {super.key, required this.idkelas, required this.mataKuliah});

  @override
  State<NilaiAkhirScreenDosen> createState() => _NilaiAkhirScreenDosenState();
}

class _NilaiAkhirScreenDosenState extends State<NilaiAkhirScreenDosen> {
  //==List Data Table ==//
  List<PenilaianAkhir> demoPenilaianAkhir = [];
  List<PenilaianAkhir> filteredPenilaianAkhir = [];
  //== DropdownButton ==//
  String selectedKeterangan = 'Tampilkan Semua';
  //== ScrollController ==//
  final ScrollController _controller = ScrollController();
  final StreamController<List<PenilaianAkhir>> _penilaianStreamController =
      StreamController<List<PenilaianAkhir>>();

  StreamSubscription<QuerySnapshot>? _nilaiHarianSubscription;

  @override
  void dispose() {
    _penilaianStreamController.close();
    _nilaiHarianSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Hapus subscription yang lama jika ada sebelum membuat yang baru
    _nilaiHarianSubscription?.cancel();

    _nilaiHarianSubscription = FirebaseFirestore.instance
        .collection('nilaiHarian')
        .where('idKelas', isEqualTo: widget.idkelas)
        .snapshots()
        .listen((snapshot) {
      // Check if there are changes in the 'nilaiHarian' collection
      if (snapshot.docChanges.isNotEmpty) {
        updateNilaiAkhir();
      }
    });

    checkAndFetchData();
  }

  Future<void> updateNilaiAkhir() async {
    try {
      final nilaiHarianSnapshots = await FirebaseFirestore.instance
          .collection('nilaiHarian')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      if (nilaiHarianSnapshots.docs.isNotEmpty) {
        final List<PenilaianAkhir> data = nilaiHarianSnapshots.docs.map((doc) {
          final data = doc.data();
          final nilaiAkhirData = calculateHuruf(
            data['modul1'] ?? 0.0,
            data['modul2'] ?? 0.0,
            data['modul3'] ?? 0.0,
            data['modul4'] ?? 0.0,
            data['modul5'] ?? 0.0,
            data['modul6'] ?? 0.0,
            data['modul7'] ?? 0.0,
            data['modul8'] ?? 0.0,
            data['pretest'] ?? 0.0,
            data['projectAkhir'] ?? 0.0,
            data['laporanResmi'] ?? 0.0,
          );
          return PenilaianAkhir(
            nim: data['nim'] ?? '',
            nama: data['nama'] ?? '',
            kode: widget.idkelas,
            matkul: widget.mataKuliah,
            modul1: data['modul1'] ?? 0.0,
            modul2: data['modul2'] ?? 0.0,
            modul3: data['modul3'] ?? 0.0,
            modul4: data['modul4'] ?? 0.0,
            modul5: data['modul5'] ?? 0.0,
            modul6: data['modul6'] ?? 0.0,
            modul7: data['modul7'] ?? 0.0,
            modul8: data['modul8'] ?? 0.0,
            pretest: data['pretest'] ?? 0.0,
            project: data['projectAkhir'] ?? 0.0,
            resmi: data['laporanResmi'] ?? 0.0,
            akhir: calculateNilaiAkhir(
                data['modul1'] ?? 0.0,
                data['modul2'] ?? 0.0,
                data['modul3'] ?? 0.0,
                data['modul4'] ?? 0.0,
                data['modul5'] ?? 0.0,
                data['modul6'] ?? 0.0,
                data['modul7'] ?? 0.0,
                data['modul8'] ?? 0.0,
                data['pretest'] ?? 0.0,
                data['projectAkhir'] ?? 0.0,
                data['laporanResmi'] ?? 0.0),
            huruf: nilaiAkhirData['nilaiHuruf'] ?? '',
            status: nilaiAkhirData['status'] ?? '',
          );
        }).toList();

        // Mengurutkan data berdasarkan nama secara ascending
        data.sort((a, b) => a.nama.compareTo(b.nama));

        // Simpan data ke dalam 'nilaiAkhir' Firestore
        await saveDataToNilaiAkhir(data);

        // Tampilkan data pada tabel
        _penilaianStreamController.add(data); // Memperbarui tampilan UI
      } else {
        // Ambil data dari 'nilaiHarian'
        await addDataFromNilaiHarian();
        // Fetch data lagi setelah menambahkan data baru
        await updateNilaiAkhir();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> saveDataToNilaiAkhir(List<PenilaianAkhir> data) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (PenilaianAkhir nilai in data) {
        // Cek apakah data nilaiAkhir sudah ada di Firestore
        final existingData = await FirebaseFirestore.instance
            .collection('nilaiAkhir')
            .where('nim', isEqualTo: nilai.nim)
            .where('idKelas', isEqualTo: nilai.kode)
            .get();

        if (existingData.docs.isNotEmpty) {
          // Jika data sudah ada, update nilai-nilai modul
          final existingDoc = existingData.docs.first.reference;
          batch.update(existingDoc, {
            'modul1': nilai.modul1,
            'modul2': nilai.modul2,
            'modul3': nilai.modul3,
            'modul4': nilai.modul4,
            'modul5': nilai.modul5,
            'modul6': nilai.modul6,
            'modul7': nilai.modul7,
            'modul8': nilai.modul8,
            'pretest': nilai.pretest,
            'projectAkhir': nilai.project,
            'laporanResmi': nilai.resmi,
            'nilaiAkhir': nilai.akhir,
            'nilaiHuruf': nilai.huruf,
            'status': nilai.status,
          });
        } else {
          // Jika data belum ada, tambahkan data baru
          final newDocRef =
              FirebaseFirestore.instance.collection('nilaiAkhir').doc();
          batch.set(newDocRef, {
            'nim': nilai.nim,
            'nama': nilai.nama,
            'idKelas': nilai.kode,
            'matakuliah': nilai.matkul,
            'modul1': nilai.modul1,
            'modul2': nilai.modul2,
            'modul3': nilai.modul3,
            'modul4': nilai.modul4,
            'modul5': nilai.modul5,
            'modul6': nilai.modul6,
            'modul7': nilai.modul7,
            'modul8': nilai.modul8,
            'pretest': nilai.pretest,
            'projectAkhir': nilai.project,
            'laporanResmi': nilai.resmi,
            'nilaiAkhir': nilai.akhir,
            'nilaiHuruf': nilai.huruf,
            'status': nilai.status,
          });
        }
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> addDataFromNilaiHarian() async {
    try {
      final nilaiHarianSnapshot = await FirebaseFirestore.instance
          .collection('nilaiHarian')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      if (nilaiHarianSnapshot.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();

        for (var doc in nilaiHarianSnapshot.docs) {
          final data = doc.data();
          final nilaiAkhirData = calculateHuruf(
              data['modul1'] ?? 0.0,
              data['modul2'] ?? 0.0,
              data['modul3'] ?? 0.0,
              data['modul4'] ?? 0.0,
              data['modul5'] ?? 0.0,
              data['modul6'] ?? 0.0,
              data['modul7'] ?? 0.0,
              data['modul8'] ?? 0.0,
              data['pretest'] ?? 0.0,
              data['projectAkhir'] ?? 0.0,
              data['laporanResmi'] ?? 0.0);
          final nilaiAkhir = calculateNilaiAkhir(
              data['modul1'] ?? 0.0,
              data['modul2'] ?? 0.0,
              data['modul3'] ?? 0.0,
              data['modul4'] ?? 0.0,
              data['modul5'] ?? 0.0,
              data['modul6'] ?? 0.0,
              data['modul7'] ?? 0.0,
              data['modul8'] ?? 0.0,
              data['pretest'] ?? 0.0,
              data['projectAkhir'] ?? 0.0,
              data['laporanResmi'] ?? 0.0);

          // Cek apakah data nilaiAkhir sudah ada di Firestore
          final existingData = await FirebaseFirestore.instance
              .collection('nilaiAkhir')
              .where('nim', isEqualTo: data['nim'])
              .where('idKelas', isEqualTo: widget.idkelas)
              .get();

          if (existingData.docs.isNotEmpty) {
            // Jika data sudah ada, update nilai-nilai modul
            final existingDoc = existingData.docs.first;
            batch.update(existingDoc.reference, {
              'modul1': data['modul1'],
              'modul2': data['modul2'],
              'modul3': data['modul3'],
              'modul4': data['modul4'],
              'modul5': data['modul5'],
              'modul6': data['modul6'],
              'modul7': data['modul7'],
              'modul8': data['modul8'],
              'pretest': data['pretest'],
              'projectAkhir': data['projectAkhir'],
              'laporanResmi': data['laporanResmi'],
              'nilaiAkhir': nilaiAkhir,
              'nilaiHuruf': nilaiAkhirData['nilaiHuruf'],
              'status': nilaiAkhirData['status'],
            });
          } else {
            // Jika data belum ada, tambahkan data baru
            final penilaianAkhirRef =
                FirebaseFirestore.instance.collection('nilaiAkhir').doc();
            batch.set(penilaianAkhirRef, {
              'nim': data['nim'],
              'nama': data['nama'],
              'idKelas': widget.idkelas,
              'matakuliah': widget.mataKuliah,
              'modul1': data['modul1'],
              'modul2': data['modul2'],
              'modul3': data['modul3'],
              'modul4': data['modul4'],
              'modul5': data['modul5'],
              'modul6': data['modul6'],
              'modul7': data['modul7'],
              'modul8': data['modul8'],
              'pretest': data['pretest'],
              'projectAkhir': data['projectAkhir'],
              'laporanResmi': data['laporanResmi'],
              'status': nilaiAkhirData['status'],
              'nilaiAkhir': nilaiAkhir,
              'nilaiHuruf': nilaiAkhirData['nilaiHuruf'],
            });
          }
        }

        await batch.commit();
        // Refresh data setelah menambahkan entri baru
        await checkAndFetchData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> checkAndFetchData() async {
    try {
      final nilaiAkhirSnapshots = await FirebaseFirestore.instance
          .collection('nilaiAkhir')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      if (nilaiAkhirSnapshots.docs.isNotEmpty) {
        final List<PenilaianAkhir> data = nilaiAkhirSnapshots.docs.map((doc) {
          final data = doc.data();
          final nilaiAkhirData = calculateHuruf(
            data['modul1'] ?? 0.0,
            data['modul2'] ?? 0.0,
            data['modul3'] ?? 0.0,
            data['modul4'] ?? 0.0,
            data['modul5'] ?? 0.0,
            data['modul6'] ?? 0.0,
            data['modul7'] ?? 0.0,
            data['modul8'] ?? 0.0,
            data['pretest'] ?? 0.0,
            data['projectAkhir'] ?? 0.0,
            data['laporanResmi'] ?? 0.0,
          );
          return PenilaianAkhir(
            nim: data['nim'] ?? '',
            nama: data['nama'] ?? '',
            kode: widget.idkelas,
            matkul: widget.mataKuliah,
            modul1: data['modul1'] ?? 0.0,
            modul2: data['modul2'] ?? 0.0,
            modul3: data['modul3'] ?? 0.0,
            modul4: data['modul4'] ?? 0.0,
            modul5: data['modul5'] ?? 0.0,
            modul6: data['modul6'] ?? 0.0,
            modul7: data['modul7'] ?? 0.0,
            modul8: data['modul8'] ?? 0.0,
            pretest: data['pretest'] ?? 0.0,
            project: data['projectAkhir'] ?? 0.0,
            resmi: data['laporanResmi'] ?? 0.0,
            akhir: calculateNilaiAkhir(
                data['modul1'] ?? 0.0,
                data['modul2'] ?? 0.0,
                data['modul3'] ?? 0.0,
                data['modul4'] ?? 0.0,
                data['modul5'] ?? 0.0,
                data['modul6'] ?? 0.0,
                data['modul7'] ?? 0.0,
                data['modul8'] ?? 0.0,
                data['pretest'] ?? 0.0,
                data['projectAkhir'] ?? 0.0,
                data['laporanResmi'] ?? 0.0),
            huruf: nilaiAkhirData['nilaiHuruf'] ?? '',
            status: nilaiAkhirData['status'] ?? '',
          );
        }).toList();
        // Mengurutkan data berdasarkan nama secara ascending
        data.sort((a, b) => a.nim.compareTo(b.nim));

        // Simpan data ke dalam 'nilaiAkhir' Firestore
        await saveDataToNilaiAkhir(data);

        // Tampilkan data pada tabel
        _penilaianStreamController.add(data);
      } else {
        // Ambil data dari 'nilaiHarian'
        await addDataFromNilaiHarian();
        // Fetch data lagi setelah menambahkan data baru
        await checkAndFetchData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> getDataFromFirebase() async {
    try {
      final penilaianStream = FirebaseFirestore.instance
          .collection('nilaiHarian')
          .where('idKelas', isEqualTo: widget.idkelas)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                final nilaiAkhirData = calculateHuruf(
                  data['modul1'] ?? 0.0,
                  data['modul2'] ?? 0.0,
                  data['modul3'] ?? 0.0,
                  data['modul4'] ?? 0.0,
                  data['modul5'] ?? 0.0,
                  data['modul6'] ?? 0.0,
                  data['modul7'] ?? 0.0,
                  data['modul8'] ?? 0.0,
                  data['pretest'] ?? 0.0,
                  data['projectAkhir'] ?? 0.0,
                  data['laporanResmi'] ?? 0.0,
                );
                return PenilaianAkhir(
                  nim: data['nim'] ?? '',
                  nama: data['nama'] ?? '',
                  kode: widget.idkelas,
                  matkul: widget.mataKuliah,
                  modul1: data['modul1'] ?? 0.0,
                  modul2: data['modul2'] ?? 0.0,
                  modul3: data['modul3'] ?? 0.0,
                  modul4: data['modul4'] ?? 0.0,
                  modul5: data['modul5'] ?? 0.0,
                  modul6: data['modul6'] ?? 0.0,
                  modul7: data['modul7'] ?? 0.0,
                  modul8: data['modul8'] ?? 0.0,
                  pretest: data['pretest'] ?? 0.0,
                  project: data['projectAkhir'] ?? 0.0,
                  resmi: data['laporanResmi'] ?? 0.0,
                  akhir: calculateNilaiAkhir(
                    data['modul1'] ?? 0.0,
                    data['modul2'] ?? 0.0,
                    data['modul3'] ?? 0.0,
                    data['modul4'] ?? 0.0,
                    data['modul5'] ?? 0.0,
                    data['modul6'] ?? 0.0,
                    data['modul7'] ?? 0.0,
                    data['modul8'] ?? 0.0,
                    data['pretest'] ?? 0.0,
                    data['projectAkhir'] ?? 0.0,
                    data['laporanResmi'] ?? 0.0,
                  ),
                  huruf: nilaiAkhirData['nilaiHuruf'] ?? '',
                  status: nilaiAkhirData['status'] ?? '',
                );
              }).toList());

      // Clear previous data before adding new one
      _penilaianStreamController.sink.add([]);

      // Add the stream to the StreamController
      _penilaianStreamController.addStream(penilaianStream);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

//== Fungsi Download dengan bentuk CSV ===//
  Future<void> downloadData() async {
    // Mengambil data dari Firestore
    Query<Map<String, dynamic>> collectionRef = FirebaseFirestore.instance
        .collection('nilaiAkhir')
        .where('idKelas', isEqualTo: widget.idkelas);
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Menyiapkan data untuk diubah menjadi CSV
    List<List<dynamic>> csvData = [
      <String>[
        'nim',
        'nama',
        'idKelas',
        'matakuliah'
            'pretest',
        'laporanResmi',
        'projectAkhir',
        'modul1',
        'modul2',
        'modul3',
        'modul4',
        'modul5',
        'modul6',
        'modul7',
        'modul8',
        'nilaiAkhir',
        'nilaiHuruf',
        'status'
      ],
    ];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      csvData.add([
        data['nim'] ?? 0,
        data['nama'] ?? '',
        data['idKelas'] ?? '',
        data['matakuliah'] ?? '',
        data['pretest'] ?? 0.0,
        data['laporanResmi'] ?? 0.0,
        data['projectAkhir'] ?? 0.0,
        data['modul1'] ?? 0.0,
        data['modul2'] ?? 0.0,
        data['modul3'] ?? 0.0,
        data['modul4'] ?? 0.0,
        data['modul5'] ?? 0.0,
        data['modul6'] ?? 0.0,
        data['modul7'] ?? 0.0,
        data['modul8'] ?? 0.0,
        data['nilaiAkhir'] ?? 0.0,
        data['nilaiHuruf'] ?? '',
        data['status'] ?? '',
      ]);
    }

    // Konversi data ke dalam format CSV
    String csv = const ListToCsvConverter().convert(csvData);

    if (kIsWeb) {
      // Mendukung pengunduhan di web
      final bytes = const Utf8Encoder().convert(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "data_nilai.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mendapatkan direktori untuk menyimpan file (Android/iOS)
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/data_nilai.csv";
      final file = File(path);

      // Menulis data CSV ke dalam file
      await file.writeAsString(csv);

      // Notifikasi sukses
      if (kDebugMode) {
        print("File telah didownload di: $path");
      }
    }
  }

  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 1; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Memilih halaman sesuai dengan index yang dipilih
      if (index == 0) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NilaiHarianDosenScreen(
              idkelas: widget.idkelas,
              mataKuliah: widget.mataKuliah,
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
      } else if (index == 1) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NilaiAkhirScreenDosen(
              idkelas: widget.idkelas,
              mataKuliah: widget.mataKuliah,
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
            label: 'Nilai AKhir',
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
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const HasilStudiNavigasiDosen(),
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
                    widget.mataKuliah,
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 700.0,
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
                padding: const EdgeInsets.only(left: 25.0, right: 25.0),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SizedBox(
                                  height: 45.0,
                                  width: 150.0,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          const Color(0xFF3CBEA9),
                                        ),
                                      ),
                                      onPressed: () {
                                        downloadData();
                                      },
                                      child: const Text(
                                        'Download File',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )),
                                ),
                              ),
                              //== Search ==//
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 30.0, left: 600.0),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Search :',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Container(
                                        width: 260.0,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          style: const TextStyle(
                                              color: Colors.black),
                                          icon: const Icon(
                                              Icons.arrow_drop_down,
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
                            ],
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
                                stream: _penilaianStreamController.stream,
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
                                        label: Text('Modul 3',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Modul 4',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Modul 5',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Modul 6',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Modul 7',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      DataColumn(
                                        label: Text('Modul 8',
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
                                                              data.modul3
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.modul4
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.modul5
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.modul6
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.modul7
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 100.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.modul8
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 150.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.project
                                                                  .toString(),
                                                              5)))),
                                                  DataCell(SizedBox(
                                                      width: 150.0,
                                                      child: Text(
                                                          getLimitedText(
                                                              data.resmi
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

  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.withOpacity(0.3) : Colors.white;
  }

  String getLimitedText(String text, int limit) {
    return text.length <= limit ? text : text.substring(0, limit);
  }

  void editNilai(PenilaianAkhir nilai) {
    TextEditingController pretestController =
        TextEditingController(text: nilai.pretest.toString());

    //== Project Akhir
    TextEditingController projectController =
        TextEditingController(text: nilai.project.toString());
    //== Laporan Resmi
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
            height: 170.0,
            width: 200.0,
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
                    //== Project Akhir
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                      child: SizedBox(
                        width: 130.0,
                        child: TextField(
                          controller: projectController,
                          onChanged: (value) {
                            nilai.project = double.parse(value);
                          },
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Project Ahir'),
                        ),
                      ),
                    ),
                    //== Laporan Resmi
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                      child: SizedBox(
                        width: 130.0,
                        child: TextField(
                          controller: resmiController,
                          onChanged: (value) {
                            nilai.resmi = double.parse(value);
                          },
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Laporan Resmi'),
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
                      nilai.modul3,
                      nilai.modul4,
                      nilai.modul5,
                      nilai.modul6,
                      nilai.modul7,
                      nilai.modul8,
                      nilai.pretest,
                      nilai.project,
                      nilai.resmi,
                    ); // Hitung kembali huruf dan status

                    QuerySnapshot<Map<String, dynamic>> querySnapshot =
                        await FirebaseFirestore.instance
                            .collection('nilaiAkhir')
                            .where('nim', isEqualTo: nilai.nim)
                            .where('nama', isEqualTo: nilai.nama)
                            .where('idKelas', isEqualTo: widget.idkelas)
                            .get();

                    if (querySnapshot.docs.isEmpty) {
                      await FirebaseFirestore.instance
                          .collection('nilaiAkhir')
                          .add({
                        'nim': nilai.nim,
                        'nama': nilai.nama,
                        'idKelas': widget.idkelas,
                        'matakuliah': widget.mataKuliah,
                        'modul1': nilai.modul1,
                        'modul2': nilai.modul2,
                        'modul3': nilai.modul3,
                        'modul4': nilai.modul4,
                        'modul5': nilai.modul5,
                        'modul6': nilai.modul6,
                        'modul7': nilai.modul7,
                        'modul8': nilai.modul8,
                        'pretest': nilai.pretest,
                        'projectAkhir': nilai.project,
                        'laporanResmi': nilai.resmi,
                        'status': nilaiAkhirData['status'],
                        'nilaiHuruf': nilaiAkhirData['nilaiHuruf'],
                        'namaAsisten': namaAsisten ?? "",
                      });
                    } else {
                      await querySnapshot.docs[0].reference.update({
                        'modul1': nilai.modul1,
                        'modul2': nilai.modul2,
                        'modul3': nilai.modul3,
                        'modul4': nilai.modul4,
                        'modul5': nilai.modul5,
                        'modul6': nilai.modul6,
                        'modul7': nilai.modul7,
                        'modul8': nilai.modul8,
                        'pretest': nilai.pretest,
                        'projectAkhir': nilai.project,
                        'laporanResmi': nilai.resmi,
                        'status': nilaiAkhirData[
                            'status'], // Gunakan nilai status yang baru
                        'nilaiHuruf': nilaiAkhirData[
                            'nilaiHuruf'], // Gunakan nilai huruf yang baru
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

  double calculateNilaiAkhir(
      double modul1,
      double modul2,
      double modul3,
      double modul4,
      double modul5,
      double modul6,
      double modul7,
      double modul8,
      double pretest,
      double project,
      double resmi) {
    return ((modul1 * 0.08) +
        (modul2 * 0.08) +
        (modul3 * 0.08) +
        (modul4 * 0.08) +
        (modul5 * 0.08) +
        (modul6 * 0.08) +
        (modul7 * 0.08) +
        (modul8 * 0.08) +
        (pretest * 0.05) +
        (resmi * 0.11) +
        (project * 0.2));
  }

  Map<String, String> calculateHuruf(
      double modul1,
      double modul2,
      double modul3,
      double modul4,
      double modul5,
      double modul6,
      double modul7,
      double modul8,
      double pretest,
      double project,
      double resmi) {
    double nilaiAkhir = calculateNilaiAkhir(modul1, modul2, modul3, modul4,
        modul5, modul6, modul7, modul8, pretest, project, resmi);
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

    return {'nilaiHuruf': huruf, 'status': status};
  }
}

class PenilaianAkhir {
  final int nim;
  final String nama;
  final String kode;
  final String matkul;

  //=== Rata - Rata
  double modul1;
  double modul2;
  double modul3;
  double modul4;
  double modul5;
  double modul6;
  double modul7;
  double modul8;

  //==Pretest
  double pretest;
  //== Project Akhir
  double project;
  //== Laporan Resmi
  double resmi;
  //== Hasil Akhir
  late double akhir;
  late String status;
  late String huruf;

  PenilaianAkhir({
    required this.nim,
    required this.nama,
    required this.kode,
    required this.matkul,
    //== Rata-Rata
    required this.modul1,
    required this.modul2,
    required this.modul3,
    required this.modul4,
    required this.modul5,
    required this.modul6,
    required this.modul7,
    required this.modul8,
    //== PreTest
    this.pretest = 0.0,
    //== Project Akhir
    this.project = 0.0,
    //== Laporan Resmi
    this.resmi = 0.0,
    //== Hasil Akhir
    this.akhir = 0.0,
    this.status = '',
    this.huruf = '',
  });
}
