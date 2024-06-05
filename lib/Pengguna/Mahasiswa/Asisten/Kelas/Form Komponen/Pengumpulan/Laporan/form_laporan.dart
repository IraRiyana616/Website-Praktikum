import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../Revisi Tampilan/Pengguna/Mahasiswa/Asisten/Dashboard/Navigasi/dashboardnav_asisten.dart';
import '../../Deskripsi/form_deskripsi.dart';
import '../Latihan/form_latihan.dart';
import '../Tugas/form_tugas.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FormPengumpulanLaporan extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const FormPengumpulanLaporan(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<FormPengumpulanLaporan> createState() => _FormPengumpulanLaporanState();
}

class _FormPengumpulanLaporanState extends State<FormPengumpulanLaporan> {
  final TextEditingController _deskripsiTugasController =
      TextEditingController();
  final TextEditingController _judulModulController = TextEditingController();
  final TextEditingController _bukaController = TextEditingController();
  final TextEditingController _tutupController = TextEditingController();

  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FormPengumpulanLatihan(
                    kodeKelas: widget.kodeKelas, mataKuliah: widget.mataKuliah),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FormPengumpulanTugas(
                    kodeKelas: widget.kodeKelas, mataKuliah: widget.mataKuliah),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FormPengumpulanLaporan(
                    kodeKelas: widget.kodeKelas, mataKuliah: widget.mataKuliah),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  //Jumlah kata maksimum yang diizinkan pada deskripsi kelas
  int _remainingWords = 1000;
  void updateRemainingWords(String text) {
    //Menghitung sisa kata dan memperbaharui state
    int currentWordCount = text.split('').length;
    int remaining = 1000 - currentWordCount;

    setState(() {
      _remainingWords = remaining;
    });
    //Memeriksa apakah sisa kata mencapai 0
    if (_remainingWords <= 0) {
      //Menonaktifkan pengeditan jika sisa kata habis
      _deskripsiTugasController.text =
          _deskripsiTugasController.text.substring(0, 1000);
      _deskripsiTugasController.selection = TextSelection.fromPosition(
          TextPosition(offset: _deskripsiTugasController.text.length));
    }
  }

  Future<bool> _checkJudulMateri(String judulMateri) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference silabusCollection =
        firestore.collection('silabusPraktikum');

    QuerySnapshot querySnapshot = await silabusCollection
        .where('judulMateri', isEqualTo: judulMateri)
        .get();

