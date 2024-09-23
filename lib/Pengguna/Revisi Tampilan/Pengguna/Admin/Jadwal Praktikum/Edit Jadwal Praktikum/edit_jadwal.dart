// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Navigasi/jadwalpraktikumnav_admin.dart';

class EditJadwalPraktikum extends StatefulWidget {
  final String kode;
  final String tahun;
  final String matkul;
  const EditJadwalPraktikum(
      {super.key,
      required this.kode,
      required this.tahun,
      required this.matkul});

  @override
  State<EditJadwalPraktikum> createState() => _EditJadwalPraktikumState();
}

class _EditJadwalPraktikumState extends State<EditJadwalPraktikum> {
  //== Fungsi Controller ==//
  TextEditingController waktuPraktikumController = TextEditingController();

  //== DropdownButton =//
  String? selectedDay;
  String? selectedRuangPraktikum;

  //== DropdownButton Memilih Hari ==//
  final List<String> days = [
    'Pilih Hari Praktikum',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jum\'at'
  ];

  //== DropdownButton Memilih Ruangan =//
  final List<String> ruangan = [
    'Pilih Ruangan Praktikum',
    'D1LABKOM',
    'D2LABKOM',
    'L1LABKOM'
  ];

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
      final startTimeFormatted = format.format(DateTime(
        0,
        0,
        0,
        startTime!.hour,
        startTime!.minute,
      ));
      final endTimeFormatted = format.format(DateTime(
        0,
        0,
        0,
        endTime!.hour,
        endTime!.minute,
      ));

      waktuPraktikumController.text = '$startTimeFormatted - $endTimeFormatted';
    }
  }

//== Fungsi Menampilkan data dari database ==//
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('JadwalPraktikum')
          .where('kodeMatakuliah', isEqualTo: widget.kode)
          .where('tahunAjaran', isEqualTo: widget.tahun)
          .get();

      if (userData.docs.isNotEmpty) {
        var data = userData.docs.first.data();
        if (mounted) {
          setState(() {
            selectedDay = data['hari'] ?? '';
            selectedRuangPraktikum = data['ruangPraktikum'] ?? '';
            waktuPraktikumController.text = data['waktuPraktikum'] ?? '';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            waktuPraktikumController.text = '';
            selectedRuangPraktikum = null;
            selectedDay = null;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //== Fungsi untuk menyimpan data ==//
  void saveData(BuildContext context) async {
    try {
      // Validasi hari, waktu, dan ruangan tidak boleh sama pada tahun ajaran yang sama
      final jadwalSnapshot = await FirebaseFirestore.instance
          .collection('JadwalPraktikum')
          .where('tahunAjaran', isEqualTo: widget.tahun)
          .where('hari', isEqualTo: selectedDay)
          .where('waktuPraktikum', isEqualTo: waktuPraktikumController.text)
          .where('ruangPraktikum', isEqualTo: selectedRuangPraktikum)
          .get();

      if (jadwalSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ruangan tersebut telah terdapat pada database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Menyimpan atau mengupdate data berdasarkan kodeMatakuliah
      final querySnapshot = await FirebaseFirestore.instance
          .collection('JadwalPraktikum')
          .where('kodeMatakuliah', isEqualTo: widget.kode)
          .where('tahunAjaran', isEqualTo: widget.tahun)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update existing document
        await FirebaseFirestore.instance
            .collection('JadwalPraktikum')
            .doc(querySnapshot.docs.first.id)
            .update({
          'hari': selectedDay,
          'waktuPraktikum': waktuPraktikumController.text,
          'ruangPraktikum': selectedRuangPraktikum,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Menyimpan data baru
        await FirebaseFirestore.instance.collection('JadwalPraktikum').add({
          'kodeMatakuliah': widget.kode,
          'matakuliah': widget.matkul,
          'tahunAjaran': widget.tahun,
          'hari': selectedDay,
          'waktuPraktikum': waktuPraktikumController.text,
          'ruangPraktikum': selectedRuangPraktikum,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
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
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const JadwalPraktikumNavigasiAdmin(),
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
          backgroundColor: const Color(0xFFF7F8FA),
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
                        color: Colors.black),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    'Admin',
                    style: GoogleFonts.quicksand(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0)
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: screenWidth > 2000.0 ? 1000.0 : screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30.0,
              ),
              Center(
                child: Container(
                  width: screenWidth > 400.0 ? 565.0 : screenWidth,
                  height: screenHeight > 400.0 ? 520.0 : screenHeight,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 40.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 70.0),
                        child: Text(
                          "Formulir Edit Jadwal",
                          style: GoogleFonts.quicksand(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 70.0, right: 70.0),
                        child: Divider(
                          thickness: 1.5,
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 400.0,
                            width: 525.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 18.0),
                                  child: Text(
                                    "Hari Praktikum",
                                    style: GoogleFonts.quicksand(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, right: 30.0),
                                  child: SizedBox(
                                      width: screenWidth > 250.0
                                          ? 430.0
                                          : screenWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedDay,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedDay = newValue;
                                          });
                                        },
                                        items: days
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                              value: value, child: Text(value));
                                        }).toList(),
                                        decoration: InputDecoration(
                                            hintText: 'Pilih Hari Praktikum',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white),
                                      )),
                                ),
                                //== Waktu Praktikum ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 15.0),
                                  child: Text(
                                    "Waktu Praktikum",
                                    style: GoogleFonts.quicksand(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30.0, left: 70.0),
                                  child: SizedBox(
                                      width: screenWidth > 250.0
                                          ? 430.0
                                          : screenWidth,
                                      child: TextField(
                                          readOnly: true,
                                          controller: waktuPraktikumController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Waktu Praktikum',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white,
                                              suffixIcon: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.access_time),
                                                    onPressed: () =>
                                                        _selectTime(context,
                                                            isStartTime: true),
                                                    tooltip: 'Waktu Awal',
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(10.0),
                                                    child: Text(
                                                      '-',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.access_time),
                                                    onPressed: () =>
                                                        _selectTime(context,
                                                            isStartTime: false),
                                                    tooltip: 'Waktu Berakhir',
                                                  ),
                                                ],
                                              )))),
                                ),
                                //== Ruangan Praktikum =//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 15.0),
                                  child: Text(
                                    "Ruangan Praktikum",
                                    style: GoogleFonts.quicksand(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30.0, left: 70.0),
                                  child: SizedBox(
                                      width: screenWidth > 250.0
                                          ? 430.0
                                          : screenWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedRuangPraktikum,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedRuangPraktikum = newValue;
                                          });
                                        },
                                        items: ruangan
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                              value: value, child: Text(value));
                                        }).toList(),
                                        decoration: InputDecoration(
                                            hintText: 'Pilih Ruangan Praktikum',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white),
                                      )),
                                ),
                                //== ElevatedButton 'SIMPAN' ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 23.0, left: 350.0),
                                  child: SizedBox(
                                    height: screenHeight > 45.0
                                        ? 45.0
                                        : screenHeight,
                                    width:
                                        screenWidth > 100.0 ? 140 : screenWidth,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF3CBEA9),
                                        ),
                                        onPressed: () {
                                          saveData(context);
                                        },
                                        child: Text(
                                          'Simpan Data',
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
