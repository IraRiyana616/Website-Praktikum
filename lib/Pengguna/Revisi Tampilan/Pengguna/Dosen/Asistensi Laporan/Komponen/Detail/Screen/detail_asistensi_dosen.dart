import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Data Mahasiswa/Screen/data_asistensi_dosen.dart';
import '../Tabel/tabel_detail_asistensi_dosen.dart';

class DetailAsistensiLaporanDosen extends StatefulWidget {
  final String kodeKelas;
  final String nama;
  final String modul;
  final int nim;
  final String mataKuliah;
  const DetailAsistensiLaporanDosen(
      {super.key,
      required this.kodeKelas,
      required this.nama,
      required this.modul,
      required this.nim,
      required this.mataKuliah});

  @override
  State<DetailAsistensiLaporanDosen> createState() =>
      _DetailAsistensiLaporanDosenState();
}

class _DetailAsistensiLaporanDosenState
    extends State<DetailAsistensiLaporanDosen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //== Fungsi Nama Mahasiswa ==//
  User? _currentUser;
  String _namaMahasiswa = '';

  //== Nama Akun ==//
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
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
          await _firestore.collection('akun_dosen').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _namaMahasiswa = doc.get('nama');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching nama dosen: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF7F8FA),
            leading: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          DataAsistenDosen(
                        kodeKelas: widget.kodeKelas,
                        mataKuliah: widget.mataKuliah,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )),
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      widget.mataKuliah,
                      style: GoogleFonts.quicksand(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
                    const Spacer(),
                    if (screenWidth > 600) const SizedBox(width: 400.0),
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
                      if (screenWidth > 600) const SizedBox(width: 10.0)
                    ],
                  ]),
            ),
          )),
      body: Container(
        color: const Color(0xFFE3E8EF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 35.0, right: 40.0),
                child: Container(
                    width: 1270.0,
                    color: Colors.white,
                    child: TabelDetailAsistensiLaporanDosen(
                        kodeKelas: widget.kodeKelas,
                        nim: widget.nim,
                        modul: widget.modul,
                        nama: widget.nama)),
              ),
            ),
            const SizedBox(
              height: 20.0,
            )
          ],
        ),
      ),
    );
  }
}
