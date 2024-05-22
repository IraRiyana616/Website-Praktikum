import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FormKelasAdmin extends StatefulWidget {
  const FormKelasAdmin({super.key});

  @override
  State<FormKelasAdmin> createState() => _FormKelasAdminState();
}

class _FormKelasAdminState extends State<FormKelasAdmin> {
  final CollectionReference _dataKelasCollection =
      FirebaseFirestore.instance.collection('dataKelas');

  //== Kode Kelas, Kode Asisten, Tahun Ajaran dan MataKuliah ==//
  final TextEditingController _kodeKelasController = TextEditingController();
  final TextEditingController _kodeAsistenController = TextEditingController();
  final TextEditingController _tahunAjaranController = TextEditingController();
  final TextEditingController _mataKuliahController = TextEditingController();

  //== Dosen Pengampu 1, NIP Dosen Pengampu 1, Dosen Pengampu 2 dan NIP Dosen Pengampu 2 ==//
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
      // Validasi untuk memastikan tidak ada TextField yang kosong
      if (_kodeKelasController.text.isEmpty ||
          _kodeAsistenController.text.isEmpty ||
          _tahunAjaranController.text.isEmpty ||
          _mataKuliahController.text.isEmpty ||
          _dosenPengampu1Controller.text.isEmpty ||
          _nipDosenPengampu1Controller.text.isEmpty ||
          _dosenPengampu2Controller.text.isEmpty ||
          _nipDosenPengampu2Controller.text.isEmpty) {
        // Tampilkan pesan kesalahan jika ada TextField yang kosong
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap lengkapi semua field'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Validasi untuk memastikan tidak ada data yang sama pada kode kelas dan kode asisten
        var existingData = await _dataKelasCollection
            .where('kodeKelas', isEqualTo: _kodeKelasController.text)
            .where('kodeAsisten', isEqualTo: _kodeAsistenController.text)
            .get();

        if (existingData.docs.isNotEmpty) {
          // Tampilkan pesan kesalahan jika data sudah ada di database
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Data dengan kode kelas dan kode asisten tersebut sudah ada'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Jika tidak ada kesalahan, simpan data ke Firestore
          await _dataKelasCollection.add(data);

          // Tampilkan pesan sukses
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil disimpan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Clear semua TextField setelah data disimpan
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
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Hero(
                tag: "backButton",
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
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
                  width: 1050.0,
                  height: 700.0,
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
                          //ROW 1
                          Row(
                            children: [
                              SizedBox(
                                height: 480.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //===============//
                                    //== Kode Kelas==//
                                    //==============//
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
                                        width: 430.0,
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
                                    //===================//
                                    //== Kode Asisten ==//
                                    //==================//
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
                                        width: 430.0,
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
                                    //===================//
                                    //== Tahun Ajaran ==//
                                    //==================//
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
                                    //=================//
                                    //== MataKuliah ==//
                                    //===============//
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
                                        width: 430.0,
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

                              /// ROW 2
                              SizedBox(
                                height: 480.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //============================//
                                    //== Nama Dosen Pengampu 1 ==//
                                    //==========================//
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
                                        width: 430.0,
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
                                    //============================//
                                    //== NIP Dosen Pengampu 1 ==//
                                    //==========================//
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
                                        width: 430.0,
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
                                    //============================//
                                    //== Nama Dosen Pengampu 2 ==//
                                    //==========================//
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
                                        width: 430.0,
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
                                    //============================//
                                    //== NIP Dosen Pengampu 2 ==//
                                    //==========================//
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
                                        width: 430.0,
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
                          )
                        ],
                      ),
                      //===============================//
                      //== ElevatedButton 'SIMPAN' ==//
                      //============================//
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 805.0),
                        child: SizedBox(
                          height: 45.0,
                          width: 180.0,
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
