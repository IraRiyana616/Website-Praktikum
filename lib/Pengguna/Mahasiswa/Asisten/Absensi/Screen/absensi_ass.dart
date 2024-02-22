import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsensiAsisten extends StatefulWidget {
  const AbsensiAsisten({super.key});

  @override
  State<AbsensiAsisten> createState() => _AbsensiAsistenState();
}

class _AbsensiAsistenState extends State<AbsensiAsisten> {
  final TextEditingController _nimEditingController = TextEditingController();
  final TextEditingController _kodeEditingController = TextEditingController();
  final TextEditingController _modulEditingController = TextEditingController();
  String selectedAbsen = 'Status Kehadiran';
  List<String> dropdownItems = [
    'Status Kehadiran',
    'Hadir',
    'Tanpa Keterangan',
    'Sakit'
  ];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void saveDataToFirestore() async {
    DateTime currentDate = DateTime.now();
    String formattedDate =
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";

    // Check if an entry for the same class code on the current date already exists
    QuerySnapshot existingEntry = await _firestore
        .collection('absensi_asisten')
        .where('kode_kelas', isEqualTo: _kodeEditingController.text)
        .where('date', isEqualTo: formattedDate)
        .get();

    if (existingEntry.docs.isEmpty) {
      // If no entry exists, add the new entry
      await _firestore.collection('absensi_asisten').add({
        'kode_kelas': _kodeEditingController.text,
        'nim': _nimEditingController.text,
        'modul': _modulEditingController.text,
        'keterangan': selectedAbsen,
        'timestamp': FieldValue.serverTimestamp(),
        'date': formattedDate,
      });

      _kodeEditingController.clear();
      _nimEditingController.clear();
      _modulEditingController.clear();
      setState(() {
        selectedAbsen = 'Status Kehadiran';
      });
      // Show SnackBar on successful data save
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // If an entry already exists, show an error or handle it accordingly
      // For example, you can display a SnackBar with an error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data telah terdapat pada database'),
          backgroundColor: Colors.red,
        ),
      );
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
          await _firestore.collection('absensi_asisten').get();
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
                    "Absensi Praktikum",
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 750.0,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, color: Color(0xFF031F31))),
                const SizedBox(width: 10.0),
                Text('Log out',
                    style: GoogleFonts.quicksand(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF031F31))),
                const SizedBox(
                  width: 50.0,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFE3E8EF),
        width: 2000,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
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
                        "Formulir Absensi",
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
                        padding: const EdgeInsets.only(left: 300.0, top: 40.0),
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
                                hintText: ' Masukkan Kode Kelas Asisten',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                        ),
                      )
                    ]),

                    /// NIM
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 300.0, top: 10.0),
                        child: Text("NIM",
                            style: GoogleFonts.quicksand(
                                fontSize: 16.0, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 85.0),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: SizedBox(
                          width: 300.0,
                          child: TextField(
                            controller: _nimEditingController,
                            decoration: InputDecoration(
                                hintText: ' Masukkan NIM',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                        ),
                      )
                    ]),

                    /// Modul
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 300.0, top: 10.0),
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
                                    borderRadius: BorderRadius.circular(10.0)),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                        ),
                      )
                    ]),

                    /// KETERANGAN
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 300.0, top: 20.0),
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
                                  'Tanpa Keterangan',
                                  'Sakit'
                                ].map<DropdownMenuItem<String>>((String value) {
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
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
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
                height: 30.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
