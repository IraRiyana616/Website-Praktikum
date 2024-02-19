import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FormKelasDosen extends StatefulWidget {
  const FormKelasDosen({super.key});

  @override
  State<FormKelasDosen> createState() => _FormKelasDosenState();
}

class _FormKelasDosenState extends State<FormKelasDosen> {
  final CollectionReference _dataKelasCollection =
      FirebaseFirestore.instance.collection('data_kelas');

  final TextEditingController _kodeKelasController = TextEditingController();
  final TextEditingController _kodeAsistenController = TextEditingController();
  final TextEditingController _tahunAjaranController = TextEditingController();
  final TextEditingController _mataKuliahController = TextEditingController();
  final TextEditingController _jumlahAsistenController =
      TextEditingController();
  final TextEditingController _jumlahMahasiswaController =
      TextEditingController();

  Future<void> _saveDataToFirestore(Map<String, dynamic> data) async {
    try {
      // Validasi untuk memastikan tidak ada TextField yang kosong
      if (_kodeKelasController.text.isEmpty ||
          _kodeAsistenController.text.isEmpty ||
          _tahunAjaranController.text.isEmpty ||
          _mataKuliahController.text.isEmpty ||
          _jumlahAsistenController.text.isEmpty ||
          _jumlahMahasiswaController.text.isEmpty) {
        // Tampilkan pesan kesalahan jika ada TextField yang kosong
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap lengkapi semua field'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Validasi untuk memastikan "Jumlah Mahasiswa" dan "Jumlah Asisten" berupa angka
        if (!_isNumeric(_jumlahMahasiswaController.text) ||
            !_isNumeric(_jumlahAsistenController.text)) {
          // Tampilkan pesan kesalahan jika bukan angka
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Jumlah Mahasiswa dan Jumlah Asisten harus berupa angka'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Validasi untuk memastikan tidak ada data yang sama pada kode kelas dan kode asisten
          var existingData = await _dataKelasCollection
              .where('kode_kelas', isEqualTo: _kodeKelasController.text)
              .where('kode_asisten', isEqualTo: _kodeAsistenController.text)
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
            _jumlahAsistenController.clear();
            _jumlahMahasiswaController.clear();
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  // Fungsi utilitas untuk memeriksa apakah suatu string adalah angka
  bool _isNumeric(String value) {
    // ignore: unnecessary_null_comparison
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
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
                    'Formulir Kelas',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
                  const SizedBox(
                    width: 800.0,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.black,
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, left: 70.0),
                                    child: Text(
                                      "**Contoh kode kelas (Prodi_Matakuliah_Tahun) => (TESD23)",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                  ),
                                  //Kode Asisten
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
                                  //MataKuliah
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 15.0),
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
                                      width: 450.0,
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
                                  //Jumlah Asisten
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 35.0),
                                    child: Text(
                                      "Jumlah Asisten",
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
                                        controller: _jumlahAsistenController,
                                        decoration: InputDecoration(
                                            hintText: 'Masukkan Jumlah Asisten',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(2)
                                        ],
                                      ),
                                    ),
                                  ),
                                  //Jumlah Mahasiswa
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70.0, top: 35.0),
                                    child: Text(
                                      "Jumlah Mahasiswa",
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
                                        controller: _jumlahMahasiswaController,
                                        decoration: InputDecoration(
                                            hintText:
                                                'Masukkan Jumlah Mahasiswa',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(2)
                                        ],
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
                                          onPressed: () {
                                            _saveDataToFirestore({
                                              'kode_kelas':
                                                  _kodeKelasController.text,
                                              'kode_asisten':
                                                  _kodeAsistenController.text,
                                              'tahun_ajaran':
                                                  _tahunAjaranController.text,
                                              'matakuliah':
                                                  _mataKuliahController.text,
                                              'jumlah_asisten':
                                                  _jumlahAsistenController.text,
                                              'jumlah_mahasiswa':
                                                  _jumlahMahasiswaController
                                                      .text
                                            });
                                            _kodeKelasController.clear();
                                            _kodeAsistenController.clear();
                                            _tahunAjaranController.clear();
                                            _mataKuliahController.clear();
                                            _jumlahAsistenController.clear();
                                            _jumlahMahasiswaController.clear();
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
