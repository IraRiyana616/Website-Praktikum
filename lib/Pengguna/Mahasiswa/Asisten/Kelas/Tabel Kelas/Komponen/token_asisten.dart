// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TokenAsisten extends StatefulWidget {
  const TokenAsisten({super.key});

  @override
  State<TokenAsisten> createState() => _TokenAsistenState();
}

class _TokenAsistenState extends State<TokenAsisten> {
  final TextEditingController _classCodeController = TextEditingController();
  Future<void> _getData() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;

      if (userUid.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();

        if (userSnapshot.exists) {
          String userNim =
              userSnapshot['nim'].toString(); // Convert nim to String

          DocumentSnapshot<Map<String, dynamic>> assistantSnapshot =
              await FirebaseFirestore.instance
                  .collection('dataAsisten')
                  .doc(userNim) // Use nim as document ID
                  .get();

          if (assistantSnapshot.exists) {
            String classCode = _classCodeController.text;

            QuerySnapshot<Map<String, dynamic>> classSnapshot =
                await FirebaseFirestore.instance
                    .collection('dataKelas')
                    .where('kodeAsisten', isEqualTo: classCode)
                    .get();

            if (classSnapshot.docs.isNotEmpty) {
              for (QueryDocumentSnapshot<Map<String, dynamic>> classDocument
                  in classSnapshot.docs) {
                String existingTokenId =
                    '$userNim-$classCode-${classDocument.id}';

                DocumentSnapshot<Map<String, dynamic>> existingTokenSnapshot =
                    await FirebaseFirestore.instance
                        .collection('tokenAsisten')
                        .doc(existingTokenId)
                        .get();

                if (existingTokenSnapshot.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Data dengan nim dan kode kelas yang sama sudah terdaftar'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  Map<String, dynamic> updatedClassData = {
                    'nama': userSnapshot['nama'],
                    'nim': userNim,
                    'tokenAsisten': existingTokenId,
                    'tokenKelas': classDocument.id,
                    'mataKuliah': classDocument['mataKuliah'],
                    'dosenPengampu': classDocument['dosenPengampu'],
                    'dosenPengampu2': classDocument['dosenPengampu2'],
                    'tahunAjaran': classDocument['tahunAjaran'],
                  };

                  await FirebaseFirestore.instance
                      .collection('tokenAsisten')
                      .doc(existingTokenId)
                      .set(updatedClassData);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil disimpan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _classCodeController.clear();
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data kelas tidak ditemukan'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('NIM tidak terdaftar sebagai asisten'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap login terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      if (kDebugMode) {
        print('Error: $e');
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
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Token Praktikum Asisten",
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
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 100.0,
              ),
              Center(
                child: Container(
                  width: 650.0,
                  height: 350.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 40.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, left: 50.0),
                        child: Text(
                          "Kode Praktikum Asisten",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 50.0,
                          right: 30.0,
                          top: 30.0,
                        ),
                        child: SizedBox(
                          width: 550.0,
                          child: TextField(
                            controller: _classCodeController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan Kode Praktikum Asisten',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 500.0),
                        child: SizedBox(
                          height: 35.0,
                          width: 100.0,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF3CBEA9),
                              ),
                            ),
                            onPressed: _getData,
                            child: const Text(
                              "Simpan",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 130.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
