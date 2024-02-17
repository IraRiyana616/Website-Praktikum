import 'package:flutter/material.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Absensi/Screen/absensi_ass.dart';

import '../../Kelas/Screen/kelas_asisten.dart';
import '../../Pengaturan/Screen/pengaturan.dart';

class AbsensiAsistenNav extends StatefulWidget {
  const AbsensiAsistenNav({super.key});

  @override
  State<AbsensiAsistenNav> createState() => _AbsensiAsistenNavState();
}

class _AbsensiAsistenNavState extends State<AbsensiAsistenNav> {
  Widget currentPage = const AbsensiAsisten(); // Halaman awal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
              width: 220,
              decoration: const BoxDecoration(
                color: Color(0xFF031F31),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      child: Image.asset(
                        "assets/images/logo_laksi.png",
                        height: 150,
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
                    //  Tampilan Navigation Main Menu
                    DashboardListTile(
                      title: 'Dashboard',
                      icon: const Icon(
                        Icons.grid_view_outlined,
                      ),
                      page: const KelasAsisten(),
                      updatePage: updatePage,
                      isActive: currentPage is KelasAsisten,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DashboardListTile(
                      title: 'Absensi',
                      icon: const Icon(
                        Icons.people,
                      ),
                      page: const KelasAsisten(),
                      updatePage: updatePage,
                      isActive: currentPage is KelasAsisten,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    DashboardListTile(
                      title: 'Hasil Studi',
                      icon: const Icon(
                        Icons.task_rounded,
                      ),
                      page: const KelasAsisten(),
                      updatePage: updatePage,
                      isActive: currentPage is KelasAsisten,
                    ),
                    //
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, bottom: 10.0, top: 15.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Asisten",
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
                    //// Asisten
                    DashboardListTile(
                      title: 'Kelas',
                      icon: const Icon(
                        Icons.book,
                      ),
                      page: const KelasAsisten(),
                      updatePage: updatePage,
                      isActive: currentPage is KelasAsisten,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DashboardListTile(
                      title: 'Mahasiswa',
                      icon: const Icon(
                        Icons.people,
                      ),
                      page: const KelasAsisten(),
                      updatePage: updatePage,
                      isActive: currentPage is KelasAsisten,
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    DashboardListTile(
                      title: 'Absensi',
                      icon: const Icon(
                        Icons.task_rounded,
                      ),
                      page: const AbsensiAsisten(),
                      updatePage: updatePage,
                      isActive: currentPage is AbsensiAsisten,
                    ),
                    const SizedBox(
                      height: 10,
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
                      height: 30.0,
                    )
                  ],
                ),
              )),
          Expanded(
            child: currentPage, // Isi Container sesuai kebutuhan
          )
        ],
      ),
    );
  }

  void updatePage(Widget newPage) {
    setState(() {
      currentPage = newPage;
    });
  }
}

class HasilStudiPage extends StatelessWidget {
  const HasilStudiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Ganti sesuai kebutuhan
      child: const Center(
        child: Text('Hasil Studi Page'),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Ganti sesuai kebutuhan
      child: const Center(
        child: Text('Login Page'),
      ),
    );
  }
}

class DashboardListTile extends StatefulWidget {
  const DashboardListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.page,
    required this.updatePage,
    this.isActive = false,
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
              color: isHovered
                  ? const Color(0xFF031F31)
                  : (widget.isActive ? Colors.white : Colors.white),
            ),
            title: Text(
              widget.title,
              style: TextStyle(
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
