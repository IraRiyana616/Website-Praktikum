import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DataKelas extends StatefulWidget {
  const DataKelas({super.key});

  @override
  State<DataKelas> createState() => _DataKelasState();
}

class _DataKelasState extends State<DataKelas> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0),
            child: Text(
              'Data Kelas',
              style: GoogleFonts.quicksand(
                  fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