    // Mengembalikan true jika data ditemukan, false jika tidak
    return querySnapshot.docs.isNotEmpty;
  }

  void _saveTugasForm() async {
    bool isJudulMateriValid =
        await _checkJudulMateri(_judulModulController.text);
    if (!isJudulMateriValid) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Judul materi tidak terdapat pada database'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    //Mendapatkan instance Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    //Mendapatka reference untuk collection 'pengumpulan_tugas'
    CollectionReference tugasCollection =
        firestore.collection('pengumpulanLaporan');

    //Mengambil data terakhir di collection untuk mendapatkan nomor urut
    QuerySnapshot querySnapshot = await tugasCollection.get();
    int documentCount = querySnapshot.docs.length;

    //Membuat nomor urut berikutnya
    int nextDocumentId = documentCount + 1;
    //Menyimpan pengumpulan tugas ke Firestore dengan document_id nomor urut
    await tugasCollection.doc(nextDocumentId.toString()).set({
      'kodeKelas': widget.kodeKelas,
      'deskripsiLaporan': _deskripsiTugasController.text,
      'judulMateri': _judulModulController.text,
      'aksesLaporan': DateTime.parse(_bukaController.text),
      'tutupAksesLaporan': DateTime.parse(_tutupController.text),
      'fileNama': _fileName
    });
    //Tampilkan pesan sukses
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data berhasil disimpan'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
    //Clear TextField
    _judulModulController.clear();
    _deskripsiTugasController.clear();
    _bukaController.clear();
    _tutupController.clear();
    setState(() {
      _fileName = '';
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null) {
      // Jika tanggal dipilih, pilih juga waktu
      // ignore: use_build_context_synchronously
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
      // Gabungkan tanggal dan waktu yang dipilih
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      setState(() {
        controller.text = selectedDateTime.toString();
      });
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

  //== Fungsi Untuk Upload File ==//
  String _fileName = "";
  void _uploadFile() async {
    //== Upload file to Firebase Storage ==//
    String kodeKelas = widget.kodeKelas;

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$kodeKelas/Laporan/${file.name}');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF7F8FA),
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
                      color: Colors.black),
                )),
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
                            border: Border.all(width: 0.5, color: Colors.grey)),
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
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FormDeskripsiKelas(
                                                kodeKelas: widget.kodeKelas,
                                                mataKuliah: widget.mataKuliah,
                                              )));
                                },
                                child: Text(
                                  'Deskripsi Kelas',
                                  style: GoogleFonts.quicksand(fontSize: 16.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 50.0, top: 38.0),
                            child: Text(
                              'Pengumpulan',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 45.0, right: 45.0),
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 90.0),
                            child: SizedBox(
                              // width: 826.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Kode Asisten
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Judul Modul',
                                              style: GoogleFonts.quicksand(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: SizedBox(
                                                width: 580.0,
                                                child: TextField(
                                                  controller:
                                                      _judulModulController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Masukkan Judul Modul',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
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
                                                  top: 15.0),
                                              child: Text(
                                                'Upload File',
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
                                                width: 580.0,
                                                child: Stack(
                                                  children: [
                                                    TextField(
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Nama File Format Laporan',
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      controller:
                                                          TextEditingController(
                                                              text: _fileName),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5.0,
                                                              left: 455.0),
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
                                                          onPressed: () async {
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
                                                              color:
                                                                  Colors.white,
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

                                      // Judul Modul
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0, left: 40.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Akses Laporan',
                                              style: GoogleFonts.quicksand(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: SizedBox(
                                                width: 580.0,
                                                child: TextField(
                                                  readOnly: true,
                                                  controller: _bukaController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Pilih Tanggal Akses',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    suffixIcon: IconButton(
                                                      icon: const Icon(
                                                          Icons.calendar_month),
                                                      onPressed: () async {
                                                        await _selectDate(
                                                            context,
                                                            _bukaController);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15.0,
                                            ),
                                            //Judul Modul
                                            Text(
                                              'Tutup Akses',
                                              style: GoogleFonts.quicksand(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: SizedBox(
                                                width: 580.0,
                                                child: TextField(
                                                  readOnly: true,
                                                  controller: _tutupController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Pilih Tanggal Tutup Akses',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    suffixIcon: IconButton(
                                                      icon: const Icon(
                                                          Icons.calendar_month),
                                                      onPressed: () async {
                                                        await _selectDate(
                                                            context,
                                                            _tutupController);
                                                      },
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

                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Text(
                                      'Deskripsi Laporan',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  //TextField
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: SizedBox(
                                      width: 1200.0,
                                      height: 300.0,
                                      child: TextField(
                                        controller: _deskripsiTugasController,
                                        maxLines: 10,
                                        onChanged: (text) {
                                          updateRemainingWords(text);
                                        },
                                        decoration: InputDecoration(
                                            hintText:
                                                'Masukkan Deskripsi Laporan',
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
                                        const EdgeInsets.only(left: 1065.0),
                                    child: Text(
                                      'Sisa Kata: $_remainingWords/1000',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFF3CBEA9)),
                                          fixedSize: MaterialStateProperty.all(
                                              const Size(150.0, 45.0))),
                                      onPressed: _saveTugasForm,
                                      child: Text(
                                        'Simpan Data',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  const SizedBox(
                                    height: 40.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Latihan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks),
            label: 'Laporan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3CBEA9),
        onTap: _onItemTapped,
      ),
    );
  }
}
