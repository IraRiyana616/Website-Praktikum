import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FormEditTabelSilabusAdmin extends StatefulWidget {
  final String kodeKelas;
  final String judulMateri;
  const FormEditTabelSilabusAdmin(
      {super.key, required this.kodeKelas, required this.judulMateri});

  @override
  State<FormEditTabelSilabusAdmin> createState() =>
      _FormEditTabelSilabusAdminState();
}

class _FormEditTabelSilabusAdminState extends State<FormEditTabelSilabusAdmin> {
  //== Controller ==//
  TextEditingController judulMateriController = TextEditingController();
  TextEditingController waktuPraktikumController = TextEditingController();
  TextEditingController tanggalPraktikumController = TextEditingController();
  String _fileName = '';

  //== Fungsi untuk upload File ==//
  void _uploadFile() async {
    //== Upload file to Firebase Storage ==//
    String kodeKelas = widget.kodeKelas;

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$kodeKelas/${file.name}');

      try {
        //== Upload file ==//
        await ref.putData(file.bytes!);
        setState(() {
          _fileName = file.name;
        });
      } catch (e) {
        // Handle error during upload or getting download URL
        if (kDebugMode) {
          print("Error during upload or getting download URL: $e");
        }
        // Show error message or snackbar
      }
    } else {
      // Show error message or snackbar
    }
  }

  //== Memilih Waktu ==//
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
        _updateTimeText();
      });
    }
  }

  void _updateTimeText() {
    if (startTime != null && endTime != null) {
      final format = DateFormat('hh:mm a');
      final startTimeFormatted = format.format(DateTime(
        0,
        0,
        0,
        startTime!.hour,
        startTime!.minute,
      ));
      final endTimeFormatted = format.format(DateTime(
        0,
        0,
        0,
        endTime!.hour,
        endTime!.minute,
      ));

      waktuPraktikumController.text = '$startTimeFormatted - $endTimeFormatted';
    }
  }

  //== Memilih Tanggal ==//
  DateTime? selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    // Initialize the locale for Indonesian
    await initializeDateFormatting('id', null);

    // ignore: use_build_context_synchronously
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        tanggalPraktikumController.text =
            DateFormat('EEEE, dd MMMM yyyy', 'id').format(picked);
      });
    }
  }

  //== Menampilkan Data dari Database ==//
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('silabusPraktikum')
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .where('judulMateri', isEqualTo: widget.judulMateri)
          .get();
      if (userData.docs.isNotEmpty) {
        var data = userData.docs.first.data();
        setState(() {
          judulMateriController.text = data['judulMateri'] ?? '';
          tanggalPraktikumController.text = data['tanggalPraktikum'] ?? '';
          waktuPraktikumController.text = data['waktuPraktikum'] ?? '';
          _fileName = data['modulPraktikum'] ?? '';
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

  //== Fungsi untuk mengedit data ==//
  Future<void> _editData() async {
    try {
      //== Update data di Firestore ==//
      await FirebaseFirestore.instance
          .collection('silabusPraktikum')
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .where('judulMateri', isEqualTo: widget.judulMateri)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({
            'judulMateri': judulMateriController.text,
            'tanggalPraktikum': tanggalPraktikumController.text,
            'waktuPraktikum': waktuPraktikumController.text,
            'modulPraktikum': _fileName
          });
        }
      });

      //== Show Success Message ==//
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbaharui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating data: $e');
      }
      // Tampilkan Snackbar jika terjadi error saat update data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbaharui data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
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
            backgroundColor: const Color(0xFFF7F8FA),
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.judulMateri,
                      style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 400.0),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      'Admin',
                      style: GoogleFonts.quicksand(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 30.0)
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: const Color(0xFFE3E8EF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Center(
                child: Container(
                  width: 1100.0,
                  height: 460.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //== Judul ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, left: 50.0),
                        child: Text(
                          'Form Edit Silabus',
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold, fontSize: 22.0),
                        ),
                      ),
                      //== Divider ==//
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 15.0, left: 50.0, right: 50.0),
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                      //=== Row ===//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //== Column Judul Materi dan Upload File ==//
                          SizedBox(
                            width: 550.0,
                            height: 370.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //== Title ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 14.0, left: 50.0),
                                  child: Text(
                                    'Judul Materi',
                                    style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0),
                                  ),
                                ),
                                //== TextField Judul Materi ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 50.0),
                                  child: SizedBox(
                                    width: 450.0,
                                    child: TextField(
                                      controller: judulMateriController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          hintText: 'Masukkan Judul Materi',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          filled: true,
                                          fillColor: Colors.grey),
                                    ),
                                  ),
                                ),
                                //== Title ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 25.0, left: 50.0),
                                  child: Text(
                                    'Upload File',
                                    style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0),
                                  ),
                                ),
                                //== TextField Upload File ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 50.0),
                                  child: SizedBox(
                                    width: 450.0,
                                    child: Stack(
                                      children: [
                                        TextField(
                                          decoration: InputDecoration(
                                              hintText: 'Nama File Modul',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                          controller: TextEditingController(
                                              text: _fileName),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5.0, left: 325.0),
                                            child: SizedBox(
                                                height: 40.0,
                                                width: 120.0,
                                                child: ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    const Color(
                                                                        0xFF3CBEA9))),
                                                    onPressed: () async {
                                                      _uploadFile();
                                                      setState(() {});
                                                    },
                                                    child: Text(
                                                      'Upload File',
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                    ))))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          //== Row Tanggal Praktikum dan Waktu Praktikum ==//
                          SizedBox(
                            width: 550.0,
                            height: 370.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //== Title ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 14.0, left: 50.0),
                                  child: Text(
                                    'Tanggal Praktikum',
                                    style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0),
                                  ),
                                ),
                                //== TextField Tanggal Praktikum ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 50.0),
                                  child: SizedBox(
                                    width: 450.0,
                                    child: TextField(
                                      controller: tanggalPraktikumController,
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan Tanggal Praktikum',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        suffixIcon: IconButton(
                                          onPressed: () => _selectDate(context),
                                          icon:
                                              const Icon(Icons.calendar_month),
                                          tooltip: 'Kalender',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                //== Title ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 25.0, left: 50.0),
                                  child: Text(
                                    'Waktu Praktikum',
                                    style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0),
                                  ),
                                ),
                                //== TextField Waktu Praktikum ==//
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 50.0),
                                  child: SizedBox(
                                    width: 450.0,
                                    child: TextField(
                                      controller: waktuPraktikumController,
                                      decoration: InputDecoration(
                                          hintText: 'Masukkan Waktu Praktikum',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () => _selectTime(
                                                    context,
                                                    isStartTime: true),
                                                icon: const Icon(
                                                    Icons.access_time),
                                                tooltip: 'Waktu Awal',
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Text(
                                                    '-',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey),
                                                  )),
                                              IconButton(
                                                onPressed: () => _selectTime(
                                                    context,
                                                    isStartTime: false),
                                                icon: const Icon(
                                                    Icons.access_time),
                                                tooltip: 'Waktu Berakhir',
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                                //== ElevatedButton 'Edit Data'
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0, left: 350.0),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color(0xFF3CBEA9)),
                                          fixedSize:
                                              MaterialStateProperty.all<Size>(
                                                  const Size(150.0, 45.0))),
                                      onPressed: _editData,
                                      child: Text('Edit Data',
                                          style: GoogleFonts.quicksand(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold))),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
