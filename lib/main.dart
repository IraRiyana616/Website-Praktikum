import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laksi/Landing%20Page/Komponen/Mahasiswa/Register/register_mhs.dart';
import 'package:laksi/Landing%20Page/Komponen/Non%20Mahasiswa/Admin/Login/login_admin.dart';

import 'package:laksi/firebase_options.dart';

import 'Landing Page/Komponen/Non Mahasiswa/Admin/Register/register_admin.dart';

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
        debugShowCheckedModeBanner: false, home: LoginAdmin());
  }
}
