import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Dashboard/Navigasi/dasboardnav_ds.dart';
import '../../Praktikan/data_praktikan.dart';
import '../Tabel/tabel_data_asisten.dart';

class DataAsistenKelas extends StatefulWidget {
  final String kodeKelas;
  const DataAsistenKelas({Key? key, required this.kodeKelas}) : super(key: key);

  @override
  State<DataAsistenKelas> createState() => _DataAsistenKelasState();
}

class _DataAsistenKelasState extends State<DataAsistenKelas> {
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
                builder: (context) =>
                    DataPraktikanKelas(kodeKelas: widget.kodeKelas)));
      } else if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DataAsistenKelas(kodeKelas: widget.kodeKelas)));
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
                        builder: (context) => const DashboardDosenNav()));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.kodeKelas,
              style: GoogleFonts.quicksand(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
                    TabelDataKelasAsisten(
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
