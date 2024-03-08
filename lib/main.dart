import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laksi/Landing%20Page/Komponen/Mahasiswa/Login/login_mhs.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Komponen/Absensi/Screen/absensi_asst.dart';
import 'package:laksi/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginMahasiswa());
  }
}
