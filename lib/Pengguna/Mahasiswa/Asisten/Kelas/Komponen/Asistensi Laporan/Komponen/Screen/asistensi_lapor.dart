import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Tabel/tbl_asistensi_lapor.dart';

class AsistensiLaporan extends StatefulWidget {
  final String kodeKelas;
  final String nama;
  final String modul;
  final int nim;
  const AsistensiLaporan({
    super.key,
    required this.kodeKelas,
    required this.nama,
    required this.modul,
    required this.nim,
  });

  @override
  State<AsistensiLaporan> createState() => _AsistensiLaporanState();
}

class _AsistensiLaporanState extends State<AsistensiLaporan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            automaticallyImplyLeading: false,
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
                    Expanded(
                        child: Text(
                      widget.nama,
                      style: GoogleFonts.quicksand(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ))
                  ]),
            ),
          )),
      body: Container(
        color: const Color(0xFFE3E8EF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 35.0, right: 40.0),
                child: Container(
                    width: 1230.0,
                    color: Colors.white,
                    //Tabel disini
                    child: TabelAsistensiLaporan(
                      modul: widget.modul,
                      kodeKelas: widget.kodeKelas,
                      nama: widget.nama,
                      nim: widget.nim,
                    )),
              ),
            ),
            const SizedBox(
              height: 20.0,
            )
          ],
        ),
      ),
    );
  }
}
