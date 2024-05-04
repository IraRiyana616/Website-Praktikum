import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:laksi/firebase_options.dart';
import 'Landing Page/Screen/landing_page.dart';
import 'Pengguna/Mahasiswa/Praktikan/Dashboard/Screen/dashboard_mhs.dart';
import 'Test memperbaiki hasil studi/memperbaiki.dart';
import 'Test memperbaiki hasil studi/tabel_memperbaiki.dart';

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // initialRoute: '/login',
      // routes: {
      //   '/dashboard': (context) => const DashboardPraktikan(),
      //   '/login': (context) => const LandingPage(),
      // },
      home: DynamicTable(),
    );
  }
}
