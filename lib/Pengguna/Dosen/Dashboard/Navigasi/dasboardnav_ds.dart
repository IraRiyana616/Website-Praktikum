import 'package:flutter/material.dart';
import 'package:laksi/Pengguna/Dosen/Dashboard/Screen/dashboard_ds.dart';
import 'package:laksi/Pengguna/Dosen/Evaluasi/Screen/evaluasi_ds.dart';
import 'package:laksi/Pengguna/Dosen/Hasil%20Studi/Screen/hasilstudi_ds.dart';
import 'package:laksi/Pengguna/Dosen/Pengaturan/Screen/pengaturan_ds.dart';
import '../../Absensi/Screen/absensi_ds.dart';

class DashboardDosenNav extends StatefulWidget {
  const DashboardDosenNav({super.key});

  @override
  State<DashboardDosenNav> createState() => _DashboardDosenNavState();
}

class _DashboardDosenNavState extends State<DashboardDosenNav> {
  Widget currentPage = const DashboardDosen();
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
            child: Column(
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
                DashboardListTile(
                  title: 'Dashboard',
                  icon: const Icon(
                    Icons.grid_view_outlined,
                  ),
                  page: const DashboardDosen(),
                  updatePage: updatePage,
                  isActive: currentPage is DashboardDosen,
                ),
                const SizedBox(
                  height: 10,
                ),
                DashboardListTile(
                  title: 'Absensi',
                  icon: const Icon(
                    Icons.people,
                  ),
                  page: const AbsensiDosen(),
                  updatePage: updatePage,
                  isActive: currentPage is AbsensiDosen,
                ),
                const SizedBox(
                  height: 10,
                ),
                DashboardListTile(
                  title: 'Hasil Studi',
                  icon: const Icon(
                    Icons.score,
                  ),
                  page: const HasilStudiDosen(),
                  updatePage: updatePage,
                  isActive: currentPage is HasilStudiDosen,
                ),
                const SizedBox(
                  height: 10,
                ),
                DashboardListTile(
                  title: 'Evaluasi',
                  icon: const Icon(
                    Icons.fact_check_sharp,
                  ),
                  page: const EvaluasiDosen(),
                  updatePage: updatePage,
                  isActive: currentPage is EvaluasiDosen,
                ),
                const SizedBox(
                  height: 10,
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
                  height: 10,
                ),
              ],
            ),
          ),
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
