// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditTahunAjaran extends StatefulWidget {
  final String kodeMatakuliah;
  final String mataKuliah;
  final String tahun;
  final String idkelas;
  const EditTahunAjaran({
    super.key,
    required this.kodeMatakuliah,
    required this.mataKuliah,
    required this.tahun,
    required this.idkelas,
  });

  @override
  State<EditTahunAjaran> createState() => _EditTahunAjaranState();
}

class _EditTahunAjaranState extends State<EditTahunAjaran> {
  //== Fungsi Controller ==//
  final TextEditingController tahunAjaranController = TextEditingController();
  final TextEditingController kodeKelasController = TextEditingController();

  //== Fungsi DropdownButton 'Semester' ==//
  String selectedSemester = 'Pilih Semester Praktikum';

  //== DropdownButton Memilih Hari ==//
  final List<String> semester = [
    'Pilih Semester Praktikum',
    'Ganjil',
    'Genap',
  ];

  //== Fungsi untuk menampilkan data ==//
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('dataKelasPraktikum')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      if (userData.docs.isNotEmpty) {
        var data = userData.docs.first.data();
        if (mounted) {
          setState(() {
            tahunAjaranController.text = data['tahunAjaran'] ?? '';
            kodeKelasController.text = data['idKelas'] ?? '';
            selectedSemester = data['semester'] ?? 'Pilih Semester Praktikum';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            tahunAjaranController.text = '';
            kodeKelasController.text = '';
            selectedSemester = 'Pilih Semester Praktikum';
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

  //= Fungsi untuk menyimpan data ke database =//
  void saveData(BuildContext context, String documentId) async {
    // Validasi jika ada kolom yang tidak diisi
    if (kodeKelasController.text.isEmpty ||
        tahunAjaranController.text.isEmpty ||
        selectedSemester == 'Pilih Semester Praktikum') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data harap diisi semua'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi panjang kodeKelas 8 huruf atau 8 angka
    if (kodeKelasController.text.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan idKelas dengan 8 huruf atau 8 angka'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Pengecekan apakah kombinasi idKelas, tahunAjaran, dan semester sudah ada
      QuerySnapshot querySnapshotCombination = await FirebaseFirestore.instance
          .collection('dataKelasPraktikum')
          .where('kodeMatakuliah', isEqualTo: widget.kodeMatakuliah)
          .where('idKelas', isEqualTo: kodeKelasController.text)
          .where('tahunAjaran', isEqualTo: tahunAjaranController.text)
          .where('semester', isEqualTo: selectedSemester)
          .get();

      if (querySnapshotCombination.docs.isNotEmpty &&
          querySnapshotCombination.docs.first.id != documentId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data telah terdaftar pada database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Jika semua pengecekan lolos, simpan atau update data
      await FirebaseFirestore.instance
          .collection('dataKelasPraktikum')
          .doc(documentId) // Gunakan documentId untuk update
          .set({
        'kodeMatakuliah': widget.kodeMatakuliah,
        'matakuliah': widget.mataKuliah,
        'idKelas': kodeKelasController.text,
        'tahunAjaran': tahunAjaranController.text,
        'semester': selectedSemester
      });

      // Berhasil menyimpan data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
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
                  width: screenWidth > 500.0 ? 550.0 : screenWidth,
                  height: screenHeight > 820.0 ? 860.0 : screenHeight,
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
                          "Formulir Tambah Tahun Ajaran",
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
                            height: 540.0,
                            width: 525.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //== Kode Kelas ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 18.0),
                                  child: Text(
                                    "id Kelas",
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
                                        controller: kodeKelasController,
                                        decoration: InputDecoration(
                                            hintText: 'Masukkan Kode Kelas',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(8),
                                          UpperCaseTextFormatter()
                                        ]),
                                  ),
                                ),
                                //== Tahun Ajaran ==//
                                const SizedBox(
                                  height: 15.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 18.0),
                                  child: Text(
                                    "Tahun Ajaran",
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
                                      controller: tahunAjaranController,
                                      decoration: InputDecoration(
                                          hintText: 'Masukkan Tahun Ajaran',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          filled: true,
                                          fillColor: Colors.white),
                                    ),
                                  ),
                                ),
                                //== Semester Praktikum ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, right: 30.0, top: 23.0),
                                  child: Text('Semester Praktikum',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold)),
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
                                      child: DropdownButtonFormField<String>(
                                        value: selectedSemester,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedSemester = newValue!;
                                          });
                                        },
                                        items: semester
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                              value: value, child: Text(value));
                                        }).toList(),
                                        decoration: InputDecoration(
                                            hintText:
                                                'Pilih Semester Praktikum',
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
                                      top: 30.0, left: 340.0),
                                  child: SizedBox(
                                    height: screenHeight > 45.0
                                        ? 45.0
                                        : screenHeight,
                                    width:
                                        screenWidth > 100.0 ? 160 : screenWidth,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF3CBEA9),
                                        ),
                                        onPressed: () {
                                          saveData(context, widget.idkelas);
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
