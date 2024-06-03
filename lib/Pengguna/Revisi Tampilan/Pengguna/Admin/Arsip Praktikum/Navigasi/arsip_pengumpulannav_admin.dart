// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../Absensi/Screen/absensi_admin.dart';
import '../../Dashboard/Screen/dashboard_admin.dart';
import '../../Hasil Studi/Screen/hasil_studi_admin.dart';
import '../../Jadwal Praktikum/Screen/jadwal_praktikum_admin.dart';
import '../../Pengaturan/pengaturan_admin.dart';
import '../Screen/arsip_praktikum_admin.dart';

class ArsipPraktikumNavigasi extends StatefulWidget {
  const ArsipPraktikumNavigasi({super.key});

  @override
  State<ArsipPraktikumNavigasi> createState() => _ArsipPraktikumNavigasiState();
}

class _ArsipPraktikumNavigasiState extends State<ArsipPraktikumNavigasi> {
  late Widget currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = const ArsipPraktikumAdmin();
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/logo_laksi.png",
                            height: 150,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
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
                            page: const DashboardAdmin(),
                            updatePage: updatePage,
                            isActive: currentPage is DashboardAdmin,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Jadwal',
                            icon: const Icon(
                              Icons.calendar_month,
                            ),
                            page: const JadwalPraktikumScreen(),
                            updatePage: updatePage,
                            isActive: currentPage is JadwalPraktikumScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Absensi',
                            icon: const Icon(
                              Icons.people,
                            ),
                            page: const DataAbsensiPraktikum(),
                            updatePage: updatePage,
                            isActive: currentPage is DataAbsensiPraktikum,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Arsip Praktikum',
                            icon: const Icon(
                              Icons.file_copy,
                            ),
                            page: const ArsipPraktikumAdmin(),
                            updatePage: updatePage,
                            isActive: currentPage is ArsipPraktikumAdmin,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Hasil Studi',
                            icon: const Icon(
                              Icons.score,
                            ),
                            page: const HasilStudiAdminScreen(),
                            updatePage: updatePage,
                            isActive: currentPage is HasilStudiAdminScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Settings',
                            icon: const Icon(
                              Icons.settings,
                            ),
                            page: const PengaturanAdmin(),
                            updatePage: updatePage,
                            isActive: currentPage is PengaturanAdmin,
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
