// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormDataKelas extends StatefulWidget {
  const FormDataKelas({Key? key}) : super(key: key);

  @override
  State<FormDataKelas> createState() => _FormDataKelasState();
}

class _FormDataKelasState extends State<FormDataKelas> {
  final CollectionReference _dataKelasCollection =
      FirebaseFirestore.instance.collection('dataKelas');

  final TextEditingController _kodeKelasController = TextEditingController();
  final TextEditingController _kodeAsistenController = TextEditingController();
  final TextEditingController _tahunAjaranController = TextEditingController();
  final TextEditingController _mataKuliahController = TextEditingController();
  final TextEditingController _dosenPengampu1Controller =
      TextEditingController();
  final TextEditingController _nipDosenPengampu1Controller =
      TextEditingController();
  final TextEditingController _dosenPengampu2Controller =
      TextEditingController();
  final TextEditingController _nipDosenPengampu2Controller =
      TextEditingController();

  Future<void> _saveDataToFirestore(Map<String, dynamic> data) async {
    try {
      if (_kodeKelasController.text.isEmpty ||
          _kodeAsistenController.text.isEmpty ||
          _tahunAjaranController.text.isEmpty ||
          _mataKuliahController.text.isEmpty ||
          _dosenPengampu1Controller.text.isEmpty ||
          _nipDosenPengampu1Controller.text.isEmpty ||
          _dosenPengampu2Controller.text.isEmpty ||
          _nipDosenPengampu2Controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap lengkapi semua field'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        var existingData = await _dataKelasCollection
            .where('kodeKelas', isEqualTo: _kodeKelasController.text)
            .where('kodeAsisten', isEqualTo: _kodeAsistenController.text)
            .get();

        if (existingData.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Data dengan kode kelas dan kode asisten tersebut sudah ada'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          await _dataKelasCollection.add(data);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil disimpan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          _kodeKelasController.clear();
          _kodeAsistenController.clear();
          _tahunAjaranController.clear();
          _mataKuliahController.clear();
          _dosenPengampu1Controller.clear();
          _nipDosenPengampu1Controller.clear();
          _dosenPengampu2Controller.clear();
          _nipDosenPengampu2Controller.clear();
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
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
              Navigator.pushReplacementNamed(context, '/dashboard');
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
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    'Formulir Kelas',
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
                  width: screenWidth > 900.0 ? 1050.0 : screenWidth,
                  height: screenHeight > 400.0 ? 700.0 : screenHeight,
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
                          "Formulir Tambah Kelas",
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
                          Row(
                            children: [
                              SizedBox(
                                height: 480.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        "Kode Praktikum",
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
                                            controller: _kodeKelasController,
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Masukkan Kode Praktikum',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                filled: true,
                                                fillColor: Colors.white),
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  8)
                                            ]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, left: 70.0),
                                      child: Text(
                                        "**Contoh kode praktikum (Prodi_Matakuliah_Tahun) => (TESD23)",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "Kode Asisten",
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
                                          controller: _kodeAsistenController,
                                          decoration: InputDecoration(
                                              hintText: 'Masukkan Kode Asisten',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(8)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, left: 70.0),
                                      child: Text(
                                        "**Contoh kode asisten (Tahun_MataKuliah_Prodi) => (23SDTE)",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                    ),
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
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 28.0),
                                      child: Text(
                                        "MataKuliah",
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
                                          controller: _mataKuliahController,
                                          decoration: InputDecoration(
                                              hintText: 'Masukkan MataKuliah',
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
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 480.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, top: 18.0),
                                      child: Text(
                                        "Dosen Pengampu 1",
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
                                          left: 30.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: TextField(
                                          controller: _dosenPengampu1Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Nama Dosen Pengampu',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, top: 34.0),
                                      child: Text(
                                        "NIP Dosen Pengampu 1",
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
                                          left: 30.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: TextField(
                                          controller:
                                              _nipDosenPengampu1Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan NIP Dosen Pengampu',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, top: 34.0),
                                      child: Text(
                                        "Dosen Pengampu 2",
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
                                          left: 30.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: TextField(
                                          controller: _dosenPengampu2Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Nama Dosen Pengampu 2',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, top: 28.0),
                                      child: Text(
                                        "NIP Dosen Pengampu 2",
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
                                          left: 30.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: TextField(
                                          controller:
                                              _nipDosenPengampu2Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan NIP Dosen Pengampu 2',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 805.0),
                        child: SizedBox(
                          height: screenHeight > 45.0 ? 45.0 : screenHeight,
                          width: screenWidth > 100.0 ? 180 : screenWidth,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3CBEA9),
                              ),
                              onPressed: () {
                                _saveDataToFirestore({
                                  'kodeKelas': _kodeKelasController.text,
                                  'kodeAsisten': _kodeAsistenController.text,
                                  'tahunAjaran': _tahunAjaranController.text,
                                  'mataKuliah': _mataKuliahController.text,
                                  'dosenPengampu':
                                      _dosenPengampu1Controller.text,
                                  'nipDosenPengampu':
                                      _nipDosenPengampu1Controller.text,
                                  'dosenPengampu2':
                                      _dosenPengampu2Controller.text,
                                  'nipDosenPengampu2':
                                      _nipDosenPengampu2Controller.text
                                });
                                _kodeKelasController.clear();
                                _kodeAsistenController.clear();
                                _tahunAjaranController.clear();
                                _mataKuliahController.clear();
                                _dosenPengampu1Controller.clear();
                                _nipDosenPengampu1Controller.clear();
                                _dosenPengampu2Controller.clear();
                                _nipDosenPengampu2Controller.clear();
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
