// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../../Mahasiswa/Asisten/Pengaturan/Screen/pengaturan.dart';
import '../../../Asisten/Dashboard/Navigasi/dashboardnav_asisten.dart';
import '../../Absensi/Screen/absensi_praktikan.dart';
import '../../Dashboard/Screen/dashboard_praktikan.dart';
import '../../File Pengumpulan/Screen/pengumpulan_praktikan.dart';
import '../../Hasil Studi/hasil_studi_praktikan.dart';
import '../Screen/asistensi_praktikan.dart';

class AsistensiLaporanNavigasi extends StatefulWidget {
  const AsistensiLaporanNavigasi({super.key});

  @override
  State<AsistensiLaporanNavigasi> createState() =>
      _AsistensiLaporanNavigasiState();
}

class _AsistensiLaporanNavigasiState extends State<AsistensiLaporanNavigasi> {
  late Widget currentPage;
  String currentRole = 'Praktikan';

  @override
  void initState() {
    super.initState();
    currentPage = const AsistensiPraktikanScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double screenWidth = constraints.maxWidth;
          final bool isWideScreen = screenWidth >= 200;

          return Row(
            children: [
              Container(
                width: isWideScreen ? 210 : null,
                decoration: const BoxDecoration(
                  color: Color(0xFF031F31),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/logo_laksi.png",
                            height: 150,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 15.0, left: 20.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Mode Pengguna",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11.0),
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                            thickness: 0.3,
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //== Icon Person ==//
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 20.0, right: 10.0),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              ),
                              //== DropdownButton ==//
                              DropdownButton<String>(
                                value: currentRole,
                                dropdownColor: const Color(0XFF3CBEA9),
                                style: const TextStyle(color: Colors.white),
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                                underline: const SizedBox
                                    .shrink(), // Menyembunyikan underline
                                items: <String>[
                                  'Praktikan',
                                  'Asisten'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(fontSize: 13.0),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  if (newValue != null) {
                                    setState(() {
                                      currentRole = newValue;
                                    });
                                    if (currentRole == 'Asisten') {
                                      await _checkAsisten(context);
                                    } else {
                                      setState(() {
                                        currentPage =
                                            const DashboardPraktikanScreen();
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //== Main Menu ==//
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, left: 20.0, bottom: 10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Main Menu",
                          style: TextStyle(color: Colors.white, fontSize: 11.0),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      thickness: 0.3,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          DashboardListTile(
                            title: 'Dashboard',
                            icon: const Icon(
                              Icons.grid_view_outlined,
                            ),
                            page: const DashboardPraktikanScreen(),
                            updatePage: updatePage,
                            isActive: currentPage is DashboardPraktikanScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Absensi',
                            icon: const Icon(
                              Icons.people,
                            ),
                            page: const AbsensiPraktikumScreen(),
                            updatePage: updatePage,
                            isActive: currentPage is AbsensiPraktikumScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'File Pengumpulan',
                            icon: const Icon(
                              Icons.file_copy,
                            ),
                            page: const FilePengumpulanPraktikan(),
                            updatePage: updatePage,
                            isActive: currentPage is FilePengumpulanPraktikan,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Asistensi Laporan',
                            icon: const Icon(
                              Icons.archive,
                            ),
                            page: const AsistensiPraktikanScreen(),
                            updatePage: updatePage,
                            isActive: currentPage is AsistensiPraktikanScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Hasil Studi',
                            icon: const Icon(
                              Icons.score,
                            ),
                            page: const HasilStudiPraktikan(),
                            updatePage: updatePage,
                            isActive: currentPage is HasilStudiPraktikan,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Settings',
                            icon: const Icon(
                              Icons.settings,
                            ),
                            page: const Pengaturan(),
                            updatePage: updatePage,
                            isActive: currentPage is Pengaturan,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: currentPage,
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _checkAsisten(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (kDebugMode) {
        print('User is logged in: ${user.uid}');
      }
      try {
        // Ambil dokumen pengguna dari Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          if (kDebugMode) {
            print('User document exists.');
          }
          final nim = userDoc.data()?['nim']; // Ambil NIM dari dokumen pengguna
          if (kDebugMode) {
            print('NIM: $nim');
          }

          if (nim != null && nim is int) {
            // Memeriksa apakah nim ada di koleksi akun_mahasiswa dan dataAsisten
            final akunMahasiswaSnapshot = await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(user.uid)
                .get();
            final tokenAsistenSnapshot = await FirebaseFirestore.instance
                .collection('dataAsisten')
                .where('nim', isEqualTo: nim)
                .get();

            if (akunMahasiswaSnapshot.exists &&
                tokenAsistenSnapshot.docs.isNotEmpty) {
              if (kDebugMode) {
                print('Both akunMahasiswa and tokenAsisten documents exist.');
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DasboardAsistenNavigasi(),
                ),
              );
            } else {
              if (kDebugMode) {
                print('One or both of the documents do not exist.');
              }
              _showNotRegisteredDialog(context);
            }
          } else {
            if (kDebugMode) {
              print('NIM is null or not an integer.');
            }
            _showNotRegisteredDialog(context);
          }
        } else {
          if (kDebugMode) {
            print('User document does not exist.');
          }
          _showNotRegisteredDialog(context);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
        _showNotRegisteredDialog(context);
      }
    } else {
      if (kDebugMode) {
        print('User is not logged in.');
      }
    }
  }

  void _showNotRegisteredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Anda tidak terdaftar sebagai asisten'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentRole = 'Praktikan';
                  currentPage = const DashboardPraktikanScreen();
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void updatePage(Widget newPage) {
    setState(() {
      currentPage = newPage;
    });
  }
}

class DashboardListTile extends StatefulWidget {
  const DashboardListTile({
    required this.title,
    required this.icon,
    required this.page,
    required this.updatePage,
    required this.isActive,
    Key? key,
  }) : super(key: key);

  final String title;
  final Icon icon;
  final Widget page;
  final Function updatePage;
  final bool isActive;

  @override
  // ignore: library_private_types_in_public_api
  _DashboardListTileState createState() => _DashboardListTileState();
}

class _DashboardListTileState extends State<DashboardListTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            EdgeInsets.symmetric(vertical: 6, horizontal: isHovered ? 16 : 0),
        decoration: BoxDecoration(
          color: isHovered
              ? const Color(0xFFEBF8F6)
              : (widget.isActive
                  ? const Color(0XFF3CBEA9)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            widget.updatePage(widget.page);
          },
          child: ListTile(
            visualDensity: const VisualDensity(vertical: -4),
            dense: true,
            leading: Icon(
              widget.icon.icon,
              size: 20.0,
              color: isHovered
                  ? const Color(0xFF031F31)
                  : (widget.isActive ? Colors.white : Colors.white),
            ),
            title: Text(
              widget.title,
              style: TextStyle(
                fontSize: 13.0,
                color: isHovered
                    ? const Color(0xFF031F31)
                    : (widget.isActive ? Colors.white : Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
