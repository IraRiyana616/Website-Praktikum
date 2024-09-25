import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormDeskripsiKelas extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  final String idkelas;
  const FormDeskripsiKelas(
      {super.key,
      required this.kodeKelas,
      required this.mataKuliah,
      required this.idkelas});

  @override
  State<FormDeskripsiKelas> createState() => _FormDeskripsiKelasState();
}

class _FormDeskripsiKelasState extends State<FormDeskripsiKelas> {
  //== Deskrispi Kelas ==//
  final TextEditingController _deskripsiKelasController =
      TextEditingController();

  //== Peralatan Belajar ==//
  final TextEditingController _softwareController = TextEditingController();
  final TextEditingController _hardwareController = TextEditingController();

  //== Jumlah kata maksimum yang diizinkan pada Deskripsi Kelas ==//
  int _remainingWords = 500;
  void updateRemainingWords(String text) {
    //== Menghitung sisa kata dan memperbaharui state ==//
    int currentWordCount = text.split('').length;
    int remaining = 500 - currentWordCount;

    setState(() {
      _remainingWords = remaining;
    });
    //== Memeriksa apakah sisa kaa sudah mencapai 0 ==//
    if (_remainingWords <= 0) {
      //== Menonaktifkan pengeditan jika sisa kata habis ==//
      _deskripsiKelasController.text =
          _deskripsiKelasController.text.substring(0, 500);
      _deskripsiKelasController.selection = TextSelection.fromPosition(
          TextPosition(offset: _deskripsiKelasController.text.length));
    }
  }

  //== Menghubungkan ke saveSilabus Screen pada Firebase ==//
  void _saveDeskripsi() async {
    //== Mendapatkan instance Firestore ==//
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    //== Mendapatkan reference untuk collection 'kelas_praktikum ==//
    CollectionReference silabusCollection =
        firestore.collection('deskripsiKelas');

    //== Memeriksa apakah semua textfield telah diisi ==//
    if (_deskripsiKelasController.text.isEmpty ||
        _softwareController.text.isEmpty ||
        _hardwareController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap isi semua kolom'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    //== Mengecheck apakah kode_asisten terdapat dalam Firestore 'token_asisten' ==//
    QuerySnapshot kodeAsistenSnapshot = await firestore
        .collection('dataAsisten')
        .where('idKelas', isEqualTo: widget.idkelas)
        .get();

    //== Jika kode_asisten tidak ditemukan ==//
    if (kodeAsistenSnapshot.docs.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data tidak terdapat pada database'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    //== Menyimpan kelas praktikum ke Firestore dengan document_id nomor urut ==//
    await silabusCollection.doc().set({
      //== Kode Kelas dan Deskripsi Kelas ==//
      'idKelas': widget.idkelas,
      'matakuliah': widget.mataKuliah,
      'deskripsikelas': _deskripsiKelasController.text,

      //== Peralatan Belajar ==//

      'perangkatLunak': _softwareController.text,
      'perangkatKeras': _hardwareController.text,
    });

    //== Tampilkan Pesan Sukses ==//
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2)));

    //== Clear TextField ==//
    //== Deskripsi Kelas ==//

    _deskripsiKelasController.clear();

    //== Peralatan belajar ==//

    _softwareController.clear();
    _hardwareController.clear();
  }

  //== Nama Akun ==//
  User? _currentUser;
  String _namaMahasiswa = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Fungsi untuk mendapatkan pengguna yang sedang login dan mengambil data nama dari database
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _getCurrentUser() async {
    setState(() {
      _currentUser = _auth.currentUser;
    });
    if (_currentUser != null) {
      await _getNamaMahasiswa(_currentUser!.uid);
    }
  }

  // Fungsi untuk mengambil nama mahasiswa dari database
  Future<void> _getNamaMahasiswa(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('akun_mahasiswa').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _namaMahasiswa = doc.get('nama');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching nama mahasiswa: $e');
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
              // Navigator.push(
              //   context,
              //   PageRouteBuilder(
              //     pageBuilder: (context, animation, secondaryAnimation) =>
              //         const DasboardAsistenNavigasi(),
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
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 400.0,
                ),
                if (_currentUser != null) ...[
                  Text(
                    _namaMahasiswa.isNotEmpty
                        ? _namaMahasiswa
                        : (_currentUser!.email ?? ''),
                    style: GoogleFonts.quicksand(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 30.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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
                              border:
                                  Border.all(width: 0.5, color: Colors.grey)),
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
                              child: Text(
                                'Deskripsi Kelas',
                                style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            //== Pengumpulan ==//
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 45.0, right: 45.0),
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
//== Komponen Deskripsi Kelas ==//
                            Padding(
                              padding: const EdgeInsets.only(left: 95.0),
                              child: SizedBox(
                                width: 826.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== Deskripsi Kelas ==//
                                    Text(
                                      'Deskripsi Kelas',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    //== TextField Deskripsi Kelas ==//
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width: 600.0,
                                        height: 300.0,
                                        child: TextField(
                                          controller: _deskripsiKelasController,
                                          maxLines: 10,
                                          onChanged: (text) {
                                            updateRemainingWords(text);
                                          },
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Deskripsi Kelas',
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
                                            const EdgeInsets.only(left: 470.0),
                                        child: Text(
                                            'Sisa Kata: $_remainingWords/500',
                                            style: const TextStyle(
                                                color: Colors.grey))),
                                    //== ElevatedButton 'SIMPAN DATA' ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0.0, top: 10.0),
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    const Color(0xFF3CBEA9)),
                                            fixedSize:
                                                MaterialStateProperty.all<Size>(
                                              const Size(150.0, 45.0),
                                            ),
                                          ),
                                          onPressed: _saveDeskripsi,
                                          child: Text(
                                            'Simpan Data',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //== Komponen Peralatan Belajar ==//
                            Padding(
                              padding: const EdgeInsets.only(right: 95.0),
                              child: SizedBox(
                                width: 350.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== Peralatan Belajar ==//
                                    Text(
                                      'Peralatan Belajar',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'Peralatan yang dibutuhkan :',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 15.0),
                                      ),
                                    ),

                                    //== Perangkat Lunak (Software) ==//
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: 40.0,
                                              width: 40.0,
                                              child: Image.asset(
                                                  'assets/images/os.png')),
                                          const SizedBox(width: 15.0),
                                          Text(
                                            'Perangkat Lunak',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width: 320.0,
                                        child: TextField(
                                          controller: _softwareController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Software yang dibutuhkan',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    //== Perangkat Keras (Hardware) ==//
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: 40.0,
                                              width: 40.0,
                                              child: Image.asset(
                                                  'assets/images/processor.png')),
                                          const SizedBox(width: 15.0),
                                          Text(
                                            'Perangkat Keras',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width: 320.0,
                                        child: TextField(
                                          controller: _hardwareController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Hardware yang dibutuhkan',
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
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 50.0,
                        )
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
