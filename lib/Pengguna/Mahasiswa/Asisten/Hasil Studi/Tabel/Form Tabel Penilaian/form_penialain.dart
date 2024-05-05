import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormPenilaian extends StatefulWidget {
  final String kodeKelas;
  const FormPenilaian({super.key, required this.kodeKelas});

  @override
  State<FormPenilaian> createState() => _FormPenilaianState();
}

class _FormPenilaianState extends State<FormPenilaian> {
  //== Komponen pada tampilan ==//
  int _selectedNumber = 7;
  String _selectedOption = 'Nilai Harian';
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _generateTextControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70.0),
            child: AppBar(
              backgroundColor: const Color(0xFFF7F8FA),
              automaticallyImplyLeading: false,
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
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                        child: Text(
                      widget.kodeKelas,
                      style: GoogleFonts.quicksand(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ))
                  ],
                ),
              ),
            )),
        body: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, top: 5.0, right: 25.0),
                child: Container(
                  width: 1500.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 45.0,
                      ),
                      Row(
                        children: [
                          //== Masukkan Berapa Jumlah Column yang diinginkan ==//
                          const Padding(
                            padding: EdgeInsets.only(right: 25.0, left: 55.0),
                            child: Text(
                              'Pilih Kolum :',
                              style: TextStyle(
                                  fontSize: 17.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          //== DropdownButton dari jumlah column ==//
                          DropdownButton<int>(
                            value: _selectedNumber,
                            items: [7, 8, 9, 10, 11, 12, 13, 14]
                                .map((number) => DropdownMenuItem<int>(
                                      value: number,
                                      child: Text('$number'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedNumber = value!;
                                _generateTextControllers();
                              });
                            },
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Row(
                            children: [
                              //== Judul Tabel Penilaian ==//
                              const Padding(
                                padding:
                                    EdgeInsets.only(right: 25.0, left: 55.0),
                                child: Text(
                                  'Pilih Tabel Penilaian :',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              DropdownButton(
                                  value: _selectedOption,
                                  items: ['Nilai Harian', 'Nilai Akhir']
                                      .map((option) => DropdownMenuItem(
                                            value: option,
                                            child: Text(option),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value!;
                                    });
                                  })
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 55.0, left: 55.0, top: 35.0),
                        child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 10.0,
                                    childAspectRatio: 4 / 1),
                            itemCount: _controllers.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  TextField(
                                    controller: _controllers[index],
                                    decoration: InputDecoration(
                                        hintText: _selectedOption ==
                                                'Nilai Harian'
                                            ? 'Masukkan Nama Kolum Nilai Harian ${index + 1}'
                                            : 'Masukkan Nama Kolum Nilai Akhir ${index + 1}',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0))),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  )
                                ],
                              );
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 55.0, bottom: 45.0, top: 15.0),
                        child: SizedBox(
                          width: 150.0,
                          height: 45.0,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3CBEA9),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              onPressed: () {
                                if (_validateTextField()) {
                                  _saveDataToFirestore();
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Harap isi semua kolom'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ));
                                }
                              },
                              child: const Text(
                                'Simpan Data',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _generateTextControllers() {
    _controllers.clear();
    for (int i = 0; i < _selectedNumber; i++) {
      _controllers.add(TextEditingController());
    }
  }

  bool _validateTextField() {
    for (final controller in _controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void _saveDataToFirestore() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    //== Mengambil data dari semua controller ==//
    List<String> data =
        _controllers.map((controller) => controller.text).toList();

    //== Menyimpan data ke Firestore ==//
    firestore.collection('dataTabel').add({
      'kodeKelas': widget.kodeKelas,
      'NamaPenilaian': _selectedOption,
      'values': data,
    }).then((_) {
      //== Jika Penyimpanan berhasil
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ));
      //== Membersihkan TextField
      for (final controller in _controllers) {
        controller.clear();
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan saat menyimpan data: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
