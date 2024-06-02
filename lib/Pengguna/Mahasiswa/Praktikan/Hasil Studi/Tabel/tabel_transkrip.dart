import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabelTranskripNilai extends StatefulWidget {
  const TabelTranskripNilai({Key? key}) : super(key: key);

  @override
  State<TabelTranskripNilai> createState() => _TabelTranskripNilaiState();
}

class _TabelTranskripNilaiState extends State<TabelTranskripNilai> {
  List<TranskripNilai> demoTranskripNilai = [];
  List<TranskripNilai> filteredTranskripNilai = [];
  //==
  //Dropdown Button Tahun Ajaran
  String selectedKeterangan = ' Status Praktikum';
  List<String> availableKeterangans = [];
  //==
  String nim = ''; // Deklarasi variable nim di luar block if
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> fetchUserNIMFromDatabase(String userUid) async {
    try {
      if (userUid.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('akun_mahasiswa')
                .doc(userUid)
                .get();
        if (userSnapshot.exists) {
          int userNim = userSnapshot['nim'] as int;
          nim = userNim.toString(); // Ubah ke string dan simpan ke dalam nim

          QuerySnapshot<Map<String, dynamic>> querySnapshot =
              await FirebaseFirestore.instance.collection('nilaiAkhir').get();
          Set<String> status = querySnapshot.docs
              .map((doc) => doc['keterangan'].toString())
              .toSet();
          setState(() {
            availableKeterangans = [' Status Praktikum', ...status.toList()];
          });
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching user data from Firebase: $error');
      }
    }
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> transkripQuerySnapshot;

      transkripQuerySnapshot =
          await FirebaseFirestore.instance.collection('nilaiAkhir').get();

      List<TranskripNilai> data = [];

      // Pemrosesan pencocokan berdasarkan NIM dan keterangan yang dipilih
      for (var transkripDoc in transkripQuerySnapshot.docs) {
        // Menggunakan 'nim' sebagai int karena sudah diubah di fetchUserNIMFromDatabase
        int transkripNim = transkripDoc['nim'] as int;

        if (transkripNim.toString() == nim) {
          // Check kesamaan NIM dengan pengguna yang sedang login
          Map<String, dynamic> transkripData = transkripDoc.data();
          if (selectedKeterangan == ' Status Praktikum' ||
              transkripData['keterangan'] == selectedKeterangan) {
            data.add(TranskripNilai(
              kode: transkripData['kodeKelas'] ?? '',
              nama: transkripData['nama'] ?? '',
              huruf: transkripData['nilaiHuruf'] ?? '',
              keterangan: transkripData['status'] ?? '',
              nim: transkripData['nim'] ?? 0,
              akhir: (transkripData['nilaiAkhir'] ?? 0.0).toDouble(),
            ));
          }
        }
      }

      setState(() {
        demoTranskripNilai = data;
        filteredTranskripNilai = demoTranskripNilai;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data from Firebase: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Ambil tahun ajaran yang tersedia
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Dapatkan NIM pengguna yang sedang Login
      String userUid = user.uid;
      fetchUserNIMFromDatabase(userUid).then((_) {
        // Mengambil data dari Firebase
        fetchDataFromFirebase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 25.0, bottom: 20.0),
              child: Text(
                'Data Hasil Studi Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 25.0),
              child: Container(
                width: 1025.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  style: const TextStyle(color: Colors.black),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  iconSize: 24,
                  elevation: 16,
                  value: selectedKeterangan,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedKeterangan = newValue!;
                      fetchDataFromFirebase();
                    });
                  },
                  underline: Container(),
                  items: [' Status Praktikum', 'Lulus', 'Tidak Lulus']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 22.0, right: 25.0, bottom: 25.0),
              child: SizedBox(
                width: double.infinity,
                child: filteredTranskripNilai.isNotEmpty
                    ? PaginatedDataTable(
                        columnSpacing: 10,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Kode Kelas',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nilai Akhir',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nilai Huruf',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Keterangan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        source: DataSource(filteredTranskripNilai),
                        rowsPerPage:
                            calculateRowsPerPage(filteredTranskripNilai.length),
                      )
                    : const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;
    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }
}

class TranskripNilai {
  String kode;
  String nama;
  String huruf;
  String keterangan;

  int nim;
  double akhir;
  TranskripNilai({
    required this.kode,
    required this.nama,
    required this.huruf,
    required this.keterangan,
    required this.nim,
    this.akhir = 0.0,
  });
}

DataRow dataFileDataRow(TranskripNilai fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.kode)),
      DataCell(Text(getLimitedText(fileInfo.akhir.toString(), 6))),
      DataCell(Text(fileInfo.huruf)),
      DataCell(Text(fileInfo.keterangan)),
    ],
  );
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  if (index % 2 == 0) {
    return Colors.grey.shade200;
  } else {
    return Colors.transparent;
  }
}

class DataSource extends DataTableSource {
  final List<TranskripNilai> data;
  DataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index);
  }

  @override
  int get rowCount => data.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}
