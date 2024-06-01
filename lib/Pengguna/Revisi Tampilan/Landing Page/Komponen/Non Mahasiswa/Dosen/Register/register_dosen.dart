// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterDosen extends StatefulWidget {
  const RegisterDosen({super.key});

  @override
  State<RegisterDosen> createState() => _RegisterDosenState();
}

class _RegisterDosenState extends State<RegisterDosen> {
  // Fungsi membuat fungsi pada textfield
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk pengguna registrasi data untuk Firestore dan Firebase Authentikasi
  Future<void> _registerUser() async {
    try {
      // Validasi NIM
      QuerySnapshot nipSnapshot = await _firestore
          .collection('akun_dosen')
          .where('nip', isEqualTo: _nipController.text)
          .get();

      if (nipSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NIP sudah terdaftar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        return;
      }
      // Check for duplicate email
      QuerySnapshot emailSnapshot = await _firestore
          .collection('akun_dosen')
          .where('email', isEqualTo: _emailController.text)
          .get();

      if (emailSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email sudah terdaftar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        return;
      }
      // Create user with email and password
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      // Create user with email and password
      await _firestore.collection('akun_dosen').doc(authResult.user?.uid).set({
        'nama': _namaController.text,
        'nip': _nipController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'no_hp': _noHpController.text,
      });

      // Reset textfields to empty after successful registration
      _namaController.clear();
      _nipController.clear();
      _emailController.clear();
      _passwordController.clear();
      _noHpController.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ));
      //== Login Dosen ==//
      Navigator.pushNamed(
        context,
        '/login_dosen',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Terjadi kesalahan saat menyimpan data'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE3E8EF),
        child: Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Card(
                      elevation: 5.0,
                      color: Colors.white,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.88,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                //== Gambar
                                SizedBox(
                                  height: 500.0,
                                  width:
                                      MediaQuery.of(context).size.width * 0.27,
                                  child: Image.asset(
                                    'assets/images/sign.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                //== Row 1
                                SizedBox(
                                  height: 450.0,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 45.0, top: 40.0),
                                        child: Text(
                                          'Registrasi Akun',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 30.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0, left: 45.0),
                                        child: Text(
                                          'Masukkan data anda untuk mendaftarkan akun',
                                          style: GoogleFonts.inter(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      //== Nama Lengkap ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 45.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: TextField(
                                            controller: _namaController,
                                            decoration: InputDecoration(
                                              prefixIcon: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              hintText:
                                                  '  Masukkan Nama Lengkap',
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      //== Nomor Induk Pengawai Negeri Sipil ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 45.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: TextField(
                                            controller: _nipController,
                                            decoration: InputDecoration(
                                              prefixIcon: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Icon(
                                                  Icons
                                                      .photo_camera_front_rounded,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              hintText: '  Masukkan NIP',
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      //== Nomor Handphone ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 45.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: TextField(
                                            controller: _noHpController,
                                            decoration: InputDecoration(
                                              prefixIcon: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Icon(
                                                  Icons.phone_android_outlined,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              hintText:
                                                  '  Masukkan Nomor Handphone',
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      //== ElevatedButton Register ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 45.0, top: 25.0),
                                        child: SizedBox(
                                          height: 45.0,
                                          width: 140.0,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF3CBEA9),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            onPressed: _registerUser,
                                            child: const Text(
                                              "Register",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                //== Row 2
                                SizedBox(
                                  height: 450.0,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 50.0, top: 70.0),
                                        child: Text(
                                          "",
                                          style: GoogleFonts.quicksand(
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      //== Email ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 40.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: TextField(
                                            controller: _emailController,
                                            decoration: InputDecoration(
                                              prefixIcon: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Icon(
                                                  Icons.email,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              hintText: '  Masukkan Email',
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      //== Password ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 45.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: TextField(
                                            controller: _passwordController,
                                            decoration: InputDecoration(
                                              prefixIcon: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Icon(
                                                  Icons.lock,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              hintText: '  Masukkan Password',
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      //== === ==//
                                      Padding(
                                          padding: const EdgeInsets.only(
                                            top: 25.0,
                                            left: 45.0,
                                          ),
                                          child: Row(children: [
                                            const Text(
                                              'Sudah memiliki akun?',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(width: 5.0),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/login-dosen',
                                                  );
                                                },
                                                child: const Text(
                                                  "Login",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
