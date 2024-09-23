// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../Revisi Tampilan/Pengguna/Mahasiswa/Praktikan/Dashboard/Navigasi/dashboardnav_praktikan.dart';
import '../../../../Asisten/Absensi/Screen/absensi_ass.dart';

class TokenPraktikan extends StatefulWidget {
  const TokenPraktikan({super.key});

  @override
  State<TokenPraktikan> createState() => _TokenPraktikanState();
}

class _TokenPraktikanState extends State<TokenPraktikan> {
  //== Controller TextField ==//
  final TextEditingController _idKelasController = TextEditingController();

  //== Fungsi Mendapatkan Data ==//
  Future<void> _getData() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;

      // ignore: unnecessary_null_comparison
      if (userUid != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();

        if (userSnapshot.exists) {
          int userNim = userSnapshot['nim'];

          QuerySnapshot<Map<String, dynamic>> classSnapshot =
              await FirebaseFirestore.instance
                  .collection('dataKelasPraktikum')
                  .where('idKelas', isEqualTo: _idKelasController.text)
                  .get();

          if (classSnapshot.docs.isNotEmpty) {
            for (QueryDocumentSnapshot<Map<String, dynamic>> classDocument
                in classSnapshot.docs) {
              String idKelas = classDocument['idKelas'];
              String kode = classDocument['kodeMatakuliah'];

              // Check if there is an existing document with the same nim and kode_kelas
              QuerySnapshot<Map<String, dynamic>> existingTokenSnapshot =
                  await FirebaseFirestore.instance
                      .collection('dataMahasiswaPraktikum')
                      .where('nim', isEqualTo: userNim)
                      .where('idKelas', isEqualTo: idKelas)
                      .where('kodeMatakuliah', isEqualTo: kode)
                      .get();

              if (existingTokenSnapshot.docs.isNotEmpty) {
                // Jika data sudah terdaftar, tampilkan snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Data dengan nim dan token praktikum telah terdapat pada database'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                // Jika data belum terdaftar, simpan data baru
                Map<String, dynamic> updatedClassData = {
                  'idKelas': idKelas,
                  'nim': userNim,
                  'kodeMatakuliah': kode
                };

                await FirebaseFirestore.instance
                    .collection('dataMahasiswaPraktikum')
                    .add(updatedClassData);

                // Tampilkan snackbar bahwa data berhasil disimpan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil disimpan'),
                    backgroundColor: Colors.green,
                  ),
                );
                _idKelasController.clear();
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data tidak ditemukan pada database'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data akun mahasiswa tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap login terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  //== Nama Akun ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String _namaMahasiswa = '';
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

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
            backgroundColor: const Color(0xFFF7F8FA),
            leading: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const DashboardNavigasiPraktikan(),
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
                )),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  'Token Kelas Praktikum',
                  style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )),
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
          )),
      body: Container(
        color: const Color(0xFFE3E8EF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 100.0,
            ),
            Center(
              child: Container(
                width: 650.0,
                height: 350.0,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, left: 50.0),
                      child: Text(
                        "Kode Kelas Praktikum",
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50.0,
                        right: 30.0,
                        top: 30.0,
                      ),
                      child: SizedBox(
                        width: 550.0,
                        child: TextField(
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            LengthLimitingTextInputFormatter(10)
                          ],
                          controller: _idKelasController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Kode Kelas Praktikum',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 500.0),
                      child: SizedBox(
                        height: 35.0,
                        width: 100.0,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF3CBEA9),
                            ),
                          ),
                          onPressed: _getData,
                          child: const Text(
                            "Simpan",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
          ],
        ),
      ),
    );
  }
}
