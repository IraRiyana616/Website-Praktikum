import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Hasil%20Studi/Komponen/Penulisan%20Laporan/Tabel/penulisanlaporan_ds.dart';

class PenulisanLaporanDosen extends StatefulWidget {
  final String documentId;
  const PenulisanLaporanDosen({super.key, required this.documentId});

  @override
  State<PenulisanLaporanDosen> createState() => _PenulisanLaporanDosenState();
}

class _PenulisanLaporanDosenState extends State<PenulisanLaporanDosen> {
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
                  "Hasil Studi Praktikum",
                  style: GoogleFonts.quicksand(
                      fontSize: 18.0,
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
                    const EdgeInsets.only(left: 35.0, top: 5.0, right: 15.0),
                child: Container(
                  width: 1300,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            color: const Color(0xFF3CBEA9),
                            width: 264.0,
                            height: 45.0,
                            child: Center(
                                child: Text(
                              'Penulisan Laporan',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                          ),
                          SizedBox(
                            width: 264.0,
                            height: 45.0,
                            child: Center(
                                child: Text(
                              'Nilai Harian',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )),
                          ),
                          SizedBox(
                            width: 263.0,
                            height: 45.0,
                            child: Center(
                                child: Text(
                              'Nilai Kuis',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )),
                          ),
                          SizedBox(
                            width: 263.22,
                            height: 45.0,
                            child: Center(
                                child: Text(
                              'Nilai Akhir',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )),
                          )
                        ],
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 8.0),
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      const TabelPenulisanLaporan()
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
