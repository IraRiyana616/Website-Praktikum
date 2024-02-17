import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laksi/Landing%20Page/Komponen/Mahasiswa/Login/login_mhs.dart';
import 'package:laksi/Landing%20Page/Komponen/Non%20Mahasiswa/Admin/Login/login_admin.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Screen/kelas_asisten.dart';
import 'package:laksi/firebase_options.dart';

import 'Pengguna/Mahasiswa/Asisten/Kelas/Navigation/kelas_assnav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginMahasiswa());
  }
}
