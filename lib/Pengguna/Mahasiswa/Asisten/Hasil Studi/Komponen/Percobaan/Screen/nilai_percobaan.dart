import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Hasil%20Studi/Komponen/Percobaan/Nilai/penilaian_percobaan.dart';

class NilaiPercobaan extends StatefulWidget {
  final String kodeKelas;
  const NilaiPercobaan({super.key, required this.kodeKelas});

  @override
  State<NilaiPercobaan> createState() => _NilaiPercobaanState();
}

class _NilaiPercobaanState extends State<NilaiPercobaan> {
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
                  'Penilaian Praktikum',
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
                    const EdgeInsets.only(left: 25.0, top: 5.0, right: 25.0),
                child: Container(
                  width: 1500.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PenilaianPercobaanAsisten(
                        kodeKelas: widget.kodeKelas,
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
