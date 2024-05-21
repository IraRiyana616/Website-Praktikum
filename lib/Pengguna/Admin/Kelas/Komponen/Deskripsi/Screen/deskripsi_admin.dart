import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laksi/Pengguna/Admin/Kelas/Komponen/Asistensi/asisten_admin.dart';
import '../../../../../Dosen/Dashboard/Komponen/Deskripsi/Tabel/tabel_modul.dart';
import '../../../Navigasi/kelas_admin_nav.dart';
import '../../Pengumpulan/Tugas/tugas_admin.dart';

class DeskripsiKelasAdmin extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;

  const DeskripsiKelasAdmin(
      {Key? key, required this.kodeKelas, required this.mataKuliah})
      : super(key: key);

  @override
  State<DeskripsiKelasAdmin> createState() => _DeskripsiKelasAdminState();
}

class _DeskripsiKelasAdminState extends State<DeskripsiKelasAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const KelasAdminNav()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          backgroundColor: const Color(0xFFF7F8FA),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    widget.mataKuliah,
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 400.0),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    'Admin',
                    style: GoogleFonts.quicksand(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(width: 30.0)
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('deskripsiKelas')
            .where('kodeKelas', isEqualTo: widget.kodeKelas)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error:${snapshot.error}'),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Column(
              children: [
                Image.asset(
                  'assets/images/404.png',
                  fit: BoxFit.cover,
                ),
                Text(
                  'Data tidak ditemukan',
                  style: GoogleFonts.quicksand(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                )
              ],
            ));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Container(
                  color: const Color(0xFFE3E8EF),
                  width: 2000.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 0.5,
                                    color: Colors.grey,
                                  ),
                                ),
                                height: 320.0,
                                width: double.infinity,
                                child: Image.asset(
                                  'assets/images/kelas.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Row(
                                children: [
                                  //Deskripsi Kelas
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 38.0,
                                      left: 95.0,
                                    ),
                                    child: Text(
                                      'Deskripsi',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  //== Pengumpulan Pre-Test, Latihan dan Tugas ==//
                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 50.0,
                                        top: 38.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  KumpulUjianPemahamanAdmin(
                                                kodeKelas: widget.kodeKelas,
                                                mataKuliah: widget.mataKuliah,
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(0.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));

                                                return SlideTransition(
                                                  position:
                                                      animation.drive(tween),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Text(
                                            'Pengumpulan',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //== Asistensi Laporan ==//

                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 50.0,
                                        top: 38.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  DataPraktikanAsistensiAdmin(
                                                kodeKelas: widget.kodeKelas,
                                                mataKuliah: widget.mataKuliah,
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(0.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));

                                                return SlideTransition(
                                                  position:
                                                      animation.drive(tween),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Text(
                                            'Asisten',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  top: 10.0,
                                  left: 45.0,
                                  right: 45.0,
                                ),
                                child: Divider(
                                  thickness: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Deskripsi Kelas
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 95.0,
                                    ),
                                    child: SizedBox(
                                      height: 350.0,
                                      width: 730.0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Deskripsi Kelas',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 20.0,
                                            ),
                                            child: Text(
                                              '${data['deskripsi_kelas'] ?? 'Not available'}',
                                              style: GoogleFonts.quicksand(
                                                fontSize: 15.0,
                                                height: 2.5,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //Peralatan Belajar
                                  SizedBox(
                                    width: 400.0,
                                    height: 350.0,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //Peralatan Belajar
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Peralatan Belajar',
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: Text(
                                              'Peralatan yang dibutuhkan :',
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 15.0),
                                            ),
                                          ),

                                          //Sistem Operasi
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 30.0,
                                                  width: 30.0,
                                                  child: Image.asset(
                                                      'assets/images/os.png'),
                                                ),
                                                const SizedBox(
                                                  width: 15.0,
                                                ),
                                                Text(
                                                  'Perangkat Lunak',
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: SizedBox(
                                              width: 320.0,
                                              child: Text(
                                                '${data['perangkatLunak'] ?? 'Not available'}',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 15.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                          //Prosesor
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 30.0,
                                                  width: 30.0,
                                                  child: Image.asset(
                                                      'assets/images/processor.png'),
                                                ),
                                                const SizedBox(
                                                  width: 15.0,
                                                ),
                                                Text(
                                                  'Perangkat Keras',
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: SizedBox(
                                              width: 320.0,
                                              child: Text(
                                                '${data['perangkatKeras'] ?? 'Not available'}',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 15.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 80.0,
                              ),
                              //Silabus
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Silabus',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'Materi yang akan dipelajari',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16.0),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 35.0,
                                    )
                                  ],
                                ),
                              ),

                              TabelSilabusPraktikumDosen(
                                  kodeKelas: widget.kodeKelas),

                              const SizedBox(height: 50.0)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
