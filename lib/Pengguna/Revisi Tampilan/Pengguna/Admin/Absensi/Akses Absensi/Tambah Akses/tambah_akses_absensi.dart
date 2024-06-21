// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Navigasi/absensinav_admin.dart';

class TambahAksesAbsensiMahasiswa extends StatefulWidget {
  final String kodeKelas;
  final String kodeAsisten;
  final String mataKuliah;
  const TambahAksesAbsensiMahasiswa(
      {super.key,
      required this.kodeKelas,
      required this.kodeAsisten,
      required this.mataKuliah});

  @override
  State<TambahAksesAbsensiMahasiswa> createState() =>
      _TambahAksesAbsensiMahasiswaState();
}

class _TambahAksesAbsensiMahasiswaState
    extends State<TambahAksesAbsensiMahasiswa> {
  //== TextField Controller ==//
  TextEditingController waktuPraktikumController = TextEditingController();

  //== Pilih Judul Modul ==//
  String? selectedJudulMateri;
  List<String> judulMateriList = [];

  //== Pilih Pertemuan ==//
  String? selectedPertemuan;

  //== Pilih Jadwal Praktikum ==//
  String? selectedWaktuPraktikum;
  List<String> waktuPraktikumList = [];

  //== Waktu Akses Praktikum ==//
  //
  //== Memilih Waktu ==//
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
        _updateTimeText();
      });
    }
  }

  void _updateTimeText() {
    if (startTime != null && endTime != null) {
      final format = DateFormat('hh:mm a');
      final startTimeFormatted =
          format.format(DateTime(0, 0, 0, startTime!.hour, startTime!.minute));
      final endTimeFormatted =
          format.format(DateTime(0, 0, 0, endTime!.hour, endTime!.minute));

      waktuPraktikumController.text = '$startTimeFormatted - $endTimeFormatted';
    }
  }

  //== Menampilkan data ==//
  @override
  void initState() {
    super.initState();
    fetchJudulMateri();
  }

  //== Menampilkan data dari 'silabusPraktikum' ==//
  Future<void> fetchJudulMateri() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('silabusPraktikum')
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .get();

      //== Judul Materi ==//
      List<String> tempList =
          snapshot.docs.map((doc) => doc['judulMateri'] as String).toList();
      //== Waktu Praktikum ==//
      List<String> waktuList = snapshot.docs
          .map((doc) => doc['tanggalPraktikum'] as String)
          .toList();

      setState(() {
        judulMateriList = tempList;
        waktuPraktikumList = waktuList;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  //== Fungsi Untuk Menyimpan Data Ke Firestore 'Akses Absensi Mahasiswa' ==//
  Future<void> saveDataToFirestore() async {
    try {
      // Check if document with the same jadwalPraktikum and judulMateri exists
      QuerySnapshot duplicateCheck = await FirebaseFirestore.instance
          .collection('AksesAbsensi')
          .where('jadwalPraktikum', isEqualTo: selectedWaktuPraktikum)
          .where('judulMateri', isEqualTo: selectedJudulMateri)
          .get();

      // If no duplicates found, proceed to save data
      if (duplicateCheck.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('AksesAbsensi').add({
          'kodeKelas': widget.kodeKelas,
          'kodeAsisten': widget.kodeAsisten,
          'mataKuliah': widget.mataKuliah,
          'judulMateri': selectedJudulMateri,
          'pertemuan': selectedPertemuan,
          'jadwalPraktikum': selectedWaktuPraktikum,
          'waktuAbsensi': waktuPraktikumController.text,
        });
        setState(() {
          selectedJudulMateri = null;
          selectedPertemuan = null;
          selectedWaktuPraktikum = null;
          waktuPraktikumController.clear();
        });
        // Show success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Show error message that duplicate entry exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data telah terdapat pada database'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
                        const AbsensiPraktikumNav(),
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
                  Text(
                    'Admin',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(width: 30.0)
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
                color: const Color(0xFFE3E8EF),
                width: 2000.0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: Container(
                            width: screenWidth > 1000.0 ? 850.0 : screenWidth,
                            height: screenWidth > 440.0 ? 440.0 : screenHeight,
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 30.0,
                                ),
                                Center(
                                  child: Container(
                                    width: screenWidth > 900.0
                                        ? 1100.0
                                        : screenWidth,
                                    height: screenHeight > 310.0
                                        ? 410.0
                                        : screenHeight,
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 70.0),
                                          child: Text(
                                            "Formulir Akses Absensi Mahasiswa",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15.0,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              left: 70.0, right: 65.0),
                                          child: Divider(
                                            thickness: 1.5,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 260.0,
                                                  width: 425.0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 70.0,
                                                                top: 18.0),
                                                        child: Text(
                                                          "Judul Materi",
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 70.0,
                                                                right: 30.0),
                                                        child: SizedBox(
                                                            width: screenWidth >
                                                                    250.0
                                                                ? 350.0
                                                                : screenWidth,
                                                            child:
                                                                DropdownButtonFormField<
                                                                    String>(
                                                              value:
                                                                  selectedJudulMateri,
                                                              decoration:
                                                                  InputDecoration(
                                                                      hintText:
                                                                          'Pilih Judul Materi',
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .white),
                                                              onChanged: (String?
                                                                  newValue) {
                                                                setState(() {
                                                                  selectedJudulMateri =
                                                                      newValue;
                                                                });
                                                              },
                                                              items: judulMateriList
                                                                  .map((String
                                                                      value) {
                                                                return DropdownMenuItem<
                                                                        String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value));
                                                              }).toList(),
                                                            )),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 70.0,
                                                                top: 15.0),
                                                        child: Text(
                                                          "Pertemuan",
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 70.0,
                                                                right: 30.0),
                                                        child: SizedBox(
                                                            width: screenWidth >
                                                                    250.0
                                                                ? 350.0
                                                                : screenWidth,
                                                            child:
                                                                DropdownButtonFormField(
                                                                    decoration: InputDecoration(
                                                                        border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                10.0)),
                                                                        filled:
                                                                            true,
                                                                        fillColor: Colors
                                                                            .white),
                                                                    hint: const Text(
                                                                        'Pilih Pertemuan'),
                                                                    items: [
                                                                      'Pertemuan 1',
                                                                      'Pertemuan 2',
                                                                      'Pertemuan 3',
                                                                      'Pertemuan 4',
                                                                      'Pertemuan 5',
                                                                      'Pertemuan 6',
                                                                      'Pertemuan 7',
                                                                      'Pertemuan 8',
                                                                    ].map<
                                                                        DropdownMenuItem<
                                                                            String>>((String
                                                                        value) {
                                                                      return DropdownMenuItem<
                                                                              String>(
                                                                          value:
                                                                              value,
                                                                          child:
                                                                              Text(value));
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        selectedPertemuan =
                                                                            newValue;
                                                                      });
                                                                    },
                                                                    value:
                                                                        selectedPertemuan)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 260.0,
                                                  width: 425.0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                top: 18.0),
                                                        child: Text(
                                                          "Jadwal Praktikum",
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                right: 30.0),
                                                        child: SizedBox(
                                                            width: screenWidth >
                                                                    250.0
                                                                ? 350.0
                                                                : screenWidth,
                                                            child:
                                                                DropdownButtonFormField(
                                                                    value:
                                                                        selectedWaktuPraktikum,
                                                                    decoration: InputDecoration(
                                                                        hintText:
                                                                            'Pilih Jadwal Praktikum',
                                                                        border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                10.0)),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors
                                                                                .white),
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        selectedWaktuPraktikum =
                                                                            newValue;
                                                                      });
                                                                    },
                                                                    items: waktuPraktikumList
                                                                        .map((String
                                                                            value) {
                                                                      return DropdownMenuItem<
                                                                              String>(
                                                                          value:
                                                                              value,
                                                                          child:
                                                                              Text(value));
                                                                    }).toList())),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                top: 15.0),
                                                        child: Text(
                                                          "Waktu Akses Absensi",
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                right: 30.0),
                                                        child: SizedBox(
                                                            width: screenWidth >
                                                                    250.0
                                                                ? 350.0
                                                                : screenWidth,
                                                            child: TextField(
                                                              readOnly: true,
                                                              controller:
                                                                  waktuPraktikumController,
                                                              decoration:
                                                                  InputDecoration(
                                                                      hintText:
                                                                          'Masukkan Waktu Akses',
                                                                      border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10.0)),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .white,
                                                                      suffixIcon:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          IconButton(
                                                                            onPressed: () =>
                                                                                _selectTime(context, isStartTime: true),
                                                                            icon:
                                                                                const Icon(Icons.access_time),
                                                                            tooltip:
                                                                                'Waktu Awal',
                                                                          ),
                                                                          const Padding(
                                                                            padding:
                                                                                EdgeInsets.all(10.0),
                                                                            child:
                                                                                Text(
                                                                              '-',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () =>
                                                                                _selectTime(context, isStartTime: false),
                                                                            icon:
                                                                                const Icon(Icons.access_time),
                                                                            tooltip:
                                                                                'Waktu Berakhir',
                                                                          )
                                                                        ],
                                                                      )),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 684.0),
                                          child: SizedBox(
                                            height: screenHeight > 45.0
                                                ? 45.0
                                                : screenHeight,
                                            width: screenWidth > 100.0
                                                ? 120
                                                : screenWidth,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF3CBEA9),
                                                ),
                                                onPressed: () {
                                                  // Validate and save data to Firestore
                                                  if (selectedJudulMateri !=
                                                          null &&
                                                      selectedPertemuan !=
                                                          null &&
                                                      selectedWaktuPraktikum !=
                                                          null &&
                                                      waktuPraktikumController
                                                          .text.isNotEmpty) {
                                                    saveDataToFirestore();
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Harap lengkapi semua kolom'),
                                                        backgroundColor:
                                                            Colors.red,
                                                        duration: Duration(
                                                            seconds: 2),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  'Simpan Data',
                                                  style: GoogleFonts.quicksand(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 111.0,
                      )
                    ]))));
  }
}
