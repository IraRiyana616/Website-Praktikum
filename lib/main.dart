import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laksi/Landing%20Page/Komponen/Non%20Mahasiswa/Dosen/Login/login_dosen.dart';
import 'package:laksi/firebase_options.dart';

import 'Pengguna/Dosen/Hasil Studi/Komponen/Penulisan Laporan/Screen/penulisanlaporan_ds.dart';

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
        debugShowCheckedModeBanner: false, home: LoginDosen());
  }
}
