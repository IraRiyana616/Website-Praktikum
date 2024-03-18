import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Landing%20Page/Komponen/Mahasiswa/Register/register_mhs.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Navigation/kelas_assnav.dart';

class LoginMahasiswa extends StatefulWidget {
  const LoginMahasiswa({super.key});

  @override
  State<LoginMahasiswa> createState() => _LoginMahasiswaState();
}

class _LoginMahasiswaState extends State<LoginMahasiswa> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE3E8EF),
        child: Center(
          child: Card(
            elevation: 5.0,
            color: Colors.white,
            child: SizedBox(
              height: 470.0,
              width: 800.0,
              child: Row(
                children: [
                  SizedBox(
                    height: 470.0,
                    width: 400.0,
                    child: Image.asset(
                      "assets/images/sign.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: 470.0,
                    width: 400.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0, left: 45.0),
                          child: Text(
                            "Login Akun",
                            style: GoogleFonts.quicksand(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 45.0),
                          child: Text(
                            "Masukkan data anda untuk masuk ke akun",
                            style: GoogleFonts.inter(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0, left: 45.0),
                          child: SizedBox(
                            width: 320.0,
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Icon(
                                    Icons.email,
                                    color: Colors.grey,
                                  ),
                                ),
                                hintText: '  Masukkan Email',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0, left: 45.0),
                          child: SizedBox(
                            width: 320.0,
                            child: TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                  ),
                                ),
                                hintText: '  Masukkan Password',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 45.0, top: 25.0, right: 35.0),
                          child: SizedBox(
                            height: 45.0,
                            width: 500.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3CBEA9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  // Attempt to sign in with email and password
                                  UserCredential userCredential =
                                      await _auth.signInWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim());

                                  // Check if authentication was successful
                                  if (userCredential.user != null) {
                                    // Ftech additional user data from Firestore
                                    DocumentSnapshot userSnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('akun_mahasiswa')
                                            .doc(userCredential.user!.uid)
                                            .get();

                                    if (userSnapshot.exists) {
                                      if (kDebugMode) {
                                        print(
                                            "User signed in: ${userCredential.user?.email}");
                                      }

                                      // ignore: use_build_context_synchronously
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  // const TestWaktu()
                                                  const KelasAsistenNav()));
                                    } else {
                                      if (kDebugMode) {
                                        print(
                                            "User data not found in Firestore");
                                      }

                                      // Handle case when user data not found in Firestore
                                    }
                                  } else {
                                    if (kDebugMode) {
                                      print(
                                          "Authentication failed: ${userCredential.toString()}");
                                    }

                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Email atau password salah'),
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 3)));
                                  }
                                } catch (e) {
                                  if (kDebugMode) {
                                    print("Error: $e");
                                  }

                                  // Handle specific error cases
                                  if (e is FirebaseAuthException) {
                                    // Check for specific error cases
                                    if (e.code == 'invalid-login-credentials') {
                                      //Invalid login credentials error
                                      //Provide feedback to the user
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content:
                                            Text('Email atau password salah'),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ));
                                    } else {
                                      // Handle other FirebaseAuthException error
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Terjadi kesalahan saat login'),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 3)));
                                    }
                                  } else {
                                    // Handle other errors
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text('Terjadi kesalahan saat login'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ));
                                  }
                                }
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 45.0, left: 45.0),
                          child: Row(
                            children: [
                              const Text(
                                'Belum memiliki akun?',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterMahasiswa(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Registrasi Akun",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.blue),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
