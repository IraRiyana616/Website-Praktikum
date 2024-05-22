import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormEvaluasiKegiatan extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const FormEvaluasiKegiatan(
      {Key? key, required this.kodeKelas, required this.mataKuliah})
      : super(key: key);

  @override
  State<FormEvaluasiKegiatan> createState() => _FormEvaluasiKegiatanState();
}

class _FormEvaluasiKegiatanState extends State<FormEvaluasiKegiatan> {
//== Controller ==//
  final TextEditingController _awalPraktikumController =
      TextEditingController();
  final TextEditingController _akhirPraktikumController =
      TextEditingController();
  final TextEditingController _evaluasiPraktikumController =
      TextEditingController();
  late String _fileName = '';

  bool _isDataSaved = false;

  //=== Fungsi dari Upload File ===//
  Future<void> _uploadFile() async {
    try {
      // Upload file to Firebase Storage
      String kodeKelas = widget.kodeKelas;

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;

        // Menggunakan Firebase Storage reference untuk menentukan folder dan nama file
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('Data Evaluasi/$kodeKelas/${file.name}');

        // Upload file
        await ref.putData(file.bytes!);

        setState(() {
          _fileName = file.name;
        });
      } else {
        // Menampilkan pesan kesalahan atau snackbar jika pengguna tidak memilih file
        // Show error message or snackbar
      }
    } catch (e) {
      // Menangani kesalahan selama proses unggah atau mendapatkan URL unduhan
      if (kDebugMode) {
        print("Error during upload or getting download URL: $e");
      }
      // Menampilkan pesan kesalahan atau snackbar
      // Show error message or snackbar
    }
  }

  //== Memilih Tanggal ==//
  DateTime? selectedAwalDate;
  DateTime? selectedAkhirDate;

// Fungsi untuk memilih tanggal awal praktikum
  Future<void> _selectAwalDate(BuildContext context) async {
    // Initialize the locale for Indonesian
    await initializeDateFormatting('id', null);

    // ignore: use_build_context_synchronously
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedAwalDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedAwalDate) {
      setState(() {
        selectedAwalDate = picked;
        _awalPraktikumController.text =
            DateFormat('EEEE, dd MMMM yyyy', 'id').format(picked);
      });
    }
  }

