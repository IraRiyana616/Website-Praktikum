import 'package:flutter/material.dart';
import '../../../../../../Mahasiswa/Asisten/Pengaturan/Screen/pengaturan.dart';
import '../../Absensi/Screen/absensi_praktikan.dart';
import '../../Asistensi/Screen/asistensi_praktikan.dart';
import '../../Dashboard/Screen/dashboard_praktikan.dart';
import '../../Hasil Studi/hasil_studi_praktikan.dart';
import '../Screen/pengumpulan_praktikan.dart';

class FilePengumpulanNavigasi extends StatefulWidget {
  const FilePengumpulanNavigasi({super.key});

  @override
  State<FilePengumpulanNavigasi> createState() =>
      _FilePengumpulanNavigasiState();
}

class _FilePengumpulanNavigasiState extends State<FilePengumpulanNavigasi> {
  late Widget currentPage;
  String currentRole = 'Praktikan';
  @override
  void initState() {
    super.initState();
    currentPage = const FilePengumpulanPraktikan();
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
                                onChanged: (String? newValue) {
                                  setState(() {
                                    currentRole = newValue!;
                                    if (currentRole == 'Praktikan') {
                                      currentPage =
                                          const DashboardPraktikanScreen();
                                    } else {
                                      //== Navigator ==//
                                      currentPage = const Pengaturan();
                                    }
                                  });
                                },
                              ),
                            ],
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
