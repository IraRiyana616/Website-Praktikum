import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Tabel/tblabsensiass_ds.dart';

class DataAbsensiAsisten extends StatefulWidget {
  const DataAbsensiAsisten({super.key});

  @override
  State<DataAbsensiAsisten> createState() => _DataAbsensiAsistenState();
}

class _DataAbsensiAsistenState extends State<DataAbsensiAsisten> {
  bool isSelected = false;
  bool isMahasiswaSelected = true;

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
              padding: const EdgeInsets.only(top: 8.0, left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    "Absensi Mahasiswa",
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
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 65.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMahasiswaSelected = true;
                        });
                      },
                      child: Container(
                        height: 45.0,
                        width: 150.0,
                        color: isMahasiswaSelected
                            ? const Color(0xFF3CBEA9)
                            : Colors.white,
                        child: Center(
                          child: Text(
                            "Mahasiswa",
                            style: GoogleFonts.quicksand(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: isMahasiswaSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMahasiswaSelected = false;
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             const AbsentAsisstantNav()));
                        });
                      },
                      child: Container(
                        height: 45.0,
                        width: 150.0,
                        color: isMahasiswaSelected
                            ? Colors.white
                            : const Color(0xFF3CBEA9),
                        child: Center(
                          child: Text(
                            "Asisten",
                            style: GoogleFonts.quicksand(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: isMahasiswaSelected
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 65.0),
                child: Container(
                  width: 1250.0,
                  color: Colors.white,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [TabelAbsensiMahasiswa()],
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
