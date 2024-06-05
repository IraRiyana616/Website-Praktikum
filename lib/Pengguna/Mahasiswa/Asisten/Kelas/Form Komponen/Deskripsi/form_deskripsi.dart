import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../../../../../Revisi Tampilan/Pengguna/Mahasiswa/Asisten/Dashboard/Navigasi/dashboardnav_asisten.dart';
import '../Pengumpulan/Latihan/form_latihan.dart';

class FormDeskripsiKelas extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const FormDeskripsiKelas(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<FormDeskripsiKelas> createState() => _FormDeskripsiKelasState();
}

class _FormDeskripsiKelasState extends State<FormDeskripsiKelas> {
  //== Deskrispi Kelas ==//
  final TextEditingController _deskripsiKelasController =
      TextEditingController();

  //== Peralatan Belajar ==//
  final TextEditingController _softwareController = TextEditingController();
  final TextEditingController _hardwareController = TextEditingController();

  //== Jumlah kata maksimum yang diizinkan pada Deskripsi Kelas ==//
  int _remainingWords = 500;
  void updateRemainingWords(String text) {
    //== Menghitung sisa kata dan memperbaharui state ==//
    int currentWordCount = text.split('').length;
    int remaining = 500 - currentWordCount;

    setState(() {
      _remainingWords = remaining;
    });
    //== Memeriksa apakah sisa kaa sudah mencapai 0 ==//
    if (_remainingWords <= 0) {
      //== Menonaktifkan pengeditan jika sisa kata habis ==//
      _deskripsiKelasController.text =
          _deskripsiKelasController.text.substring(0, 500);
      _deskripsiKelasController.selection = TextSelection.fromPosition(
          TextPosition(offset: _deskripsiKelasController.text.length));
    }
  }

  //== Menghubungkan ke saveSilabus Screen pada Firebase ==//
  void _saveDeskripsi() async {
    //== Mendapatkan instance Firestore ==//
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    //== Mendapatkan reference untuk collection 'kelas_praktikum ==//
    CollectionReference silabusCollection =
        firestore.collection('deskripsiKelas');

    //== Memeriksa apakah semua textfield telah diisi ==//
    if (_deskripsiKelasController.text.isEmpty ||
        _softwareController.text.isEmpty ||
        _hardwareController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap isi semua kolom'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    //== Mengecheck apakah kode_asisten terdapat dalam Firestore 'token_asisten' ==//
    QuerySnapshot kodeAsistenSnapshot = await firestore
        .collection('dataAsisten')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    //== Jika kode_asisten tidak ditemukan ==//
    if (kodeAsistenSnapshot.docs.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data tidak terdapat pada database'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    //== Mengambil data terakhir di collection untuk mendapatkan nomor urut ==//
    QuerySnapshot querySnapshot = await silabusCollection.get();
    int documentCount = querySnapshot.docs.length;

    //== Membuat nomor urut berikutnya ==//
    int nextDocumentId = documentCount + 1;

    //== Menyimpan kelas praktikum ke Firestore dengan document_id nomor urut ==//
    await silabusCollection.doc(nextDocumentId.toString()).set({
      //== Kode Kelas dan Deskripsi Kelas ==//
      'kodeKelas': widget.kodeKelas,
      'mataKuliah': widget.mataKuliah,
      'deskripsi_kelas': _deskripsiKelasController.text,

      //== Peralatan Belajar ==//

      'perangkatLunak': _softwareController.text,
      'perangkatKeras': _hardwareController.text,
    });

    //== Tampilkan Pesan Sukses ==//
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2)));

    //== Clear TextField ==//
    //== Deskripsi Kelas ==//

    _deskripsiKelasController.clear();

    //== Peralatan belajar ==//

