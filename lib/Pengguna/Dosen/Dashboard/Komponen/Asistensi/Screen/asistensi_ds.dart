import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Navigasi/dasboardnav_ds.dart';
import '../../Deskripsi/Screen/deskripsi_dosen.dart';
import '../../Pengumpulan/Latihan/latihan_ds.dart';
import '../Tabel/tabel_asistensi.dart';

class DataPraktikanAsistensiDosen extends StatefulWidget {
  final String kodeKelas;

  const DataPraktikanAsistensiDosen({super.key, required this.kodeKelas});

  @override
  State<DataPraktikanAsistensiDosen> createState() =>
      _DataPraktikanAsistensiDosenState();
}

class _DataPraktikanAsistensiDosenState
    extends State<DataPraktikanAsistensiDosen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardDosenNav()));
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )),
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
                        color: Colors.black),
                  ))
                ],
              ),
            ),
          )),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5, color: Colors.grey)),
                        height: 320.0,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/kelas.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        children: [
                          //Deskripsi Kelas
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 38.0, left: 95.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DeskripsiKelasDosen(
                                                kodeKelas: widget.kodeKelas)));
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  'Deskripsi',
                                  style: GoogleFonts.quicksand(fontSize: 16.0),
                                ),
                              ),
                            ),
                          ),

                          //Pengumpulan Pre-Test, Latihan dan Tugas
                          GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 50.0,
                                top: 38.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              KumpulUjianPemahamanDosen(
                                                  kodeKelas:
                                                      widget.kodeKelas)));
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    'Pengumpulan',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //Asistensi Laporan
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 50.0,
                              top: 38.0,
                            ),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text(
                                'Asistensi',
                                style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 45.0, right: 45.0),
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),

                      //Tabel Data Praktikan
                      TabelDataPraktikanDosen(kodeKelas: widget.kodeKelas),
                      const SizedBox(
                        height: 20.0,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
