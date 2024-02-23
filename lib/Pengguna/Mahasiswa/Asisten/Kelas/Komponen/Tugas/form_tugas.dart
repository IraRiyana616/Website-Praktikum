import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Navigation/kelas_assnav.dart';
import '../Deskripsi/form_deskripsi.dart';
import '../Laporan/form_laporan.dart';

class FormPengumpulanTugas extends StatefulWidget {
  const FormPengumpulanTugas({super.key});

  @override
  State<FormPengumpulanTugas> createState() => _FormPengumpulanTugasState();
}

class _FormPengumpulanTugasState extends State<FormPengumpulanTugas> {
  final TextEditingController _deskripsiTugasController =
      TextEditingController();
  final TextEditingController _judulModulController = TextEditingController();
  final TextEditingController _kodeKelasController = TextEditingController();

  //Jumlah kata maksimum yang diizinkan pada deskripsi kelas
  int _remainingWords = 1500;
  void updateRemainingWords(String text) {
    //Menghitung sisa kata dan memperbaharui state
    int currentWordCount = text.split('').length;
    int remaining = 1500 - currentWordCount;

    setState(() {
      _remainingWords = remaining;
    });
    //Memeriksa apakah sisa kata mencapai 0
    if (_remainingWords <= 0) {
      //Menonaktifkan pengeditan jika sisa kata habis
      _deskripsiTugasController.text =
          _deskripsiTugasController.text.substring(0, 2500);
      _deskripsiTugasController.selection = TextSelection.fromPosition(
          TextPosition(offset: _deskripsiTugasController.text.length));
    }
  }

  // Menambah fungsi untuk mengecek kode kelas
  Future<bool> _checkKodeKelas(String kodeKelas) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    //Menggunakan collection 'data_kelas' sebagai referensi
    CollectionReference kelasCollection = firestore.collection('token_asisten');
    //Melakukan query untuk mencari data dengan kode kelas yang sesuai
    QuerySnapshot querySnapshot =
        await kelasCollection.where('kode_kelas', isEqualTo: kodeKelas).get();
    //Mengembalikan true jika data ditemukan, false jika tidak
    return querySnapshot.docs.isNotEmpty;
  }

  //Menghubungkan ke saveTugasForm pada Firebase
  void _saveTugasForm() async {
    //Memeriksa apakah kode kelas terdapat dalam Firestore 'data_kelas'
    bool isKodeKelasValid = await _checkKodeKelas(_kodeKelasController.text);
    //Jika tidak valid, tampilkan snackbar dan berhenti eksekusi
    if (!isKodeKelasValid) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Kode kelas tidak terdapat pada database'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    //Mendapatkan instance Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    //Mendapatka reference untuk collection 'pengumpulan_tugas'
    CollectionReference tugasCollection =
        firestore.collection('pengumpulan_tugas');

    //Mengambil data terakhir di collection untuk mendapatkan nomor urut
    QuerySnapshot querySnapshot = await tugasCollection.get();
    int documentCount = querySnapshot.docs.length;

    //Membuat nomor urut berikutnya
    int nextDocumentId = documentCount + 1;
    //Menyimpan pengumpulan tugas ke Firestore dengan document_id nomor urut
    await tugasCollection.doc(nextDocumentId.toString()).set({
      'kode_kelas': _kodeKelasController.text,
      'deskripsiTugas': _deskripsiTugasController.text,
      'judulModul': _judulModulController.text,
    });
    //Tampilkan pesan sukses
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data berhasil disimpan'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
    //Clear TextField
    _kodeKelasController.clear();
    _judulModulController.clear();
    _deskripsiTugasController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const KelasAsistenNav()));
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
                    'Kelas Praktikum',
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
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5, color: Colors.grey)),
                        height: 320.0,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/kelas.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 38.0, left: 95.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FormDeskripsiKelas()));
                              },
                              child: Text(
                                'Deskripsi Kelas',
                                style: GoogleFonts.quicksand(fontSize: 16.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 50.0, top: 38.0),
                            child: Text(
                              'Tugas',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 50.0, top: 38.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FormPengempulanLaporan()));
                              },
                              child: Text(
                                'Laporan',
                                style: GoogleFonts.quicksand(fontSize: 16.0),
                              ),
                            ),
                          )
                        ],
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 45.0, right: 45.0),
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 90.0),
                            child: SizedBox(
                              // width: 826.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Kode Asisten
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Kode Asisten',
                                              style: GoogleFonts.quicksand(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: SizedBox(
                                                width: 580.0,
                                                child: TextField(
                                                  controller:
                                                      _kodeKelasController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Masukkan Kode Asisten',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Judul Modul
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0, left: 40.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Judul Modul',
                                              style: GoogleFonts.quicksand(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: SizedBox(
                                                width: 580.0,
                                                child: TextField(
                                                  controller:
                                                      _judulModulController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Masukkan Judul Modul',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Text(
                                      'Deskripsi Tugas',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  //TextField
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: SizedBox(
                                      width: 1200.0,
                                      height: 300.0,
                                      child: TextField(
                                        controller: _deskripsiTugasController,
                                        maxLines: 10,
                                        onChanged: (text) {
                                          updateRemainingWords(text);
                                        },
                                        decoration: InputDecoration(
                                            hintText:
                                                'Masukkan Deskripsi Tugas',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 40.0,
                                                    horizontal: 15.0),
                                            filled: true,
                                            fillColor: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 1065.0),
                                    child: Text(
                                      'Sisa Kata: $_remainingWords/1500',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFF3CBEA9)),
                                          fixedSize: MaterialStateProperty.all(
                                              const Size(150.0, 45.0))),
                                      onPressed: _saveTugasForm,
                                      child: Text(
                                        'Simpan Data',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  const SizedBox(
                                    height: 20.0,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
