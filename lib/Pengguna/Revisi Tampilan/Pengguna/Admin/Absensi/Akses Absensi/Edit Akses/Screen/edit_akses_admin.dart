import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Revisi%20Tampilan/Pengguna/Admin/Absensi/Akses%20Absensi/Edit%20Akses/Tabel/tabel_edit_akses_admin.dart';
import '../../../Navigasi/absensinav_admin.dart';

class EditAksesScreenAdmin extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  final String kodeAsisten;
  const EditAksesScreenAdmin(
      {super.key,
      required this.kodeKelas,
      required this.mataKuliah,
      required this.kodeAsisten});

  @override
  State<EditAksesScreenAdmin> createState() => _EditAksesScreenAdminState();
}

class _EditAksesScreenAdminState extends State<EditAksesScreenAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70.0),
            child: AppBar(
              backgroundColor: const Color(0xFFF7F8FA),
              automaticallyImplyLeading: false,
              leading: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AbsensiPraktikumNav(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  )),
              title: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      widget.mataKuliah,
                      style: GoogleFonts.quicksand(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
                    const SizedBox(
                      width: 700.0,
                    ),
                    Text(
                      'Admin',
                      style: GoogleFonts.quicksand(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      width: 30.0,
                    )
                  ],
                ),
              ),
            )),
        body: LayoutBuilder(builder: (context, constraints) {
          return Container(
            color: const Color(0xFFE3E8EF),
            constraints: const BoxConstraints.expand(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, top: 15.0, right: 15.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1350.0),
                      color: Colors.white,
                      child: Column(
                        children: [
                          TabelAksesAbsensiMahasiswa(
                            kodeAsisten: widget.kodeAsisten,
                            kodeKelas: widget.kodeKelas,
                            mataKuliah: widget.mataKuliah,
                          ),
                          const SizedBox(
                            height: 30.0,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }));
  }
}
