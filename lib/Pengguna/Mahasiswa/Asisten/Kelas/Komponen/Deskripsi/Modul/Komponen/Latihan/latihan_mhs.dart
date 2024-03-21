import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Komponen/Deskripsi/Modul/Komponen/Latihan/Edit/edit_latihan.dart';

class LatihanAsisten extends StatefulWidget {
  final String kodeKelas;
  final String modul;
  const LatihanAsisten(
      {super.key, required this.kodeKelas, required this.modul});

  @override
  State<LatihanAsisten> createState() => _LatihanAsistenState();
}

class _LatihanAsistenState extends State<LatihanAsisten> {
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
            .collection('pengumpulanLatihan')
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
                                    '${data['deskripsiLatihan'] ?? 'Not available'}',
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      height: 2.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 75.0, top: 30.0),
                                    child: SizedBox(
                                      height: 45.0,
                                      width: 150.0,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            const Color(0xFF3CBEA9),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditLatihanAsisten(
                                                        kodeKelas:
                                                            widget.kodeKelas,
                                                        modul: widget.modul,
                                                      )));
                                        },
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 3.0),
                                            const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 5.0),
                                            Text(
                                              'Edit Data',
                                              style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
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
    );
  }
}
