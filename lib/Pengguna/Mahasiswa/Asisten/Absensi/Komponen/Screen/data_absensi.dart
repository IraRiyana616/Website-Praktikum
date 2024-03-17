import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Absensi/Komponen/Tabel/tabel_data_absensi.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Komponen/Deskripsi/Screen/deskripsi_kelas.dart';

class DataAbsensiPraktikan extends StatefulWidget {
  final String kodeKelas;
  const DataAbsensiPraktikan({super.key, required this.kodeKelas});

  @override
  State<DataAbsensiPraktikan> createState() => _DataAbsensiPraktikanState();
}

class _DataAbsensiPraktikanState extends State<DataAbsensiPraktikan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70.0),
            child: AppBar(
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
                      widget.kodeKelas,
                      style: GoogleFonts.quicksand(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
                    const SizedBox(
                      width: 750.0,
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
            )),
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
                              border:
                                  Border.all(width: 0.5, color: Colors.grey)),
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
                                          builder: (context) => DeskripsiKelas(
                                              kodeKelas: widget.kodeKelas)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 38.0, left: 95.0),
                                  child: Text(
                                    'Deskripsi',
                                    style:
                                        GoogleFonts.quicksand(fontSize: 16.0),
                                  ),
                                )),
                            //Absensi
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 38.0, left: 50.0),
                              child: Text(
                                'Absensi',
                                style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            //Laporan
                            GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => DeskripsiKelas(
                                  //             kodeKelas: widget.kodeKelas)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 38.0, left: 50.0),
                                  child: Text(
                                    'Laporan',
                                    style:
                                        GoogleFonts.quicksand(fontSize: 16.0),
                                  ),
                                )),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 45.0, right: 45.0),
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        const TabelDataAbsensiPraktikan()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
