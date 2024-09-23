// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditPengumpulanLaporan extends StatefulWidget {
  final String idkelas;
  final String modul;
  const EditPengumpulanLaporan(
      {super.key, required this.idkelas, required this.modul});

  @override
  State<EditPengumpulanLaporan> createState() => _EditPengumpulanLaporanState();
}

class _EditPengumpulanLaporanState extends State<EditPengumpulanLaporan> {
  //== Fungsi untuk TextEditingController ==//
  final TextEditingController waktuAksesController = TextEditingController();
  final TextEditingController waktuTutupAksesController =
      TextEditingController();
  final TextEditingController deskripsiPengumpulanController =
      TextEditingController();

//== Fungsi untuk memilih tanggal ==//
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      await _selectTime(context, controller, picked);
    }
  }

  Future<void> _selectTime(BuildContext context,
      TextEditingController controller, DateTime selectedDate) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      String formattedDateTime =
          DateFormat('dd MMMM yyyy hh:mm a').format(selectedDateTime);

      setState(() {
        controller.text = formattedDateTime;
      });
    }
  }

//Jumlah kata maksimum yang diizinkan pada deskripsi kelas
  int _remainingWords = 1000;
  void updateRemainingWords(String text) {
    //Menghitung sisa kata dan memperbaharui state
    int currentWordCount = text.split('').length;
    int remaining = 1000 - currentWordCount;

    setState(() {
      _remainingWords = remaining;
    });
    //Memeriksa apakah sisa kata mencapai 0
    if (_remainingWords <= 0) {
      //Menonaktifkan pengeditan jika sisa kata habis
      deskripsiPengumpulanController.text =
          deskripsiPengumpulanController.text.substring(0, 1000);
      deskripsiPengumpulanController.selection = TextSelection.fromPosition(
          TextPosition(offset: deskripsiPengumpulanController.text.length));
    }
  }

  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('Pengumpulan')
          .where('idKelas', isEqualTo: widget.idkelas)
          .where('judulModul', isEqualTo: widget.modul)
          .where('jenisPengumpulan', isEqualTo: 'Asistensi Laporan')
          .get();

      if (userData.docs.isNotEmpty) {
        var data = userData.docs.first.data();
        if (mounted) {
          setState(() {
            deskripsiPengumpulanController.text =
                data['deskripsiPengumpulan'] ?? '';
            // Mengambil waktuAkses sebagai string dari Firestore
            waktuAksesController.text = data['waktuAkses'] ?? '';

            // Mengambil waktuTutupAkses sebagai string dari Firestore
            waktuTutupAksesController.text = data['waktuTutupAkses'] ?? '';
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat mengambil data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //== Fungsi Edit Data ==//
  void saveData(BuildContext context) async {
    String akses = waktuAksesController.text.trim();
    String tutup = waktuTutupAksesController.text.trim();
    String deskripsi = deskripsiPengumpulanController.text.trim();

    try {
      DateFormat dateFormat = DateFormat('dd MMMM yyyy hh:mm a');
      DateTime waktuAkses = dateFormat.parse(akses);
      DateTime waktuTutupAkses = dateFormat.parse(tutup);

      if (waktuAkses.isAtSameMomentAs(waktuTutupAkses)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu akses dan waktu tutup akses tidak boleh sama'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (waktuTutupAkses.isBefore(waktuAkses)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Waktu tutup akses tidak boleh kurang dari waktu akses'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Pengumpulan')
          .where('idKelas', isEqualTo: widget.idkelas)
          .where('judulModul', isEqualTo: widget.modul)
          .where('jenisPengumpulan', isEqualTo: 'Asistensi Laporan')
          .get();

      await FirebaseFirestore.instance
          .collection('Pengumpulan')
          .doc(querySnapshot.docs.first.id)
          .update({
        'waktuAkses': akses,
        'waktuTutupAkses': tutup,
        'deskripsiPengumpulan': deskripsi
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      deskripsiPengumpulanController.clear();
      waktuAksesController.clear();
      waktuTutupAksesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
        ),
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
              Navigator.pop(context);
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
                    widget.modul,
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
                  width: screenWidth > 1100.0 ? 1100.0 : screenWidth,
                  height: screenHeight > 540.0 ? 550.0 : screenHeight,
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
                          "Akses Pengumpulan",
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
                      Row(
                        children: [
                          //== Jenis Pengumpulan, Waktu Pengumpulan dan Waktu Tutup Pengumpulan ==//
                          Column(
                            children: [
                              SizedBox(
                                height: 420.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
//=== Waktu Pengumpulan ===//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 25.0),
                                      child: Text(
                                        "Waktu Pengumpulan",
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
                                        left: 70.0,
                                        right: 30.0,
                                      ),
                                      child: SizedBox(
                                        width: MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                300.0
                                            ? 430.0
                                            : MediaQuery.of(context).size.width,
                                        child: TextField(
                                          controller: waktuAksesController,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Masukkan Waktu Pengumpulan',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                _selectDate(context,
                                                    waktuAksesController);
                                              },
                                              icon:
                                                  const Icon(Icons.access_time),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //=== Waktu Tutup Pengumpulan ===//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 30.0),
                                      child: Text(
                                        "Waktu Tutup Pengumpulan",
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
                                        left: 70.0,
                                        right: 30.0,
                                      ),
                                      child: SizedBox(
                                        width: MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                300.0
                                            ? 430.0
                                            : MediaQuery.of(context).size.width,
                                        child: TextField(
                                          readOnly: true,
                                          controller: waktuTutupAksesController,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Masukkan Waktu Tutup Pengumpulan',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                _selectDate(context,
                                                    waktuTutupAksesController);
                                              },
                                              icon:
                                                  const Icon(Icons.access_time),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 420.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== Deskripsi Pengumpulan ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        "Deskripsi Pengumpulan",
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
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: TextField(
                                          controller:
                                              deskripsiPengumpulanController,
                                          maxLines: 10,
                                          onChanged: (text) {
                                            updateRemainingWords(text);
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Deskripsi',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 40.0,
                                                    horizontal: 15.0),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 10.0),
                                      child: Text(
                                        'Sisa Kata: $_remainingWords/1000',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ),

                                    //== ElevatedButton 'SIMPAN' ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15.0, left: 350.0),
                                      child: SizedBox(
                                        height: screenHeight > 45.0
                                            ? 45.0
                                            : screenHeight,
                                        width: screenWidth > 100.0
                                            ? 140
                                            : screenWidth,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 1000.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
