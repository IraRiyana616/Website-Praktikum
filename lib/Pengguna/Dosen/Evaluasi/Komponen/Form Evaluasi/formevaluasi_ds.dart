import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormEvaluasiDosen extends StatefulWidget {
  const FormEvaluasiDosen({super.key});

  @override
  State<FormEvaluasiDosen> createState() => _FormEvaluasiDosenState();
}

class _FormEvaluasiDosenState extends State<FormEvaluasiDosen> {
  final TextEditingController _kodeKelasController = TextEditingController();
  final TextEditingController _tahunAjaranController = TextEditingController();
  final TextEditingController _lulusController = TextEditingController();
  final TextEditingController _tidakController = TextEditingController();
  final TextEditingController _hasilEvaluasiController =
      TextEditingController();
  void _saveEvaluation() async {
    // Mendapatkan instance Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Mendapatkan reference untuk collection 'data_evaluasi'
    CollectionReference evaluationCollection =
        firestore.collection('data_evaluasi');

    // Mengambil data terakhir di collection untuk mendapatkan nomor urut
    QuerySnapshot querySnapshot = await evaluationCollection.get();
    int documentCount = querySnapshot.docs.length;

    // Membuat nomor urut berikutnya
    int nextDocumentId = documentCount + 1;

    // Menyimpan data evaluasi ke Firestore dengan document_id berupa nomor urut
    await evaluationCollection.doc(nextDocumentId.toString()).set({
      'kode_kelas': _kodeKelasController.text,
      'tahun_ajaran': _tahunAjaranController.text,
      'lulus': int.parse(_lulusController.text),
      'tidak_lulus': int.parse(_tidakController.text),
      'hasil_evaluasi': _hasilEvaluasiController.text,
    });

    // Tampilkan pesan sukses
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data berhasil disimpan'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));

    _kodeKelasController.clear();
    _tahunAjaranController.clear();
    _lulusController.clear();
    _tidakController.clear();
    _hasilEvaluasiController.clear();

    // Setelah data disimpan, Anda dapat menambahkan logika atau navigasi lainnya
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
              padding: const EdgeInsets.only(top: 8.0, left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    'Formulir Evaluasi',
                    style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
                  const SizedBox(
                    width: 750.0,
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
                    width: 50.0,
                  )
                ],
              ),
            ),
          )),
    );
  }
}
