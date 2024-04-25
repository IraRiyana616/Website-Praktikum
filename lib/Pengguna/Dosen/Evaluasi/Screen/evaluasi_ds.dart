import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Dosen/Evaluasi/Tabel/tblevaluasi_ds.dart';

class EvaluasiDosen extends StatefulWidget {
  const EvaluasiDosen({super.key});

  @override
  State<EvaluasiDosen> createState() => _EvaluasiDosenState();
}

class _EvaluasiDosenState extends State<EvaluasiDosen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          automaticallyImplyLeading: false,
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
                  "Evaluasi Praktikum",
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
                padding: const EdgeInsets.only(left: 25.0, top: 5.0),
                child: Container(
                  width: 1055.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 35.0, top: 30.0),
                        child: Text(
                          'Tahun Ajaran',
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ),
                      //Tabel Evaluasi Praktikum
                      const TabelEvaluasiDosen()
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
