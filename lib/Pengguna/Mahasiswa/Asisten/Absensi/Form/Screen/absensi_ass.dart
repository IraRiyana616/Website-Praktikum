import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              'keterangan': selectedAbsen
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
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                      child: Text(
                    'Absensi Praktikan',
                    style: GoogleFonts.quicksand(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
                  const SizedBox(
                    width: 750.0,
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
                  Text(
                    'Log out',
                    style: GoogleFonts.quicksand(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF031F31)),
                  ),
                  const SizedBox(
                    width: 50.0,
                  )
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
                const SizedBox(
                  height: 30.0,
                ),
                Container(
                  width: 1055.0,
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
                        padding:
                            EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                        child: Divider(thickness: 0.5, color: Colors.grey),
                      ),

                      /// KODE KELAS
                      Row(children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 300.0, top: 40.0),
                          child: Text("Kode Kelas",
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 30.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: SizedBox(
                            width: 300.0,
                            child: TextField(
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

                      /// Modul
                      Row(children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 300.0, top: 10.0),
                          child: Text("Modul",
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 68.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                            width: 300.0,
                            child: TextField(
                              controller: _modulEditingController,
                              decoration: InputDecoration(
                                  hintText: ' Masukkan Nama Modul',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  filled: true,
                                  fillColor: Colors.white),
                            ),
                          ),
                        )
                      ]),

                      /// KETERANGAN
                      Row(children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 300.0, top: 20.0),
                          child: Text("Keterangan",
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 25.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                              width: 300.0,
                              child: Container(
                                height: 47.0,
                                width: 980.0,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade700),
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: DropdownButton<String>(
                                  value: selectedAbsen,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedAbsen = newValue!;
                                    });
                                  },
                                  items: ['Status Kehadiran', 'Hadir', 'Sakit']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem(
                                        value: value,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            value,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        ));
                                  }).toList(),
                                  style: TextStyle(color: Colors.grey.shade700),
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

                      Padding(
                        padding: const EdgeInsets.only(left: 620.0, top: 40.0),
                        child: SizedBox(
                          height: 40.0,
                          width: 100.0,
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
