import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Tabel/tabel_jadwal.dart';

class JadwalPraktikumScreen extends StatefulWidget {
  const JadwalPraktikumScreen({super.key});

  @override
  State<JadwalPraktikumScreen> createState() => _JadwalPraktikumScreenState();
}

class _JadwalPraktikumScreenState extends State<JadwalPraktikumScreen> {
  //== Fungsi untuk autentikasi ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //== Fungsi Keluar dari akun ==//
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      // Navigasi kembali ke halaman login atau halaman lain setelah logout berhasil
      Navigator.of(context).pushReplacementNamed('/login-admin');
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
                    "Jadwal Praktikum",
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
      body: Container(
        color: const Color(0xFFE3E8EF),
        constraints: const BoxConstraints.expand(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 15.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1105.0),
                    color: Colors.white,
                    child: const TabelJadwalPraktikum(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
