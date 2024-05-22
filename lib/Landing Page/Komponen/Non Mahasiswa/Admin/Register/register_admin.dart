import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Login/login_admin.dart';

class RegisterAdmin extends StatefulWidget {
  const RegisterAdmin({super.key});

  @override
  State<RegisterAdmin> createState() => _RegisterAdminState();
}

class _RegisterAdminState extends State<RegisterAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to register user data to Firestore and Firebase Auth
  Future<void> _registerUser() async {
    try {
      // Create user with email and password
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      // Add user data to firestore
      await _firestore.collection('akun_admin').doc(authResult.user?.uid).set({
        'email': _emailController.text,
        'password': _passwordController.text,
      });

      // Reset textfields to empty after successful registration
      _emailController.clear();
      _passwordController.clear();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        duration: Duration(seconds: 3),
      ));

      // Navigate to the login screen
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginAdmin(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      // Handle error
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                        padding: const EdgeInsets.only(top: 50.0, left: 45.0),
                        child: Text(
                          "Register Akun",
                          style: GoogleFonts.quicksand(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 45.0),
                        child: Text(
                          "Masukkan data anda untuk masuk ke akun",
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0, left: 45.0),
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
                              hintText: ' Masukkan Email',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 45.0),
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
                              hintText: ' Masukkan Password',
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
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
