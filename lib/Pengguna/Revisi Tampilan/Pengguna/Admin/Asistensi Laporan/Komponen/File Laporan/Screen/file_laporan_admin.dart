import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Data Mahasiswa Asisten/Screen/data_mahasiswa_asistensi_laporan.dart';
import '../Tabel/tabel_file_laporan_admin.dart';

class FileLaporanPraktikanAdmin extends StatefulWidget {
  final String kodeKelas;
  final String nama;
  final String modul;
  final int nim;
  final String mataKuliah;
  const FileLaporanPraktikanAdmin(
      {super.key,
      required this.kodeKelas,
      required this.nama,
      required this.modul,
      required this.nim,
      required this.mataKuliah});

  @override
  State<FileLaporanPraktikanAdmin> createState() =>
      _FileLaporanPraktikanAdminState();
}

class _FileLaporanPraktikanAdminState extends State<FileLaporanPraktikanAdmin> {
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
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          DataMahasiswaAsistensiLaporan(
                        kodeKelas: widget.kodeKelas,
                        mataKuliah: widget.mataKuliah,
                      ),
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
                      widget.nama,
                      style: GoogleFonts.quicksand(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
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
                    width: 1270.0,
                    color: Colors.white,
                    child: TabelFileLaporanAdmin(
                        kodeKelas: widget.kodeKelas,
                        nim: widget.nim,
                        modul: widget.modul,
                        nama: widget.nama)),
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
