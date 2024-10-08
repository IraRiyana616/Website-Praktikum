// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Pengaturan extends StatefulWidget {
  const Pengaturan({super.key});

  @override
  State<Pengaturan> createState() => _PengaturanState();
}

class _PengaturanState extends State<Pengaturan> {
  //== TextField Controller ==//
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  TextEditingController namaLengkapController = TextEditingController();
  TextEditingController nimController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController noHandphoneController = TextEditingController();
  //== Firebase Authentikasi ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;
//== Menampilkan Data dari Database ==//
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(user.uid)
                .get();
        if (userData.exists) {
          setState(() {
            namaLengkapController.text = userData.get('nama') ?? '';
            nimController.text = userData.get('nim').toString();
            noHandphoneController.text = userData.get('no_hp').toString();
            emailController.text = userData.get('email') ?? '';
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user data: $e");
        }
      }
    }
  }

  //== Update Password ==//
  Future<void> _updatePassword() async {
    try {
      // Retrieve user ID From FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      // Ensure user is authenticated
      if (user != null) {
        // Get the new password and confirm password from the text fields
        String newPassword = _newPasswordController.text;
        String confirmPassword = _confirmPasswordController.text;

        // Check if new password and confirm password match
        if (newPassword != confirmPassword) {
          // Show an error message if passwords do not match
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Password yang dimasukkan tidak sama'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ));
          return;
        }

        // Update the password in FirebaseAuth
        await user.updatePassword(newPassword);

        // Update the password in Firestore
        await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .update({'password': newPassword});
        // Clear text fields after successful password update
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password berhasil diperbaharui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating password: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    }
  }
  //== Update Nomor Handphone ==//

  Future<void> _updatePhoneNumber() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String newPhoneNumber = noHandphoneController.text.trim();

        // Validate if the entered value is a valid integer
        if (newPhoneNumber.isEmpty || int.tryParse(newPhoneNumber) == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Nomor handphone harus berupa angka'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ));
          return;
        }

        // Convert the string to an integer
        int parsedPhoneNumber = int.parse(newPhoneNumber);

        // Get the current user's document
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .get();

        // Check if the phone number has changed
        if (userDoc.exists) {
          var currentPhoneNumber = userDoc.get('no_hp') as int?;

          if (currentPhoneNumber == parsedPhoneNumber) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Anda tidak melakukan perubahan pada nomor handphone'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ));
            return;
          }
        }

        // Update the phone number
        await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .update({'no_hp': parsedPhoneNumber});

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nomor handphone berhasil diperbaharui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating phone number: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  //== Nama Akun ==//
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String _namaMahasiswa = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUserData();
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

  //== Fungsi Logout ==//
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login-mahasiswa');
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
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
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    "Pengaturan Akun",
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
                    IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFF031F31),
                        )),
                    const SizedBox(
                      width: 10.0,
                    ),
                  ],
                ],
              ),
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //== Profil Akun ==//
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: 850.0,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 20.0),
                          child: Text(
                            "Profil Pengguna",
                            style: GoogleFonts.quicksand(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Divider(
                            thickness: 1.5,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Row(
                          children: [
                            //== Nama dan NIM ==//
                            SizedBox(
                              height: 242.0,
                              width: 425.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Text(
                                      "Nama Lengkap",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: SizedBox(
                                      width: 400.0,
                                      child: TextField(
                                        readOnly: true,
                                        controller: namaLengkapController,
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan Nama Lengkap',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  //== Nomor Induk Mahasiswa ==//
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, top: 15.0),
                                    child: Text(
                                      "Nomor Induk Mahasiswa (NIM)",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: SizedBox(
                                      width: 400.0,
                                      child: TextField(
                                        readOnly: true,
                                        controller: nimController,
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan NIM',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //== Email dan No.Handphone ==//
                            SizedBox(
                              height: 242.0,
                              width: 425.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //== Email ==//
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Text(
                                      "Email",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: SizedBox(
                                      width: 400.0,
                                      child: TextField(
                                        readOnly: true,
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan Email',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  //== Nomor Handphone ==//
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, top: 15.0),
                                    child: Text(
                                      "Nomor Handphone",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: SizedBox(
                                      width: 400.0,
                                      child: TextField(
                                        keyboardType: TextInputType.phone,
                                        controller: noHandphoneController,
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan Nomor Handphone',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(12),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 295.0),
                                    child: SizedBox(
                                        height: 35.0,
                                        width: 100.0,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      const Color(0xFF3CBEA9)),
                                            ),
                                            onPressed: _updatePhoneNumber,
                                            child: const Text(
                                              "Simpan",
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 0.0),
                              child: Text(
                                "Ubah Password",
                                style: GoogleFonts.quicksand(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              child: Divider(
                                thickness: 1.5,
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Text(
                                "Ubah Password",
                                style: GoogleFonts.quicksand(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 30.0),
                              child: SizedBox(
                                child: TextField(
                                  controller: _newPasswordController,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Password Baru',
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
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Text(
                                "Konfirmasi Password",
                                style: GoogleFonts.quicksand(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 30.0),
                              child: SizedBox(
                                child: TextField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    hintText: 'Konfirmasi Password Baru',
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
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 715.0),
                              child: SizedBox(
                                  height: 35.0,
                                  width: 100.0,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                const Color(0xFF3CBEA9)),
                                      ),
                                      onPressed: _updatePassword,
                                      child: const Text(
                                        "Simpan",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ))),
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 2000.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
