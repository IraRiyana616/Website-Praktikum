// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Navigasi/jadwalpraktikumnav_admin.dart';

class FormJadwalPraktikum extends StatefulWidget {
  const FormJadwalPraktikum({super.key});

  @override
  State<FormJadwalPraktikum> createState() => _FormJadwalPraktikumState();
}

class _FormJadwalPraktikumState extends State<FormJadwalPraktikum> {
  //== Fungsi Controller ==//
  TextEditingController waktuPraktikumController = TextEditingController();
  final TextEditingController kodeMatakuliahController =
      TextEditingController();

  ////=====/////
  @override
  void dispose() {
    kodeMatakuliahController.dispose();
    super.dispose();
  }

  //== DropdownButton =//
  String? selectedMatakuliah;
  String? selectedTahunAjaran;
  String? selectedDay;
  String? selectedRuangPraktikum;
  String? selectedKodeMatakuliah;

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

//=== Menyimpan data pada Firestore 'JadwalPraktikum ===//
  Future<void> _saveDataToFirestore() async {
    if (selectedMatakuliah == null ||
        selectedTahunAjaran == null ||
        selectedDay == null ||
        selectedRuangPraktikum == null ||
        waktuPraktikumController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap lengkapi data'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Memeriksa apakah data sudah ada sebelum menyimpan
    bool isDataExist = await _checkDataExist();
    if (isDataExist) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ruangan tersebut telah terdapat pada database'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('JadwalPraktikum').add({
        'matakuliah': selectedMatakuliah,
        'kodeMatakuliah': kodeMatakuliahController.text,
        'tahunAjaran': selectedTahunAjaran,
        'hari': selectedDay,
        'ruangPraktikum': selectedRuangPraktikum,
        'waktuPraktikum': waktuPraktikumController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        backgroundColor: Colors.green,
      ));
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  Future<bool> _checkDataExist() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('JadwalPraktikum')
              .where('tahunAjaran', isEqualTo: selectedTahunAjaran)
              .where('waktuPraktikum', isEqualTo: waktuPraktikumController.text)
              .where('ruangPraktikum', isEqualTo: selectedRuangPraktikum)
              .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking data existence: $e');
      }
      return false;
    }
  }

  void _clearForm() {
    setState(() {
      selectedKodeMatakuliah = null;
      selectedTahunAjaran = null;
      selectedDay = null;
      selectedRuangPraktikum = null;
      waktuPraktikumController.clear();
      kodeMatakuliahController.clear();
      startTime = null;
      endTime = null;
    });
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
                )),
            backgroundColor: const Color(0xFFF7F8FA),
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    'Formulir Jadwal Praktikum',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
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
          )),
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
                  width: screenWidth > 400.0 ? 1050.0 : screenWidth,
                  height: screenHeight > 490.0 ? 540.0 : screenHeight,
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
                          'Formulir Tambah Jadwal Praktikum',
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
                          //== Kode Praktikum, MataKuliah, Hari Praktikum ===//
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 425.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== Nama Matakuliah ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        'Nama MataKuliah',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 15.0),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('dataKelasPraktikum')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const CircularProgressIndicator();
                                            }

                                            List<DropdownMenuItem<String>>
                                                modulItems = [];
                                            Set<String> seen = {};

                                            for (var document
                                                in snapshot.data!.docs) {
                                              String matakuliah =
                                                  document['matakuliah'];
                                              if (!seen.contains(matakuliah)) {
                                                seen.add(matakuliah);
                                                modulItems.add(
                                                  DropdownMenuItem<String>(
                                                    value: matakuliah,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15.0),
                                                      child: Text(matakuliah,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      16.0)),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }

                                            if (!modulItems.any((item) =>
                                                item.value ==
                                                selectedMatakuliah)) {
                                              selectedMatakuliah =
                                                  null; // Or handle it in a way that fits your logic
                                            }

                                            return Container(
                                              height: 47.0,
                                              width: 360.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade700),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: DropdownButton<String>(
                                                value: selectedMatakuliah,
                                                hint: const Text(
                                                  '   Pilih Nama Matakuliah',
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                items: modulItems,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedMatakuliah =
                                                        newValue;
                                                    selectedKodeMatakuliah = snapshot
                                                            .data!.docs
                                                            .firstWhere(
                                                                (document) =>
                                                                    document[
                                                                        'matakuliah'] ==
                                                                    newValue)[
                                                        'kodeMatakuliah'];
                                                    kodeMatakuliahController
                                                            .text =
                                                        selectedKodeMatakuliah ??
                                                            '';
                                                  });
                                                },
                                                isExpanded: true,
                                                dropdownColor: Colors.white,
                                                style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 14.0),
                                                underline: Container(),
                                                icon: const Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.grey),
                                                iconSize: 24,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    //== Kode Matakuliah ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text('Kode MataKuliah',
                                          style: GoogleFonts.quicksand(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 15.0),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 70.0),
                                      child: SizedBox(
                                        width: screenWidth > 250.0
                                            ? 430.0
                                            : screenWidth,
                                        height: 47.0,
                                        child: TextField(
                                          controller: kodeMatakuliahController,
                                          decoration: InputDecoration(
                                            hintText: 'Kode Matakuliah',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 15.0),
                                          ),
                                          style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14.0),
                                          readOnly: true,
                                        ),
                                      ),
                                    ),

                                    //== Tahun Ajaran ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        'Tahun Ajaran',
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
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('dataKelasPraktikum')
                                              .where('matakuliah',
                                                  isEqualTo: selectedMatakuliah)
                                              .where('kodeMatakuliah',
                                                  isEqualTo:
                                                      kodeMatakuliahController
                                                          .text)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            List<DropdownMenuItem<String>>
                                                modulItems = snapshot.data!.docs
                                                    .map((DocumentSnapshot
                                                        document) {
                                              String tahunAjaran =
                                                  document['tahunAjaran'];
                                              return DropdownMenuItem<String>(
                                                value: tahunAjaran,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0),
                                                  child: Text(
                                                    tahunAjaran,
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                ),
                                              );
                                            }).toList();

                                            return Container(
                                              height: 47.0,
                                              width: 360.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade700),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: DropdownButton<String>(
                                                value: selectedTahunAjaran,
                                                hint: const Text(
                                                  '   Pilih Tahun Ajaran',
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                items: modulItems,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedTahunAjaran =
                                                        newValue;
                                                  });
                                                },
                                                isExpanded: true,
                                                dropdownColor: Colors.white,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 14.0,
                                                ),
                                                underline: Container(),
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.grey,
                                                ),
                                                iconSize: 24,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              //== Waktu Praktikum, Tahun Ajaran ==//
                              SizedBox(
                                  height: 425.0,
                                  width: 525.0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //== Hari Praktikum ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30.0, top: 18.0),
                                        child: Text('Hari Praktikum',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 30.0),
                                        child: SizedBox(
                                            width: screenWidth > 250.0
                                                ? 430.0
                                                : screenWidth,
                                            height: 47.0,
                                            child:
                                                DropdownButtonFormField<String>(
                                              value: selectedDay,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedDay = newValue;
                                                });
                                              },
                                              items: days.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value));
                                              }).toList(),
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'Pilih Hari Praktikum',
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
                                            left: 30.0, top: 18.0),
                                        child: Text('Waktu Praktikum',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 30.0,
                                        ),
                                        child: SizedBox(
                                            width: screenWidth > 250.0
                                                ? 430.0
                                                : screenWidth,
                                            height: 47.0,
                                            child: TextField(
                                                readOnly: true,
                                                controller:
                                                    waktuPraktikumController,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Masukkan Waktu Praktikum',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10.0)),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    suffixIcon: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(Icons
                                                              .access_time),
                                                          onPressed: () =>
                                                              _selectTime(
                                                                  context,
                                                                  isStartTime:
                                                                      true),
                                                          tooltip: 'Waktu Awal',
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child: Text(
                                                            '-',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons
                                                              .access_time),
                                                          onPressed: () =>
                                                              _selectTime(
                                                                  context,
                                                                  isStartTime:
                                                                      false),
                                                          tooltip:
                                                              'Waktu Berakhir',
                                                        ),
                                                      ],
                                                    )))),
                                      ),
                                      //== Ruang Praktikum ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30.0, top: 15.0),
                                        child: Text('Ruang Praktikum',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 70.0, left: 30.0),
                                        child: SizedBox(
                                            width: screenWidth > 250.0
                                                ? 430.0
                                                : screenWidth,
                                            height: 47.0,
                                            child:
                                                DropdownButtonFormField<String>(
                                              value: selectedRuangPraktikum,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedRuangPraktikum =
                                                      newValue;
                                                });
                                              },
                                              items: ruangan.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value));
                                              }).toList(),
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'Pilih Ruangan Praktikum',
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  filled: true,
                                                  fillColor: Colors.white),
                                            )),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 320.0),
                                        child: SizedBox(
                                          height: screenHeight > 40.0
                                              ? 40.0
                                              : screenHeight,
                                          width: screenWidth > 80.0
                                              ? 130.0
                                              : screenWidth,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF3CBEA9)),
                                              onPressed: () async {
                                                _saveDataToFirestore();
                                              },
                                              child: Text('Simpan Data',
                                                  style: GoogleFonts.quicksand(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 23.0)
            ],
          ),
        ),
      ),
    );
  }
}
