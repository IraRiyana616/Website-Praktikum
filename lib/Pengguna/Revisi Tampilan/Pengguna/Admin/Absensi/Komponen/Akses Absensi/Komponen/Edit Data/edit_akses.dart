// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditAksesAbsen extends StatefulWidget {
  final String mataKuliah;
  final String idModul;
  final String idkelas;
  const EditAksesAbsen(
      {super.key,
      required this.mataKuliah,
      required this.idModul,
      required this.idkelas});

  @override
  State<EditAksesAbsen> createState() => _EditAksesAbsenState();
}

class _EditAksesAbsenState extends State<EditAksesAbsen> {
  //== Fungsi Controller ==//
  final TextEditingController idModulController = TextEditingController();
  final TextEditingController waktuAksesController = TextEditingController();
  final TextEditingController waktuTutupAksesController =
      TextEditingController();

  //== Fungsi Edit Data ==//
  void saveData(BuildContext context) async {
    String akses = waktuAksesController.text.trim();
    String tutup = waktuTutupAksesController.text.trim();

    try {
      DateFormat dateFormat = DateFormat('dd MMMM yyyy hh:mm a');
      DateTime waktuAkses = dateFormat.parse(akses);
      DateTime waktuTutupAkses = dateFormat.parse(tutup);

      if (waktuAkses.isAtSameMomentAs(waktuTutupAkses)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu akses dan waktu tutup akses tidak boleh sama'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (waktuTutupAkses.isBefore(waktuAkses)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Waktu tutup akses tidak boleh kurang dari waktu akses'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('aksesAbsen')
          .where('idKelas', isEqualTo: widget.idkelas)
          .where('idModul', isEqualTo: widget.idModul)
          .get();

      await FirebaseFirestore.instance
          .collection('aksesAbsen')
          .doc(querySnapshot.docs.first.id)
          .update({
        'waktuAkses': akses,
        'waktuTutupAkses': tutup,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      waktuAksesController.clear();
      waktuTutupAksesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
        ),
      );
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      await _selectTime(context, controller, picked);
    }
  }

  Future<void> _selectTime(BuildContext context,
      TextEditingController controller, DateTime selectedDate) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      String formattedDateTime =
          DateFormat('dd MMMM yyyy HH:mm a').format(selectedDateTime);

      setState(() {
        controller.text = formattedDateTime;
      });
    }
  }

  //== Fungsi Menampilkan data dari database ==//
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('aksesAbsen')
          .where('idModul', isEqualTo: widget.idModul)
          .where('idKelas', isEqualTo: widget.idkelas)
          .get();

      if (userData.docs.isNotEmpty) {
        var data = userData.docs.first.data();
        if (mounted) {
          setState(() {
            waktuAksesController.text = data['waktuAkses'] ?? '';
            waktuTutupAksesController.text = data['waktuTutupAkses'] ?? '';
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat mengambil data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
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
                const SizedBox(width: 10.0),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30.0),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width > 550.0
                      ? 550.0
                      : MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height > 400.0
                      ? 430.0
                      : MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 70.0),
                        child: Text(
                          "Akses Absensi Praktikum",
                          style: GoogleFonts.quicksand(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      const Padding(
                        padding: EdgeInsets.only(left: 70.0, right: 70.0),
                        child: Divider(
                          thickness: 1.5,
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 300.0,
                            width: 525.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 18.0),
                                  child: Text(
                                    "Akses Absensi",
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 70.0,
                                    right: 30.0,
                                  ),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            300.0
                                        ? 430.0
                                        : MediaQuery.of(context).size.width,
                                    child: TextField(
                                      controller: waktuAksesController,
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan Akses Absensi',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            _selectDate(
                                                context, waktuAksesController);
                                          },
                                          icon: const Icon(Icons.access_time),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25.0),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 70.0,
                                  ),
                                  child: Text(
                                    "Tutup Akses Absensi",
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 70.0,
                                    right: 30.0,
                                  ),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            300.0
                                        ? 430.0
                                        : MediaQuery.of(context).size.width,
                                    child: TextField(
                                      readOnly: true,
                                      controller: waktuTutupAksesController,
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan Waktu Tutup Akses',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            _selectDate(context,
                                                waktuTutupAksesController);
                                          },
                                          icon: const Icon(Icons.access_time),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 350.0,
                                    top: 27.0,
                                  ),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height >
                                            45.0
                                        ? 45.0
                                        : MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width >
                                            100.0
                                        ? 140
                                        : MediaQuery.of(context).size.width,
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
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 1000.0),
            ],
          ),
        ),
      ),
    );
  }
}
