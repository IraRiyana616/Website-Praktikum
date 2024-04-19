import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Hasil%20Studi/Komponen/Percobaan/Nilai/penilaian_percobaan.dart';

class NilaiPercobaan extends StatefulWidget {
  final String kodeKelas;
  const NilaiPercobaan({Key? key, required this.kodeKelas}) : super(key: key);

  @override
  State<NilaiPercobaan> createState() => _NilaiPercobaanState();
}

class _NilaiPercobaanState extends State<NilaiPercobaan> {
  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 0; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Memilih halaman sesuai dengan index yang dipilih
      if (index == 0) {
        // Tindakan ketika item "Latihan" ditekan
        // Di sini Anda dapat menambahkan navigasi ke halaman pengumpulan latihan
        // Misalnya:
      } else if (index == 1) {
        // Tindakan ketika item "Tugas" ditekan
        // Di sini Anda dapat menambahkan navigasi ke halaman pengumpulan tugas
        // Misalnya:
      } else if (index == 2) {
        // Tindakan ketika item "Tugas" ditekan
        // Di sini Anda dapat menambahkan navigasi ke halaman pengumpulan tugas
        // Misalnya:
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
              Navigator.pop(context);
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
                    'Penilaian Praktikum',
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 750.0,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF031F31),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  'Log out',
                  style: GoogleFonts.quicksand(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF031F31),
                  ),
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
                      PenilaianPercobaanAsisten(
                        kodeKelas: widget.kodeKelas,
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
            icon: Icon(Icons.book),
            label: 'Latihan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Keaktifan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3CBEA9),
        onTap: _onItemTapped,
      ),
    );
  }
}
