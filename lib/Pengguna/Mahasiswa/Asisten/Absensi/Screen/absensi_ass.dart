import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AbsensiAsisten extends StatefulWidget {
  const AbsensiAsisten({super.key});

  @override
  State<AbsensiAsisten> createState() => _AbsensiAsistenState();
}

class _AbsensiAsistenState extends State<AbsensiAsisten> {
  final TextEditingController _kodeEditingController = TextEditingController();
  final TextEditingController _modulEditingController = TextEditingController();
  String selectedAbsen = 'Status Kehadiran';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _fileName = '';
  //== Nama Akun ==//
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String _namaMahasiswa = '';

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

  // Fungsi untuk logout dari akun Firebase
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      // Navigasi kembali ke halaman login atau halaman lain setelah logout berhasil
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      // Tangani kesalahan logout
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
    _getCurrentUser();
  }

  Future<void> saveDataToFirestore() async {
    DateTime currentDate = DateTime.now();
    String formattedDate =
        '${currentDate.year}-${currentDate.month}-${currentDate.day}';
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('akun_mahasiswa')
              .doc(userUid)
              .get();

      if (userSnapshot.exists) {
        int userNim = userSnapshot['nim'];

        // Memeriksa apakah judulMateri sesuai dengan yang ada di Firestore
        bool isModulValid =
            await checkModulInFirestore(_modulEditingController.text);

        if (isModulValid) {
          // Memeriksa apakah data dengan tanggal yang sama telah ada dalam database
          bool isDataExists = await checkDataExists(formattedDate, userNim);
          if (isDataExists) {
            // Data dengan tanggal yang sama telah ada dalam database
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Data telah terdapat pada database'),
              backgroundColor: Colors.red,
            ));
          } else {
            // Data belum ada dalam database, simpan data baru
            Map<String, dynamic> updatedAbsenData = {
              'kodeAsisten': _kodeEditingController.text,
              'judulMateri': _modulEditingController.text,
              'nama': userSnapshot['nama'],
              'nim': userNim,
              'tanggal': formattedDate,
              'timestamp': FieldValue.serverTimestamp(),
              'keterangan': selectedAbsen,
              'namaFile': _fileName,
            };
            await FirebaseFirestore.instance
                .collection('absensiAsisten')
                .add(updatedAbsenData);

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Data berhasil disimpan'),
              backgroundColor: Colors.green,
            ));

            _kodeEditingController.clear();
            _modulEditingController.clear();
            setState(() {
              selectedAbsen = 'Status Kehadiran';
              _fileName = '';
            });
          }
        } else {
          // JudulMateri tidak sesuai dengan yang ada di Firestore
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data tidak terdapat pada database'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error:$e'),
        backgroundColor: Colors.red,
      ));
      if (kDebugMode) {
        print('Error:$e');
      }
    }
  }

  Future<bool> checkModulInFirestore(String judulMateri) async {
    try {
      QuerySnapshot<Map<String, dynamic>> modulSnapshot =
          await FirebaseFirestore.instance
              .collection('silabusPraktikum')
              .where('judulMateri', isEqualTo: judulMateri)
              .get();

      return modulSnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching modul data: $e');
      }
      return false;
    }
  }

  Future<bool> checkDataExists(String formattedDate, int userNim) async {
    try {
      QuerySnapshot<Map<String, dynamic>> dataSnapshot =
          await FirebaseFirestore.instance
              .collection('absensiAsisten')
              .where('tanggal', isEqualTo: formattedDate)
              .where('nim', isEqualTo: userNim) // check for userNim as well
              .get();

      return dataSnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking data existence: $e');
      }
      return false;
    }
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('akun_mahasiswa')
              .doc(userUid)
              .get();

      if (userSnapshot.exists) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }
//== Upload File ==//

  void _uploadFile() async {
    String kodeKelas = _kodeEditingController.text;
    String namaModul = _modulEditingController.text;

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      try {
        String userUid = FirebaseAuth.instance.currentUser!.uid;
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();

        if (userSnapshot.exists) {
          int userNim = userSnapshot['nim'];

          firebase_storage.Reference ref =
              firebase_storage.FirebaseStorage.instance.ref().child(
                  'Absensi Mahasiswa/$kodeKelas/$namaModul/$userNim/${file.name}');

          // Upload file
          await ref.putData(file.bytes!);

          setState(() {
            _fileName = file.name;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User data not found'),
            backgroundColor: Colors.red,
          ));
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error during upload or getting download URL: $e");
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error uploading image'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file selected'),
        backgroundColor: Colors.red,
      ));
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
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      "Absensi Asisten",
                      style: GoogleFonts.quicksand(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
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
                    IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFF031F31),
                        )),
                    const SizedBox(
                      width: 10.0,
                    ),
                  ],
                ],
              ),
            ),
          )),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: 1095.0,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 40.0, top: 30.0),
                          child: Text(
                            "Formulir Absensi Praktikum",
                            style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, right: 30.0, top: 10.0),
                          child: Divider(thickness: 0.5, color: Colors.grey),
                        ),

                        //== Kode Kelas ==//
                        Row(children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 270.0, top: 40.0),
                            child: Text("Kode Praktikum",
                                style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 30.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: SizedBox(
                              width: 325.0,
                              child: TextField(
                                inputFormatters: [
                                  UpperCaseTextFormatter(),
                                  LengthLimitingTextInputFormatter(6)
                                ],
                                controller: _kodeEditingController,
                                decoration: InputDecoration(
                                    hintText: ' Masukkan Kode Asisten',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    filled: true,
                                    fillColor: Colors.white),
                              ),
                            ),
                          )
                        ]),
                        //== Nama Modul ==//
                        Row(children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 270.0, top: 10.0),
                            child: Text("Judul Modul",
                                style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 60.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              width: 325.0,
                              child: TextField(
                                controller: _modulEditingController,
                                decoration: InputDecoration(
                                    hintText: ' Masukkan Judul Modul',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    filled: true,
                                    fillColor: Colors.white),
                              ),
                            ),
                          )
                        ]),

                        //== Keterangan ==//
                        Row(children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 270.0, top: 20.0),
                            child: Text("Keterangan",
                                style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 60.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                                width: 325.0,
                                child: Container(
                                  height: 47.0,
                                  width: 980.0,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade700),
                                      borderRadius: BorderRadius.circular(8.0)),
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
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
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
                        //== Bukti Foto ==//
                        Row(children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 270.0, top: 20.0),
                            child: Text("Foto Absensi",
                                style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 53.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              width: 325.0,
                              child: Stack(
                                children: [
                                  TextField(
                                    controller:
                                        TextEditingController(text: _fileName),
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
                                        top: 5.0, left: 200.0),
                                    child: SizedBox(
                                        height: 40.0,
                                        width: 120.0,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      const Color(0xFF3CBEA9))),
                                          onPressed: () async {
                                            _uploadFile();
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

                        Padding(
                          padding:
                              const EdgeInsets.only(left: 617.0, top: 25.0),
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
                        const SizedBox(
                          height: 60.0,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 103.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//== UpperCaseTextFormatter ==//
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
