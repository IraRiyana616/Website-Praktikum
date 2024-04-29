import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Dosen/Absensi/Komponen/Asisten/Tabel/tbl_asisten_ds.dart';
import '../../Navigasi/absensi_admin_nav.dart';
import '../Praktikan/absensi_praktikan_admin.dart';

class AbsensiAsistenAdmin extends StatefulWidget {
  final String kodeKelas;
  final String kodeAsisten;

  const AbsensiAsistenAdmin(
      {Key? key, required this.kodeKelas, required this.kodeAsisten})
      : super(key: key);

  @override
  State<AbsensiAsistenAdmin> createState() => _AbsensiAsistenAdminState();
}

class _AbsensiAsistenAdminState extends State<AbsensiAsistenAdmin> {
  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 1; // untuk mengatur index bottom navigation
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
                      kodeAsisten: widget.kodeAsisten,
                    )));
      } else if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AbsensiAsistenAdmin(
                    kodeKelas: widget.kodeKelas,
                    kodeAsisten: widget.kodeAsisten)));
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
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    widget.kodeKelas,
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
                height: 20.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, top: 5.0, right: 25.0),
                child: Container(
                  width: 1500.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabelAbsensiAsistenDosen(kodeAsisten: widget.kodeAsisten),
                      const SizedBox(
                        height: 20.0,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 1000.0,
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
