import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Screen/kelas_asisten.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Dashboard/Komponen/Deskripsi/Screen/deskripsi_mhs.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Dashboard/Komponen/Pengumpulan/Latihan/Tabel/tabel_peng_latihan_mhs.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Dashboard/Komponen/Pengumpulan/Tugas/Screen/peng_tugas_mhs.dart';

import '../../../../../Absensi/Komponen/tampilan_absensi_mhs.dart';
import '../../../Asistensi/Screen/asistensi_laporan_prak.dart';

class DataLatihanPraktikan extends StatefulWidget {
  final String kodeKelas;

  const DataLatihanPraktikan({
    super.key,
    required this.kodeKelas,
  });

  @override
  State<DataLatihanPraktikan> createState() => _DataLatihanPraktikanState();
}

class _DataLatihanPraktikanState extends State<DataLatihanPraktikan> {
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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DataTugasPraktikan(
                    kodeKelas: widget.kodeKelas,
                  )),
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
                    MaterialPageRoute(
                        builder: (context) => const KelasAsisten()));
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
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    child: Text(
                  widget.kodeKelas,
                  style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )),
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
              Center(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                        height: 320.0,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/kelas.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        children: [
                          //Deskripsi Kelas
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DeskripsiMahasiswa(
                                          kodeKelas: widget.kodeKelas)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 38.0,
                                left: 95.0,
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  'Deskripsi',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //Absensi
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 50.0,
                              top: 38.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AbsensiPraktikanScreen(
                                                kodeKelas: widget.kodeKelas)));
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  'Absensi',
                                  style: GoogleFonts.quicksand(fontSize: 16.0),
                                ),
                              ),
                            ),
                          ),
                          //Pengumpulan
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 50.0,
                              top: 38.0,
                            ),
                            child: Text(
                              'Pengumpulan',
                              style: GoogleFonts.quicksand(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          //Asistensi
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 50.0,
                              top: 38.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DataAsistensiPraktikan(
                                                kodeKelas: widget.kodeKelas)));
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  'Asistensi',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          left: 45.0,
                          right: 45.0,
                        ),
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                      TabelKLatihanPraktikan(kodeKelas: widget.kodeKelas),
                      const SizedBox(
                        height: 20.0,
                      )
                    ],
                  ),
                ),
              ),
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
            icon: Icon(Icons.bookmarks),
            label: 'Tugas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3CBEA9),
        onTap: _onItemTapped,
      ),
    );
  }
}
