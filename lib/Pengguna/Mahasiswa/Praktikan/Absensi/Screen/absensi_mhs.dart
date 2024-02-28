import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsensiPraktikan extends StatefulWidget {
  const AbsensiPraktikan({Key? key}) : super(key: key);

  @override
  State<AbsensiPraktikan> createState() => _AbsensiPraktikanState();
}

class _AbsensiPraktikanState extends State<AbsensiPraktikan> {
  final TextEditingController _kodeEditingController = TextEditingController();
  final TextEditingController _modulEditingController = TextEditingController();
  String selectedAbsen = 'Status Kehadiran';
  List<String> dropdownItems = ['Status Kehadiran', 'Hadir', 'Sakit'];

  Future<void> saveDataToFirestore() async {
    DateTime currentDate = DateTime.now();
    String formattedDate =
        '${currentDate.year}-${currentDate.month}-${currentDate.day}';
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('akun_mahasiswa')
              .doc(userUid)
              .get();

      if (userSnapshot.exists) {
        int userNim = userSnapshot['nim'];

        // Check if the user has already submitted attendance for today with the same code and module
        QuerySnapshot<Map<String, dynamic>> existingAttendanceSnapshot =
            await FirebaseFirestore.instance
                .collection('absensiMahasiswa')
                .where('nim', isEqualTo: userNim)
                .where('tanggal', isEqualTo: formattedDate)
                .where('kodeKelas', isEqualTo: _kodeEditingController.text)
                .where('modul', isEqualTo: _modulEditingController.text)
                .get();

        if (existingAttendanceSnapshot.docs.isNotEmpty) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Anda sudah melakukan absensi untuk kode kelas dan modul ini hari ini.'),
            backgroundColor: Colors.red,
          ));
        } else {
          // Check if the kodeKelas exists for the current user
          QuerySnapshot<Map<String, dynamic>> tokenKelasSnapshot =
              await FirebaseFirestore.instance
                  .collection('tokenKelas')
                  .where('nim', isEqualTo: userNim)
                  .where('kodeKelas', isEqualTo: _kodeEditingController.text)
                  .get();

          if (tokenKelasSnapshot.docs.isEmpty) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Data yang anda masukkan tidak terdapat pada database.'),
              backgroundColor: Colors.red,
            ));
            return;
          }

          Map<String, dynamic> updatedAbsenData = {
            'kodeKelas': _kodeEditingController.text,
            'modul': _modulEditingController.text,
            'nama': userSnapshot['nama'],
            'nim': userNim,
            'tanggal': formattedDate,
            'timestamp': FieldValue.serverTimestamp(),
            'keterangan': selectedAbsen
          };
          await FirebaseFirestore.instance
              .collection('absensiMahasiswa')
              .add(updatedAbsenData);

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ));

          // Update dropdownItems with the new value
          dropdownItems.add(selectedAbsen);
          setState(() {});

          _kodeEditingController.clear();
          _modulEditingController.clear();
          setState(() {
            selectedAbsen = 'Status Kehadiran';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error:$e'),
        backgroundColor: Colors.red,
      ));
      if (kDebugMode) {
        print('Error:$e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('absensiMahasiswa').get();
      for (var doc in querySnapshot.docs) {
        String keterangan = doc['keterangan'];
        dropdownItems.add(keterangan);
      }
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
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
                    'Absensi Praktikan',
                    style: GoogleFonts.quicksand(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
                  const SizedBox(
                    width: 750.0,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout,
                        color: Color(0xFF031F31),
                      )),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Log out',
                    style: GoogleFonts.quicksand(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF031F31)),
                  ),
                  const SizedBox(
                    width: 50.0,
                  )
                ],
              ),
            ),
          )),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE3E8EF),
          width: 2000,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30.0,
                ),
                Container(
                  width: 1055.0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, top: 30.0),
                        child: Text(
                          "Formulir Absensi Praktikum",
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                        child: Divider(thickness: 0.5, color: Colors.grey),
                      ),

                      /// KODE KELAS
                      Row(children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 300.0, top: 40.0),
                          child: Text("Kode Kelas",
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 30.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: SizedBox(
                            width: 300.0,
                            child: TextField(
                              controller: _kodeEditingController,
                              decoration: InputDecoration(
                                  hintText: ' Masukkan Kode Kelas',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  filled: true,
                                  fillColor: Colors.white),
                            ),
                          ),
                        )
                      ]),

                      /// Modul
                      Row(children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 300.0, top: 10.0),
                          child: Text("Modul",
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 68.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                            width: 300.0,
                            child: TextField(
                              controller: _modulEditingController,
                              decoration: InputDecoration(
                                  hintText: ' Masukkan Nama Modul',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  filled: true,
                                  fillColor: Colors.white),
                            ),
                          ),
                        )
                      ]),

                      /// KETERANGAN
                      Row(children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 300.0, top: 20.0),
                          child: Text("Keterangan",
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 25.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                              width: 300.0,
                              child: Container(
                                height: 47.0,
                                width: 980.0,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade700),
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: DropdownButton<String>(
                                  value: selectedAbsen,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedAbsen = newValue!;
                                    });
                                  },
                                  items: [
                                    'Status Kehadiran',
                                    'Hadir',
                                    'Telat',
                                    'Sakit'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem(
                                        value: value,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            value,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        ));
                                  }).toList(),
                                  style: TextStyle(color: Colors.grey.shade700),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.grey),
                                  iconSize: 24,
                                  elevation: 16,
                                  isExpanded: true,
                                  underline: Container(),
                                ),
                              )),
                        )
                      ]),

                      Padding(
                        padding: const EdgeInsets.only(left: 620.0, top: 40.0),
                        child: SizedBox(
                          height: 40.0,
                          width: 100.0,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFF3CBEA9))),
                              onPressed: () {
                                saveDataToFirestore();
                              },
                              child: Text(
                                "Simpan",
                                style: GoogleFonts.quicksand(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 60.0,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 103.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
