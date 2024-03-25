import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PengumpulanUjianPemahaman extends StatefulWidget {
  final String kodeKelas;
  final String modul;
  const PengumpulanUjianPemahaman(
      {super.key, required this.kodeKelas, required this.modul});

  @override
  State<PengumpulanUjianPemahaman> createState() =>
      _PengumpulanUjianPemahamanState();
}

class _PengumpulanUjianPemahamanState extends State<PengumpulanUjianPemahaman> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
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
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    widget.kodeKelas,
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
