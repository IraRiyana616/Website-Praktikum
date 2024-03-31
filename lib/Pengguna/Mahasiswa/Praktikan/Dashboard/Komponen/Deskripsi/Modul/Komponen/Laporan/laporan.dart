import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PengumpulanLaporan extends StatefulWidget {
  final String kodeKelas;
  final String modul;
  const PengumpulanLaporan(
      {super.key, required this.kodeKelas, required this.modul});

  @override
  State<PengumpulanLaporan> createState() => _PengumpulanLaporanState();
}

class _PengumpulanLaporanState extends State<PengumpulanLaporan> {
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

  Future<void> uploadFile(String fileName, PlatformFile file) async {
    try {
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('laporan/${widget.kodeKelas}/${widget.modul}/$fileName');

      await storageRef.putData(file.bytes!);
      // Mengambil referensi ke jumlah dokumen saat ini dalam koleksi 'laporan'
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('laporan').get();
      int userUid = querySnapshot.docs.length + 1;

      await FirebaseFirestore.instance.collection('laporan').add({
        'UserUid': userUid,
        'namaFile': fileName,
        'waktuPengumpulan': DateTime.now(),
        'nim': userNim,
        'nama': userName,
        'kodeKelas': widget.kodeKelas,
        'judulMateri': widget.modul
      });

      // ignore: use_build_context_synchronously
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

  bool isButtonVisible(Map<String, dynamic> data) {
    Timestamp? aksesLatihan = data['aksesLaporan'];
    Timestamp? tutupAksesLatihan = data['tutupAksesLaporan'];
    Timestamp now = Timestamp.now();

    if (aksesLatihan != null && tutupAksesLatihan != null) {
      // Perbandingan menggunakan nilai waktu dalam objek Timestamp
      if (now.seconds > aksesLatihan.seconds &&
          now.seconds < tutupAksesLatihan.seconds) {
        return true;
      }
    }

    return false;
  }

  // Fungsi async untuk memeriksa keberadaan kodeKelas dan judulMateri dalam Firestore
  Future<bool> checkDataExist(String kodeKelas, String modul) async {
    bool exists = false;

    // Melakukan query ke Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('pengumpulanLaporan')
        .where('kodeKelas', isEqualTo: kodeKelas)
        .where('judulMateri', isEqualTo: modul)
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
                    widget.modul,
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
            .collection('pengumpulanLaporan')
            .where('kodeKelas', isEqualTo: widget.kodeKelas)
            .where('judulMateri', isEqualTo: widget.modul)
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
                  height: 620.0,
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
                                    '${data['deskripsiLaporan'] ?? 'Not available'}',
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
                                const SizedBox(height: 35.0),
                              ],
                            ),
                          ),
                        ),
                      ),
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
