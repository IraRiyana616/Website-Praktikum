// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TambahAksesAbsensi extends StatefulWidget {
  final String idkelas;
  final String mataKuliah;
  final String kode;

  const TambahAksesAbsensi({
    Key? key,
    required this.idkelas,
    required this.mataKuliah,
    required this.kode,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TambahAksesAbsensiState createState() => _TambahAksesAbsensiState();
}

class _TambahAksesAbsensiState extends State<TambahAksesAbsensi> {
  //== Fungsi untuk TextEditingController ==//
  final TextEditingController waktuAksesController = TextEditingController();
  final TextEditingController waktuTutupAksesController =
      TextEditingController();
//== Fungsi untuk dropdownButton ==//
  String? selectedidModul;

//== Fungsi untuk menyimpan data ==//
  void saveData(BuildContext context) async {
    String akses = waktuAksesController.text.trim();
    String tutup = waktuTutupAksesController.text.trim();
    String? idModul = selectedidModul;
//== Fungsi untuk mengecheck data harus diisi==//
    if (akses.isEmpty || tutup.isEmpty || idModul == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua data harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      DateFormat dateFormat = DateFormat('dd MMMM yyyy hh:mm a');
      DateTime waktuAkses = dateFormat.parse(akses);
      DateTime waktuTutupAkses = dateFormat.parse(tutup);
//== Fungsi untuk mengecheck waktu akses dan tutup akses tidak boleh sama ==//
      if (waktuAkses.isAtSameMomentAs(waktuTutupAkses)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu akses dan waktu tutup akses tidak boleh sama'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
//== Fungsi untuk mengecheck waktu tutup akses tidak boleh kurang dari waktu akses ==//
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

      QuerySnapshot idModulQuerySnapshot = await FirebaseFirestore.instance
          .collection('aksesAbsen')
          .where('idKelas', isEqualTo: widget.idkelas)
          .where('idModul', isEqualTo: idModul)
          .get();
//== Fungsi untuk mengecheck idModul sudah ada dalam database ==//
      if (idModulQuerySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('idModul sudah ada dalam database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
//== Fungsi untuk menambahkan data ke dalam Firestore 'aksesAbsen' ==//
      await FirebaseFirestore.instance.collection('aksesAbsen').add({
        'idKelas': widget.idkelas,
        'idModul': idModul,
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
      setState(() {
        selectedidModul = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
        ),
      );
    }
  }

//== Fungsi untuk memilih tanggal ==//
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

//== Fungsi untuk memilih waktu ==//
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
          DateFormat('dd MMMM yyyy hh:mm a').format(selectedDateTime);

      setState(() {
        controller.text = formattedDateTime;
      });
    }
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
                  width: MediaQuery.of(context).size.width > 580.0
                      ? 580.0
                      : MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height > 500.0
                      ? 530.0
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
                            height: 400.0,
                            width: 525.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 18.0),
                                  child: Text(
                                    "id Modul",
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
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('silabusMatakuliah')
                                          .where('idKelas',
                                              isEqualTo: widget.idkelas)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        }

                                        List<DropdownMenuItem<String>>
                                            modulItems =
                                            snapshot.data!.docs.map(
                                                (DocumentSnapshot document) {
                                          String idModul = document['idModul'];
                                          return DropdownMenuItem<String>(
                                            value: idModul,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 15.0,
                                              ),
                                              child: Text(
                                                idModul,
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList();

                                        return Container(
                                          height: 47.0,
                                          width: 360.0,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade700,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: DropdownButton(
                                            value: selectedidModul,
                                            hint: const Text(
                                              '   Pilih id Modul',
                                              style: TextStyle(
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            items: modulItems,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedidModul = newValue;
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
