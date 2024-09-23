// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../deskripsi_kelas_asisten.dart';

class EditDataSilabus extends StatefulWidget {
  final String idkelas;
  final String modul;
  final String kodeMatakuliah;
  final String matakuliah;
  final String idModul;
  const EditDataSilabus(
      {super.key,
      required this.idkelas,
      required this.modul,
      required this.kodeMatakuliah,
      required this.matakuliah,
      required this.idModul});

  @override
  State<EditDataSilabus> createState() => _EditDataSilabusState();
}

class _EditDataSilabusState extends State<EditDataSilabus> {
  //== Fungsi Authentikasi ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //== Fungsi Nama Mahasiswa ==//
  User? _currentUser;
  String _namaMahasiswa = '';

  //== Nama Akun ==//
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUserData();
  }

  // Fungsi untuk mendapatkan pengguna yang sedang login dan mengambil data nama dari database
  void _getCurrentUser() async {
    setState(() {
      _currentUser = _auth.currentUser;
    });
    if (_currentUser != null) {
      await _getNamaMahasiswa(_currentUser!.uid);
    }
  }

  // Fungsi untuk mengambil nama mahasiswa dari database
  Future<void> _getNamaMahasiswa(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('akun_mahasiswa').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _namaMahasiswa = doc.get('nama');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching nama mahasiswa: $e');
      }
    }
  }

  //===//

  //== Fungsi Cntroller ==//
  final TextEditingController judulModulController = TextEditingController();
  String _fileName = "";
  String selectedPertemuan = 'Pertemuan Praktikum';

  //== Fungsi untuk menampilkan data ==//
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('silabusMatakuliah')
          .where('idKelas', isEqualTo: widget.idkelas)
          .where('idModul', isEqualTo: widget.idModul)
          .get();

      if (userData.docs.isNotEmpty) {
        var data = userData.docs.first.data();
        if (mounted) {
          setState(() {
            judulModulController.text = data['judulModul'] ?? '';
            _fileName = data['namaFile'] ?? '';
            selectedPertemuan = data['pertemuan'] ?? '';
          });
        }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
  }

//== Fungsi untuk mengedit data pada Silabus Matakuliah ===//
  Future<void> updateData(BuildContext context) async {
    String pertemuanPraktikum = selectedPertemuan;
    String modulPraktikum = _fileName;

    if (judulModulController.text.isEmpty ||
        modulPraktikum.isEmpty ||
        pertemuanPraktikum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi data yang dibutuhkan')),
      );
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('silabusMatakuliah')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      bool isModulNameDuplicate = false;
      bool isPertemuanDuplicate = false;
      String? documentIdToUpdate;

      for (var doc in querySnapshot.docs) {
        if (doc['idModul'] == widget.idModul) {
          documentIdToUpdate = doc.id;
          continue; // Skip the document that matches the current idModul
        }
        if (doc['judulModul'] == judulModulController.text) {
          isModulNameDuplicate = true;
        }
        if (doc['pertemuan'] == pertemuanPraktikum) {
          isPertemuanDuplicate = true;
        }
      }

      if (isModulNameDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama modul sudah ada pada idKelas yang sama'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (isPertemuanDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertemuan sudah ada pada idKelas yang sama'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (documentIdToUpdate != null) {
        await FirebaseFirestore.instance
            .collection('silabusMatakuliah')
            .doc(documentIdToUpdate)
            .update({
          'idModul': widget.idModul,
          'idKelas': widget.idkelas,
          'judulModul': judulModulController.text,
          'namaFile': modulPraktikum,
          'pertemuan': pertemuanPraktikum,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
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

    String idKelas = widget.idkelas;
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
                      DeskripsiKelasAsisten(
                    kode: widget.kodeMatakuliah,
                    mataKuliah: widget.matakuliah,
                    idkelas: widget.idkelas,
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
                    widget.modul,
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const Spacer(),
                if (_currentUser != null) ...[
                  Text(
                    _namaMahasiswa.isNotEmpty
                        ? _namaMahasiswa
                        : (_currentUser!.email ?? ''),
                    style: GoogleFonts.quicksand(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                ],
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
                  width: screenWidth > 540.0 ? 570.0 : screenWidth,
                  height: screenHeight > 500.0 ? 530.0 : screenHeight,
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
                      Column(
                        children: [
                          SizedBox(
                            height: 400.0,
                            width: 525.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                                  BorderRadius.circular(10.0)),
                                          filled: true,
                                          fillColor: Colors.white),
                                    ),
                                  ),
                                ),
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
                                                color: Colors.grey.shade700),
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
                                                  BorderRadius.circular(10.0),
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
                                                        .all<Color>(const Color(
                                                            0xFF3CBEA9)),
                                              ),
                                              onPressed: () async {
                                                _uploadFile();
                                                setState(() {});
                                              },
                                              child: Text(
                                                'Upload File',
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
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
                                    width:
                                        screenWidth > 100.0 ? 140 : screenWidth,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF3CBEA9),
                                        ),
                                        onPressed: () {
                                          updateData(context);
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
                height: 1000.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
