// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FormEditDataAsisten extends StatefulWidget {
  final String idkelas;
  final String mataKuliah;
  final String kode;
  const FormEditDataAsisten(
      {super.key,
      required this.idkelas,
      required this.mataKuliah,
      required this.kode});

  @override
  State<FormEditDataAsisten> createState() => _FormEditDataAsistenState();
}

class _FormEditDataAsistenState extends State<FormEditDataAsisten> {
  //== Fungsi Controller  ==//
  TextEditingController nimAsistenController = TextEditingController();
  TextEditingController nimAsisten2Controller = TextEditingController();
  TextEditingController nimAsisten3Controller = TextEditingController();
  TextEditingController nimAsisten4Controller = TextEditingController();

  //== Fungsi untuk menampilkan data dari Firestore 'dataAsisten'==//
  Future<void> fetchDataAsisten() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('dataAsisten')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();

        setState(() {
          nimAsistenController.text = data['nim'].toString();
          nimAsisten2Controller.text = data['nim2'].toString();
          nimAsisten3Controller.text = data['nim3'].toString();
          nimAsisten4Controller.text = data['nim4'].toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data tidak ditemukan di database'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataAsisten();
  }

//== Fungsi untuk menyimpan data ==//
  Future<void> editData() async {
    String nimAsisten = nimAsistenController.text;
    String nimAsisten2 = nimAsisten2Controller.text;
    String nimAsisten3 = nimAsisten3Controller.text;
    String nimAsisten4 = nimAsisten4Controller.text;

    // Daftar NIM dari TextField
    List<String> nims = [nimAsisten, nimAsisten2, nimAsisten3, nimAsisten4];

    // Menghitung jumlah TextField yang tidak kosong
    int filledFields = nims.where((element) => element.isNotEmpty).length;

    // Pengecekan minimal harus mengisi 2 TextField
    if (filledFields < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal mengisi TextField sebanyak 2 kolom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Pengecekan apakah NIM bertipe integer dan validasi agar tidak ada NIM yang sama

    List<int> nimValues = [];

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

        nimValues.add(parsedNim);
      }
    }

    // Tambahkan 0 untuk NIM yang kosong
    while (nimValues.length < 4) {
      nimValues.add(0);
    }

    int nimAsistenValue = nimValues[0];
    int nimAsisten2Value = nimValues[1];
    int nimAsisten3Value = nimValues[2];
    int nimAsisten4Value = nimValues[3];

    try {
      // Mendapatkan referensi dokumen berdasarkan idTA
      var querySnapshot = await FirebaseFirestore.instance
          .collection('dataAsisten')
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data tidak ditemukan di database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var documentId = querySnapshot.docs.first.id;

      // Fungsi untuk mengupdate data
      await FirebaseFirestore.instance
          .collection('dataAsisten')
          .doc(documentId)
          .update({
        'nim': nimAsistenValue,
        'nim2': nimAsisten2Value,
        'nim3': nimAsisten3Value,
        'nim4': nimAsisten4Value,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      nimAsistenController.clear();
      nimAsisten2Controller.clear();
      nimAsisten3Controller.clear();
      nimAsisten4Controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data: $e')),
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

                // Navigator.push(
                //   context,
                //   PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) =>
                //         DataAsistenScreen(
                //       mataKuliah: widget.mataKuliah,
                //       idkelas: widget.idkelas,
                //       kode: widget.kode,
                //     ),
                //     transitionsBuilder:
                //         (context, animation, secondaryAnimation, child) {
                //       const begin = Offset(0.0, 0.0);
                //       const end = Offset.zero;
                //       const curve = Curves.ease;

                //       var tween = Tween(begin: begin, end: end)
                //           .chain(CurveTween(curve: curve));

                //       return SlideTransition(
                //         position: animation.drive(tween),
                //         child: child,
                //       );
                //     },
                //   ),
                // );
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
                      '',
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
                  height: screenHeight > 420 ? 440.0 : screenHeight,
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
                                height: 340.0,
                                width: 475.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //===================//
                                    //== NIM Asisten 1 ==//
                                    //==================//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
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
                                  ],
                                ),
                              ),

                              //== Row 2 ==//
                              //=== NIM Asisten 3 dan 4===//
                              SizedBox(
                                height: 340.0,
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
                                              onPressed: editData,
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
