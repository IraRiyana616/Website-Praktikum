import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Navigasi/asistensi_laporan_navigasi_admin.dart';
import '../Tabel/tabel_data_mahasiswa_asistensi_laporan.dart';

class DataMahasiswaAsistensiLaporan extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const DataMahasiswaAsistensiLaporan(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<DataMahasiswaAsistensiLaporan> createState() =>
      _DataMahasiswaAsistensiLaporanState();
}

class _DataMahasiswaAsistensiLaporanState
    extends State<DataMahasiswaAsistensiLaporan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AsistensiLaporanNavigasiAdmin(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
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
                    widget.mataKuliah,
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    'Admin',
                    style: GoogleFonts.quicksand(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 30.0),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: const Color(0xFFE3E8EF),
            constraints: const BoxConstraints.expand(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 15.0),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1250.0),
                          color: Colors.white,
                          child: TabelDataMahasiswaAsistensiLaporan(
                            kodeKelas: widget.kodeKelas,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
