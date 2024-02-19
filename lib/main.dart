import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laksi/Landing%20Page/Komponen/Mahasiswa/Login/login_mhs.dart';
import 'package:laksi/Pengguna/Dosen/Dashboard/Komponen/form_kelas.dart';
import 'package:laksi/Pengguna/Dosen/Dashboard/Screen/dashboard_ds.dart';
import 'package:laksi/Pengguna/Dosen/Evaluasi/Screen/evaluasi_ds.dart';
import 'package:laksi/Pengguna/Dosen/Mahasiswa/Screen/mahasiswa_ds.dart';
import 'package:laksi/firebase_options.dart';

import 'Landing Page/Komponen/Non Mahasiswa/Dosen/Login/login_dosen.dart';

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
