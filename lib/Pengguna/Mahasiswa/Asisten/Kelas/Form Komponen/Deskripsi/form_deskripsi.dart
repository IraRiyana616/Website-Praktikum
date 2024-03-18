import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../Laporan/form_laporan.dart';
import '../Tugas/form_tugas.dart';

class FormDeskripsiKelas extends StatefulWidget {
  const FormDeskripsiKelas({super.key});

  @override
  State<FormDeskripsiKelas> createState() => _FormDeskripsiKelasState();
}

class _FormDeskripsiKelasState extends State<FormDeskripsiKelas> {
  //Kode Kelas dan Deskrispi Kelas
  final TextEditingController _kodeKelasController = TextEditingController();
  final TextEditingController _deskripsiKelasController =
      TextEditingController();
  //Jadwal Praktikum
  //Peralatan Belajar
  final TextEditingController _ramController = TextEditingController();
  final TextEditingController _sistemOperasiController =
      TextEditingController();
  final TextEditingController _presesorController = TextEditingController();

  //Jumlah kata maksimum yang diizinkan pada Deskripsi Kelas
  int _remainingWords = 500;
  void updateRemainingWords(String text) {
    //Menghitung sisa kata dan memperbaharui state
    int currentWordCount = text.split('').length;
    int remaining = 500 - currentWordCount;

    setState(() {
      _remainingWords = remaining;
    });
    //Memeriksa apakah sisa kaa sudah mencapai 0
    if (_remainingWords <= 0) {
      //Menonaktifkan pengeditan jika sisa kata habis
      _deskripsiKelasController.text =
          _deskripsiKelasController.text.substring(0, 500);
      _deskripsiKelasController.selection = TextSelection.fromPosition(
          TextPosition(offset: _deskripsiKelasController.text.length));
    }
  }

  /// Menghubungkan ke saveSilabus Screen pada Firebase
  void _saveDeskripsi() async {
    //Mendapatkan instance Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    //Mendapatkan reference untuk collection 'kelas_praktikum
    CollectionReference silabusCollection =
        firestore.collection('deskripsiKelas');

    //Memeriksa apakah semua textfield telah diisi
    if (_kodeKelasController.text.isEmpty ||
        _deskripsiKelasController.text.isEmpty ||
        _ramController.text.isEmpty ||
        _sistemOperasiController.text.isEmpty ||
        _presesorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap isi semua kolom'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    //Mengecheck apakah kode_asisten terdapat dalam Firestore 'token_asisten'
    QuerySnapshot kodeAsistenSnapshot = await firestore
        .collection('tokenAsisten')
        .where('kodeKelas', isEqualTo: _kodeKelasController.text)
        .get();

    // Jika kode_asisten tidak ditemukan
    if (kodeAsistenSnapshot.docs.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data tidak terdapat pada database'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    //Mengambil data terakhir di collection untuk mendapatkan nomor urut
    QuerySnapshot querySnapshot = await silabusCollection.get();
    int documentCount = querySnapshot.docs.length;

    //Membuat nomor urut berikutnya
    int nextDocumentId = documentCount + 1;

    //Menyimpan kelas praktikum ke Firestore dengan document_id nomor urut
    await silabusCollection.doc(nextDocumentId.toString()).set({
      //Kode Kelas dan Deskripsi Kelas
      'kodeKelas': _kodeKelasController.text,
      'deskripsi_kelas': _deskripsiKelasController.text,

      //Peralatan Belajar
      'ram': _ramController.text,
      'sistemOperasi': _sistemOperasiController.text,
      'prosesor': _presesorController.text,
    });

    //Tampilkan Pesan Sukses
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2)));

    //Clear TextField
    //Kode Kelas dan Deskripsi Kelas
    _kodeKelasController.clear();
    _deskripsiKelasController.clear();

