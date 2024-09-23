import 'package:flutter/material.dart';
import '../../../Praktikan/Dashboard/Navigasi/dashboardnav_praktikan.dart';
import '../../Asistensi Laporan/Screen/asistensi_laporan_asisten.dart';
import '../../Dashboard/Screen/dashboard_asisten.dart';
import '../../File Pengumpulan/Screen/file_pengumpulan.dart';
import '../../Hasil Studi/Screen/hasil_studi_asisten.dart';
import '../Screen/absensi_praktikum_asisten.dart';

class AbsensiPraktikumNavigasi extends StatefulWidget {
  const AbsensiPraktikumNavigasi({super.key});

  @override
  State<AbsensiPraktikumNavigasi> createState() =>
      _AbsensiPraktikumNavigasiState();
}

class _AbsensiPraktikumNavigasiState extends State<AbsensiPraktikumNavigasi> {
  late Widget currentPage;
  String currentRole = 'Asisten';

  @override
  void initState() {
    super.initState();
    currentPage = const AbsensiPraktikumAsistenScreen();
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
                width: isWideScreen ? 220 : null,
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
                                onChanged: (String? newValue) {
                                  setState(() {
                                    currentRole = newValue!;
                                    if (currentRole == 'Asisten') {
                                      currentPage = const DashboardAsisten();
                                    } else {
                                      //== Navigator Untuk Asisten ==//
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DashboardNavigasiPraktikan(),
                                        ),
                                      );
                                    }
                                  });
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
                            page: const DashboardAsisten(),
                            updatePage: updatePage,
                            isActive: currentPage is DashboardAsisten,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Absensi',
                            icon: const Icon(
                              Icons.people,
                            ),
                            page: const AbsensiPraktikumAsistenScreen(),
                            updatePage: updatePage,
                            isActive:
                                currentPage is AbsensiPraktikumAsistenScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'File Pengumpulan',
                            icon: const Icon(
                              Icons.file_copy,
                            ),
                            page: const FilePengumpulanScreen(),
                            updatePage: updatePage,
                            isActive: currentPage is FilePengumpulanScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Asistensi Laporan',
                            icon: const Icon(
                              Icons.archive,
                            ),
                            page: const AsistensiLaporanScreen(),
                            updatePage: updatePage,
                            isActive: currentPage is AsistensiLaporanScreen,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DashboardListTile(
                            title: 'Hasil Studi',
                            icon: const Icon(
                              Icons.score,
                            ),
                            page: const HasilStudiAsistensi(),
                            updatePage: updatePage,
                            isActive: currentPage is HasilStudiAsistensi,
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
