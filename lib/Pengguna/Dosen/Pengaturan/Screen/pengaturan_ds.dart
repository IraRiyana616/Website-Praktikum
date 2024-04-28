import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PengaturanDosen extends StatefulWidget {
  const PengaturanDosen({super.key});

  @override
  State<PengaturanDosen> createState() => _PengaturanDosenState();
}

class _PengaturanDosenState extends State<PengaturanDosen> {
  //== Fungsi untuk textfield ==
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _newPhoneNumberController =
      TextEditingController();
  //== Fungsi untuk authentikasi ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;

//== Update Password ==//
  Future<void> _updatePassword() async {
    try {
      //Retrieve user ID From FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;
      //Ensure user is authenticated
      if (user != null) {
        //Get the new password from the textfield
        String newPassword = _newPasswordController.text;
        //Update the password in FirebaseAuth
        await user.updatePassword(newPassword);
        //Update the password in Firestore
        await FirebaseFirestore.instance
            .collection('akun_dosen')
            .doc(user.uid)
            .update({'password': newPassword});
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ));
        // Clear the text fields after successful update
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating password: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    }
  }

//== Update Nomor Hp ==//
  Future<void> _updatePhoneNumber() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String newPhoneNumber = _newPhoneNumberController.text;

        await FirebaseFirestore.instance
            .collection('akun_dosen')
            .doc(user.uid)
            .update({'no_hp': newPhoneNumber});

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Phone number updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ));
        // Clear the text field after successful update
        _newPhoneNumberController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating phone number: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  //== Fungsi Keluar dari akun ==//
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      // Navigasi kembali ke halaman login atau halaman lain setelah logout berhasil
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      // Tangani kesalahan logout
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
              padding: const EdgeInsets.only(top: 8.0, left: 20.0),
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
                    width: 750,
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
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30.0,
              ),
              Center(
                child: Container(
                  width: 550.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
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
                        height: 15.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Text(
                          "Nomor Handphone",
                          style: GoogleFonts.quicksand(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: SizedBox(
                          child: TextField(
                            controller: _newPhoneNumberController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan Nomor Handphone Baru',
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
                        padding: const EdgeInsets.only(left: 420.0),
                        child: SizedBox(
                            height: 35.0,
                            width: 100.0,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
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
                      const SizedBox(
                        height: 25.0,
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
                          "Password",
                          style: GoogleFonts.quicksand(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
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
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
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
                          "Konfirmasi Password Baru",
                          style: GoogleFonts.quicksand(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: SizedBox(
                          child: TextField(
                            controller: _confirmPasswordController,
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
                        height: 20.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 420.0),
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
                      const SizedBox(height: 60.0)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
