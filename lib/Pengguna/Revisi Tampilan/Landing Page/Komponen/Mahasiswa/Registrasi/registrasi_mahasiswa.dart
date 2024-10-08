// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterMahasiswa extends StatefulWidget {
  const RegisterMahasiswa({super.key});

  @override
  State<RegisterMahasiswa> createState() => _RegisterMahasiswaState();
}

class _RegisterMahasiswaState extends State<RegisterMahasiswa> {
  // Fungsi membuat fungsi pada textfield
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _angkatanController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk pengguna registrasi data untuk Firestore dan Firebase Authentikasi
  Future<void> _registerUser() async {
    try {
      // Validasi NIM
      if (_nimController.text.isEmpty ||
          !RegExp(r'^\d+$').hasMatch(_nimController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NIM harus diisi dan berupa angka'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        return;
      }
      // Parse NIM to integer
      int nim = int.parse(_nimController.text);
      // Parse Angkatan to integer
      int angkatan = int.parse(_angkatanController.text);
      // Parse Nomor Handphone
      int noHandphone = int.parse(_noHpController.text);
      // Check for duplicate NIM
      QuerySnapshot nimSnapshot = await _firestore
          .collection('akun_mahasiswa')
          .where('nim', isEqualTo: _nimController.text)
          .get();

      if (nimSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NIM sudah terdaftar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        return;
      }
      // Check for duplicate email
      QuerySnapshot emailSnapshot = await _firestore
          .collection('akun_mahasiswa')
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
      await _firestore
          .collection('akun_mahasiswa')
          .doc(authResult.user?.uid)
          .set({
        'nama': _namaController.text,
        'nim': nim,
        'email': _emailController.text,
        'password': _passwordController.text,
        'no_hp': noHandphone,
        'angkatan': angkatan,
      });

      // Reset textfields to empty after successful registration
      _namaController.clear();
      _nimController.clear();
      _emailController.clear();
      _passwordController.clear();
      _newPasswordController.clear();
      _noHpController.clear();
      _angkatanController.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ));
      // Login Mahasiswa
      Navigator.pushNamed(
        context,
        '/login-mahasiswa',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

//== Password ==//
  bool _obscurePassword = true;

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
                                  height: 480.0,
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
                                      //== Nomor Induk Mahasiswa ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 45.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: TextField(
                                            controller: _nimController,
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
                                              hintText: '  Masukkan NIM',
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
                                      //== Angkatan ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 45.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: TextField(
                                            controller: _angkatanController,
                                            decoration: InputDecoration(
                                              prefixIcon: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Icon(
                                                  Icons.school,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              hintText:
                                                  '  Masukkan Tahun Masuk Kuliah',
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
                                    ],
                                  ),
                                ),
                                //== Row 2
                                SizedBox(
                                  height: 480.0,
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
                                            obscureText: _obscurePassword,
                                            decoration: InputDecoration(
                                                prefixIcon: const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0),
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
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                suffixIcon: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscurePassword =
                                                            !_obscurePassword;
                                                      });
                                                    },
                                                    icon: Icon(_obscurePassword
                                                        ? Icons.visibility
                                                        : Icons
                                                            .visibility_off))),
                                          ),
                                        ),
                                      ),
                                      //== Konfirmasi Password ==//
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 45.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: TextField(
                                            controller: _newPasswordController,
                                            obscureText: _obscurePassword,
                                            decoration: InputDecoration(
                                                prefixIcon: const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0),
                                                  child: Icon(
                                                    Icons.lock,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                hintText:
                                                    '  Konfirmasi Password',
                                                hintStyle: const TextStyle(
                                                    color: Colors.grey),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                suffixIcon: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscurePassword =
                                                            !_obscurePassword;
                                                      });
                                                    },
                                                    icon: Icon(_obscurePassword
                                                        ? Icons.visibility
                                                        : Icons
                                                            .visibility_off))),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                            top: 15.0,
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
                                                    '/login-mahasiswa',
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 250.0, top: 25.0),
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
