// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PengumpulanLaporanPraktikan extends StatefulWidget {
  final String judulModul;
  final String idkelas;
  final String kode;
  const PengumpulanLaporanPraktikan(
      {super.key,
      required this.judulModul,
      required this.idkelas,
      required this.kode});

  @override
  State<PengumpulanLaporanPraktikan> createState() =>
      _PengumpulanLaporanPraktikanState();
}

class _PengumpulanLaporanPraktikanState
    extends State<PengumpulanLaporanPraktikan> {
  //== Fungsi untuk mengambil data akun yang sedang login ==//
  late int userNim;
  late String userName;
  //== Fungsi pada dropdownButton ==//
  late String selectedRevisi = 'Status Asistensi';

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

//== Fungsi untuk mengupload File ==//
  Future<void> uploadFile(
      String fileName, PlatformFile file, String revisi) async {
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
          .child('tugas/${widget.idkelas}/${widget.judulModul}/$fileName');

      await storageRef.putData(file.bytes!);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('d MMMM yyyy hh:mm a').format(now);

      await FirebaseFirestore.instance.collection('pengumpulanLaporan').add({
        'namaFile': fileName,
        'waktuAsistensi': formattedDate,
        'nim': userNim,
        'nama': userName,
        'idKelas': widget.idkelas,
        'judulModul': widget.judulModul,
        'statusRevisi': revisi
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

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Status Revisi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          content: DropdownButton(
            value: selectedRevisi,
            onChanged: (String? newValue) {
              setState(() {
                selectedRevisi = newValue!;
              });
              Navigator.of(context).pop();
              _openFilePicker();
            },
            items: <String>[
              'Status Asistensi', // Pisahkan dengan koma di sini
              'Revisi 1',
              'Revisi 2',
              'Revisi 3',
              'Revisi 4',
              'Revisi 5'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;
        String fileName = file.name;

        await uploadFile(fileName, file, selectedRevisi);

        if (kDebugMode) {
          print('Selected file: $fileName');
        }
      } else {
        if (kDebugMode) {
          print('File picker canceled');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error picking/uploading file: $e'),
        backgroundColor: Colors.red,
      ));
      if (kDebugMode) {
        print('Error picking/uploading file: $e');
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
            .where('jenisPengumpulan', isEqualTo: 'Asistensi Laporan')
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
                  height: 800.0,
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
                                            onPressed: () {
                                              _showDialog();
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
                                        ),
                                ),
                                const SizedBox(height: 35.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(
                      //   height: 600.0,
                      // )
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
          child: const Padding(
            padding: EdgeInsets.only(right: 70.0),
          ),
        ),
      ),
    );
  }
}
