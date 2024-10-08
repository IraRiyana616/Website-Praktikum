import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Landing%20Page/Komponen/Mahasiswa/Login/login_mhs.dart';
import 'package:laksi/Landing%20Page/Komponen/Non%20Mahasiswa/Dosen/Login/login_dosen.dart';

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
            const Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: Text(
                '© 2023. Penelitian Skripsi. Ira Riyana Sari Siregar',
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 400.0,
                    width: 700.0,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 100.0, left: 90.0),
                            child: Text(
                              'Laboratorium Komputasi \ndan Sistem Informasi \nFakultas Teknik',
                              style: GoogleFonts.quicksand(
                                  fontSize: 45.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, left: 90.0),
                            child: Text(
                              'Website penunjang kegiatan praktikum',
                              style: GoogleFonts.inter(fontSize: 20.0),
                            ),
                          )
                        ]),
                  ),
                  const SizedBox(
                    width: 100.0,
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 183.0),
                        child: Container(
                          width: 450.0,
                          height: 200.0,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.green],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(50.0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 100.0),
                        child: Image.asset('assets/images/background.png'),
                      )
                    ],
                  )
                ],
              ),
              Text(
                'Layanan',
                style: GoogleFonts.quicksand(
                    fontSize: 45.0, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 55.0),
                child: Container(
                  color: Colors.grey.shade300,
                  height: 400.0,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //== Halaman Mahasiswa ==//
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginMahasiswa(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                        child: Padding(
                          padding: const EdgeInsets.only(left: 200.0),
                          child: Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              height: 240.0,
                              width: 400.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/mahasiswa.png',
                                    height: 150.0,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  const Text(
                                    'Mahasiswa',
                                    style: TextStyle(
                                        fontSize: 35.0,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      //== Halaman Non Mahasiswa ==//
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginDosen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                        child: Padding(
                          padding: const EdgeInsets.only(right: 200.0),
                          child: Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              height: 240.0,
                              width: 400.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/dosen.png',
                                    height: 150.0,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  const Text(
                                    'Non Mahasiswa',
                                    style: TextStyle(
                                        fontSize: 35.0,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
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
