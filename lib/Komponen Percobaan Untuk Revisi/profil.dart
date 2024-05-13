import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  TextEditingController namaController = TextEditingController();
  TextEditingController nimController = TextEditingController();
  TextEditingController nomorHandphoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  String? _photoUrl;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadImageAndGetUrl(Uint8List imageBytes) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Reference ref = FirebaseStorage.instance.ref().child(
            'Coba/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

        UploadTask uploadTask = ref.putData(imageBytes);
        TaskSnapshot taskSnapshot = await uploadTask;

        String url = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .update({'fotoProfil': url});

        return url;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
    }
    return null;
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(user.uid)
                .get();
        if (userData.exists) {
          setState(() {
            namaController.text = userData.get('nama') ?? '';
            nimController.text = userData.get('nim').toString();
            nomorHandphoneController.text = userData.get('no_hp').toString();
            emailController.text = userData.get('email') ?? '';
            _photoUrl = userData.get('fotoProfil');
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user data: $e");
        }
      }
    }
  }

  Future<void> _updateProfile({int? newPhoneNumber}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (_imageBytes != null) {
          String? photoUrl = await _uploadImageAndGetUrl(_imageBytes!);
          if (photoUrl != null) {
            setState(() {
              _photoUrl = photoUrl;
            });
          }
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating profile: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              CircleAvatar(
                radius: 17.5,
                backgroundColor: const Color(0xFF3CBEA9),
                child: _photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Image.network(
                          _photoUrl!,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.account_circle,
                        size: 35.0, color: Colors.white),
              ),
              const SizedBox(width: 10.0),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFF031F31),
                ),
              ),
              const SizedBox(width: 30.0)
            ],
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
              const SizedBox(height: 30.0),
              Center(
                child: Container(
                  width: 650.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25.0),
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
                      const SizedBox(height: 15.0),
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Divider(thickness: 1.5),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, left: 30.0),
                                child: Text(
                                  'Foto Profil',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 15.0,
                                  left: 30.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Container(
                                    height: 200.0,
                                    width: 200.0,
                                    color: const Color(0xFF3CBEA9),
                                    child: Stack(
                                      children: [
                                        if (_photoUrl != null &&
                                            _imageBytes == null)
                                          Image.network(
                                            _photoUrl!,
                                            fit: BoxFit.cover,
                                            height: 200.0,
                                            width: 200.0,
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(80.0),
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
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 47.0, left: 30.0),
                                child: Text(
                                  'Nama Lengkap',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, top: 10.0, right: 30.0),
                                child: SizedBox(
                                  width: 360.0,
                                  child: TextField(
                                    controller: namaController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: 'Nama Lengkap',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      fillColor: Colors.grey.shade400,
                                      filled: true,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 25.0, left: 30.0),
                                child: Text(
                                  'Nomor Induk Mahasiswa (NIM)',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, top: 10.0, right: 30.0),
                                child: SizedBox(
                                  width: 360.0,
                                  child: TextField(
                                    controller: nimController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: 'NIM',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      fillColor: Colors.grey.shade400,
                                      filled: true,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
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
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 10.0, right: 30.0),
                        child: SizedBox(
                          width: 600.0,
                          child: TextField(
                            controller: nomorHandphoneController,
                            decoration: InputDecoration(
                              hintText: 'Nomor Handphone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
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
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 10.0, right: 30.0),
                        child: SizedBox(
                          width: 600.0,
                          child: TextField(
                            controller: emailController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Masukkan Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.grey.shade400,
                              filled: true,
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFF3CBEA9)),
                            ),
                            onPressed: () {
                              _updateProfile(
                                newPhoneNumber: int.tryParse(
                                  nomorHandphoneController.text,
                                ),
                              );
                            },
                            child: const Text(
                              "Simpan Perubahan ",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
