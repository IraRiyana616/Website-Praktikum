import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Register/register_dosen.dart';

class LoginDosen extends StatefulWidget {
  const LoginDosen({super.key});

  @override
  State<LoginDosen> createState() => _LoginDosenState();
}

class _LoginDosenState extends State<LoginDosen> {
//== Fungsi Controller ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

//== Password ==//
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: const Color(0xFFE3E8EF),
          child: LayoutBuilder(builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.only(top: constraints.maxHeight * 0.025),
              child: Center(
                child: Card(
                  elevation: 5.0,
                  color: Colors.white,
                  child: SizedBox(
                    height: constraints.maxHeight * 0.7,
                    width: constraints.maxWidth * 0.6,
                    child: Row(
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * 0.7,
                          width: constraints.maxWidth * 0.3,
                          child: Image.asset(
                            'assets/images/sign.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: constraints.maxHeight * 0.7,
                          width: constraints.maxWidth * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 50.0, left: 45.0),
                                child: Text(
                                  'Login Akun',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, left: 45.0),
                                child: Text(
                                  'Masukkan data anda untuk masuk ke akun',
                                  style: GoogleFonts.inter(
                                      fontSize: 14.0, color: Colors.grey),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 35.0, left: 45.0),
                                child: SizedBox(
                                  width: constraints.maxWidth * 0.23,
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
                                        hintText: '   Masukkan Email',
                                        hintStyle:
                                            const TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, left: 45.0),
                                child: SizedBox(
                                  width: constraints.maxWidth * 0.23,
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Icon(
                                            Icons.lock,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        hintText: '   Masukkan Password',
                                        hintStyle:
                                            const TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(_obscurePassword
                                                ? Icons.visibility
                                                : Icons.visibility_off))),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 45.0, top: 25.0, right: 35.0),
                                child: SizedBox(
                                  height: 45.0,
                                  width: constraints.maxWidth * 0.23,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF3CBEA9),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0))),
                                      onPressed: () async {
                                        try {
                                          //== Attempt to sign in with email and password
                                          UserCredential userCredential =
                                              await _auth
                                                  .signInWithEmailAndPassword(
                                                      email: _emailController
                                                          .text
                                                          .trim(),
                                                      password:
                                                          _passwordController
                                                              .text
                                                              .trim());

                                          //== Check if authentication was successful
                                          if (userCredential.user != null) {
                                            //== Fetch additional user data from Firestore
                                            DocumentSnapshot userSnapshot =
                                                await FirebaseFirestore.instance
                                                    .collection('akun_dosen')
                                                    .doc(userCredential
                                                        .user!.uid)
                                                    .get();
                                            if (userSnapshot.exists) {
                                              if (kDebugMode) {
                                                print(
                                                    'User signed in: ${userCredential.user?.email}');
                                              }
                                              //== Navigator ke arah berikutnya
                                            } else {
                                              if (kDebugMode) {
                                                print(
                                                    'User data not found in Firestore');
                                              }
                                            }
                                          } else {
                                            if (kDebugMode) {
                                              print(
                                                  'Authentication failed: ${userCredential.toString()}');
                                            }
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Email atau Password salah'),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 3),
                                            ));
                                          }
                                        } catch (e) {
                                          if (kDebugMode) {
                                            print('Error: $e');
                                          }
                                          //== Handle Specific Error Cases
                                          if (e is FirebaseAuthException) {
                                            //== Check for specific error codes
                                            if (e.code ==
                                                'invalid-login-credentials') {
                                              //== Invalid login credential error
                                              //== Provide feedback to the user
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Email atau Password Salah'),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                              ));
                                            } else {
                                              //== Handle othe FirebaseAuthException errors
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Terjadi Kesalahan Saat Login'),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                              ));
                                            }
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0),
                                      )),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                    top: 45.0,
                                    left: 45.0,
                                  ),
                                  child: Row(children: [
                                    const Text(
                                      'Belum memiliki akun?',
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
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  const RegisterDosen(),
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
                                        child: const Text(
                                          "Registrasi Akun",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    )
                                  ]))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          })),
    );
  }
}
