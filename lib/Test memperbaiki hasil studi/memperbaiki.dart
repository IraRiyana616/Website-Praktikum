import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  final String kodeKelas;

  MyHomePage({Key? key, required this.kodeKelas}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _controller = ScrollController();

//== Dropdown Button ==
  String selectedKeterangan = 'Tampilkan Semua';

  List<PenilaianAkhir> demoPenilaianAkhir = [];

  List<PenilaianAkhir> filteredPenilaianAkhir = [];

  @override
  void initState() {
    super.initState();
    checkAndFetchData();
  }

  Future<void> checkAndFetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('nilaiHarian')
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      await Future.forEach(querySnapshot.docs, (doc) async {
        // Ambil data yang diperlukan dari 'nilaiHarian'
        String nama = doc['nama'] ?? '';
        int nim = doc['nim'] ?? 0;
        double modul1 = doc['modul1'] ?? 0.0;
        double modul2 = doc['modul2'] ?? 0.0;
        double modul3 = doc['modul3'] ?? 0.0;
        double modul4 = doc['modul4'] ?? 0.0;
        double modul5 = doc['modul5'] ?? 0.0;

        // Periksa apakah data sudah ada di 'nilaiAkhir'
        QuerySnapshot<Map<String, dynamic>> nilaiSnapshot =
            await FirebaseFirestore.instance
                .collection('nilaiAkhir')
                .where('nim', isEqualTo: nim)
                .where('kodeKelas', isEqualTo: widget.kodeKelas)
                .get();

        if (nilaiSnapshot.docs.isEmpty) {
          // Jika data tidak ada, tambahkan ke 'nilaiAkhir'
          await FirebaseFirestore.instance.collection('nilaiAkhir').add({
            'nama': nama,
            'nim': nim,
            'kodeKelas': widget.kodeKelas,
            'modul1': modul1,
            'modul2': modul2,
            'modul3': modul3,
            'modul4': modul4,
            'modul5': modul5,
          });
        }
      });

      await getDataFromFirebase();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> getDataFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      if (selectedKeterangan != 'Tampilkan Semua') {
        // Jika keterangan yang akan difilter tidak kosong, lakukan query dengan filter
        querySnapshot = await FirebaseFirestore.instance
            .collection('nilaiAkhir')
            .where('kodeKelas', isEqualTo: widget.kodeKelas)
            .where('keterangan', isEqualTo: selectedKeterangan)
            .get();
      } else {
        // Jika keterangan yang akan difilter kosong, ambil semua data
        querySnapshot = await FirebaseFirestore.instance
            .collection('nilaiAkhir')
            .where('kodeKelas', isEqualTo: widget.kodeKelas)
            .get();
      }

      setState(() {
        demoPenilaianAkhir = querySnapshot.docs.map((docs) {
          Map<String, dynamic> data = docs.data();
          return PenilaianAkhir(
            nim: data['nim'] ?? 0,
            nama: data['nama'] ?? '',
            kode: data['kodeKelas'] ?? '',
            //== Rata - Rata Modul ==
            modul1: data['modul1'] ?? 0.0,
            modul2: data['modul2'] ?? 0.0,
            modul3: data['modul3'] ?? 0.0,
            modul4: data['modul4'] ?? 0.0,
            modul5: data['modul5'] ?? 0.0,
            //== Komponen Nilai Akhir
            pretest: data['pretest'] ?? 0.0,
            project: data['projectAkhir'] ?? 0.0,
            resmi: data['laporanResmi'] ?? 0.0,
            akhir: data['nilaiAkhir'] ?? 0.0,
            //== Penentuan Nilai Akhir ==
            status: data['keterangan'] ?? '',
            huruf: data['nilaiHuruf'] ?? '',
          );
        }).toList();
        filteredPenilaianAkhir = List.from(demoPenilaianAkhir);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error:$e');
      }
    }
  }

  //== Tampilan Dialog ==
  void editNilai(PenilaianAkhir nilai) {
    // == Pre-Test ==
    TextEditingController pretestController =
        TextEditingController(text: nilai.pretest.toString());
    //
    //== Komponen Nilai Rata - Rata
    TextEditingController modul1Controller =
        TextEditingController(text: nilai.modul1.toString());
    TextEditingController modul2Controller =
        TextEditingController(text: nilai.modul2.toString());
    TextEditingController modul3Controller =
        TextEditingController(text: nilai.modul3.toString());
    TextEditingController modul4Controller =
        TextEditingController(text: nilai.modul4.toString());
    TextEditingController modul5Controller =
        TextEditingController(text: nilai.modul5.toString());
//
// == Projek Akhir dan Laporan Resmi
    TextEditingController projectController =
        TextEditingController(text: nilai.project.toString());
    TextEditingController resmiController =
        TextEditingController(text: nilai.resmi.toString());

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Formulir Nilai Akhir',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                  child: Divider(
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              height: 240.0,
              width: 400.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //== Pre-Test, Modul 1, Modul 2 dan Modul 3
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // == PreTest
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: pretestController,
                            decoration:
                                const InputDecoration(labelText: 'Pre-Test'),
                          ),
                        ),
                      ),
                      // == Modul 1
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul1Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 1'),
                          ),
                        ),
                      ),
                      // == Modul 2
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul2Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 2'),
                          ),
                        ),
                      ),
                      // == Modul 3
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul3Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 3'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //== Modul 4, Modul 5, Projek Akhir, Laporan Resmi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // == Modul 4
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul4Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 4'),
                          ),
                        ),
                      ),
                      // == Modul 5
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: modul5Controller,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Modul 5'),
                          ),
                        ),
                      ),
                      // == Project Resmi
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 5.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: projectController,
                            decoration: const InputDecoration(
                                labelText: 'Project Resmi'),
                          ),
                        ),
                      ),
                      // == Laporan Resmi
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: SizedBox(
                          width: 130.0,
                          child: TextField(
                            controller: resmiController,
                            decoration: const InputDecoration(
                                labelText: 'Laporan Resmi'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextButton(
                  onPressed: () async {
                    // Dalam bagian onPressed dari TextButton:
                    double pretest =
                        double.tryParse(pretestController.text) ?? 0.0;
                    double project =
                        double.tryParse(projectController.text) ?? 0.0;
                    double resmi = double.tryParse(resmiController.text) ?? 0.0;

                    // Update nilai pretest, project, dan resmi pada objek nilai
                    nilai.pretest = pretest;
                    nilai.project = project;
                    nilai.resmi = resmi;

                    try {
                      // Dapatkan nama asisten
                      String? namaAsisten = await getNamaAsisten();

                      QuerySnapshot<Map<String, dynamic>> querySnapshot =
                          await FirebaseFirestore.instance
                              .collection('nilaiAkhir')
                              .where('nim', isEqualTo: nilai.nim)
                              .where('kodeKelas', isEqualTo: widget.kodeKelas)
                              .get();

                      if (querySnapshot.docs.isEmpty) {
                        await FirebaseFirestore.instance
                            .collection('nilaiAkhir')
                            .add({
                          'nim': nilai.nim,
                          'kodeKelas': widget.kodeKelas,
                          'modul1': nilai.modul1,
                          'modul2': nilai.modul2,
                          'modul3': nilai.modul3,
                          'modul4': nilai.modul4,
                          'modul5': nilai.modul5,
                          'pretest': pretest,
                          'projectAkhir': project,
                          'laporanResmi': resmi,
                          'keterangan': nilai.status,
                          'nilaiHuruf': nilai.huruf,
                          'namaAsisten':
                              namaAsisten ?? "", // Pastikan tidak null
                        });
                      } else {
                        await querySnapshot.docs[0].reference.update({
                          'modul1': nilai.modul1,
                          'modul2': nilai.modul2,
                          'modul3': nilai.modul3,
                          'modul4': nilai.modul4,
                          'modul5': nilai.modul5,
                          'pretest': pretest,
                          'projectAkhir': project,
                          'laporanResmi': resmi,
                          'keterangan': nilai.status,
                          'nilaiHuruf': nilai.huruf,
                          'namaAsisten':
                              namaAsisten ?? "", // Pastikan tidak null
                        });
                      }

                      setState(() {
                        demoPenilaianAkhir = demoPenilaianAkhir.map((item) {
                          if (item.nim == nilai.nim) {
                            return nilai;
                          } else {
                            return item;
                          }
                        }).toList();
                        filteredPenilaianAkhir = List.from(demoPenilaianAkhir);
                      });

                      // Perbarui data yang ditampilkan setelah menyimpan ke Firestore
                      await getDataFromFirebase();

                      // Hitung dan simpan nilai akhir
                      await _calculateAndSaveNilaiAkhir(nilai);

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error updating data:$e');
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, right: 20.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
              )
            ],
          );
        });
  }

