// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../deskripsi_kelas_asisten.dart';
import '../Tugas/tugas.dart';
import 'Edit Latihan/edit_latihan.dart';

class PengumpulanLatihan extends StatefulWidget {
  final String judulModul;
  final String idkelas;
  final String matkul;
  final String kode;
  const PengumpulanLatihan(
      {super.key,
      required this.judulModul,
      required this.idkelas,
      required this.matkul,
      required this.kode});

  @override
  State<PengumpulanLatihan> createState() => _PengumpulanLatihanState();
}

class _PengumpulanLatihanState extends State<PengumpulanLatihan> {
  //=== Fungsi untuk menampilkan data ===//
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentUser();
  }

  //== Load Data dari Database ==//
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('Pengumpulan')
          .where('idKelas', isEqualTo: widget.idkelas)
          .where('judulModul', isEqualTo: widget.judulModul)
          .where('jenisPengumpulan', isEqualTo: 'Latihan')
          .get();
      if (userData.docs.isNotEmpty) {}
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
  }

// Fungsi async untuk memeriksa keberadaan kodeKelas dan judulMateri dalam Firestore
  Future<bool> checkDataExist(String kodeKelas, String modul) async {
    bool exists = false;

    // Melakukan query ke Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Pengumpulan')
        .where('idKelas', isEqualTo: widget.idkelas)
        .where('judulModul', isEqualTo: widget.judulModul)
        .where('jenisPengumpulan', isEqualTo: 'Latihan')
        .get();

    // Jika data ditemukan, set exists menjadi true
    if (querySnapshot.docs.isNotEmpty) {
      exists = true;
    }

    return exists;
  }

//===
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //== Fungsi Nama Mahasiswa ==//
  User? _currentUser;
  String _namaMahasiswa = '';

  // Fungsi untuk mendapatkan pengguna yang sedang login dan mengambil data nama dari database
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
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DeskripsiKelasAsisten(
                    kode: widget.kode,
                    idkelas: widget.idkelas,
                    mataKuliah: widget.matkul,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
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
                    widget.judulModul,
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const Spacer(),
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
                ],
                const SizedBox(width: 10.0)
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Pengumpulan')
            .where('idKelas', isEqualTo: widget.idkelas)
            .where('judulModul', isEqualTo: widget.judulModul)
            .where('jenisPengumpulan', isEqualTo: 'Latihan')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error:${snapshot.error}'),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/404.png',
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'Data tidak ditemukan',
                    style: GoogleFonts.quicksand(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Container(
                  color: const Color(0xFFE3E8EF),
                  width: 2000.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 65.0, right: 65.0, top: 20.0),
                        child: Center(
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 75.0, right: 100.0, top: 55.0),
                                  child: Text(
                                    '${data['deskripsiPengumpulan'] ?? 'Not available'}',
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      height: 2.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 75.0, top: 20.0),
                                    child: SizedBox(
                                      height: 45.0,
                                      width: 150.0,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            const Color(0xFF3CBEA9),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  EditLatihan(
                                                idkelas: widget.idkelas,
                                                modul: widget.judulModul,
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(0.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));

                                                return SlideTransition(
                                                  position:
                                                      animation.drive(tween),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 3.0),
                                            const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 5.0),
                                            Text(
                                              'Edit Data',
                                              style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                const SizedBox(height: 35.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 800.0),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          color: const Color(0xFFF7F8FA),
          child: Padding(
            padding: const EdgeInsets.only(right: 70.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    // Memeriksa keberadaan data sebelum melakukan navigasi
                    bool dataExists =
                        await checkDataExist(widget.idkelas, widget.judulModul);
                    if (dataExists) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) => Tugas(
                            idkelas: widget.idkelas,
                            modul: widget.judulModul,
                            kode: widget.kode,
                            matakuliah: widget.matkul,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    } else {
                      // Tampilkan pesan atau lakukan aksi lain sesuai kebutuhan
                      if (kDebugMode) {
                        print('Data tidak ditemukan di Firestore');
                      }
                    }
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'Selanjutnya',
                      style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                const Icon(Icons.arrow_circle_right)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