// Fungsi untuk memilih tanggal akhir praktikum
  Future<void> _selectAkhirDate(BuildContext context) async {
    // Initialize the locale for Indonesian
    await initializeDateFormatting('id', null);

    // ignore: use_build_context_synchronously
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedAkhirDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedAkhirDate) {
      setState(() {
        selectedAkhirDate = picked;
        _akhirPraktikumController.text =
            DateFormat('EEEE, dd MMMM yyyy', 'id').format(picked);
      });
    }
  }

  //=== Fungsi Simpan Data ke Firestore ===//
  Future<void> _simpanData() async {
    if (_isDataSaved) {
      // Jika data sudah disimpan, tampilkan snackbar bahwa data telah terdapat pada database
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data telah terdapat pada database'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Mendapatkan data dari inputan pengguna
      String kodeKelas = widget.kodeKelas;
      String awalPraktikum = _awalPraktikumController.text;
      String akhirPraktikum = _akhirPraktikumController.text;
      String evaluasiPraktikum = _evaluasiPraktikumController.text;

      // Cek apakah data sudah ada sebelumnya
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dataEvaluasi')
          .where('kodeKelas', isEqualTo: kodeKelas)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Jika data sudah ada, tampilkan snackbar bahwa data telah terdapat pada database
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data telah terdapat pada database'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isDataSaved = true;
        });
        return;
      }

      // Menyimpan data ke Firestore
      await FirebaseFirestore.instance.collection('dataEvaluasi').add({
        'kodeKelas': kodeKelas,
        'awalPraktikum': awalPraktikum,
        'akhirPraktikum': akhirPraktikum,
        'evaluasiPraktikum': evaluasiPraktikum,
        'fileDokumentasi': _fileName,
      });

      // Reset text field setelah penyimpanan berhasil
      _awalPraktikumController.clear();
      _akhirPraktikumController.clear();
      _evaluasiPraktikumController.clear();
      _fileName = '';

      // Tampilkan snackbar jika penyimpanan berhasil
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isDataSaved = true;
      });
    } catch (e) {
      // Menangani kesalahan selama proses penyimpanan data
      if (kDebugMode) {
        print("Error saving data to Firestore: $e");
      }
      // Menampilkan pesan kesalahan atau snackbar
      // Show error message or snackbar
    }
  }

  //== Nama Akun ==//
  //== Nama Akun ==//
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  String _namaDosen = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

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
                      color: Colors.black,
                    ),
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
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  width: 1000.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 25.0),
                      //== Judul pada Form ==//
                      Padding(
                        padding: const EdgeInsets.only(left: 75.0, top: 35.0),
                        child: Text(
                          'Form Evaluasi Kegiatan Praktikum',
                          style: GoogleFonts.quicksand(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 75.0),
                        child: Text(
                          'Masukkan data hasil evaluasi kegiatan praktikum yang telah berlangsung',
                          style: GoogleFonts.quicksand(fontSize: 15.0),
                        ),
                      ),
                      //== Komponen Form Evaluasi ==//
                      Padding(
                        padding: const EdgeInsets.only(left: 75.0, top: 50.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //== Judul Praktikum di Mulai ==//
                            Text(
                              'Praktikum Mulai',
                              style: GoogleFonts.quicksand(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //== Judul Praktikum Selesai ==//
                            Padding(
                              padding: const EdgeInsets.only(left: 400.0),
                              child: Text(
                                'Praktikum Selesai',
                                style: GoogleFonts.quicksand(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //== TextField Komponen Praktikum Mulai dan Berakhir ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 75),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //== Mulai Praktikum =//
                            SizedBox(
                              width: 300.0,
                              child: TextField(
                                controller: _awalPraktikumController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Mulai Praktikum',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () async {
                                      await _selectAwalDate(context);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            //== Praktikum Selesai ==//
                            Padding(
                              padding: const EdgeInsets.only(left: 230.0),
                              child: SizedBox(
                                width: 300.0,
                                child: TextField(
                                  controller: _akhirPraktikumController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'Praktikum Selesai',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () async {
                                        await _selectAkhirDate(context);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //=== Form Upload Foto Kegiatan Praktikum ===//
                      Padding(
                        padding: const EdgeInsets.only(left: 75.0, top: 30.0),
                        child: Text(
                          'Dokumentasi Kegiatan Praktikum',
                          style: GoogleFonts.quicksand(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 75.0),
                        child: SizedBox(
                          width: 835.0,
                          child: Stack(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Nama File Modul',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                controller:
                                    TextEditingController(text: _fileName),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0, left: 710.0),
                                child: SizedBox(
                                  height: 40.0,
                                  width: 120.0,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        const Color(0xFF3CBEA9),
                                      ),
                                    ),
                                    onPressed: _uploadFile,
                                    child: Text(
                                      'Upload File',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 75.0),
                          child: Text(
                            'Catatan : Dokumentasi dalam bentuk PDF',
                            style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                                color: Colors.red),
                          )),
                      //== Evaluasi Kegiatan Praktikum ==//
                      Padding(
                        padding: const EdgeInsets.only(left: 75.0, top: 30.0),
                        child: Text(
                          'Ringkasan Evaluasi Kegiatan Praktikum',
                          style: GoogleFonts.quicksand(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 75.0),
                        child: SizedBox(
                          width: 835.0,
                          child: TextField(
                            controller: _evaluasiPraktikumController,
                            maxLines: 7,
                            decoration: InputDecoration(
                              hintText:
                                  'Masukkan Ringkasan Evaluasi Kegiatan Praktikum',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 40.0,
                                horizontal: 15.0,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 780.0, top: 20.0),
                        child: SizedBox(
                          width: 125.0,
                          height: 40.0,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF3CBEA9),
                              ),
                            ),
                            onPressed: _simpanData,
                            child: Text(
                              'Simpan Data',
                              style: GoogleFonts.quicksand(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
