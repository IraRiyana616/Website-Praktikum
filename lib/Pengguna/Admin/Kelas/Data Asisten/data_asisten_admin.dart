// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DataAsistenAdmin extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const DataAsistenAdmin(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<DataAsistenAdmin> createState() => _DataAsistenAdminState();
}

class _DataAsistenAdminState extends State<DataAsistenAdmin> {
  //== Nama Asisten ==//
  TextEditingController namaAsistenController = TextEditingController();
  TextEditingController namaAsisten2Controller = TextEditingController();
  TextEditingController namaAsisten3Controller = TextEditingController();
  TextEditingController namaAsisten4Controller = TextEditingController();

  //== NIM Asisten ==//
  TextEditingController nimAsistenController = TextEditingController();
  TextEditingController nimAsisten2Controller = TextEditingController();
  TextEditingController nimAsisten3Controller = TextEditingController();
  TextEditingController nimAsisten4Controller = TextEditingController();

  //== Koleksi dari Database ==//
  final CollectionReference _dataAsistenCollection =
      FirebaseFirestore.instance.collection('dataAsisten');

  //== Fungsi untuk menyimpan data ==//
  Future<void> _saveDataToFirestore(Map<String, dynamic> data) async {
    try {
      //== Validasi untuk memastikan tidak ada TextField yang kosong ==//
      if (namaAsistenController.text.isEmpty ||
          namaAsisten2Controller.text.isEmpty ||
          nimAsistenController.text.isEmpty ||
          nimAsisten2Controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Minimal Mengisi 2 Data Asisten'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      } else {
        // Validasi untuk memastikan tidak ada data yang sama pada kode kelas yang sama.
        var existingData = await _dataAsistenCollection
            .where('kodeKelas', isEqualTo: widget.kodeKelas)
            .get();
        if (existingData.docs.isNotEmpty) {
          //== Tampilka pesan jika data telah terdapat pada database ==//
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data Telah Terdapat Pada Database'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ));
        } else {
          //== Jika tida ada kesalahan, simpan data ke Firestore
          await _dataAsistenCollection.add(data);

          //== Tampilkan Pesan Sukses ==
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Data Berhasil disimpan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3)));

          //== Menghapus Semua TextField yang Telah disimpan
          namaAsistenController.clear();
          namaAsisten2Controller.clear();
          namaAsisten3Controller.clear();
          namaAsisten4Controller.clear();
          nimAsistenController.clear();
          nimAsisten2Controller.clear();
          nimAsisten3Controller.clear();
          nimAsisten4Controller.clear();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
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
                    'Data Asisten Praktikum',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
                  const SizedBox(
                    width: 800.0,
                  ),
                ],
              ),
            ),
          )),
      body: SingleChildScrollView(
        child: Container(
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
                  width: 900.0,
                  height: 620.0,
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
                          widget.mataKuliah,
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
                          //== Row 1 //===
                          //== Nama Asisten 1 dan 2, Serta NIM Asisten 1 dan 2 ==//
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 420.0,
                                width: 450.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //===============//
                                    //== Nama Asisten 1==//
                                    //==============//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        "Nama Asisten ",
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
                                        width: 330.0,
                                        child: TextField(
                                          controller: namaAsistenController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Nama Asisten 1',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),

                                    //===================//
                                    //== NIM Asisten 1 ==//
                                    //==================//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "NIM Asisten ",
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
                                        width: 330.0,
                                        child: TextField(
                                          controller: nimAsistenController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan NIM Asisten 1',
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

                                    //===================//
                                    //== Nama Asisten 2 ==//
                                    //==================//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "Nama Asisten ",
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
                                        width: 330.0,
                                        child: TextField(
                                          controller: namaAsisten2Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Nama Asisten 2',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    //=================//
                                    //== NIM Asisten 2 ==//
                                    //===============//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "NIM Asisten ",
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
                                        width: 330.0,
                                        child: TextField(
                                          controller: nimAsisten2Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan NIM Asisten 2',
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

                              //== Row 2 ==//
                              //=== Nama Asisten 3 dan 4, serta NIM Asisten 3 dan 4 ===//
                              SizedBox(
                                height: 420.0,
                                width: 450.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //===============//
                                    //== Nama Asisten 3==//
                                    //==============//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 18.0, left: 60.0),
                                      child: Text(
                                        "Nama Asisten ",
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
                                          left: 60.0, right: 30.0),
                                      child: SizedBox(
                                        width: 330.0,
                                        child: TextField(
                                          controller: namaAsisten3Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Nama Asisten 3',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),

                                    //===================//
                                    //== NIM Asisten 3 ==//
                                    //==================//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 60.0, top: 15.0),
                                      child: Text(
                                        "NIM Asisten ",
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
                                          left: 60.0, right: 30.0),
                                      child: SizedBox(
                                        width: 330.0,
                                        child: TextField(
                                          controller: nimAsisten3Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan NIM Asisten 3',
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

                                    //===================//
                                    //== Nama Asisten 4 ==//
                                    //==================//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 60.0, top: 15.0),
                                      child: Text(
                                        "Nama Asisten ",
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
                                          left: 60.0, right: 30.0),
                                      child: SizedBox(
                                        width: 330.0,
                                        child: TextField(
                                          controller: namaAsisten4Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Nama Asisten 4',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    //=================//
                                    //== NIM Asisten 4 ==//
                                    //===============//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 60.0, top: 15.0),
                                      child: Text(
                                        "NIM Asisten ",
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
                                          left: 60.0, right: 30.0),
                                      child: SizedBox(
                                        width: 330.0,
                                        child: TextField(
                                          controller: nimAsisten4Controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan NIM Asisten 4',
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
                          //== ElevatedButton 'SIMPAN DATA' ==//
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, left: 600.0),
                            child: SizedBox(
                                height: 45.0,
                                width: 180.0,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF3CBEA9)),
                                    onPressed: () {
                                      _saveDataToFirestore({
                                        'kodeKelas': widget.kodeKelas,
                                        'mataKuliah': widget.mataKuliah,
                                        'namaAsisten':
                                            namaAsistenController.text,
                                        'nimAsisten': nimAsistenController.text,
                                        'namaAsisten2':
                                            namaAsisten2Controller.text,
                                        'nimAsisten2':
                                            nimAsisten2Controller.text,
                                        'namaAsisten3':
                                            namaAsisten3Controller.text,
                                        'nimAsisten3':
                                            nimAsisten3Controller.text,
                                        'namaAsisten4':
                                            namaAsisten4Controller.text,
                                        'nimAsisten4':
                                            nimAsisten4Controller.text,
                                      });
                                      namaAsistenController.clear();
                                      namaAsisten2Controller.clear();
                                      namaAsisten3Controller.clear();
                                      namaAsisten4Controller.clear();
                                      nimAsistenController.clear();
                                      nimAsisten2Controller.clear();
                                      nimAsisten3Controller.clear();
                                      nimAsistenController.clear();
                                    },
                                    child: Text('Simpan Data',
                                        style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.bold)))),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30.0)
            ],
          ),
        ),
      ),
    );
  }
}
