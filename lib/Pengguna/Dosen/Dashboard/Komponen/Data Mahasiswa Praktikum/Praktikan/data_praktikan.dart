import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Dashboard/Navigasi/dasboardnav_ds.dart';
import '../../../../../Mahasiswa/Asisten/Data Mahasiswa/Tabel/tabel_data.dart';
import '../Asisten/Screen/data_asisten.dart';

class DataPraktikanKelas extends StatefulWidget {
  final String kodeKelas;
  const DataPraktikanKelas({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  State<DataPraktikanKelas> createState() => _DataPraktikanKelasState();
}

class _DataPraktikanKelasState extends State<DataPraktikanKelas> {
  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 0; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Memilih halaman sesuai dengan index yang dipilih
      if (index == 0) {
        Navigator.pop(context);
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
