import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PengumpulanTugas extends StatefulWidget {
  final String documentId;
  const PengumpulanTugas({super.key, required this.documentId});

  @override
  State<PengumpulanTugas> createState() => _PengumpulanTugasState();
}

class _PengumpulanTugasState extends State<PengumpulanTugas> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> futureData;
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
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data akun tidak ditemukan'),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Harap login terlebih dahulu'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
    futureData = FirebaseFirestore.instance
        .collection('pengumpulan_tugas')
        .doc(widget.documentId)
        .get();
  }

  Future<void> uploadFile(String fileName, PlatformFile file) async {
    try {
      // Upload file to Firebase Storage
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('tugas/$fileName');

      await storageRef.putData(file.bytes!);

      // Get download URL
      final String downloadURL = await storageRef.getDownloadURL();

      // Save file details to Firestore
      await FirebaseFirestore.instance.collection('tugas').add({
        'fileName': fileName,
        'downloadURL': downloadURL,
        'waktu_pengumpulan': DateTime.now(),
        'nim': userNim,
        'nama': userName,
      });

      // Tampilkan pesan sukses
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
      if (kDebugMode) {
        print('File uploaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
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
                  Navigator.pop(context);
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
                    'Pengumpulan Laporan',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
                  const SizedBox(
                    width: 700.0,
                  ),
                  IconButton(
                      onPressed: () {},
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
                    width: 100.0,
                  )
                ],
              ),
            ),
          )),
      body: FutureBuilder(
        future: futureData,
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Map<String, dynamic> data = snapshot.data!.data() ?? {};
            return SingleChildScrollView(
              child: Container(
                color: const Color(0xFFE3E8EF),
                height: 1000.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child: Container(
                        width: 1250.0,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 85.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 95.0),
                              child: Text(
                                "${data['judul_modul'] ?? 'Not available'}",
                                style: GoogleFonts.quicksand(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0, left: 95.0, right: 150.0),
                              child: Text(
                                "${data['deskripsi_tugas'] ?? 'Not available'}",
                                style: const TextStyle(
                                    fontSize: 15.0, height: 2.5),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 60.0, left: 95.0),
                                child: SizedBox(
                                  height: 45.0,
                                  width: 150.0,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color(0xFF3CBEA9))),
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
                                            await uploadFile(fileName, file);

                                            if (kDebugMode) {
                                              print('Selected file: $fileName');
                                            }
                                          } else {
                                            // User canceled the picker
                                            if (kDebugMode) {
                                              print('File picker canceled');
                                            }
                                          }
                                        } catch (e) {
                                          if (kDebugMode) {
                                            print(
                                                'Error picking/uploading file: $e');
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Upload Tugas',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )),
                                )),
                            const SizedBox(
                              height: 100.0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