    //Peralatan belajar
    _ramController.clear();
    _sistemOperasiController.clear();
    _presesorController.clear();
  }

  ///
  ///
  ///
  ///
  ///
  ///Fungsi untuk database SilabusPraktikum
  final TextEditingController _kodeAsistenController = TextEditingController();
  final TextEditingController _judulMateriController = TextEditingController();
  final TextEditingController _waktuPraktikumController =
      TextEditingController();
  String _fileName = "";

  void _saveSilabus() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference modulCollection =
        firestore.collection('silabusPraktikum');

    String kodeKelas = _kodeAsistenController.text;
    String judulMateri = _judulMateriController.text;
    String waktuPraktikum = _waktuPraktikumController.text;
    String modulPraktikum = _fileName;

    if (kodeKelas.isEmpty ||
        judulMateri.isEmpty ||
        waktuPraktikum.isEmpty ||
        modulPraktikum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap lengkapi semua data'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    QuerySnapshot kodeKelasSnapshot = await firestore
        .collection('tokenAsisten')
        .where('kodeKelas', isEqualTo: kodeKelas)
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
        .where('kodeKelas', isEqualTo: kodeKelas)
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
      'kodeKelas': kodeKelas,
      'judulMateri': judulMateri,
      'waktuPraktikum': waktuPraktikum,
      'modulPraktikum': modulPraktikum,
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data berhasil disimpan'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));

    _kodeAsistenController.clear();
    _judulMateriController.clear();
    _waktuPraktikumController.clear();
    setState(() {
      _fileName = '';
    });
  }

  void _uploadFile() async {
    // Upload file to Firebase Storage
    String kodeKelas = _kodeAsistenController.text;

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$kodeKelas/${file.name}');

      try {
        // Upload file
        await ref.putData(file.bytes!);

        // Get download URL
        // String downloadURL = await ref.getDownloadURL();

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
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    "Kelas Praktikum",
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 800.0,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, color: Color(0xFF031F31))),
                const SizedBox(width: 10.0),
                Text('Log out',
                    style: GoogleFonts.quicksand(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF031F31))),
                const SizedBox(
                  width: 50.0,
                ),
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

                            //Tugas
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 50.0, top: 38.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FormPengumpulanTugas()));
                                },
                                child: Text(
                                  'Tugas',
                                  style: GoogleFonts.quicksand(fontSize: 16.0),
                                ),
                              ),
                            ),
                            //Laporan
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 50.0, top: 38.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FormPengempulanLaporan()));
                                },
                                child: Text(
                                  'Laporan',
                                  style: GoogleFonts.quicksand(fontSize: 16.0),
                                ),
                              ),
                            )
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
                            Padding(
                              padding: const EdgeInsets.only(left: 95.0),
                              child: SizedBox(
                                // height: 200.0,
                                width: 826.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Komponen Kode Kelas
                                    Text(
                                      'Kode Kelas',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    //TextField Kode kelas
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width: 600.0,
                                        child: TextField(
                                          controller: _kodeKelasController,
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Kode Kelas',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    //Komponen Deskripsi Kelas
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30.0),
                                      child: Text(
                                        'Deskripsi Kelas',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    //TextField Deskripsi Kelas
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
                            Padding(
                              padding: const EdgeInsets.only(right: 95.0),
                              child: SizedBox(
                                width: 350.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Peralatan Belajar
                                    Text(
                                      'Peralatan Belajar',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'Spesifikasi minimal perangkat',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 15.0),
                                      ),
                                    ),
                                    //RAM
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: 30.0,
                                              width: 30.0,
                                              child: Image.asset(
                                                  'assets/images/disk.png')),
                                          const SizedBox(width: 15.0),
                                          Text(
                                            'RAM',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 15.0,
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
                                          controller: _ramController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan RAM yang dibutuhkan',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    //Sistem Operasi
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
                                            'Sistem Operasi',
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
                                          controller: _sistemOperasiController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Sistem Operasi yang dibutuhkan',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              filled: true,
                                              fillColor: Colors.white),
                                        ),
                                      ),
                                    ),
                                    //Prosesor
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
                                            'Prosesor',
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
                                          controller: _presesorController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan Prosesor yang dibutuhkan',
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
                                              Text(
                                                'Kode Kelas',
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: SizedBox(
                                                  width: 600.0,
                                                  child: TextField(
                                                    controller:
                                                        _kodeAsistenController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Masukkan Kode Kelas',
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
                                              Text(
                                                'Jadwal Praktikum',
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: SizedBox(
                                                  width: 600.0,
                                                  child: TextField(
                                                    controller:
                                                        _waktuPraktikumController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Masukkan Jadwal Praktikum',
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
