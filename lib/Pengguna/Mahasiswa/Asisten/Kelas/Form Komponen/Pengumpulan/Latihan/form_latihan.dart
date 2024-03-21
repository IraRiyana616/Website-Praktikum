import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Navigation/kelas_assnav.dart';
import '../../Deskripsi/form_deskripsi.dart';
import '../Laporan/form_laporan.dart';
import '../Tugas/form_tugas.dart';

class FormPengumpulanLatihan extends StatefulWidget {
  const FormPengumpulanLatihan({Key? key}) : super(key: key);

  @override
  State<FormPengumpulanLatihan> createState() => _FormPengumpulanLatihanState();
}

class _FormPengumpulanLatihanState extends State<FormPengumpulanLatihan> {
  final TextEditingController _deskripsiTugasController =
      TextEditingController();
  final TextEditingController _judulModulController = TextEditingController();
  final TextEditingController _kodeKelasController = TextEditingController();
  final TextEditingController _bukaController = TextEditingController();
  final TextEditingController _tutupController = TextEditingController();

  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 0; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Memilih halaman sesuai dengan index yang dipilih
      if (index == 0) {
        // Tindakan ketika item "Latihan" ditekan
        // Di sini Anda dapat menambahkan navigasi ke halaman pengumpulan latihan
        // Misalnya:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const FormPengumpulanLatihan()),
        );
      } else if (index == 1) {
        // Tindakan ketika item "Tugas" ditekan
        // Di sini Anda dapat menambahkan navigasi ke halaman pengumpulan tugas
        // Misalnya:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormPengumpulanTugas()),
        );
      } else if (index == 2) {
        // Tindakan ketika item "Tugas" ditekan
        // Di sini Anda dapat menambahkan navigasi ke halaman pengumpulan tugas
        // Misalnya:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const FormPengumpulanLaporan()),
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

  // Menambah fungsi untuk mengecek kode kelas
  Future<bool> _checkKodeKelas(String kodeKelas) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    //Menggunakan collection 'data_kelas' sebagai referensi
    CollectionReference kelasCollection = firestore.collection('tokenAsisten');
    //Melakukan query untuk mencari data dengan kode kelas yang sesuai
    QuerySnapshot querySnapshot =
        await kelasCollection.where('kodeKelas', isEqualTo: kodeKelas).get();
    //Mengembalikan true jika data ditemukan, false jika tidak
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

    //Memeriksa apakah kode kelas terdapat dalam Firestore 'data_kelas'
    bool isKodeKelasValid = await _checkKodeKelas(_kodeKelasController.text);
    //Jika tidak valid, tampilkan snackbar dan berhenti eksekusi
    if (!isKodeKelasValid) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Kode kelas tidak terdapat pada database'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    //Mendapatkan instance Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    //Mendapatka reference untuk collection 'pengumpulan_tugas'
    CollectionReference tugasCollection =
        firestore.collection('pengumpulanLatihan');

    //Mengambil data terakhir di collection untuk mendapatkan nomor urut
    QuerySnapshot querySnapshot = await tugasCollection.get();
    int documentCount = querySnapshot.docs.length;

    //Membuat nomor urut berikutnya
    int nextDocumentId = documentCount + 1;
    //Menyimpan pengumpulan tugas ke Firestore dengan document_id nomor urut
    await tugasCollection.doc(nextDocumentId.toString()).set({
      'kodeKelas': _kodeKelasController.text,
      'deskripsiLatihan': _deskripsiTugasController.text,
      'judulMateri': _judulModulController.text,
      'aksesLatihan': DateTime.parse(_bukaController.text),
      'tutupAksesLatihan': DateTime.parse(_tutupController.text),
    });
    //Tampilkan pesan sukses
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data berhasil disimpan'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
    //Clear TextField
    _kodeKelasController.clear();
    _judulModulController.clear();
    _deskripsiTugasController.clear();
    _bukaController.clear();
    _tutupController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KelasAsistenNav()));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
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
                  'Kelas Praktikum',
                  style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )),
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FormDeskripsiKelas()));
                              },
                              child: Text(
                                'Deskripsi Kelas',
                                style: GoogleFonts.quicksand(fontSize: 16.0),
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
                                                width: 580.0,
                                                child: TextField(
                                                  controller:
                                                      _kodeKelasController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Masukkan Kode Kelas',
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
                                            const SizedBox(
                                              height: 15.0,
                                            ),
                                            //Judul Modul
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
                                              'Akses Latihan',
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
                                                          Icons.calendar_today),
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
                                                          Icons.calendar_today),
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
                                      'Deskripsi Latihan',
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
                                                'Masukkan Deskripsi Latihan',
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
