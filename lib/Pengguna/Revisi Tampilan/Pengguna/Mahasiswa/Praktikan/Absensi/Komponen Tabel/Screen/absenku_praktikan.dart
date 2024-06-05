// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../Navigasi/absensi_praktikan_nav.dart';
import '../Tabel/Screen/tabel_absensi.dart';

class AbsenkuPraktikan extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;

  const AbsenkuPraktikan(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<AbsenkuPraktikan> createState() => _AbsenkuPraktikanState();
}

class _AbsenkuPraktikanState extends State<AbsenkuPraktikan> {
  String? selectedModul;
  String selectedAbsen = 'Status Kehadiran';
  String selectedPertemuan = 'Pertemuan Praktikum';
  String _fileName = "";

  late int userNim;
  late String userName;

  Future<void> _getData() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('akun_mahasiswa')
              .doc(userUid)
              .get();

      if (userSnapshot.exists) {
        setState(() {
          userNim = userSnapshot['nim'];
          userName = userSnapshot['nama'];
        });
      } else {
        _showSnackbar('Data akun tidak ditemukan', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red);
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _getCurrentUser();
  }

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;

      setState(() {
        _fileName = fileName;
      });

      // Show the uploading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Uploading..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        final firebase_storage.Reference storageRef =
            firebase_storage.FirebaseStorage.instance.ref().child(
                'absensiPraktikan/${widget.kodeKelas}/${widget.mataKuliah}/$fileName');

        await storageRef.putData(file.bytes!);

        Navigator.of(context).pop(); // Close the dialog

