import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Admin/Kelas/Komponen/Asistensi/asisten_admin.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Komponen/Pengumpulan/Tugas/Tabel/tbl_tugas_prak.dart';
import '../../Deskripsi/Screen/deskripsi_admin.dart';
import '../Tugas/tugas_admin.dart';

class KumpulTugasAdmin extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const KumpulTugasAdmin(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<KumpulTugasAdmin> createState() => _KumpulTugasAdminState();
}

class _KumpulTugasAdminState extends State<KumpulTugasAdmin> {
  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 1; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                KumpulUjianPemahamanAdmin(
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
                KumpulTugasAdmin(
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
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF7F8FA),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 30.0,
                ),
                Expanded(
                    child: Text(
                  widget.mataKuliah,
                  style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )),
                const SizedBox(width: 400.0),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    'Admin',
                    style: GoogleFonts.quicksand(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
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
                                          DeskripsiKelasAdmin(
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
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // == Pengumpulan Pre-Test, Latihan dan Tugas ==//
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
                                          KumpulUjianPemahamanAdmin(
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
                                    'Pengumpulan',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //== Asistensi Laporan ==//
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
                                          DataPraktikanAsistensiAdmin(
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
                                    'Asistensi',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                      TabelKumpulTugas(kodeKelas: widget.kodeKelas),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Latihan'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmarks), label: 'Tugas'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3CBEA9),
        onTap: _onItemTapped,
      ),
    );
  }
}
