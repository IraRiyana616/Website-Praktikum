// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Mahasiswa/Asisten/Absensi/Form/Screen/absensi_ass.dart';

class FormJadwalPraktikumAdmin extends StatefulWidget {
  const FormJadwalPraktikumAdmin({super.key});

  @override
  State<FormJadwalPraktikumAdmin> createState() =>
      _FormJadwalPraktikumAdminState();
}

class _FormJadwalPraktikumAdminState extends State<FormJadwalPraktikumAdmin> {
  //== Controller ==//
  TextEditingController kodeKelasController = TextEditingController();
  TextEditingController mataKuliahController = TextEditingController();
  TextEditingController waktuPraktikumController = TextEditingController();
  TextEditingController tahunAjaranController = TextEditingController();

  //== Koleksi dari Database ==//
  final CollectionReference _dataJadwalCollection =
      FirebaseFirestore.instance.collection('jadwalPraktikum');

  Future<void> _saveDataToFirestore(Map<String, dynamic> data) async {
    try {
      //== Validasi untuk Memastikan Tidak Ada TextField yang Kosong ==//
      if (kodeKelasController.text.isEmpty ||
          mataKuliahController.text.isEmpty ||
          selectedDay == null ||
          selectedDay == 'Pilih Hari Praktikum' ||
          waktuPraktikumController.text.isEmpty ||
          tahunAjaranController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Harap lengkapi semua field'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      } else {
        //== Cek apakah kodeKelas terdapat dalam database dataKelas ==//
        var kodeKelasExists = await FirebaseFirestore.instance
            .collection('dataKelas')
            .doc(kodeKelasController.text)
            .get();

        if (!kodeKelasExists.exists) {
          //== Tampilkan Pesan Kesalahan Jika kodeKelas tidak ditemukan di database ==
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Kode praktikum tidak terdapat pada database'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ));
        } else {
          //== Validasi untuk Memastikan Tidak Ada Data yang Sama Pada Kode Kelas yang Sama.
          var existingData = await _dataJadwalCollection
              .where('kodeKelas', isEqualTo: kodeKelasController.text)
              .get();
          if (existingData.docs.isNotEmpty) {
            //== Tampilkan Pesan Kesalahan Jika Data Sudah Ada di Database
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Data telah terdapat pada database'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ));
          } else {
            //== Jika Tidak Ada Kesalahan, Simpan Data ke Firestore
            await _dataJadwalCollection.add(data);
            //== Tampilkan Pesan Sukses ==//
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Data berhasil disimpan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ));
            //== Clear Semua TextField Setelah Data diSimpan ==//
            kodeKelasController.clear();
            mataKuliahController.clear();
            setState(() {
              selectedDay = null;
            });
            waktuPraktikumController.clear();
            tahunAjaranController.clear();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  //== DropdownButton Memilih Hari ==//
  String? selectedDay;
  final List<String> days = [
    'Pilih Hari Praktikum',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jum\'at'
  ];
  //== Memilih Waktu ==//
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        waktuPraktikumController.text = picked.format(context);
      });
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
                  tag: 'backButton',
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                )),
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
                    'Formulir Jadwal Praktikum',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
                  const SizedBox(
                    width: 800.0,
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
                width: 1050.0,
                height: 510.0,
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
                        'Formulir Tambah Jadwal Praktikum',
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
                        //== Kode Praktikum, MataKuliah, Hari Praktikum ===//
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 400.0,
                              width: 525.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //== Kode Kelas ==//
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 18.0),
                                    child: Text(
                                      'Kode Praktikum',
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
                                          LengthLimitingTextInputFormatter(6),
                                          UpperCaseTextFormatter(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //== MataKuliah ==//
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 15.0),
                                    child: Text('MataKuliah',
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
                                      width: 430.0,
                                      child: TextField(
                                        controller: mataKuliahController,
                                        decoration: InputDecoration(
                                            hintText: 'Masukkan MataKuliah',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white),
                                      ),
                                    ),
                                  ),
                                  //== Jadwal Praktikum ==//
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 15.0),
                                    child: Text('Hari Praktikum',
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
                                        width: 430.0,
                                        child: DropdownButtonFormField<String>(
                                          value: selectedDay,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedDay = newValue;
                                            });
                                          },
                                          items: days
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value));
                                          }).toList(),
                                          decoration: InputDecoration(
                                              hintText: 'Pilih Hari Praktikum',
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
                                        top: 30.0, left: 70.0),
                                    child: SizedBox(
                                      height: 40.0,
                                      width: 130.0,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF3CBEA9)),
                                          onPressed: () {
                                            _saveDataToFirestore({
                                              'kodeKelas':
                                                  kodeKelasController.text,
                                              'mataKuliah':
                                                  mataKuliahController.text,
                                              'hariPraktikum': selectedDay,
                                              'waktuPraktikum':
                                                  waktuPraktikumController.text,
                                              'tahunAjaran':
                                                  tahunAjaranController.text
                                            });
                                            kodeKelasController.clear();
                                            mataKuliahController.clear();
                                            setState(() {
                                              selectedDay = null;
                                            });
                                            waktuPraktikumController.clear();
                                            tahunAjaranController.clear();
                                          },
                                          child: Text('Simpan Data',
                                              style: GoogleFonts.quicksand(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            //== Waktu Praktikum, Tahun Ajaran ==//
                            SizedBox(
                                height: 400.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== Waktu Praktikum ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, top: 18.0),
                                      child: Text('Waktu Praktikum',
                                          style: GoogleFonts.quicksand(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 70.0, left: 30.0),
                                      child: SizedBox(
                                        width: 430.0,
                                        child: TextField(
                                          controller: waktuPraktikumController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: 'Pilih Waktu Praktikum',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            suffixIcon: IconButton(
                                              icon:
                                                  const Icon(Icons.access_time),
                                              onPressed: () {
                                                _selectTime(context);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //== Tahun Ajaran ==//
                                    //== Waktu Praktikum ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, top: 15.0),
                                      child: Text('Tahun Ajaran',
                                          style: GoogleFonts.quicksand(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 70.0, left: 30.0),
                                      child: SizedBox(
                                        width: 430.0,
                                        child: TextField(
                                          controller: tahunAjaranController,
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
                                  ],
                                ))
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 23.0)
          ],
        ),
      ),
    );
  }
}