//== Nama Pengoreksi
  Future<String?> getNamaAsisten() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      // Kueri Firestore untuk mendapatkan data mahasiswa
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('akun_mahasiswa')
          .doc(uid)
          .get();
      if (snapshot.exists) {
        // Jika dokumen ditemukan, ambil nilai dari field 'nama'
        String? namaAsisten = snapshot.data()?['nama'];
        return namaAsisten;
      }
    }
    return null;
  }

  Future<void> _calculateAndSaveNilaiAkhir(PenilaianAkhir nilai) async {
    // Perhitungan nilai akhir
    double nilaiAkhir = ((nilai.pretest * 0.15) +
            (nilai.modul1 * 0.05) +
            (nilai.modul2 * 0.05) +
            (nilai.modul3 * 0.05) +
            (nilai.modul4 * 0.05) +
            (nilai.modul5 * 0.05) +
            (nilai.project * 0.3) +
            (nilai.resmi * 0.3))
        .toDouble();

    // Inisialisasi variabel huruf dan status
    String huruf;
    String status;

    // Penentuan huruf dan status berdasarkan nilai akhir
    if (nilaiAkhir >= 80) {
      huruf = 'A';
      status = 'Lulus';
    } else if (nilaiAkhir >= 70) {
      huruf = 'B';
      status = 'Lulus';
    } else if (nilaiAkhir >= 60) {
      huruf = 'C';
      status = 'Lulus';
    } else if (nilaiAkhir >= 40) {
      huruf = 'D';
      status = 'Tidak Lulus';
    } else {
      huruf = 'E';
      status = 'Tidak Lulus';
    }

    // Update nilai huruf dan status pada objek nilai
    nilai.huruf = huruf;
    nilai.status = status;
    nilai.akhir = nilaiAkhir;

    // Simpan nilai akhir ke Firestore
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('nilaiAkhir')
              .where('nim', isEqualTo: nilai.nim)
              .where('kodeKelas', isEqualTo: widget.kodeKelas)
              .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('nilaiAkhir').add({
          'nim': nilai.nim,
          'kodeKelas': widget.kodeKelas,
          'modul1': nilai.modul1,
          'modul2': nilai.modul2,
          'modul3': nilai.modul3,
          'modul4': nilai.modul4,
          'modul5': nilai.modul5,
          'pretest': nilai.pretest,
          'projectAkhir': nilai.project,
          'laporanResmi': nilai.resmi,
          'keterangan': nilai.status,
          'nilaiHuruf': nilai.huruf,
          'nilaiAkhir': nilai.akhir,
        });
      } else {
        await querySnapshot.docs[0].reference.update({
          'modul1': nilai.modul1,
          'modul2': nilai.modul2,
          'modul3': nilai.modul3,
          'modul4': nilai.modul4,
          'modul5': nilai.modul5,
          'pretest': nilai.pretest,
          'projectAkhir': nilai.project,
          'laporanResmi': nilai.resmi,
          'keterangan': nilai.status,
          'nilaiHuruf': nilai.huruf,
          'nilaiAkhir': nilai.akhir,
        });
      }

      setState(() {
        demoPenilaianAkhir = demoPenilaianAkhir.map((item) {
          if (item.nim == nilai.nim) {
            return nilai;
          } else {
            return item;
          }
        }).toList();
        filteredPenilaianAkhir = List.from(demoPenilaianAkhir);
      });

      // Perbarui data yang ditampilkan setelah menyimpan ke Firestore
      await getDataFromFirebase();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating data:$e');
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
                    'Penilaian Praktikum',
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
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE3E8EF),
          ),
          width:
              MediaQuery.of(context).size.width, // Menambahkan pembatasan lebar
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 45.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 20.0, color: Colors.white)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 25.0, bottom: 20.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, bottom: 30.0, left: 880.0),
                            child: Row(
                              children: [
                                //== Text ==
                                const Text(
                                  'Search :',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Container(
                                    width: 260.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.grey),
                                      iconSize: 24,
                                      elevation: 16,

                                      value: selectedKeterangan,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedKeterangan = newValue!;
                                          getDataFromFirebase();
                                        });
                                      },
                                      underline:
                                          Container(), // Menjadikan garis bawah kosong
                                      items: <String>[
                                        'Tampilkan Semua',
                                        'Lulus',
                                        'Tidak Lulus'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text(value),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.075, color: Colors.grey),
                                borderRadius: BorderRadius.circular(7.0)),
                            child: SingleChildScrollView(
                              controller: _controller,
                              scrollDirection: Axis.horizontal,
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('nilaiAkhir')
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  return DataTable(
                                    columnSpacing: 10,
                                    columns: const [
                                      DataColumn(
                                          label: Text('NIM',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Nama',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Pre-Test',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Modul 1',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Modul 2',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Modul 3',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Modul 4',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Modul 5',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Modul 6',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Modul 7',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Modul 8',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Project Akhir',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Laporan Resmi',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Nilai Akhir',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Nilai Huruf',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Aksi',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ],
                                    rows: snapshot.data!.docs
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      DocumentSnapshot document = entry.value;
                                      Map<String, dynamic> data = document
                                          .data() as Map<String, dynamic>;
                                      return DataRow(
                                        color: MaterialStateColor.resolveWith(
                                            (states) => getRowColor(index)),
                                        cells: [
                                          DataCell(SizedBox(
                                              width: 150.0,
                                              child: Text(data['nim'] != null
                                                  ? data['nim'].toString()
                                                  : ''))),
                                          DataCell(SizedBox(
                                              width: 200.0,
                                              child: Text(data['nama'] != null
                                                  ? data['nama'].toString()
                                                  : ''))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['pretest'] != null
                                                      ? data['pretest']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['modul1'] != null
                                                      ? data['modul1']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['modul2'] != null
                                                      ? data['modul2']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['modul3'] != null
                                                      ? data['modul3']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['modul4'] != null
                                                      ? data['modul4']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['modul5'] != null
                                                      ? data['modul5']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['modul6'] != null
                                                      ? data['modul6']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['modul7'] != null
                                                      ? data['modul7']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['modul8'] != null
                                                      ? data['modul8']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['projectAkhir'] != null
                                                      ? data['projectAkhir']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['laporanResmi'] != null
                                                      ? data['laporanResmi']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 100.0,
                                              child: Text(getLimitedText(
                                                  data['nilaiAkhir'] != null
                                                      ? data['nilaiAkhir']
                                                          .toString()
                                                      : '',
                                                  5)))),
                                          DataCell(SizedBox(
                                              width: 80.0,
                                              child: Text(getLimitedText(
                                                  data['nilaiHuruf'] != null
                                                      ? data['nilaiHuruf']
                                                          .toString()
                                                      : '',
                                                  1)))),
                                          DataCell(SizedBox(
                                            child: IconButton(
                                              onPressed: () {
                                                // Inisialisasi objek PenilaianAkhir dengan nilai-nilai awal yang sesuai
                                                PenilaianAkhir nilai =
                                                    PenilaianAkhir(
                                                  // Masukkan nilai-nilai awal sesuai kebutuhan
                                                  pretest: 0.0,
                                                  modul1: 0.0,
                                                  modul2: 0.0,
                                                  modul3: 0.0,
                                                  modul4: 0.0,
                                                  modul5: 0.0,
                                                  project: 0.0,
                                                  resmi: 0.0, nim: 0, nama: '',
                                                  kode: '', status: '',
                                                  huruf: '',
                                                  // Tambahkan nilai-nilai lainnya sesuai kebutuhan
                                                );
                                                // Panggil fungsi editNilai dengan objek nilai sebagai argumen
                                                editNilai(nilai);
                                              },
                                              icon: const Icon(Icons.add_box,
                                                  color: Colors.grey),
                                            ),
                                          ))
                                        ],
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 359.0,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 35.0,
            height: 35.0,
            child: FloatingActionButton(
              onPressed: () {
                _controller.animateTo(
                  _controller.offset - 200,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
          const SizedBox(width: 16), // Spacer between buttons
          SizedBox(
            width: 35.0,
            height: 35.0,
            child: FloatingActionButton(
              onPressed: () {
                _controller.animateTo(
                  _controller.offset + 200,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

class PenilaianAkhir {
  String kode;
  int nim;
  String nama;
  double pretest;
  double modul1;
  double modul2;
  double modul3;
  double modul4;
  double modul5;
  double modul6;
  double modul7;
  double modul8;
  double project;
  double resmi;
  double akhir;
  String status;
  String huruf;

  PenilaianAkhir({
    required this.nim,
    required this.nama,
    required this.kode,
    this.pretest = 0.0,
    this.modul1 = 0.0,
    this.modul2 = 0.0,
    this.modul3 = 0.0,
    this.modul4 = 0.0,
    this.modul5 = 0.0,
    this.modul6 = 0.0,
    this.modul7 = 0.0,
    this.modul8 = 0.0,
    this.project = 0.0,
    this.resmi = 0.0,
    this.akhir = 0.0,
    required this.status,
    required this.huruf,
  });
}
