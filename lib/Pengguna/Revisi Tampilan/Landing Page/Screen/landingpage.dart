import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Landing Page/Komponen/Mahasiswa/Login/login_mhs.dart';
import '../../../../Landing Page/Komponen/Non Mahasiswa/Dosen/Login/login_dosen.dart';
import '../Komponen/Non Mahasiswa/Admin/Login/login_admin.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 35.0),
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.cover,
                height: 250.0,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  constraints.maxWidth >= 600
                      ? Row(
                          children: [
                            SizedBox(
                              height: 400.0,
                              width: constraints.maxWidth * 0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 100.0, left: 90.0),
                                    child: Text(
                                      'Laboratorium Komputasi \ndan Sistem Informasi \nFakultas Teknik',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 45.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0, left: 90.0),
                                    child: Text(
                                      'Website penunjang kegiatan praktikum',
                                      style: GoogleFonts.inter(fontSize: 20.0),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth * 0.15,
                            ),
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 183.0),
                                  child: Container(
                                    width: constraints.maxWidth * 0.3,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            colors: [Colors.blue, Colors.green],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight),
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 100.0),
                                  child: Image.asset(
                                      'assets/images/background.png'),
                                )
                              ],
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Laboratorium Komputasi \ndan Sistem Informasi \nFakultas Teknik',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.quicksand(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Website penunjang kegiatan praktikum',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 16.0),
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  width: constraints.maxWidth * 0.6,
                                  height: 200.0,
                                  decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [Colors.blue, Colors.green],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight),
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 50.0),
                                  child: Image.asset(
                                      'assets/images/background.png'),
                                )
                              ],
                            ),
                          ],
                        ),
                  //== Layanan ==//
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      'Layanan',
                      style: GoogleFonts.quicksand(
                          fontSize: 45.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    color: Colors.grey.shade300,
                    height: 370.0,
                    padding: const EdgeInsets.all(20.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return constraints.maxWidth >= 600
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  serviceBox(
                                    'Mahasiswa',
                                    'assets/images/mahasiswa.png',
                                    () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const LoginMahasiswa(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(0.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    constraints.maxWidth * 0.28,
                                  ),
                                  serviceBox(
                                    'Dosen',
                                    'assets/images/dosen.png',
                                    () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const LoginDosen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(0.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    constraints.maxWidth * 0.28,
                                  ),
                                  serviceBox(
                                    'Admin',
                                    'assets/images/dosen.png',
                                    () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const LoginAdmin(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(0.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    constraints.maxWidth * 0.28,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  serviceBox(
                                    'Mahasiswa',
                                    'assets/images/mahasiswa.png',
                                    () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const LoginMahasiswa(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(0.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    constraints.maxWidth * 0.6,
                                  ),
                                  const SizedBox(height: 20.0),
                                  serviceBox(
                                    'Dosen',
                                    'assets/images/dosen.png',
                                    () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const LoginDosen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(0.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    constraints.maxWidth * 0.6,
                                  ),
                                  const SizedBox(height: 20.0),
                                  serviceBox(
                                    'Admin',
                                    'assets/images/dosen.png',
                                    () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const LoginAdmin(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(0.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    constraints.maxWidth * 0.6,
                                  ),
                                ],
                              );
                      },
                    ),
                  ),
                  //== Footer Halaman Website ==//
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 40.0, right: 90.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Contact Us',
                          style: GoogleFonts.quicksand(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            'Email: info@labkom.com | Phone: (021) 12345678',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 16.0),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [],
                        ),
                        Text(
                          '© 2023. Penelitian Skripsi. Ira Riyana Sari Siregar',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12.0),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget serviceBox(
      String title, String imagePath, Function() onTap, double width) {
    return InkWell(
      onTap: onTap,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: 240.0,
          width: width,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 120.0,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: GoogleFonts.quicksand(
                      fontSize: 35.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
