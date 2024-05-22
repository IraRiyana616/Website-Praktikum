import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Dashboard/Navigasi/dasboardnav_ds.dart';
import '../../../../../Mahasiswa/Asisten/Data Mahasiswa/Tabel/tabel_data.dart';
import '../Asisten/Screen/data_asisten.dart';

class DataPraktikanKelas extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  final String kodeAsisten;
  const DataPraktikanKelas(
      {Key? key,
      required this.kodeKelas,
      required this.mataKuliah,
      required this.kodeAsisten})
      : super(key: key);

  @override
  State<DataPraktikanKelas> createState() => _DataPraktikanKelasState();
}

class _DataPraktikanKelasState extends State<DataPraktikanKelas> {
  //== Nama Akun ==//
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  String _namaDosen = '';

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
      await _getNamaDosen(_currentUser!.uid);
    }
  }

  // Fungsi untuk mengambil nama mahasiswa dari database
  Future<void> _getNamaDosen(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('akun_dosen').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _namaDosen = doc.get('nama');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching nama mahasiswa: $e');
      }
    }
  }

  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 0; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DataPraktikanKelas(
                    kodeKelas: widget.kodeKelas,
                    mataKuliah: widget.mataKuliah,
                    kodeAsisten: widget.kodeAsisten),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
      } else if (index == 1) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DataAsistenKelas(
              kodeKelas: widget.kodeKelas,
              mataKuliah: widget.mataKuliah,
              kodeAsisten: widget.kodeAsisten,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const DashboardDosenNav(),
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 10.0,
              ),
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
              const SizedBox(
                width: 700.0,
              ),
              if (_currentUser != null) ...[
                Text(
                  _namaDosen.isNotEmpty
                      ? _namaDosen
                      : (_currentUser!.email ?? ''),
                  style: GoogleFonts.quicksand(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(
                  width: 30.0,
                ),
              ],
            ],
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
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 35.0, top: 5.0),
                child: Container(
                  width: 1300.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabelDataKelasMahasiswa(kodeKelas: widget.kodeKelas),
                      const SizedBox(
                        height: 30.0,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 1000.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Praktikan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Asisten',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3CBEA9),
        onTap: _onItemTapped,
      ),
    );
  }
}
