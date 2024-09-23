// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../Mahasiswa/Asisten/Absensi/Screen/absensi_ass.dart';
import '../../../Navigasi/dasboardnav_admin.dart';

class EditFormDataKelas extends StatefulWidget {
  final String matkul;
  const EditFormDataKelas({super.key, required this.matkul});

  @override
  State<EditFormDataKelas> createState() => _EditFormDataKelasState();
}

class _EditFormDataKelasState extends State<EditFormDataKelas> {
  //== Fungsi Controller ==//
  final TextEditingController _kodeKelasController = TextEditingController();
  final TextEditingController _mataKuliahController = TextEditingController();

  //== Fungsi untuk memanggil dropdownButton ==//
  String? selectedNamaDosen;
  String? selectedNamaDosen2;
  String? selectedNipDosen;
  String? selectedNipDosen2;

//== Fungsi Menampilkan data dari database ==//
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('dataMatakuliah')
          .where('matakuliah', isEqualTo: widget.matkul)
          .get();

      if (userData.docs.isNotEmpty) {
        var data = userData.docs.first.data();
        setState(() {
          _kodeKelasController.text = data['kodeMatakuliah'] ?? '';
          _mataKuliahController.text = data['matakuliah'] ?? '';
          selectedNamaDosen = data['namaDosen'] ?? '';
          selectedNamaDosen2 = data['namaDosen2'] ?? '';
          selectedNipDosen = data['nipDosen'] ?? '';
          selectedNipDosen2 = data['nipDosen2'] ?? '';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //== Fungsi untuk menyimpan data ==//
  void saveData(BuildContext context) async {
    String kodeMatakuliah = _kodeKelasController.text.trim();
    String namaMatakuliah = _mataKuliahController.text.trim();

    // Validasi jika ada kolom yang tidak diisi
    if (kodeMatakuliah.isEmpty ||
        namaMatakuliah.isEmpty ||
        selectedNamaDosen == null ||
        selectedNamaDosen2 == null ||
        selectedNipDosen == null ||
        selectedNipDosen2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data harap diisi semua'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Periksa apakah kodeMatakuliah sudah ada
      final querySnapshot = await FirebaseFirestore.instance
          .collection('dataMatakuliah')
          .where('kodeMatakuliah', isEqualTo: kodeMatakuliah)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode matakuliah tidak ditemukan di database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      //== Validasi apabila nama dan nip tidak sesuai ==//
      final dosen1 = await FirebaseFirestore.instance
          .collection('akun_dosen')
          .where('nama', isEqualTo: selectedNamaDosen)
          .where('nip', isEqualTo: selectedNipDosen)
          .get();

      final dosen2 = await FirebaseFirestore.instance
          .collection('akun_dosen')
          .where('nama', isEqualTo: selectedNamaDosen2)
          .where('nip', isEqualTo: selectedNipDosen2)
          .get();

      if (dosen1.docs.isEmpty || dosen2.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Data nama dan nip tidak sesuai'),
              backgroundColor: Colors.red),
        );
        return;
      }

      // Update data berdasarkan kodeMatakuliah
      await FirebaseFirestore.instance
          .collection('dataMatakuliah')
          .doc(querySnapshot.docs.first.id)
          .update({
        'kodeMatakuliah': kodeMatakuliah,
        'matakuliah': namaMatakuliah,
        'namaDosen': selectedNamaDosen,
        'namaDosen2': selectedNamaDosen2,
        'nipDosen': selectedNipDosen,
        'nipDosen2': selectedNipDosen2,
      });

      // Berhasil menyimpan data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const DashboardNavigasiAdmin(),
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
            ),
          ),
          backgroundColor: const Color(0xFFF7F8FA),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.matkul,
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
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
                const SizedBox(width: 10.0)
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: screenWidth > 2000.0 ? 1000.0 : screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30.0,
              ),
              Center(
                child: Container(
                  width: screenWidth > 1000.0 ? 1100.0 : screenWidth,
                  height: screenHeight > 400.0 ? 520.0 : screenHeight,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 40.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 70.0),
                        child: Text(
                          "Formulir Edit Matakuliah",
                          style: GoogleFonts.quicksand(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 70.0, right: 70.0),
                        child: Divider(
                          thickness: 1.5,
                        ),
                      ),
                      Row(
                        children: [
                          //== Kode Matakuliah, Nama Matakuliah dan Nama Dosen Pengampu ==//
                          Column(
                            children: [
                              SizedBox(
                                height: 400.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        "Kode Matakuliah",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: TextField(
                                            readOnly: true,
                                            controller: _kodeKelasController,
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Masukkan Kode Matakuliah',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                filled: true,
                                                fillColor: Colors.grey),
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  4),
                                              UpperCaseTextFormatter()
                                            ]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "Nama Matakuliah",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: TextField(
                                          controller: _mataKuliahController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Nama Matakuliah',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "Nama Dosen Pengampu",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('akun_dosen')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const CircularProgressIndicator();
                                            }

                                            List<DropdownMenuItem<String>>
                                                modulItems = snapshot.data!.docs
                                                    .map((DocumentSnapshot
                                                        document) {
                                              String namaDosen =
                                                  document['nama'];
                                              return DropdownMenuItem<String>(
                                                value: namaDosen,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0),
                                                  child: Text(
                                                    namaDosen,
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                ),
                                              );
                                            }).toList();

                                            return Container(
                                              height: 47.0,
                                              width: 360.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade700),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: DropdownButton<String>(
                                                value: selectedNamaDosen,
                                                hint: const Text(
                                                  '   Pilih Nama Dosen Pengampu',
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                items: modulItems,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedNamaDosen =
                                                        newValue;
                                                    selectedNipDosen = snapshot
                                                        .data!.docs
                                                        .firstWhere((document) =>
                                                            document['nama'] ==
                                                            newValue)['nip'];
                                                  });
                                                },
                                                isExpanded: true,
                                                dropdownColor: Colors.white,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 14.0,
                                                ),
                                                underline: Container(),
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.grey,
                                                ),
                                                iconSize: 24,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          //== NIP Dosen Pengampu 1, Nama Dosen Pengampu 2 dan NIP Dosen Pengampu 2
                          Column(
                            children: [
                              SizedBox(
                                height: 400.0,
                                width: 525.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 18.0),
                                      child: Text(
                                        "NIP Dosen Pengampu 1",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: Container(
                                          height: 47.0,
                                          width: 360.0,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade700),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: TextField(
                                            controller: TextEditingController(
                                                text: selectedNipDosen),
                                            decoration: const InputDecoration(
                                              hintText: ' NIP Dosen Pengampu',
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.only(left: 15.0),
                                            ),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14.0,
                                            ),
                                            readOnly: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "Nama Dosen Pengampu 2",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('akun_dosen')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const CircularProgressIndicator();
                                            }

                                            List<DropdownMenuItem<String>>
                                                modulItems = snapshot.data!.docs
                                                    .map((DocumentSnapshot
                                                        document) {
                                              String namaDosen2 =
                                                  document['nama'];
                                              return DropdownMenuItem<String>(
                                                value: namaDosen2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0),
                                                  child: Text(
                                                    namaDosen2,
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                ),
                                              );
                                            }).toList();

                                            return Container(
                                              height: 47.0,
                                              width: 360.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade700),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: DropdownButton<String>(
                                                value: selectedNamaDosen2,
                                                hint: const Text(
                                                  '   Pilih Nama Dosen Pengampu',
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                items: modulItems,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedNamaDosen2 =
                                                        newValue;
                                                    selectedNipDosen2 = snapshot
                                                        .data!.docs
                                                        .firstWhere((document) =>
                                                            document['nama'] ==
                                                            newValue)['nip'];
                                                  });
                                                },
                                                isExpanded: true,
                                                dropdownColor: Colors.white,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 14.0,
                                                ),
                                                underline: Container(),
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.grey,
                                                ),
                                                iconSize: 24,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, top: 15.0),
                                      child: Text(
                                        "NIP Pengampu Dosen 2",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, right: 30.0),
                                      child: SizedBox(
                                        width: screenWidth > 300.0
                                            ? 430.0
                                            : screenWidth,
                                        child: Container(
                                          height: 47.0,
                                          width: 360.0,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade700),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: TextField(
                                            controller: TextEditingController(
                                                text: selectedNipDosen2),
                                            decoration: const InputDecoration(
                                              hintText: ' NIP Dosen Pengampu',
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.only(left: 15.0),
                                            ),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14.0,
                                            ),
                                            readOnly: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    //== ElevatedButton 'SIMPAN' ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 23.0, left: 350.0),
                                      child: SizedBox(
                                        height: screenHeight > 45.0
                                            ? 45.0
                                            : screenHeight,
                                        width: screenWidth > 100.0
                                            ? 140
                                            : screenWidth,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF3CBEA9),
                                            ),
                                            onPressed: () {
                                              saveData(context);
                                            },
                                            child: Text(
                                              'Simpan Data',
                                              style: GoogleFonts.quicksand(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
