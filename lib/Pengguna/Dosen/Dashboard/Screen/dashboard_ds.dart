import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Dashboard/Tabel/kelas_ds.dart';

class DashboardDosen extends StatefulWidget {
  const DashboardDosen({super.key});

  @override
  State<DashboardDosen> createState() => _DashboardDosenState();
}

class _DashboardDosenState extends State<DashboardDosen> {
  //== Fungsi untuk authentikasi ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
                  "Dashboard",
                  style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )),
                const SizedBox(
                  width: 750.0,
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
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 20.0),
                child: Container(
                  width: 1055.0,
                  color: Colors.white,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabelKelasDosen(),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 161.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
