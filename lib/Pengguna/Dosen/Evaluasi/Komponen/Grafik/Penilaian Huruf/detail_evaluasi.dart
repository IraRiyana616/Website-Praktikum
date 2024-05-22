import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PieChartNilaiHuruf extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const PieChartNilaiHuruf(
      {Key? key, required this.kodeKelas, required this.mataKuliah})
      : super(key: key);

  @override
  State<PieChartNilaiHuruf> createState() => _PieChartNilaiHurufState();
}

class _PieChartNilaiHurufState extends State<PieChartNilaiHuruf> {
  List<PieChartSectionData> _pieChartSections = [];
  List<PieChartSectionData> _pieChartKelulusanSections = [];
  bool _dataLoaded = false;
  //== Nama Akun ==//
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String _namaDosen = '';

  // Fungsi untuk mendapatkan pengguna yang sedang login dan mengambil data nama dari database
  void _getCurrentUser() async {
    setState(() {
      _currentUser = _auth.currentUser;
    });
    if (_currentUser != null) {
      await _getNamaDosen(_currentUser!.uid);
    }
  }

  // Fungsi untuk mengambil nama mahasiswa dari database
  Future<void> _getNamaDosen(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('akun_dosen').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _namaDosen = doc.get('nama');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching nama mahasiswa: $e');
      }
    }
  }

  //== Fungsi untuk authentikasi ==//
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadDataLulusTidakLulusFromFirestore();
    _loadDataFromFirestore();
    _getCurrentUser();
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
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
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
      _dataLoaded = true;
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

//== Fungsi Download File ==//
  Future<void> downloadFile(String kodeKelas, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('Data Evaluasi/$kodeKelas/$fileName');

    try {
      final url = await ref.getDownloadURL();
      // ignore: deprecated_member_use
      if (await canLaunch(url)) {
        // ignore: deprecated_member_use
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
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
                    widget.mataKuliah,
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 700.0,
                ),
                if (_currentUser != null) ...[
                  Text(
                    _namaDosen.isNotEmpty
                        ? _namaDosen
                        : (_currentUser!.email ?? ''),
                    style: GoogleFonts.quicksand(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 30.0,
                  ),
                ],
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
                                      left: 65.0, top: 50.0),
                                  child: Text(
                                    'Grafik Nilai Akhir',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Visibility(
                                  visible: _dataLoaded,
                                  child: Padding(
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
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 80.0, top: 105.0),
                            child: SizedBox(
                              height: 250.0,
                              width: 280.0,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLegendItem(
                                          'Presentase Nilai A',
                                          Colors.green,
                                        ),
                                        _buildLegendItem(
                                          'Presentase  Nilai B',
                                          Colors.blue,
                                        ),
                                        _buildLegendItem(
                                          'Presentase Nilai C',
                                          Colors.orange,
                                        ),
                                        _buildLegendItem(
                                          'Presentase Nilai D',
                                          Colors.red,
                                        ),
                                        _buildLegendItem(
                                          'Presentase Nilai E',
                                          Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 50.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 80.0, top: 50.0),
                                  child: Text(
                                    'Grafik Mahasiswa Lulus dan Tidak Lulus',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Visibility(
                                  visible: _dataLoaded,
                                  child: Padding(
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //== Tampilan Waktu Kegiatan Praktikum ==//
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('dataEvaluasi')
                            .where('kodeKelas', isEqualTo: widget.kodeKelas)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text("No Data"),
                            );
                          }
                          var data = snapshot.data!.docs.first.data();
                          //== Awal Kegiatan Praktikum ==//
                          var tanggalAwal = data['awalPraktikum'] != null
                              ? data['awalPraktikum'].toString()
                              : 'Data tidak ditemukan';
                          //== Berakhir Kegiatan Praktikum ==//
                          var tanggalAkhir = data['akhirPraktikum'] != null
                              ? data['akhirPraktikum'].toString()
                              : 'Data tidak ditemukan';
                          //== Nama File ==//
                          var namaFile = data['fileDokumentasi'] != null
                              ? data['fileDokumentasi'].toString()
                              : 'Data tidak ditemukan';
                          //== Ringkasan Evaluasi Kegiatan Praktikum ==//
                          var evaluasiPraktikum =
                              data['evaluasiPraktikum'] != null
                                  ? data['evaluasiPraktikum'].toString()
                                  : 'Data tidak ditemukan';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 35.0, left: 65.0),
                                child: Text(
                                  'Waktu Kegiatan Praktikum',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, left: 65.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        tanggalAwal,
                                        style: const TextStyle(fontSize: 14.0),
                                      ),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(left: 20.0, top: 8.0),
                                      child: Text(
                                        'Sampai',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 8.0),
                                      child: Text(
                                        tanggalAkhir,
                                        style: const TextStyle(fontSize: 14.0),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              //== Tampilan Dokumentasi Kegiatan Praktikum ==//
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 25.0, left: 65.0),
                                child: Text(
                                  'File Dokumentasi Kegiatan Praktikum',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 25.0, left: 65.0),
                                child: Row(
                                  children: [
                                    Text(
                                      namaFile,
                                      style: const TextStyle(
                                          fontSize: 14.0, color: Colors.blue),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: IconButton(
                                          onPressed: () {
                                            downloadFile(
                                                widget.kodeKelas, namaFile);
                                          },
                                          icon: const Icon(
                                            Icons.download,
                                            color: Colors.grey,
                                          )),
                                    )
                                  ],
                                ),
                              ),
                              //== Tampilan Data Hasil Evaluasi Kegiatan Praktikum ==//
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 35.0, left: 65.0),
                                child: Text(
                                  'Hasil Evaluasi Kegiatan Praktikum',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 25.0, left: 65.0, right: 67.0),
                                child: Text(
                                  evaluasiPraktikum,
                                  style: const TextStyle(
                                      fontSize: 14.0, height: 2.0),
                                ),
                              ),

                              const SizedBox(
                                height: 50.0,
                              )
                            ],
                          );
                        },
                      ),
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

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        children: [
          Container(
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: GoogleFonts.quicksand(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
