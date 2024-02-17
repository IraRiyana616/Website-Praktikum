import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Pengaturan extends StatefulWidget {
  const Pengaturan({super.key});

  @override
  State<Pengaturan> createState() => _PengaturanState();
}

class _PengaturanState extends State<Pengaturan> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _newPhoneNumberController =
      TextEditingController();

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
        // ignore: use_build_context_synchronously
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

  Future<void> _updatePhoneNumber() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String newPhoneNumber = _newPhoneNumberController.text;

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

        await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .update({'no_hp': parsedPhoneNumber});
        _newPhoneNumberController.clear();

        // ignore: use_build_context_synchronously
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
                    width: 750.0,
                  ),
                  IconButton(
                      onPressed: () {},
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
                          "Ubah Nomor Handphone",
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
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Text(
                          "Ubah Password",
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
                          "Konfirmasi Password",
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
                      const SizedBox(
                        height: 25.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
