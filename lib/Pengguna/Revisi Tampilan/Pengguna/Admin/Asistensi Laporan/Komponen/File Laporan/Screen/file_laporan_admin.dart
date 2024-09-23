import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Tabel/tabel_file_laporan_admin.dart';

class FileLaporanPraktikanAdmin extends StatefulWidget {
  final String idkelas;
  final String nama;
  final int nim;
  final String mataKuliah;
  const FileLaporanPraktikanAdmin(
      {super.key,
      required this.idkelas,
      required this.nama,
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
                    )),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text(
                        '',
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
      body: SingleChildScrollView(
        child: Container(
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
                          idkelas: widget.idkelas,
                          nim: widget.nim,
                          nama: widget.nama)),
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
