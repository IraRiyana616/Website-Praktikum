import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laksi/firebase_options.dart';
import 'dart:async';
import 'Landing Page/Komponen/Non Mahasiswa/Admin/Register/register_admin.dart';
import 'Pengguna/Revisi Tampilan/Landing Page/Komponen/Mahasiswa/Login/login_mahasiswa.dart';
import 'Pengguna/Revisi Tampilan/Landing Page/Komponen/Mahasiswa/Registrasi/registrasi_mahasiswa.dart';
import 'Pengguna/Revisi Tampilan/Landing Page/Komponen/Non Mahasiswa/Admin/login_admin.dart';
import 'Pengguna/Revisi Tampilan/Landing Page/Komponen/Non Mahasiswa/Dosen/Login/login_dosen.dart';
import 'Pengguna/Revisi Tampilan/Landing Page/Komponen/Non Mahasiswa/Dosen/Register/register_dosen.dart';
import 'Pengguna/Revisi Tampilan/Landing Page/Screen/landingpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/landingpage',
      routes: {
        '/landingpage': (context) => const LandingPage(),
        '/login-mahasiswa': (context) => const LoginMahasiswa(),
        '/register-mahasiswa': (context) => const RegisterMahasiswa(),
        '/login-dosen': (context) => const LoginDosen(),
        '/register-dosen': (context) => const RegisterDosen(),
        '/login-admin': (context) => const LoginAdmin(),
        '/register-admin': (context) => const RegisterAdmin(),
      },
    );
  }
}
