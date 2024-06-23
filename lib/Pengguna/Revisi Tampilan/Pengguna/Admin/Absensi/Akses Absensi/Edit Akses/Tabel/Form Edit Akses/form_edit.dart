// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FormEditAksesAbsensi extends StatefulWidget {
  final String kodeKelas;
  final String kodeAsisten;
  final String judulMateri;
  const FormEditAksesAbsensi(
      {super.key,
      required this.kodeKelas,
      required this.kodeAsisten,
      required this.judulMateri});

  @override
  State<FormEditAksesAbsensi> createState() => _FormEditAksesAbsensiState();
}

class _FormEditAksesAbsensiState extends State<FormEditAksesAbsensi> {
  //== TextField Controller ==//

  //== Waktu Akses Praktikum ==//
  TextEditingController waktuAksesPraktikumController = TextEditingController();

  //== Waktu Tutup Akses Praktikum ==//
  TextEditingController waktuTutupAksesPraktikumController =
      TextEditingController();

  //== Judul Materi ==//
  TextEditingController judulMateriController = TextEditingController();

  //== Pertemuan =//
  TextEditingController pertemuanController = TextEditingController();

//== Menampilkan data dari database ==//
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('AksesAbsensi')
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .where('judulMateri', isEqualTo: widget.judulMateri)
          .get();

      if (userData.docs.isNotEmpty) {
        var data = userData.docs.first.data();
        setState(() {
          judulMateriController.text = data['judulMateri'] ?? '';
          pertemuanController.text = data['pertemuan'] ?? '';

          // Konversi Timestamp ke String untuk waktu akses absensi
          waktuAksesPraktikumController.text =
              (data['waktuAksesAbsensi'] as Timestamp?)?.toDate().toString() ??
                  '';

          // Konversi Timestamp ke String untuk waktu tutup akses absensi
          waktuTutupAksesPraktikumController.text =
              (data['waktuTutupAksesAbsensi'] as Timestamp?)
                      ?.toDate()
                      .toString() ??
                  '';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
  }

  //== Memilih Waktu dan Tanggal ==//
  // Fungsi untuk memilih tanggal
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

  // Fungsi untuk memilih waktu
  Future<void> _selectTime(BuildContext context,
      TextEditingController controller, DateTime selectedDate) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Gabungkan tanggal dan waktu yang dipilih
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      // Format tanggal dan waktu
      String formattedDateTime = DateFormat(
        'dd MMMM yyyy HH:mm a',
      ).format(selectedDateTime);

      setState(() {
        controller.text = formattedDateTime;
      });
    }
  }

