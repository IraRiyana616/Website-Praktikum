import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DynamicTable extends StatefulWidget {
  const DynamicTable({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DynamicTableState createState() => _DynamicTableState();
}

class _DynamicTableState extends State<DynamicTable> {
  int _selectedNumber = 7;
  String _selectedOption = 'Nilai Akhir'; // Tambahkan variabel _selectedOption
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _generateTextControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 45.0,
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 25.0, left: 55.0),
                    child: Text(
                      'Pilih Kolum :',
                      style: TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButton<int>(
                    value: _selectedNumber,
                    items: [7, 8, 9, 10]
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
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      //== Judul Tabel Penilaian ==//
                      const Padding(
                        padding: EdgeInsets.only(right: 25.0, left: 55.0),
                        child: Text(
                          'Pilih Tabel Penilaian :',
                          style: TextStyle(
                              fontSize: 17.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DropdownButton(
                        // Tambahkan DropdownButton baru
                        value: _selectedOption,
                        items: ['Nilai Akhir', 'Nilai Harian'] // Opsi dropdown
                            .map((option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(right: 55.0, left: 55.0, top: 35.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 4 / 1,
                  ),
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            hintText: _selectedOption == 'Nilai Akhir'
                                ? 'Masukkan Nilai Akhir ${index + 1}'
                                : 'Masukkan Nilai Harian ${index + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 1090.0, top: 10.0),
                child: SizedBox(
                  width: 150.0,
                  height: 45.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CBEA9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    onPressed: () {
                      if (_validateTextField()) {
                        _saveDataToFirestore();
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Harap isi semua kolom diisi'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ));
                      }
                    },
                    child: const Text(
                      'Simpan Data',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    // Mengakses Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Mengambil data dari semua controller
    List<String> data =
        _controllers.map((controller) => controller.text).toList();

    // Menyimpan data ke Firestore
    firestore.collection('dataTabel').add({
      'NamaPenilaian': _selectedOption,
      'values': data,
    }).then((_) {
      // Jika penyimpanan berhasil
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ));

      // Membersihkan TextField
      for (final controller in _controllers) {
        controller.clear();
      }
    }).catchError((error) {
      // Jika terjadi error saat penyimpanan
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
