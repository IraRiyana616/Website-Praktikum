import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Tabel%20Kelas/tabel_kelas.dart';

class KelasAsisten extends StatefulWidget {
  const KelasAsisten({super.key});

  @override
  State<KelasAsisten> createState() => _KelasAsistenState();
}

class _KelasAsistenState extends State<KelasAsisten> {
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
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      "Dashboard Asisten",
                      style: GoogleFonts.quicksand(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
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
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40.0,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 35.0, right: 40.0),
                  child: Container(
                      width: 1090.0,
                      color: Colors.white,
                      child: const TabelKelasAsisten()),
                ),
              ),
              const SizedBox(
                height: 150.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
