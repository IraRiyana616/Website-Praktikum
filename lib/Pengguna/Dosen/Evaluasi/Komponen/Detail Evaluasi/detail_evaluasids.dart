import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailEvaluasiDosen extends StatefulWidget {
  final String documentId;
  const DetailEvaluasiDosen({super.key, required this.documentId});

  @override
  State<DetailEvaluasiDosen> createState() => _DetailEvaluasiDosenState();
}

class _DetailEvaluasiDosenState extends State<DetailEvaluasiDosen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = FirebaseFirestore.instance
        .collection('dataEvaluasi')
        .doc(widget.documentId)
        .get();
  }

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
                    'Detail Evaluasi',
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
          )),
      body: FutureBuilder(
        future: futureData,
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            //Access the data frm the snapshot
            Map<String, dynamic> data = snapshot.data!.data() ?? {};
            return SingleChildScrollView(
              child: Container(
                color: const Color(0xFFE3E8EF),
                width: 2000.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child: Container(
                        width: 1200.0,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 35.0, top: 30.0),
                              child: Text(
                                "Detail Evaluasi Praktikum",
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 35.0, right: 35.0),
                              child: Divider(thickness: 1.0),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text("Kode Kelas",
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text(
                                  "${data['kodeKelas'] ?? 'Not available'}",
                                  style: const TextStyle(fontSize: 15.0)),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text("Tahun Ajaran",
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text(
                                  "${data['tahunAjaran'] ?? 'Not available'}",
                                  style: const TextStyle(fontSize: 15.0)),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text("Jumlah Mahasiswa Lulus",
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text(
                                  "${data['jumlahLulus'] ?? 'Not available'}",
                                  style: const TextStyle(fontSize: 15.0)),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text("Jumlah Mahasiswa Tidak Lulus",
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text(
                                  "${data['jumlahTidak_lulus'] ?? 'Not available'}",
                                  style: const TextStyle(fontSize: 15.0)),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text("Detail Evaluasi",
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 35.0, right: 45.0),
                              child: Text(
                                  "${data['hasilEvaluasi'] ?? 'Not available'}",
                                  style: const TextStyle(
                                      fontSize: 15.0, height: 2.0)),
                            ),
                            const SizedBox(height: 40.0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 500.0,
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
