// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../Screen/silabus.dart';

class TambahSilabusPraktikum extends StatefulWidget {
  final String idKelas;
  final String mataKuliah;
  final String kodeMatakuliah;
  const TambahSilabusPraktikum(
      {super.key,
      required this.idKelas,
      required this.mataKuliah,
      required this.kodeMatakuliah});

  @override
  State<TambahSilabusPraktikum> createState() => _TambahSilabusPraktikumState();
}

class _TambahSilabusPraktikumState extends State<TambahSilabusPraktikum> {
  //== Fungsi Cntroller ==//
  final TextEditingController judulModulController = TextEditingController();
  final TextEditingController idModulController = TextEditingController();
  String _fileName = "";
  String selectedPertemuan = 'Pertemuan Praktikum';

  void saveData(BuildContext context) async {
    String judulModul = judulModulController.text.trim();
    String keymodul = idModulController.text.trim();
    String modulPraktikum = _fileName;
    String pertemuanPraktikum = selectedPertemuan;

    // == Validasi jika ada kolom yang tidak diisi == //
    if (judulModul.isEmpty ||
        pertemuanPraktikum.isEmpty ||
        keymodul.isEmpty ||
        modulPraktikum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data harap diisi semua'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // == Validasi idModul tidak boleh memasukkan lebih dari satu kali == //
      final idModulQuerySnapshot = await FirebaseFirestore.instance
          .collection('silabusMatakuliah')
          .where('idKelas', isEqualTo: widget.idKelas)
          .where('idModul', isEqualTo: keymodul)
          .get();

      if (idModulQuerySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('idModul telah terdapat pada database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // == Validasi judulModul tidak boleh memasukkan lebih dari satu kali == //
      final judulModulQuerySnapshot = await FirebaseFirestore.instance
          .collection('silabusMatakuliah')
          .where('idKelas', isEqualTo: widget.idKelas)
          .where('judulModul', isEqualTo: judulModul)
          .get();

      if (judulModulQuerySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Judul modul telah terdapat pada database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // == Validasi pertemuan tidak boleh memasukkan lebih dari satu kali == //
      final pertemuanQuerySnapshot = await FirebaseFirestore.instance
          .collection('silabusMatakuliah')
          .where('idKelas', isEqualTo: widget.idKelas)
          .where('pertemuan', isEqualTo: pertemuanPraktikum)
          .get();

      if (pertemuanQuerySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertemuan telah terdapat pada database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('silabusMatakuliah').add({
        'idKelas': widget.idKelas,
        'idModul': keymodul,
        'judulModul': judulModul,
        'namaFile': modulPraktikum,
        'pertemuan': pertemuanPraktikum,
      });

      // == Validasi sistem dapat menyimpan data == //
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      judulModulController.clear();
      idModulController.clear();
      setState(() {
        _fileName = '';
        selectedPertemuan = 'Pertemuan Praktikum';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  //== Fungsi Untuk Upload File ==//

  void _uploadFile() async {
    setState(() {});

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Uploading..."),
              ],
            ),
          ),
        );
      },
    );

    String idKelas = widget.idKelas;
    String judulModul = judulModulController.text;

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$idKelas/$judulModul/${file.name}');

      try {
        if (kIsWeb) {
          await ref.putData(file.bytes!);
        } else {
          await ref.putFile(File(file.path!));
        }
        setState(() {
          _fileName = file.name;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during upload: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File selection cancelled'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {});

    Navigator.of(context).pop(); // Close the loading dialog
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
                      SilabusScreen(
                    kodeMatakuliah: widget.kodeMatakuliah,
                    mataKuliah: widget.mataKuliah,
                    idkelas: widget.idKelas,
                  ),
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
                    widget.mataKuliah,
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
                  height: screenHeight > 400.0 ? 430.0 : screenHeight,
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
                          "Silabus Praktikum",
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
                          //== idModul dan Judul Modul
                          Column(
                            children: [
                              SizedBox(
                                height: 300.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== id Modul ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        "id Modul",
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
                                          controller: idModulController,
                                          decoration: InputDecoration(
                                              hintText: 'Masukkan id Modul',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
//=== Judul Modul ===//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 25.0),
                                      child: Text(
                                        "Judul Materi",
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
                                          controller: judulModulController,
                                          decoration: InputDecoration(
                                              hintText: 'Masukkan Judul Materi',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
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
                                height: 300.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== Pertemuan ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        "Pertemuan",
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
                                          child: Container(
                                            height: 50.0,
                                            width: 980.0,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade700),
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            child: DropdownButton<String>(
                                              value: selectedPertemuan,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedPertemuan = newValue!;
                                                });
                                              },
                                              items: [
                                                'Pertemuan Praktikum',
                                                'Pertemuan 1',
                                                'Pertemuan 2',
                                                'Pertemuan 3',
                                                'Pertemuan 4',
                                                'Pertemuan 5',
                                                'Pertemuan 6',
                                                'Pertemuan 7',
                                                'Pertemuan 8',
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem(
                                                    value: value,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15.0),
                                                      child: Text(
                                                        value,
                                                        style: const TextStyle(
                                                            fontSize: 16.0),
                                                      ),
                                                    ));
                                              }).toList(),
                                              style: TextStyle(
                                                  color: Colors.grey.shade700),
                                              icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.grey),
                                              iconSize: 24,
                                              elevation: 16,
                                              isExpanded: true,
                                              underline: Container(),
                                            ),
                                          )),
                                    ),
//=== Nama File ===//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 25.0),
                                      child: Text(
                                        "Nama File",
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
                                        child: Stack(
                                          children: [
                                            TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Nama File Modul',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              controller: TextEditingController(
                                                  text: _fileName),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0, left: 300.0),
                                              child: SizedBox(
                                                height: 40.0,
                                                width: 120.0,
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                const Color(
                                                                    0xFF3CBEA9)),
                                                  ),
                                                  onPressed: () async {
                                                    _uploadFile();
                                                    setState(() {});
                                                  },
                                                  child: Text(
                                                    'Upload File',
                                                    style:
                                                        GoogleFonts.quicksand(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    //== ElevatedButton 'SIMPAN' ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 27.0, left: 350.0),
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
