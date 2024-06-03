import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../../Admin/Data Mahasiswa/Asisten/Tabel/tabel_data_asisten_admin.dart';
import '../../../Navigasi/dashboardnav_asisten.dart';
import '../Data Mahasiswa/data_mahasiswa_asisten.dart';
import '../Deskripsi Kelas/deskripsi_kelas_asisten.dart';

class DataAsisten extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const DataAsisten(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<DataAsisten> createState() => _DataAsistenState();
}

class _DataAsistenState extends State<DataAsisten> {
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

  @override
  Widget build(BuildContext context) {
    //== MediaQuery ==//
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const DasboardAsistenNavigasi(),
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
            ),
          ),
          backgroundColor: const Color(0xFFF7F8FA),
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
                      color: Colors.black,
                    ),
                  ),
                ),
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
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: screenWidth > 1050.0 ? 2000.0 : screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5, color: Colors.grey)),
                        height: 320.0,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/kelas.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      //== Tab Layout Deskripsi >> Data Mahasiswa >> Data Asisten ==//
                      Row(
                        children: [
                          //== Deskripsi Kelas ==//
                          GestureDetector(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 38.0, left: 95.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          DeskripsiKelasAsisten(
                                        kodeKelas: widget.kodeKelas,
                                        mataKuliah: widget.mataKuliah,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(0.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    'Deskripsi',
                                    style:
                                        GoogleFonts.quicksand(fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //== Data Mahasiswa ==//
                          GestureDetector(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 38.0, left: 50.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          DataMahasiswaAsisten(
                                        kodeKelas: widget.kodeKelas,
                                        mataKuliah: widget.mataKuliah,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(0.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    'Data Mahasiswa',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //== Data Asisten ==//
                          GestureDetector(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 38.0, left: 50.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          DataAsisten(
                                        kodeKelas: widget.kodeKelas,
                                        mataKuliah: widget.mataKuliah,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(0.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    'Data Asistensi',
                                    style:
                                        GoogleFonts.quicksand(fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 45.0, right: 45.0),
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TabelDataAsistenAdmin(kodeKelas: widget.kodeKelas),
                      const SizedBox(
                        height: 20.0,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
