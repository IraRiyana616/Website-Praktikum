import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PengaturanAdmin extends StatefulWidget {
  const PengaturanAdmin({super.key});

  @override
  State<PengaturanAdmin> createState() => _PengaturanAdminState();
}

class _PengaturanAdminState extends State<PengaturanAdmin> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  //== Fungsi untuk authentikasi ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //== Fungsi Keluar dari akun ==//
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      // Navigasi kembali ke halaman login atau halaman lain setelah logout berhasil
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/login-admin');
    } catch (e) {
      // Tangani kesalahan logout
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  Future<void> _updatePassword() async {
    try {
      // Retrieve user ID from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      // Ensure user is authenticated
      if (user != null) {
        // Get the new password from the TextField
        String newPassword = _newPasswordController.text;

        // Update the password in FirebaseAuth
        await user.updatePassword(newPassword);

        // Update the password in Firestore
        await FirebaseFirestore.instance
            .collection('akun_admin')
            .doc(user.uid)
            .update({
          'password': newPassword,
        });

        // Show a success message or navigate to another screen
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle errors, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    "Pengaturan Akun",
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    'Admin',
                    style: GoogleFonts.quicksand(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF031F31),
                  ),
                  tooltip: 'Logout',
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 100.0,
              ),
              Center(
                child: Container(
                  width: 550.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, top: 40.0),
                        child: Text(
                          "Password",
                          style: GoogleFonts.quicksand(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
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
                            controller: _confirmNewPasswordController,
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
                      const SizedBox(height: 65.0)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 80.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