        _showSnackbar('File berhasil diupload', Colors.green);
      } catch (e) {
        Navigator.of(context).pop(); // Close the dialog

        _showSnackbar('Error uploading file: $e', Colors.red);

        if (kDebugMode) {
          print('Error uploading file: $e');
        }
      }
    }
  }

  Future<void> saveDataToFirestore() async {
    try {
      if (selectedModul!.isEmpty ||
          selectedAbsen.isEmpty ||
          selectedPertemuan.isEmpty) {
        _showSnackbar('Harap lengkapi semua field', Colors.red);
        return;
      }

      // Cek apakah data sudah ada
      QuerySnapshot<Map<String, dynamic>> existingData = await FirebaseFirestore
          .instance
          .collection('absensiMahasiswa')
          .where('nim', isEqualTo: userNim)
          .where('kodeKelas', isEqualTo: widget.kodeKelas)
          .where('mataKuliah', isEqualTo: widget.mataKuliah)
          .where('judulMateri', isEqualTo: selectedModul)
          .limit(1)
          .get();

      if (existingData.docs.isNotEmpty) {
        _showSnackbar(
            'Data sudah ada, absensi hanya dapat dilakukan sekali', Colors.red);
        return;
      }

      // Jika data belum ada, simpan data ke Firestore
      await FirebaseFirestore.instance.collection('absensiMahasiswa').add({
        'namaFile': _fileName,
        'waktuAbsensi': DateTime.now(),
        'nim': userNim,
        'nama': userName,
        'kodeKelas': widget.kodeKelas,
        'mataKuliah': widget.mataKuliah,
        'pertemuan': selectedPertemuan,
        'keterangan': selectedAbsen,
        'judulMateri': selectedModul
      });

      _showSnackbar('Data berhasil disimpan', Colors.green);
      setState(() {
        selectedAbsen = 'Status Kehadiran';
        _fileName = '';
        selectedModul = '';
        selectedPertemuan = 'Pertemuan Praktikum';
      });
    } catch (e) {
      _showSnackbar('Error saving data: $e', Colors.red);
      if (kDebugMode) {
        print('Error saving data: $e');
      }
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //== Fungsi Nama Mahasiswa ==//
  User? _currentUser;
  String _namaMahasiswa = '';

  //== Nama Akun ==//

  // Fungsi untuk mendapatkan pengguna yang sedang login dan mengambil data nama dari database
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

  //Fungsi Untuk Bottom Navigation
  int _selectedIndex = 0; // untuk mengatur index bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Memilih halaman sesuai dengan index yang dipilih
      if (index == 0) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AbsenkuPraktikan(
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
                TabelAbsensiPraktikanScreen(
              kodeKelas: widget.kodeKelas,
              mataKuliah: widget.mataKuliah,
            ),
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

  @override
  Widget build(BuildContext context) {
    //== MediaQuery ==//
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AbsensiPraktikanNavigasi(),
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
              )),
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
                if (screenWidth > 600) const SizedBox(width: 400.0),
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
                  if (screenWidth > 600) const SizedBox(width: 10.0)
                ],
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFE3E8EF),
        constraints: const BoxConstraints.expand(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 15.0, right: 20.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1350.0),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 35.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, top: 10.0),
                            child: Text(
                              "Formulir Absensi Praktikum",
                              style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                                left: 30.0, right: 30.0, top: 10.0),
                            child: Divider(thickness: 0.5, color: Colors.grey),
                          ),
                          Row(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 395.0, top: 40.0),
                              child: Text("Modul",
                                  style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 70.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: SizedBox(
                                width: 360.0,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('silabusPraktikum')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const CircularProgressIndicator();
                                    }

                                    List<DropdownMenuItem<String>> modulItems =
                                        snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                      String judulMateri =
                                          document['judulMateri'];
                                      return DropdownMenuItem<String>(
                                        value: judulMateri,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            judulMateri,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                      );
                                    }).toList();

                                    return Container(
                                      height: 47.0,
                                      width: 360.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade700),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: DropdownButton<String>(
                                        value: selectedModul,
                                        hint: const Text(
                                          '     Pilih Modul Praktikum',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        items: modulItems,
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedModul = newValue!;
                                          });
                                        },
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14.0),
                                        underline: Container(),
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.grey),
                                        iconSize: 24,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          ]),
                          Row(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 395.0, top: 20.0),
                              child: Text("Pertemuan",
                                  style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 31.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: SizedBox(
                                  width: 360.0,
                                  child: Container(
                                    height: 47.0,
                                    width: 980.0,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade700),
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: DropdownButton<String>(
                                      value: selectedPertemuan,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedPertemuan = newValue!;
                                        });
                                      },
                                      items: [
                                        'Pertemuan Praktikum',
                                        'Pertemuan 1',
                                        'Pertemuan 2',
                                        'Pertemuan 3',
                                        'Pertemuan 4',
                                        'Pertemuan 5',
                                        'Pertemuan 6',
                                        'Pertemuan 7',
                                        'Pertemuan 8',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0),
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                    fontSize: 16.0),
                                              ),
                                            ));
                                      }).toList(),
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.grey),
                                      iconSize: 24,
                                      elevation: 16,
                                      isExpanded: true,
                                      underline: Container(),
                                    ),
                                  )),
                            )
                          ]),
                          Row(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 395.0, top: 20.0),
                              child: Text("Keterangan",
                                  style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 26.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: SizedBox(
                                  width: 360.0,
                                  child: Container(
                                    height: 47.0,
                                    width: 980.0,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade700),
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: DropdownButton<String>(
                                      value: selectedAbsen,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedAbsen = newValue!;
                                        });
                                      },
                                      items: [
                                        'Status Kehadiran',
                                        'Hadir',
                                        'Sakit'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0),
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                    fontSize: 16.0),
                                              ),
                                            ));
                                      }).toList(),
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.grey),
                                      iconSize: 24,
                                      elevation: 16,
                                      isExpanded: true,
                                      underline: Container(),
                                    ),
                                  )),
                            )
                          ]),
                          Row(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 395.0, top: 20.0),
                              child: Text("Bukti Absensi",
                                  style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: SizedBox(
                                width: 360.0,
                                child: Stack(
                                  children: [
                                    TextField(
                                      controller: TextEditingController(
                                          text: _fileName),
                                      decoration: InputDecoration(
                                          hintText: ' Nama File',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          filled: true,
                                          fillColor: Colors.white),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, left: 234.0),
                                      child: SizedBox(
                                          height: 40.0,
                                          width: 120.0,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty
                                                        .all<Color>(const Color(
                                                            0xFF3CBEA9))),
                                            onPressed: () async {
                                              await uploadFile();
                                              setState(() {});
                                            },
                                            child: Text('Upload Foto',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ]),
                          //== ElevatedButton 'SIMPAN' ==//
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 747.0, top: 25.0, bottom: 30.0),
                            child: SizedBox(
                              height: 40.0,
                              width: 130.0,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              const Color(0xFF3CBEA9))),
                                  onPressed: () {
                                    saveDataToFirestore();
                                  },
                                  child: Text(
                                    "Simpan",
                                    style: GoogleFonts.quicksand(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Form Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Tabel Absensi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3CBEA9),
        onTap: _onItemTapped,
      ),
    );
  }
}
