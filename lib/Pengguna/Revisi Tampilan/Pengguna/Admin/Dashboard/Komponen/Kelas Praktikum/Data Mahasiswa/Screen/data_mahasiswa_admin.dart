import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Data Kelas/Screen/tahun_ajaran_screen.dart';
import '../../Data Asisten/Screen/data_asisten_admin.dart';
import '../../Silabus Praktikum/Screen/silabus.dart';
import '../Tabel/tabel_mahasiswa.dart';

class DataMahasiswaScreen extends StatefulWidget {
  final String kodeMatakuliah;
  final String mataKuliah;
  final String idkelas;
  const DataMahasiswaScreen(
      {super.key,
      required this.kodeMatakuliah,
      required this.mataKuliah,
      required this.idkelas});

  @override
  State<DataMahasiswaScreen> createState() => _DataMahasiswaScreenState();
}

class _DataMahasiswaScreenState extends State<DataMahasiswaScreen> {
  @override
  Widget build(BuildContext context) {
    //== MediaQuery ==//
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TahunAjaranScreen(
                    mataKuliah: widget.mataKuliah,
                    kodeMatakuliah: widget.kodeMatakuliah,
                  ),
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
            ),
          ),
          backgroundColor: const Color(0xFFF7F8FA),
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
                if (screenWidth > 600) const SizedBox(width: 400.0),
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
                if (screenWidth > 600) const SizedBox(width: 10.0)
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: screenWidth > 1050.0 ? 2000.0 : screenWidth,
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
                      //== Tab Layout Data Asisten >> Data Mahasiswa >> Silabus Praktikum ==//
                      Row(
                        children: [
                          //== Silabus Praktikum ==//
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
                                          SilabusScreen(
                                        kodeMatakuliah: widget.kodeMatakuliah,
                                        mataKuliah: widget.mataKuliah,
                                        idkelas: widget.idkelas,
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
                                    'Silabus Praktikum',
                                    style:
                                        GoogleFonts.quicksand(fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //== Data Asisten ==//
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
                                          DataAsistenScreen(
                                        idkelas: widget.idkelas,
                                        mataKuliah: widget.mataKuliah,
                                        kode: widget.kodeMatakuliah,
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
                                    'Data Asisten',
                                    style:
                                        GoogleFonts.quicksand(fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //== Data Mahasiswa ==//
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
                                          DataMahasiswaScreen(
                                        kodeMatakuliah: widget.kodeMatakuliah,
                                        mataKuliah: widget.mataKuliah,
                                        idkelas: widget.idkelas,
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
                                    'Data Mahasiswa',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
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
                      TabelDataMahasiswa(
                        mataKuliah: widget.mataKuliah,
                        idkelas: widget.idkelas,
                        kode: widget.kodeMatakuliah,
                      ),
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
    );
  }
}
