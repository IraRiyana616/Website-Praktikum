// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Data Kelas/Komponen/Edit Kelas Praktikum/edit_tahun_ajaran.dart';

class FormDataAsisten extends StatefulWidget {
  final String kodeMatakuliah;
  final String mataKuliah;
  final String idkelas;
  const FormDataAsisten({
    super.key,
    required this.kodeMatakuliah,
    required this.mataKuliah,
    required this.idkelas,
  });

  @override
  State<FormDataAsisten> createState() => _FormDataAsistenState();
}

class _FormDataAsistenState extends State<FormDataAsisten> {
  //== Fungsi Controller  ==//
  TextEditingController idAsistenController = TextEditingController();
  TextEditingController nimAsistenController = TextEditingController();
  TextEditingController nimAsisten2Controller = TextEditingController();
  TextEditingController nimAsisten3Controller = TextEditingController();
  TextEditingController nimAsisten4Controller = TextEditingController();

//== Fungsi untuk menyimpan data ==//
  Future<void> saveData() async {
    String idAsisten = idAsistenController.text;
    String nimAsisten = nimAsistenController.text;
    String nimAsisten2 = nimAsisten2Controller.text;
    String nimAsisten3 = nimAsisten3Controller.text;
    String nimAsisten4 = nimAsisten4Controller.text;

    // Pengecekan tidak boleh ada kolom yang kosong
    if ([idAsisten, nimAsisten, nimAsisten2, nimAsisten3, nimAsisten4]
        .every((element) => element.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pada kolom tidak boleh kosong semua'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Pengecekan apakah NIM bertipe integer dan tidak duplikat
    List<String> nims = [nimAsisten, nimAsisten2, nimAsisten3, nimAsisten4];
    Set<String> nimSet = {};

    for (var nim in nims) {
      if (nim.isNotEmpty) {
        int? parsedNim = int.tryParse(nim);
        if (parsedNim == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NIM harus bertipe angka'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (nimSet.contains(nim)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NIM tidak boleh duplikat'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        } else {
          nimSet.add(nim);
        }
      }
    }

    // Pengecekan idAsisten pada Database
    var existingIdAsisten = await FirebaseFirestore.instance
        .collection('dataAsisten')
        .where('idKelas', isEqualTo: widget.idkelas)
        .where('idAsisten', isEqualTo: idAsisten)
        .get();

    if (existingIdAsisten.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('idAsisten telah terdaftar pada database'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Pengecekan idTA pada Database
    var existingIdTA = await FirebaseFirestore.instance
        .collection('dataAsisten')
        .where('kodeMatakuliah', isEqualTo: widget.kodeMatakuliah)
        .where('idKelas', isEqualTo: widget.idkelas)
        .get();

    if (existingIdTA.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data telah terdapat pada database'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Fungsi untuk menyimpan data
      await FirebaseFirestore.instance.collection('dataAsisten').add({
        'idKelas': widget.idkelas,
        'idAsisten': idAsisten,
        'nim': nimAsisten.isNotEmpty ? int.parse(nimAsisten) : 0,
        'nim2': nimAsisten2.isNotEmpty ? int.parse(nimAsisten2) : 0,
        'nim3': nimAsisten3.isNotEmpty ? int.parse(nimAsisten3) : 0,
        'nim4': nimAsisten4.isNotEmpty ? int.parse(nimAsisten4) : 0,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      idAsistenController.clear();
      nimAsistenController.clear();
      nimAsisten2Controller.clear();
      nimAsisten3Controller.clear();
      nimAsisten4Controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
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
                  Expanded(
                      child: Text(
                    widget.mataKuliah,
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
                  width: screenWidth > 750.0 ? 950.0 : screenWidth,
                  height: screenHeight > 420 ? 470.0 : screenHeight,
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
                                height: 370.0,
                                width: 475.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //===============//
                                    //== Id Asisten ==//
                                    //==============//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        "idAsisten",
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
                                        width: screenWidth > 230
                                            ? 330
                                            : screenWidth,
                                        child: TextField(
                                            controller: idAsistenController,
                                            decoration: InputDecoration(
                                                hintText: 'Masukkan ID Asisten',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                filled: true,
                                                fillColor: Colors.white),
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  10),
                                              UpperCaseTextFormatter()
                                            ]),
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
                                        width: screenWidth > 230
                                            ? 330
                                            : screenWidth,
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
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                        ),
                                      ),
                                    ),

                                    //===================//
                                    //== NIM Asisten 2 ==//
                                    //==================//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "NIM Asisten 2 ",
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
                                        width: screenWidth > 230
                                            ? 330
                                            : screenWidth,
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
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //== Row 2 ==//
                              //=== NIM Asisten 3 dan 4===//
                              SizedBox(
                                height: 370.0,
                                width: 475.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //===============//
                                    //== NIM Asisten 3 ==//
                                    //==============//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 18.0, left: 70.0),
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
                                        width: screenWidth > 230
                                            ? 330
                                            : screenWidth,
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
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                        ),
                                      ),
                                    ),

                                    //===================//
                                    //== NIM Asisten 4 ==//
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
                                        width: screenWidth > 230
                                            ? 330
                                            : screenWidth,
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
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                        ),
                                      ),
                                    ),
                                    //== ElevatedButton 'SIMPAN DATA' ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 25.0, left: 270.0),
                                      child: SizedBox(
                                          height: screenHeight > 45.0
                                              ? 45.0
                                              : screenHeight,
                                          width: screenWidth > 130.0
                                              ? 130
                                              : screenWidth,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF3CBEA9)),
                                              onPressed: saveData,
                                              child: Text('Simpan Data',
                                                  style: GoogleFonts.quicksand(
                                                      fontWeight:
                                                          FontWeight.bold)))),
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
              const SizedBox(height: 1000.0)
            ],
          ),
        ),
      ),
    );
  }
}
