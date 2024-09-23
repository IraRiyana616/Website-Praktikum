// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import '../../../Deskripsi Kelas/deskripsi_praktikan.dart';
import '../Tugas/pengumpulan_tugas.dart';

class PengumpulanLatihanPraktikan extends StatefulWidget {
  final String judulModul;
  final String idkelas;
  final String kode;
  final String matkul;
  const PengumpulanLatihanPraktikan({
    super.key,
    required this.judulModul,
    required this.idkelas,
    required this.kode,
    required this.matkul,
  });

  @override
  State<PengumpulanLatihanPraktikan> createState() =>
      _PengumpulanLatihanPraktikanState();
}

class _PengumpulanLatihanPraktikanState
    extends State<PengumpulanLatihanPraktikan> {
  //== Fungsi untuk mengambil data dari akun yang login =//
  late int userNim;
  late String userName;

  Future<void> _getData() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;
      // ignore: unnecessary_null_comparison
      if (userUid != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();

        if (userSnapshot.exists) {
          userNim = userSnapshot['nim'];
          userName = userSnapshot['nama'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data akun tidak ditemukan'),
            backgroundColor: Colors.red,
          ));
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Harap login terlebih dahulu'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
      if (kDebugMode) {
        print('Error: $e');
      }
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  //== FUngsi untuk mengupload file ==//

  Future<void> uploadFile(String fileName, PlatformFile file) async {
    try {
      // Menampilkan dialog loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('latihan/${widget.idkelas}/${widget.judulModul}/$fileName');

      await storageRef.putData(file.bytes!);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('d MMMM yyyy hh:mm a').format(now);

      await FirebaseFirestore.instance.collection('dataPengumpulan').add({
        'namaFile': fileName,
        'waktuPengumpulan': formattedDate,
        'nim': userNim,
        'nama': userName,
        'idKelas': widget.idkelas,
        'judulModul': widget.judulModul,
        'jenisPengumpulan': 'Latihan'
      });

      // Menutup dialog loading
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
    }
  }

//== Fungsi untuk menampilkan button ==//
  bool isButtonVisible(Map<String, dynamic> data) {
    String? aksesLatihanStr = data['waktuAkses'];
    String? tutupAksesLatihanStr = data['waktuTutupAkses'];
    DateTime now = DateTime.now();

    if (aksesLatihanStr != null && tutupAksesLatihanStr != null) {
      DateFormat dateFormat = DateFormat("d MMMM yyyy h:mm a");
      DateTime aksesLatihan = dateFormat.parse(aksesLatihanStr);
      DateTime tutupAksesLatihan = dateFormat.parse(tutupAksesLatihanStr);

      // Perbandingan menggunakan nilai waktu dalam objek DateTime
      if (now.isAfter(aksesLatihan) && now.isBefore(tutupAksesLatihan)) {
        return true;
      }
    }

    return false;
  }

// Fungsi async untuk memeriksa keberadaan idKelas dan judulMateri dalam Firestore
  Future<bool> checkDataExist(String idKelas, String modul) async {
    bool exists = false;

    // Melakukan query ke Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Pengumpulan')
        .where('idKelas', isEqualTo: idKelas)
        .where('judulModul', isEqualTo: modul)
        .where('jenisPengumpulan', isEqualTo: 'Tugas')
        .get();

    // Jika data ditemukan, set exists menjadi true
    if (querySnapshot.docs.isNotEmpty) {
      exists = true;
    }

    return exists;
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
                      DeskripsiKelasPraktikan(
                    kodeKelas: widget.kode,
                    idkelas: widget.idkelas,
                    mataKuliah: widget.matkul,
                  ),
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
                    widget.judulModul,
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Pengumpulan')
            .where('idKelas', isEqualTo: widget.idkelas)
            .where('judulModul', isEqualTo: widget.judulModul)
            .where('jenisPengumpulan', isEqualTo: 'Latihan')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error:${snapshot.error}'),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/404.png',
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'Data tidak ditemukan',
                    style: GoogleFonts.quicksand(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Container(
                  color: const Color(0xFFE3E8EF),
                  width: 2000.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 65.0, right: 65.0, top: 20.0),
                        child: Center(
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 75.0, right: 100.0, top: 55.0),
                                  child: Text(
                                    '${data['deskripsiPengumpulan'] ?? 'Not available'}',
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      height: 2.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 75.0, top: 30.0),
                                  child: isButtonVisible(data)
                                      ? SizedBox(
                                          height: 45.0,
                                          width: 150.0,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                const Color(0xFF3CBEA9),
                                              ),
                                            ),
                                            onPressed: () async {
                                              try {
                                                FilePickerResult? result =
                                                    await FilePicker.platform
                                                        .pickFiles();

                                                if (result != null) {
                                                  PlatformFile file =
                                                      result.files.first;
                                                  String fileName = file.name;

                                                  // Upload file and save details to Firestore
                                                  await uploadFile(
                                                      fileName, file);

                                                  if (kDebugMode) {
                                                    print(
                                                        'Selected file: $fileName');
                                                  }
                                                } else {
                                                  // User canceled the picker
                                                  if (kDebugMode) {
                                                    print(
                                                        'File picker canceled');
                                                  }
                                                }
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print(
                                                      'Error picking/uploading file: $e');
                                                }
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.upload,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 5.0),
                                                Text(
                                                  'Upload File',
                                                  style: GoogleFonts.quicksand(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 45.0,
                                          width: 150.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            child: Row(children: [
                                              const SizedBox(width: 15.0),
                                              const Icon(
                                                Icons.upload,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 5.0),
                                              Text(
                                                'Upload File',
                                                style: GoogleFonts.quicksand(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ), // Atau Container() jika tidak ingin menampilkan apa pun
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 600.0,
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          color: const Color(0xFFF7F8FA),
          child: Padding(
            padding: const EdgeInsets.only(right: 70.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    // Memeriksa keberadaan data sebelum melakukan navigasi
                    bool dataExists =
                        await checkDataExist(widget.idkelas, widget.judulModul);
                    if (dataExists) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  PengumpulanTugasPraktikan(
                            judulModul: widget.judulModul,
                            idkelas: widget.idkelas,
                            kode: widget.kode,
                            matkul: widget.matkul,
                          ),
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
                    } else {
                      // Tampilkan pesan atau lakukan aksi lain sesuai kebutuhan
                      if (kDebugMode) {
                        print('Data tidak ditemukan di Firestore');
                      }
                    }
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'Selanjutnya',
                      style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                const Icon(Icons.arrow_circle_right)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
