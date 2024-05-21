import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Navigasi/absensi_admin_nav.dart';
import '../../Asisten/Screen/absensi_asisten_admin.dart';
import '../Tabel/absensi_praktikan_admin.dart';

class AbsensiPraktikanAdmin extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  final String kodeAsisten;

  const AbsensiPraktikanAdmin({
    Key? key,
    required this.kodeKelas,
    required this.mataKuliah,
    required this.kodeAsisten,
  }) : super(key: key);

  @override
  State<AbsensiPraktikanAdmin> createState() => _AbsensiPraktikanAdminState();
}

class _AbsensiPraktikanAdminState extends State<AbsensiPraktikanAdmin> {
  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 0; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Memilih halaman sesuai dengan index yang dipilih
      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AbsensiPraktikanAdmin(
                      kodeKelas: widget.kodeKelas,
                      mataKuliah: widget.mataKuliah,
                      kodeAsisten: widget.kodeAsisten,
                    )));
      } else if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AbsensiAsistenAdmin(
                      kodeKelas: widget.kodeKelas,
                      mataKuliah: widget.mataKuliah,
                      kodeAsisten: widget.kodeAsisten,
                    )));
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
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AbsensiAdminNav()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
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
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 65.0, top: 20.0, right: 45.0),
                child: Container(
                  width: 1260.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabelAbsensiPraktikanAdmin(
                        kodeKelas: widget.kodeKelas,
                        mataKuliah: widget.mataKuliah,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 200.0,
              )
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
