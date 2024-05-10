import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes!;
      });
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
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pengaturan Akun',
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                //Tampilan Icon Avatar !!!!
                Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF031F31),
                  ),
                ),
                const SizedBox(
                  width: 60.0,
                )
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30.0,
              ),
              Center(
                child: Container(
                  width: 650.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Text(
                          'Profil Pengguna',
                          style: GoogleFonts.quicksand(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Divider(
                          thickness: 1.5,
                        ),
                      ),
                      //== Foto Profil ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 30.0),
                        child: Text(
                          'Foto Profil',
                          style: GoogleFonts.quicksand(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //== Komponen Foto Profil ==//
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          left: 30.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            height: 150.0,
                            width: 150.0,
                            color: const Color(0xFF3CBEA9),
                            child: Stack(
                              children: [
                                if (_imageBytes != null)
                                  Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.cover,
                                    height: 150.0,
                                    width: 150.0,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(55.0),
                                  child: IconButton(
                                    onPressed: _pickImage,
                                    icon: const Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      //== Nama Lengkap ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 30.0),
                        child: Text(
                          'Nama Lengkap',
                          style: GoogleFonts.quicksand(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //== TextField Nama Lengkap ==//
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 10.0, right: 30.0),
                        child: SizedBox(
                          width: 600.0,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Ira Riyana Sari Siregar',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      //== Nomor Induk Mahasiswa (NIM) ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 30.0),
                        child: Text(
                          'Nomor Induk Mahasiswa (NIM)',
                          style: GoogleFonts.quicksand(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //== TextField Nama Lengkap ==//
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 10.0, right: 30.0),
                        child: SizedBox(
                          width: 600.0,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '1809075014',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      //== Nomor Handphone ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 30.0),
                        child: Text(
                          'Nomor Handphone',
                          style: GoogleFonts.quicksand(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //== TextField Nomor Handphone ==//
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 10.0, right: 30.0),
                        child: SizedBox(
                          width: 600.0,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '1809075014',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      //===== Pengaturan Akun =====//
                      const SizedBox(
                        height: 45.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Text(
                          'Pengaturan Akun',
                          style: GoogleFonts.quicksand(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Divider(
                          thickness: 1.5,
                        ),
                      ),
                      //== Email ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 30.0),
                        child: Text(
                          'Email',
                          style: GoogleFonts.quicksand(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //== TextField Nama Lengkap ==//
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 10.0, right: 30.0),
                        child: SizedBox(
                          width: 600.0,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'irariyana@gmail.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      //== Password ==//
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 30.0),
                        child: Text(
                          'Password',
                          style: GoogleFonts.quicksand(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //== TextField Nama Lengkap ==//
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 10.0, right: 30.0),
                        child: SizedBox(
                          width: 600.0,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '1809075014',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 450.0, top: 35.0),
                        child: SizedBox(
                            height: 45.0,
                            width: 170.0,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFF3CBEA9)),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  "Simpan Perubahan ",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ))),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
