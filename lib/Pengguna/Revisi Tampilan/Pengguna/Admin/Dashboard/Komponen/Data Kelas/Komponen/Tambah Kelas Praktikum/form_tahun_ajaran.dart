// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Screen/tahun_ajaran_screen.dart';

class FormTahunAjaran extends StatefulWidget {
  final String mataKuliah;
  final String kodeMatakuliah;

  const FormTahunAjaran({
    super.key,
    required this.mataKuliah,
    required this.kodeMatakuliah,
  });

  @override
  State<FormTahunAjaran> createState() => _FormTahunAjaranState();
}

class _FormTahunAjaranState extends State<FormTahunAjaran> {
  //== Fungsi Controller ==//
  final TextEditingController _tahunAjaranController = TextEditingController();
  final TextEditingController kodeKelasController = TextEditingController();
//== Fungsi DropdownButton 'Semester' ==//
  String? selectedSemester;

//== DropdownButton Memilih Semester ==//
  final List<String> semester = [
    'Pilih Semester Praktikum',
    'Ganjil',
    'Genap',
  ];

//== Fungsi untuk menyimpan data ==//
  Future<void> _simpanData(BuildContext context) async {
    final tahunAjaran = _tahunAjaranController.text;
    final kodeKelas = kodeKelasController.text;

    if (tahunAjaran.isEmpty ||
        kodeKelas.isEmpty ||
        selectedSemester == 'Pilih Semester Praktikum') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi data yang dibutuhkan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    //== Validasi panjang kode kelas 8 huruf atau 8 angka ==//
    if (kodeKelas.length != 8) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan idKelas dengan 8 huruf atau 8 angka'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      //== Validasi apabila idTahunAjaran sudah ada di database ==//
      final idTahunAjaranSnapshot = await FirebaseFirestore.instance
          .collection('dataKelasPraktikum')
          .where('idKelas', isEqualTo: kodeKelas)
          .get();

      if (idTahunAjaranSnapshot.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('idKelas telah terdaftar pada database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      //== Validasi apabila tahun ajaran dan kode Matakuliah sama ==//
      final querySnapshot = await FirebaseFirestore.instance
          .collection('dataKelasPraktikum')
          .where('tahunAjaran', isEqualTo: tahunAjaran)
          .where('kodeMatakuliah', isEqualTo: widget.kodeMatakuliah)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Data tahun ajaran pada matakuliah telah terdapat pada database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('dataKelasPraktikum').add({
        'idKelas': kodeKelas,
        'tahunAjaran': tahunAjaran,
        'kodeMatakuliah': widget.kodeMatakuliah,
        'matakuliah': widget.mataKuliah,
        'semester': selectedSemester,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      _tahunAjaranController.clear();
      kodeKelasController.clear();
      setState(() {
        selectedSemester = 'Pilih Semester Praktikum';
      });
    } catch (e) {
      if (!mounted) return;
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
                      TahunAjaranScreen(
                    mataKuliah: widget.mataKuliah,
                    kodeMatakuliah: widget.kodeMatakuliah,
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
                                        controller: _tahunAjaranController,
                                        decoration: InputDecoration(
                                            hintText: 'Masukkan Tahun Ajaran',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(9),
                                        ]),
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
                                            selectedSemester = newValue;
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
                                          _simpanData(context);
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

// Helper class untuk mengubah teks menjadi huruf besar
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