    _softwareController.clear();
    _hardwareController.clear();
  }

  //== SILABUS PRAKTIKUM ==//

  //== Fungsi untuk database SilabusPraktikum ==//
  final TextEditingController _judulMateriController = TextEditingController();
  final TextEditingController _waktuPraktikumController =
      TextEditingController();
  final TextEditingController _tanggalPraktikumController =
      TextEditingController();
  String _fileName = "";

  void _saveSilabus() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference modulCollection =
        firestore.collection('silabusPraktikum');

    String judulMateri = _judulMateriController.text;
    String tanggalPraktikum = _tanggalPraktikumController.text;
    String waktuPraktikum = _waktuPraktikumController.text;
    String modulPraktikum = _fileName;

    if (judulMateri.isEmpty || modulPraktikum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap lengkapi semua data'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    QuerySnapshot kodeKelasSnapshot = await firestore
        .collection('dataAsisten')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    if (kodeKelasSnapshot.docs.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Kode Kelas tidak terdapat pada database'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    QuerySnapshot existingDataSnapshot = await modulCollection
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .where('judulMateri', isEqualTo: judulMateri)
        .get();

    if (existingDataSnapshot.docs.isNotEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Judul Materi sudah ada untuk Kode Kelas ini'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    QuerySnapshot querySnapshot = await modulCollection.get();
    int documentCount = querySnapshot.docs.length;
    int nextDocumentId = documentCount + 1;

    await modulCollection.doc(nextDocumentId.toString()).set({
      'kodeKelas': widget.kodeKelas,
      'judulMateri': judulMateri,
      'modulPraktikum': modulPraktikum,
      'tanggalPraktikum': tanggalPraktikum,
      'waktuPraktikum': waktuPraktikum
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data berhasil disimpan'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));

    _judulMateriController.clear();
    setState(() {
      _fileName = '';
    });
  }

//== Fungsi Untuk Upload File ==//
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

  //== Nama Akun ==//
  User? _currentUser;
  String _namaMahasiswa = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Fungsi untuk mendapatkan pengguna yang sedang login dan mengambil data nama dari database
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _getCurrentUser() async {
    setState(() {
      _currentUser = _auth.currentUser;
    });
    if (_currentUser != null) {
      await _getNamaMahasiswa(_currentUser!.uid);
    }
  }

  // Fungsi untuk mengambil nama mahasiswa dari database
  Future<void> _getNamaMahasiswa(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('akun_mahasiswa').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _namaMahasiswa = doc.get('nama');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching nama mahasiswa: $e');
      }
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

      _waktuPraktikumController.text =
          '$startTimeFormatted - $endTimeFormatted';
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
        _tanggalPraktikumController.text =
            DateFormat('EEEE, dd MMMM yyyy', 'id').format(picked);
      });
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
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const DasboardAsistenNavigasi(),
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
                    widget.mataKuliah,
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 400.0,
                ),
                if (_currentUser != null) ...[
                  Text(
                    _namaMahasiswa.isNotEmpty
                        ? _namaMahasiswa
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
                              border:
                                  Border.all(width: 0.5, color: Colors.grey)),
                          height: 320.0,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/kelas.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 38.0, left: 95.0),
                              child: Text(
                                'Deskripsi Kelas',
                                style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            //== Pengumpulan ==//
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 50.0, top: 38.0),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FormPengumpulanLatihan(
                                                    kodeKelas: widget.kodeKelas,
                                                    mataKuliah:
                                                        widget.mataKuliah)));
                                  },
                                  child: Text(
                                    'Pengumpulan',
                                    style:
                                        GoogleFonts.quicksand(fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 45.0, right: 45.0),
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
//== Komponen Deskripsi Kelas ==//
                            Padding(
                              padding: const EdgeInsets.only(left: 95.0),
                              child: SizedBox(
                                width: 826.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== Deskripsi Kelas ==//
                                    Text(
                                      'Deskripsi Kelas',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    //== TextField Deskripsi Kelas ==//
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width: 600.0,
                                        height: 300.0,
                                        child: TextField(
                                          controller: _deskripsiKelasController,
                                          maxLines: 10,
                                          onChanged: (text) {
                                            updateRemainingWords(text);
                                          },
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Deskripsi Kelas',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 40.0,
                                                      horizontal: 15.0),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                        padding:
                                            const EdgeInsets.only(left: 470.0),
                                        child: Text(
                                            'Sisa Kata: $_remainingWords/500',
                                            style: const TextStyle(
                                                color: Colors.grey))),
                                    //== ElevatedButton 'SIMPAN DATA' ==//
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0.0, top: 10.0),
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    const Color(0xFF3CBEA9)),
                                            fixedSize:
                                                MaterialStateProperty.all<Size>(
                                              const Size(150.0, 45.0),
                                            ),
                                          ),
                                          onPressed: _saveDeskripsi,
                                          child: Text(
                                            'Simpan Data',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //== Komponen Peralatan Belajar ==//
                            Padding(
                              padding: const EdgeInsets.only(right: 95.0),
                              child: SizedBox(
                                width: 350.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //== Peralatan Belajar ==//
                                    Text(
                                      'Peralatan Belajar',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'Peralatan yang dibutuhkan :',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 15.0),
                                      ),
                                    ),

                                    //== Perangkat Lunak (Software) ==//
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: 40.0,
                                              width: 40.0,
                                              child: Image.asset(
                                                  'assets/images/os.png')),
                                          const SizedBox(width: 15.0),
                                          Text(
                                            'Perangkat Lunak',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width: 320.0,
                                        child: TextField(
                                          controller: _softwareController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Software yang dibutuhkan',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    //== Perangkat Keras (Hardware) ==//
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: 40.0,
                                              width: 40.0,
                                              child: Image.asset(
                                                  'assets/images/processor.png')),
                                          const SizedBox(width: 15.0),
                                          Text(
                                            'Perangkat Keras',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width: 320.0,
                                        child: TextField(
                                          controller: _hardwareController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Hardware yang dibutuhkan',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 40.0, left: 45.0, right: 45.0),
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 50.0),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Silabus',
                                style: GoogleFonts.quicksand(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Text(
                                  'Materi yang akan dipelajari',
                                  style: GoogleFonts.quicksand(fontSize: 18.0),
                                ),
                              ),
                              const SizedBox(height: 50.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 95.0),
                                        child: Container(
                                          color: Colors.white,
                                          width: 526.0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              //== Judul Materi ==//
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: Text(
                                                  'Judul Materi',
                                                  style: GoogleFonts.quicksand(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: SizedBox(
                                                  width: 600.0,
                                                  child: TextField(
                                                    controller:
                                                        _judulMateriController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Masukkan Judul Materi',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              //== Upload File ==//

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: Text(
                                                  'Upload Modul',
                                                  style: GoogleFonts.quicksand(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: SizedBox(
                                                  width: 600.0,
                                                  child: Stack(
                                                    children: [
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Nama File Modul',
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                        ),
                                                        controller:
                                                            TextEditingController(
                                                                text:
                                                                    _fileName),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5.0,
                                                                left: 400.0),
                                                        child: SizedBox(
                                                          height: 40.0,
                                                          width: 120.0,
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      const Color(
                                                                          0xFF3CBEA9)),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              _uploadFile();
                                                              setState(() {});
                                                            },
                                                            child: Text(
                                                              'Upload File',
                                                              style: GoogleFonts
                                                                  .quicksand(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 70.0),
                                        child: Container(
                                          color: Colors.white,
                                          width: 526.0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              //== Tanggal Praktikum ==//
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: Text(
                                                  'Tanggal Praktikum',
                                                  style: GoogleFonts.quicksand(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: SizedBox(
                                                  width: 600.0,
                                                  child: TextField(
                                                    readOnly: true,
                                                    controller:
                                                        _tanggalPraktikumController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            'Masukkan Tanggal Praktikum',
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        suffixIcon: IconButton(
                                                            onPressed: () =>
                                                                _selectDate(
                                                                    context),
                                                            icon: const Icon(Icons
                                                                .calendar_month))),
                                                  ),
                                                ),
                                              ),

                                              //== Waktu Praktikum ==//

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: Text(
                                                  'Waktu Praktikum',
                                                  style: GoogleFonts.quicksand(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: SizedBox(
                                                    width: 600.0,
                                                    child: TextField(
                                                        readOnly: true,
                                                        controller:
                                                            _waktuPraktikumController,
                                                        decoration:
                                                            InputDecoration(
                                                                hintText:
                                                                    'Masukkan Waktu Praktikum',
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0)),
                                                                filled: true,
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                suffixIcon: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed: () => _selectTime(
                                                                            context,
                                                                            isStartTime:
                                                                                true),
                                                                        icon: const Icon(
                                                                            Icons.access_time),
                                                                        tooltip:
                                                                            'Waktu Awal',
                                                                      ),
                                                                      const Padding(
                                                                          padding: EdgeInsets.all(
                                                                              10.0),
                                                                          child: Text(
                                                                              '-',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                                                      IconButton(
                                                                          onPressed: () => _selectTime(
                                                                              context,
                                                                              isStartTime:
                                                                                  false),
                                                                          icon: const Icon(Icons
                                                                              .access_time),
                                                                          tooltip:
                                                                              'Waktu Berakhir')
                                                                    ])))),
                                              ),
                                              //== ElevatedButton 'SIMPAN DATA' ==//
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 370.0, top: 30.0),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                const Color(
                                                                    0xFF3CBEA9)),
                                                    fixedSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                                const Size(
                                                                    150.0,
                                                                    45.0)),
                                                  ),
                                                  onPressed: _saveSilabus,
                                                  child: Text(
                                                    'Simpan Data',
                                                    style:
                                                        GoogleFonts.quicksand(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 50.0)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
