import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Absensi/Komponen/Praktikan/Tabel/tblabsensiprak_ds.dart';

class AbsensiMahasiswaScreen extends StatefulWidget {
  const AbsensiMahasiswaScreen({super.key});

  @override
  State<AbsensiMahasiswaScreen> createState() => _AbsensiMahasiswaScreenState();
}

class _AbsensiMahasiswaScreenState extends State<AbsensiMahasiswaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          leading: IconButton(
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const AsistenNav()));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          backgroundColor: const Color(0xFFF7F8FA),
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
                  'Kelas Praktikum',
                  style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )),
                const SizedBox(
                  width: 800.0,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFF031F31),
                    )),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  'Log out',
                  style: GoogleFonts.quicksand(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF031F31)),
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
                          //Deskripsi
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 38.0, left: 95.0),
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Deskripsi',
                                style: GoogleFonts.quicksand(fontSize: 16.0),
                              ),
                            ),
                          ),
                          //Absensi
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 50.0, top: 38.0),
                            child: Text(
                              'Absensi',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          //Percobaan
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 50.0, top: 38.0),
                            child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Percobaan',
                                  style: GoogleFonts.quicksand(fontSize: 16.0),
                                )),
                          ),
                          //Tugas
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 50.0, top: 38.0),
                            child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Tugas',
                                  style: GoogleFonts.quicksand(fontSize: 16.0),
                                )),
                          ),
                          //Laporan
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 50.0, top: 38.0),
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Laporan',
                                style: GoogleFonts.quicksand(fontSize: 16.0),
                              ),
                            ),
                          )
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

                      //Tabel Absensi
                      const TabelAbsensiPraktikan()
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
