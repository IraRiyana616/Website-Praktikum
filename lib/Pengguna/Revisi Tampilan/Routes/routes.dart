import 'package:flutter/material.dart';
import 'package:laksi/Pengguna/Revisi%20Tampilan/Pengguna/Mahasiswa/Praktikan/Dashboard/Navigasi/dashboardnav_praktikan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Landing Page/Komponen/Non Mahasiswa/Admin/Register/register_admin.dart';
import '../Landing Page/Komponen/Mahasiswa/Login/login_mahasiswa.dart';
import '../Landing Page/Komponen/Mahasiswa/Registrasi/registrasi_mahasiswa.dart';
import '../Landing Page/Komponen/Non Mahasiswa/Admin/login_admin.dart';
import '../Landing Page/Komponen/Non Mahasiswa/Dosen/Login/login_dosen.dart';
import '../Landing Page/Komponen/Non Mahasiswa/Dosen/Register/register_dosen.dart';
import '../Landing Page/Screen/landingpage.dart';
import '../Pengguna/Admin/Absensi/Navigasi/absensinav_admin.dart';
import '../Pengguna/Admin/Dashboard/Komponen/Tambah Kelas/form_kelas.dart';
import '../Pengguna/Admin/Dashboard/Navigasi/dasboardnav_admin.dart';
import '../Pengguna/Admin/Jadwal Praktikum/Navigasi/jadwalpraktikumnav_admin.dart';
import '../Pengguna/Admin/Jadwal Praktikum/Tambah Jadwal Praktikum/form_jadwal_praktikum_admin.dart';

Map<String, WidgetBuilder> appRoutes = {
  //== Routes Komponen Landing Page ==//
  '/landingpage': (context) => const LandingPage(),
  '/login-mahasiswa': (context) => const LoginMahasiswa(),
  '/register-mahasiswa': (context) => const RegisterMahasiswa(),
  '/login-dosen': (context) => const LoginDosen(),
  '/register-dosen': (context) => const RegisterDosen(),
  '/login-admin': (context) => const LoginAdmin(),
  '/register-admin': (context) => const RegisterAdmin(),

  //== Routes Tampilan Admin ==//
  '/dashboard': (context) => const AuthGuard(child: DashboardNavigasiAdmin()),
  '/form-kelas-praktikum': (context) => const AuthGuard(child: FormDataKelas()),
  '/jadwal-praktikum': (context) =>
      const AuthGuard(child: JadwalPraktikumNavigasiAdmin()),
  '/form-tambah-jadwal-praktikum': (context) =>
      const AuthGuard(child: FormJadwalPraktikum()),
  '/data-absensi-praktikum': (context) =>
      const AuthGuard(child: AbsensiPraktikumNav()),

  //== Routes Tampilan Praktikan ==//
  '/dashboard-praktikan': (context) => const DashboardNavigasiPraktikan(),
};

//== AuthService ==//
class AuthService {
  static final AuthService _instance = AuthService._internal();
  late SharedPreferences _prefs;
  bool _loggedIn = false;

  AuthService._internal();

  factory AuthService() => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loggedIn = _prefs.getBool('loggedIn') ?? false;
  }

  bool isLoggedIn() {
    return _loggedIn;
  }

  Future<void> login() async {
    _loggedIn = true;
    await _prefs.setBool('loggedIn', _loggedIn);
  }

  Future<void> logout() async {
    _loggedIn = false;
    await _prefs.setBool('loggedIn', _loggedIn);
  }
}

//== Authentikasi Fungsi ==//
class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<void>(
      future: authService.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else {
          if (!authService.isLoggedIn()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login-admin');
            });
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return child;
        }
      },
    );
  }
}
