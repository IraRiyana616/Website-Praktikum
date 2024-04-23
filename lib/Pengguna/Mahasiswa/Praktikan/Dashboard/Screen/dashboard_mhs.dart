import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Dashboard/Tabel/tblkelas_mhs.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPraktikan extends StatefulWidget {
  const DashboardPraktikan({Key? key}) : super(key: key);

  @override
  State<DashboardPraktikan> createState() => _DashboardPraktikanState();
}

class _DashboardPraktikanState extends State<DashboardPraktikan> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk logout dari akun Firebase
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
          backgroundColor: const Color(0xFFF7F8FA),
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
                    'Dashboard Praktikan',
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _logout, // Call _signOut() function when pressed
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF031F31),
                  ),
                ),
                const SizedBox(width: 10.0),
                Text(
                  'Log out',
                  style: GoogleFonts.quicksand(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF031F31),
                  ),
                ),
                const SizedBox(width: 50.0),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Container(
                    width: 1090.0,
                    color: Colors.white,
                    child: const TabelKelasPraktikan(),
                  ),
                ),
              ),
              const SizedBox(height: 500.0),
            ],
          ),
        ),
      ),
    );
  }
}
