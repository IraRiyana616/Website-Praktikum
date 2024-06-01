import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laksi/firebase_options.dart';
import 'dart:async';
import 'Pengguna/Revisi Tampilan/Routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/landingpage',
      routes: appRoutes,
    );
  }
}
