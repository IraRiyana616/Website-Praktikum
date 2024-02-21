// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FormEvaluasiDosen extends StatefulWidget {
  const FormEvaluasiDosen({super.key});

  @override
  State<FormEvaluasiDosen> createState() => _FormEvaluasiDosenState();
}

class _FormEvaluasiDosenState extends State<FormEvaluasiDosen> {
  final TextEditingController _kodeKelasController = TextEditingController();
  final TextEditingController _tahunAjaranController = TextEditingController();
  final TextEditingController _lulusController = TextEditingController();
  final TextEditingController _tidakController = TextEditingController();
  final TextEditingController _hasilEvaluasiController =
      TextEditingController();
  Future<void> _saveEvaluation() async {
    String kodeKelas = _kodeKelasController.text;

    if (kodeKelas.isNotEmpty) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('data_evaluasi')
          .where('kode_kelas',
              isEqualTo:
                  kodeKelas) // Memeriksa apakah kode kelas sudah ada di koleksi 'data_evaluasi'
          .get();

      // Jika tidak ada dokumen dengan kode kelas yang sama
      if (querySnapshot.docs.isEmpty) {
        var kelasQuerySnapshot = await FirebaseFirestore.instance
            .collection('data_kelas')
            .where('kode_kelas', isEqualTo: kodeKelas)
            .get();

        if (kelasQuerySnapshot.docs.isNotEmpty) {
          await FirebaseFirestore.instance.collection('data_evaluasi').add({
            'kode_kelas': kodeKelas,
            'tahun_ajaran': _tahunAjaranController.text,
            'jumlah_lulus': _lulusController.text,
            'jumlah_tidak_lulus': _tidakController.text,
            'hasil_evaluasi': _hasilEvaluasiController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil disimpan'),
              duration: Duration(seconds: 2),
            ),
          );

          _kodeKelasController.clear();
          _tahunAjaranController.clear();
          _lulusController.clear();
          _tidakController.clear();
          _hasilEvaluasiController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kode kelas tidak ditemukan'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode kelas sudah ada dalam data evaluasi'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode kelas'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF7F8FA),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )),
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    'Formulir Evaluasi',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
                  const SizedBox(
                    width: 750.0,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout,
                        color: Color(0xFF031F31),
                      )),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Log out',
                    style: GoogleFonts.quicksand(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF031F31)),
                  ),
                  const SizedBox(
                    width: 50.0,
                  )
                ],
              ),
            ),
          )),
      body: Container(
        color: const Color(0xFFE3E8EF),
        width: 2000.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30.0,
            ),
            Center(
              child: Container(
                width: 1200.0,
                height: 530.0,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 25.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 70.0),
                      child: Text(
                        "Tambahkan Evaluasi Praktikum",
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
                        //ROW 1
                        Row(
                          children: [
                            SizedBox(
                              height: 440.0,
                              width: 580.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Kode Kelas
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 15.0),
                                    child: Text(
                                      "Kode Kelas",
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
                                      width: 430.0,
                                      child: TextField(
                                          controller: _kodeKelasController,
                                          decoration: InputDecoration(
                                              hintText: 'Masukkan Kode Kelas',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(8)
                                          ]),
                                    ),
                                  ),

                                  //Tahun Ajaran
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 15.0),
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
                                      width: 430.0,
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
                                      ),
                                    ),
                                  ),
                                  //Lulus Praktikum
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 15.0),
                                    child: Text(
                                      "Jumlah Mahasiswa Lulus Praktikum",
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
                                      width: 430.0,
                                      child: TextField(
                                        controller: _lulusController,
                                        decoration: InputDecoration(
                                            hintText:
                                                'Masukkan Jumlah Mahasiswa Lulus Praktikum',
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

                            /// ROW 2
                            SizedBox(
                              height: 440.0,
                              width: 580.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Jumlah Mahasiswa Tidak Lulus Praktikum
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 15.0),
                                    child: Text(
                                      "Jumlah Mahasiswa Tidak Lulus Praktikum",
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
                                      width: 450.0,
                                      child: TextField(
                                        controller: _tidakController,
                                        decoration: InputDecoration(
                                            hintText:
                                                'Masukkan Jumlah Mahasiswa Tidak Lulus Praktikum',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(20)
                                        ],
                                      ),
                                    ),
                                  ),
                                  //Evaluasi
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 25.0),
                                    child: Text(
                                      "Hasil Evaluasi Praktikum",
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
                                      width: 450.0,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: TextField(
                                          controller: _hasilEvaluasiController,
                                          maxLines: 5,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Catatan Evaluasi Kegiatan Praktikum',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 40.0,
                                                      horizontal: 15.0)),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 30.0, left: 390.0),
                                    child: SizedBox(
                                      height: 40.0,
                                      width: 130.0,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF3CBEA9),
                                          ),
                                          onPressed: _saveEvaluation,
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
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            )
          ],
        ),
      ),
    );
  }
}
