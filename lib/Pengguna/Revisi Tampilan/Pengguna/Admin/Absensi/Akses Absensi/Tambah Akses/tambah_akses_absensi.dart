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
  TextEditingController waktuAksesPraktikumController = TextEditingController();
  TextEditingController waktuTutupAksesPraktikumController =
      TextEditingController();

  //== Pilih Judul Modul ==//
  String? selectedJudulMateri;
  List<String> judulMateriList = [];

  //== Pilih Pertemuan ==//
  String? selectedPertemuan;

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

      setState(() {
        judulMateriList = tempList;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  //== Fungsi Untuk Menyimpan Data Ke Firestore 'Akses Absensi Mahasiswa' ==//
  Future<void> saveDataToFirestore(BuildContext context) async {
    try {
      // Validasi waktu dengan menggunakan DateFormat
      DateFormat dateFormat = DateFormat('dd MMMM yyyy hh:mm a');
      DateTime waktuAkses =
          dateFormat.parse(waktuAksesPraktikumController.text);
      DateTime waktuTutupAkses =
          dateFormat.parse(waktuTutupAksesPraktikumController.text);

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

      // Validasi jika data sudah ada di 'AksesAbsensi'
      QuerySnapshot duplicateCheck = await FirebaseFirestore.instance
          .collection('AksesAbsensi')
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .where('judulMateri', isEqualTo: selectedJudulMateri)
          .where('pertemuan', isEqualTo: selectedPertemuan)
          .get();

      if (duplicateCheck.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data telah terdapat pada database'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Jika validasi lolos, lanjutkan untuk menyimpan data
      await FirebaseFirestore.instance.collection('AksesAbsensi').add({
        'kodeKelas': widget.kodeKelas,
        'judulMateri': selectedJudulMateri,
        'pertemuan': selectedPertemuan,
        'waktuAksesAbsensi': waktuAkses,
        'waktuTutupAksesAbsensi': waktuTutupAkses
      });

      setState(() {
        selectedPertemuan = null;
        selectedJudulMateri = null;
        waktuAksesPraktikumController.clear();
        waktuTutupAksesPraktikumController.clear();
      });

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
                                                                if (selectedJudulMateri != null &&
                                                                    selectedPertemuan !=
                                                                        null &&
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
