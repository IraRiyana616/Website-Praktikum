import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Hasil%20Studi/Navigation/hasil_studi_ds.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Hasil%20Studi/Komponen/Nilai%20Akhir/Table/tabel_nilai_akhir.dart';
import '../Nilai Harian/nilai_harian_ds.dart';

class NilaiAkhirDosen extends StatefulWidget {
  final String kodeKelas;
  const NilaiAkhirDosen({super.key, required this.kodeKelas});

  @override
  State<NilaiAkhirDosen> createState() => _NilaiAkhirDosenState();
}

class _NilaiAkhirDosenState extends State<NilaiAkhirDosen> {
  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NilaiPercobaanDosen(kodeKelas: widget.kodeKelas)));
      } else if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NilaiAkhirDosen(kodeKelas: widget.kodeKelas)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Nilai Harian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Nilai AKhir',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3CBEA9),
        onTap: _onItemTapped,
      ),
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
                      builder: (context) => const HasilStudiDosenNav()));
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
                    'Penilaian Akhir',
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
                      TabelNilaiAkhir(kodeKelas: widget.kodeKelas),
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
    );
  }
}
