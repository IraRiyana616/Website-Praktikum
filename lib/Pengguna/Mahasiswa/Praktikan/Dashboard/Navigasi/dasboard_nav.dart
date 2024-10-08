import 'package:flutter/material.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Hasil%20Studi/Screen/hasilstudi_ass.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Absensi/Screen/absensi_mhs.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Dashboard/Screen/dashboard_mhs.dart';
import 'package:laksi/Pengguna/Mahasiswa/Praktikan/Hasil%20Studi/Screen/transkrip.dart';
import '../../../Asisten/Absensi/Screen/absensi_ass.dart';
import '../../../Asisten/Jadwal/Screen/jadwal_asisten.dart';
import '../../../Asisten/Kelas/Screen/kelas_asisten.dart';
import '../../../Asisten/Pengaturan/Screen/pengaturan.dart';

class DashboardPraktikanNav extends StatefulWidget {
  const DashboardPraktikanNav({super.key});

  @override
  State<DashboardPraktikanNav> createState() => _DashboardPraktikanNavState();
}

class _DashboardPraktikanNavState extends State<DashboardPraktikanNav> {
  Widget currentPage = const DashboardPraktikan(); // Halaman awal

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
                      child: Image.asset("assets/images/logo_laksi.png",
                          height: 150),
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
                      page: const DashboardPraktikan(),
                      updatePage: updatePage,
                      isActive: currentPage is DashboardPraktikan,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DashboardListTile(
                      title: 'Absensi',
                      icon: const Icon(
                        Icons.people,
                      ),
                      page: const AbsensiPraktikan(),
                      updatePage: updatePage,
                      isActive: currentPage is AbsensiPraktikan,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    DashboardListTile(
                      title: 'Hasil Studi',
                      icon: const Icon(
                        Icons.score,
                      ),
                      page: const TranskripNilai(),
                      updatePage: updatePage,
                      isActive: currentPage is TranskripNilai,
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
                      title: 'Jadwal',
                      icon: const Icon(
                        Icons.calendar_month,
                      ),
                      page: const JadwalPraktikumAsisten(),
                      updatePage: updatePage,
                      isActive: currentPage is JadwalPraktikumAsisten,
                    ),
                    const SizedBox(
                      height: 10.0,
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
                      title: 'Hasil Studi',
                      icon: const Icon(
                        Icons.score,
                      ),
                      page: const HasilStudiAsisten(),
                      updatePage: updatePage,
                      isActive: currentPage is HasilStudiAsisten,
                    ),
                    const SizedBox(
                      height: 10.0,
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
