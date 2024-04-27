import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PieChartNilaiHuruf extends StatefulWidget {
  final String kodeKelas;
  const PieChartNilaiHuruf({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  State<PieChartNilaiHuruf> createState() => _PieChartNilaiHurufState();
}

class _PieChartNilaiHurufState extends State<PieChartNilaiHuruf> {
  List<PieChartSectionData> _pieChartSections = [];
  List<PieChartSectionData> _pieChartKelulusanSections = [];

  @override
  void initState() {
    super.initState();
    _loadDataLulusTidakLulusFromFirestore();
    _loadDataFromFirestore();
  }

  Future<void> _loadDataLulusTidakLulusFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('nilaiAkhir')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    int lulusCount = 0;
    int tidakLulusCount = 0;
    for (var doc in querySnapshot.docs) {
      double nilaiAkhir = doc['nilaiAkhir'];
      if (nilaiAkhir >= 60) {
        lulusCount++;
      } else {
        tidakLulusCount++;
      }
    }

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        color: Colors.green.shade400,
        value: lulusCount.toDouble(),
        title:
            'Lulus: ${((lulusCount / (lulusCount + tidakLulusCount)) * 100).toStringAsFixed(2)}%',
        radius: 50,
        titleStyle:
            const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red.shade400,
        value: tidakLulusCount.toDouble(),
        title:
            'Tidak Lulus: ${((tidakLulusCount / (lulusCount + tidakLulusCount)) * 100).toStringAsFixed(2)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];

    setState(() {
      _pieChartKelulusanSections = sections;
    });
  }

  Future<void> _loadDataFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('nilaiAkhir')
        .where('kodeKelas',
            isEqualTo: widget.kodeKelas) // Add filter by kodeKelas
        .get();

    Map<String, int> nilaiHurufCount = {};
    for (var doc in querySnapshot.docs) {
      String nilaiHuruf = doc['nilaiHuruf'];
      nilaiHurufCount.update(
        nilaiHuruf,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    int totalCount = nilaiHurufCount.values.reduce((a, b) => a + b);
    List<PieChartSectionData> sections = nilaiHurufCount.entries.map((entry) {
      double percentage = (entry.value / totalCount) * 100;
      return PieChartSectionData(
        color: _getColorForNilaiHuruf(entry.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle:
            const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
      );
    }).toList();
    setState(() {
      _pieChartSections = sections;
    });
  }

  Color _getColorForNilaiHuruf(String nilaiHuruf) {
    switch (nilaiHuruf) {
      case 'A':
        return Colors.green.shade400;
      case 'B':
        return Colors.blue.shade400;
      case 'C':
        return Colors.orange.shade400;
      case 'D':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

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
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
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
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  width: 1200.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 25.0,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 50.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 95.0, top: 30.0),
                                    child: Text(
                                      'Grafik Nilai Akhir',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 80.0, top: 65.0),
                                    child: SizedBox(
                                      width: 150.0,
                                      height: 150.0,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: PieChart(PieChartData(
                                            sections:
                                                _pieChartSections.isNotEmpty
                                                    ? _pieChartSections
                                                    : [],
                                            borderData:
                                                FlBorderData(show: false),
                                            centerSpaceRadius: 50,
                                            sectionsSpace: 0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 105.0),
                              child: SizedBox(
                                  height: 250.0,
                                  width: 280.0,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 12.0,
                                              height: 12.0,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  color: Colors.green),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 30.0),
                                              child: Container(
                                                width: 12.0,
                                                height: 12.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    color: Colors.blue),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 30.0),
                                              child: Container(
                                                width: 12.0,
                                                height: 12.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    color: Colors.orange),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 30.0),
                                              child: Container(
                                                width: 12.0,
                                                height: 12.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    color: Colors.red),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 30.0),
                                              child: Container(
                                                width: 12.0,
                                                height: 12.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Presentase Nilai A',
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 23.0),
                                              child: Text(
                                                'Presentase  Nilai B',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 23.0),
                                              child: Text(
                                                'Presentase Nilai C',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 23.0),
                                              child: Text(
                                                'Presentase Nilai D',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 23.0),
                                              child: Text(
                                                'Presentase Nilai E',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 50.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 80.0, top: 30.0),
                                    child: Text(
                                      'Grafik Mahasiswa Lulus dan Tidak Lulus',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 80.0, top: 65.0),
                                    child: SizedBox(
                                      width: 150.0,
                                      height: 150.0,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: PieChart(PieChartData(
                                            sections: _pieChartKelulusanSections
                                                    .isNotEmpty
                                                ? _pieChartKelulusanSections
                                                : [],
                                            borderData:
                                                FlBorderData(show: false),
                                            centerSpaceRadius: 50,
                                            sectionsSpace: 0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                      //== Tampilan Nama Dosen ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 65.0),
                        child: Text(
                          'Nama Dosen',
                          style: GoogleFonts.quicksand(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 25.0, left: 65.0),
                        child: Text(
                          'Ira Riyana',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      //== Tampilan Dokumentasi Kegiatan Praktikum ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 65.0),
                        child: Text(
                          'File Dokumentasi Kegiatan Praktikum',
                          style: GoogleFonts.quicksand(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 65.0),
                        child: Row(
                          children: [
                            const Text(
                              'Nama File ',
                              style:
                                  TextStyle(fontSize: 16.0, color: Colors.blue),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.grey,
                                ))
                          ],
                        ),
                      ),
                      //== Tampilan Data Hasil Evaluasi Kegiatan Praktikum ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0, left: 65.0),
                        child: Text(
                          'Hasil Evaluasi Kegiatan Praktikum',
                          style: GoogleFonts.quicksand(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 80.0,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 40.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