  //== Menampilkan data ==//
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //== Fungsi Untuk Menyimpan Data Ke Firestore 'Akses Absensi Mahasiswa' ==//
  Future<void> saveDataToFirestore(BuildContext context) async {
    try {
      DateFormat dateFormat = DateFormat('dd MMMM yyyy hh:mm a');

      // Ambil teks dari controller untuk parsing
      DateTime waktuAkses =
          dateFormat.parse(waktuAksesPraktikumController.text);
      DateTime waktuTutupAkses =
          dateFormat.parse(waktuTutupAksesPraktikumController.text);

      // Validasi waktu akses dan waktu tutup akses
      if (waktuAkses.isAtSameMomentAs(waktuTutupAkses)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu akses dan waktu tutup akses tidak boleh sama'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
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
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Query untuk mencari dokumen dengan judulMateri yang sesuai
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('AksesAbsensi')
          .where('judulMateri', isEqualTo: widget.judulMateri)
          .get();

      // Lakukan update jika ada dokumen yang sesuai
      if (querySnapshot.docs.isNotEmpty) {
        // Ambil dokumen pertama karena judulMateri seharusnya unik
        var docId = querySnapshot.docs[0].id;

        // Lakukan update data
        await FirebaseFirestore.instance
            .collection('AksesAbsensi')
            .doc(docId)
            .update({
          'kodeKelas': widget.kodeKelas,

          'judulMateri': widget.judulMateri,
          'pertemuan': pertemuanController.text,
          'waktuAksesAbsensi': Timestamp.fromDate(
              waktuAkses), // Gunakan Timestamp untuk menyimpan DateTime di Firestore
          'waktuTutupAksesAbsensi': Timestamp.fromDate(waktuTutupAkses),
        });
      }

      // Bersihkan controller setelah data berhasil disimpan
      judulMateriController.clear();
      pertemuanController.clear();
      waktuAksesPraktikumController.clear();
      waktuTutupAksesPraktikumController.clear();

      // Tampilkan snackbar untuk notifikasi data berhasil disimpan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving data: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
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
                  Expanded(
                    child: Text(
                      widget.kodeKelas,
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
                            height: screenWidth > 430.0 ? 480.0 : screenHeight,
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 30.0,
                                ),
                                Center(
                                  child: SizedBox(
                                    width: screenWidth > 900.0
                                        ? 1100.0
                                        : screenWidth,
                                    height: screenHeight > 410.0
                                        ? 410.0
                                        : screenHeight,
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
                                                  height: 350.0,
                                                  width: 425.0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      //== Judul Materi ==//
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
                                                            child: TextField(
                                                              controller:
                                                                  judulMateriController,
                                                              readOnly: true,
                                                              decoration: InputDecoration(
                                                                  hintText:
                                                                      'Masukkan Judul Materi',
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  fillColor:
                                                                      Colors
                                                                          .grey,
                                                                  filled: true),
                                                            )),
                                                      ),
                                                      //== Pertemuan ==//
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
                                                            child: TextField(
                                                              controller:
                                                                  pertemuanController,
                                                              readOnly: true,
                                                              decoration: InputDecoration(
                                                                  hintText:
                                                                      'Masukkan Judul Materi',
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  fillColor:
                                                                      Colors
                                                                          .grey,
                                                                  filled: true),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                //== Waktu Akses dan Tutup Akses ==//
                                                SizedBox(
                                                  height: 350.0,
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
                                                                top: 19.0),
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
                                                            controller:
                                                                waktuAksesPraktikumController,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Masukkan Akses Absensi',
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10.0)),
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                    filled:
                                                                        true,
                                                                    suffixIcon:
                                                                        IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              _selectDate(context, waktuAksesPraktikumController);
                                                                            },
                                                                            icon:
                                                                                const Icon(Icons.access_time))),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                top: 18.0),
                                                        child: Text(
                                                          "Waktu Tutup Absensi",
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
                                                        height: 17.0,
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
                                                                  waktuTutupAksesPraktikumController,
                                                              decoration:
                                                                  InputDecoration(
                                                                      hintText:
                                                                          'Masukkan Waktu Tutup Akses',
                                                                      border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10.0)),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .white,
                                                                      suffixIcon: IconButton(
                                                                          onPressed: () {
                                                                            _selectDate(context,
                                                                                waktuTutupAksesPraktikumController);
                                                                          },
                                                                          icon: const Icon(Icons.access_time))),
                                                            )),
                                                      ),
                                                      //== ElevatedButton 'SIMPAN' ==//
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 25.0,
                                                                left: 250.0),
                                                        child: SizedBox(
                                                          height: screenHeight >
                                                                  45.0
                                                              ? 45.0
                                                              : screenHeight,
                                                          width: screenWidth >
                                                                  100.0
                                                              ? 120
                                                              : screenWidth,
                                                          child: ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    const Color(
                                                                        0xFF3CBEA9),
                                                              ),
                                                              onPressed: () {
                                                                // Validate and save data to Firestore
                                                                if (judulMateriController.text.isNotEmpty &&
                                                                    pertemuanController
                                                                        .text
                                                                        .isNotEmpty &&
                                                                    waktuAksesPraktikumController
                                                                        .text
                                                                        .isNotEmpty &&
                                                                    waktuTutupAksesPraktikumController
                                                                        .text
                                                                        .isNotEmpty) {
                                                                  saveDataToFirestore(
                                                                      context);
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          'Harap lengkapi semua kolom'),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      duration: Duration(
                                                                          seconds:
                                                                              2),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: Text(
                                                                'Simpan Data',
                                                                style: GoogleFonts.quicksand(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                        ),
                                                      ),
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
