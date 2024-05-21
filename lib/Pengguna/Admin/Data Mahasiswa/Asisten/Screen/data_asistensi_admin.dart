import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Admin/Data%20Mahasiswa/Praktikan/Screen/data_mahasiswa_admin.dart';
import '../Tabel/tabel_data_asisten_admin.dart';

class DataAsistenKelasAdmin extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const DataAsistenKelasAdmin(
      {Key? key, required this.kodeKelas, required this.mataKuliah})
      : super(key: key);

  @override
  State<DataAsistenKelasAdmin> createState() => _DataAsistenKelasAdminState();
}

class _DataAsistenKelasAdminState extends State<DataAsistenKelasAdmin> {
  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 1; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Memilih halaman sesuai dengan index yang dipilih
      if (index == 0) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DataPraktikanKelasAdmin(
              kodeKelas: widget.kodeKelas,
              mataKuliah: widget.mataKuliah,
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
      } else if (index == 1) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DataAsistenKelasAdmin(
              kodeKelas: widget.kodeKelas,
              mataKuliah: widget.mataKuliah,
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
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 40.0,
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
              Text(
                'Admin',
                style: GoogleFonts.quicksand(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(width: 30.0)
            ],
          ),
        ),
      ),
      body: Container(
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
                    TabelDataAsistenAdmin(
                      kodeKelas: widget.kodeKelas,
                    ),
                    const SizedBox(
                      height: 30.0,
                    )
                  ],
                ),
              ),
            ),
          ],
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
