// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../../../../Dosen/Pengaturan/Screen/pengaturan_ds.dart';
import '../../Absensi/Screen/absensi_dosen.dart';
import '../../Asistensi Laporan/Screen/asisten_laporan_dosen.dart';
import '../../Dashboard/Screen/dashboard_dosen.dart';
import '../../Hasil Studi/Screen/hasil_studi_dosen.dart';
import '../Screen/file_pengumpulan_dosen.dart';

class FilePengumpulanDosenNavigasi extends StatefulWidget {
  const FilePengumpulanDosenNavigasi({super.key});

  @override
  State<FilePengumpulanDosenNavigasi> createState() =>
      _FilePengumpulanDosenNavigasiState();
}

class _FilePengumpulanDosenNavigasiState
    extends State<FilePengumpulanDosenNavigasi> {
  late Widget currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = const FilePengumpulanScreenDosen();
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
                            page: const DashboardDosenScreen(),
                            updatePage: updatePage,
                            isActive: currentPage is DashboardDosenScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Absensi',
                            icon: const Icon(
                              Icons.people,
                            ),
                            page: const AbsensiScreenDosen(),
                            updatePage: updatePage,
                            isActive: currentPage is AbsensiScreenDosen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'File Pengumpulan',
                            icon: const Icon(
                              Icons.file_copy,
                            ),
                            page: const FilePengumpulanScreenDosen(),
                            updatePage: updatePage,
                            isActive: currentPage is FilePengumpulanScreenDosen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Asistensi Laporan',
                            icon: const Icon(
                              Icons.archive,
                            ),
                            page: const AsistensiLaporanDosen(),
                            updatePage: updatePage,
                            isActive: currentPage is AsistensiLaporanDosen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Hasil Studi',
                            icon: const Icon(
                              Icons.score,
                            ),
                            page: const HasilStudiScreenDosen(),
                            updatePage: updatePage,
                            isActive: currentPage is HasilStudiScreenDosen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Settings',
                            icon: const Icon(
                              Icons.settings,
                            ),
                            page: const PengaturanDosen(),
                            updatePage: updatePage,
                            isActive: currentPage is PengaturanDosen,
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
