import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TabelPenulisanLaporan extends StatefulWidget {
  const TabelPenulisanLaporan({super.key});

  @override
  State<TabelPenulisanLaporan> createState() => _TabelPenulisanLaporanState();
}

class _TabelPenulisanLaporanState extends State<TabelPenulisanLaporan> {
  List<NilaiLaporan> demoNilaiLaporan = [];
  List<NilaiLaporan> filteredNilaiLaporan = [];

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      // Fetching data from 'data_kelas'
      QuerySnapshot dataKelasSnapshot =
          await FirebaseFirestore.instance.collection('dataKelas').get();

      // Fetching data from 'token_kelas'
      QuerySnapshot tokenKelasSnapshot =
          await FirebaseFirestore.instance.collection('tokenKelas').get();

      // Grouping token_kelas data based on 'kode_kelas'
      Map<String, List<QueryDocumentSnapshot>> groupedTokenData = {};
      for (var tokenDoc in tokenKelasSnapshot.docs) {
        String kodeKelas = tokenDoc['kodeKelas'];
        groupedTokenData.putIfAbsent(kodeKelas, () => []);
        groupedTokenData[kodeKelas]!.add(tokenDoc);
      }

      // Connecting data based on 'kode_kelas'
      for (QueryDocumentSnapshot dataKelasDoc in dataKelasSnapshot.docs) {
        String kodeKelas = dataKelasDoc['kodeKelas'];

        // Finding all token_kelas that match kode_kelas
        List<QueryDocumentSnapshot>? tokenKelasDocs =
            groupedTokenData[kodeKelas];

        if (tokenKelasDocs != null && tokenKelasDocs.isNotEmpty) {
          // Adding data to nilai_laporan
          for (QueryDocumentSnapshot tokenKelasDoc in tokenKelasDocs) {
            int nim = int.parse(tokenKelasDoc['nim'].toString());
            String nama = tokenKelasDoc['nama'];

            // Checking if data already exists in demoNilaiLaporan
            bool dataExists = demoNilaiLaporan
                .any((data) => data.nim == nim && data.kode == kodeKelas);

            if (!dataExists) {
              // Creating NilaiLaporan
              NilaiLaporan nilaiLaporan = NilaiLaporan(
                nim: nim,
                nama: nama,
                kode: kodeKelas,
                nilai1: 0.0,
                nilai2: 0.0,
                nilai3: 0.0,
                rata: 0.0,
              );
              // Adding nilai laporan to demoNilaiLaporan
              setState(() {
                demoNilaiLaporan.add(nilaiLaporan);
                filteredNilaiLaporan = List.from(demoNilaiLaporan);
              });

              // Adding data to Firestore 'nilai_laporan'
              await addDataToFirestore(nilaiLaporan);
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> addDataToFirestore(NilaiLaporan nilaiLaporan) async {
    try {
      // Checking if data already exists in Firestore
      bool firestoreDataExists = await checkFirestoreDataExists(nilaiLaporan);

      if (!firestoreDataExists) {
        // Adding data to Firestore 'nilai_laporan'
        await FirebaseFirestore.instance.collection('nilai_laporan').add({
          'nim': nilaiLaporan.nim,
          'nama': nilaiLaporan.nama,
          'kode': nilaiLaporan.kode,
          'nilai1': nilaiLaporan.nilai1,
          'nilai2': nilaiLaporan.nilai2,
          'nilai3': nilaiLaporan.nilai3,
          'rata': calculateAverage(nilaiLaporan),
        });
        // Update the average in the local data list
        setState(() {
          int index = demoNilaiLaporan.indexWhere((data) =>
              data.nim == nilaiLaporan.nim && data.kode == nilaiLaporan.kode);
          if (index != -1) {
            demoNilaiLaporan[index].rata = calculateAverage(nilaiLaporan);
            filteredNilaiLaporan = List.from(demoNilaiLaporan);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding data to Firestore: $e');
      }
    }
  }

  double calculateAverage(NilaiLaporan nilaiLaporan) {
    return (nilaiLaporan.nilai1 + nilaiLaporan.nilai2 + nilaiLaporan.nilai3) /
        3;
  }

  Future<bool> checkFirestoreDataExists(NilaiLaporan nilaiLaporan) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('nilai_laporan')
          .where('nim', isEqualTo: nilaiLaporan.nim)
          .where('kode', isEqualTo: nilaiLaporan.kode)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Firestore data existence: $e');
      }
      return false;
    }
  }

  Future<void> getDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('nilai_laporan').get();
      setState(() {
        demoNilaiLaporan = querySnapshot.docs
            .map((DocumentSnapshot doc) => NilaiLaporan(
                nim: doc['nim'],
                nama: doc['nama'],
                kode: doc['kode'],
                nilai1: doc['nilai1'].toDouble(),
                nilai2: doc['nilai2'].toDouble(),
                nilai3: doc['nilai3'].toDouble(),
                rata: doc['rata'].toDouble()))
            .toList();
        filteredNilaiLaporan = demoNilaiLaporan;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  void filterData(String query) {
    setState(() {
      filteredNilaiLaporan = demoNilaiLaporan
          .where(
              (data) => (data.kode.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
  }

  void editNilai(NilaiLaporan nilai) {
    TextEditingController nilai1Controller =
        TextEditingController(text: nilai.nilai1.toString());
    TextEditingController nilai2Controller =
        TextEditingController(text: nilai.nilai2.toString());
    TextEditingController nilai3Controller =
        TextEditingController(text: nilai.nilai3.toString());
    TextEditingController nilaiRataController =
        TextEditingController(text: _hitungRataRata(nilai).toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Nilai Laporan'),
          content: SizedBox(
            height: 220.0,
            width: 150.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TextField untuk mengedit nilai1
                TextField(
                  controller: nilai1Controller,
                  onChanged: (newValue) {
                    // Perbarui nilai1 saat pengguna mengubah nilai
                    setState(() {
                      nilai.nilai1 = double.parse(newValue);
                      // Perbarui nilai rata-rata
                      nilaiRataController.text =
                          _hitungRataRata(nilai).toString();
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Nilai 1'),
                ),
                // TextField untuk mengedit nilai2
                TextField(
                  controller: nilai2Controller,
                  onChanged: (newValue) {
                    // Perbarui nilai2 saat pengguna mengubah nilai
                    setState(() {
                      nilai.nilai2 = double.parse(newValue);
                      // Perbarui nilai rata-rata
                      nilaiRataController.text =
                          _hitungRataRata(nilai).toString();
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Nilai 2'),
                ),
                // TextField untuk mengedit nilai3
                TextField(
                  controller: nilai3Controller,
                  onChanged: (newValue) {
                    // Perbarui nilai3 saat pengguna mengubah nilai
                    setState(() {
                      nilai.nilai3 = double.parse(newValue);
                      // Perbarui nilai rata-rata
                      nilaiRataController.text =
                          _hitungRataRata(nilai).toString();
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Nilai 3'),
                ),
                // TextField untuk menampilkan nilai rata-rata (read-only)
                TextField(
                  controller: nilaiRataController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(labelText: 'Nilai Rata-rata'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Mencari dokumen dengan NIM yang sama
                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                      .collection('nilai_laporan')
                      .where('nim', isEqualTo: nilai.nim)
                      .get();
                  // Memperbarui nilai pada dokumen yang ditemukan
                  if (querySnapshot.docs.isNotEmpty) {
                    await querySnapshot.docs[0].reference.update({
                      'nilai1': nilai.nilai1,
                      'nilai2': nilai.nilai2,
                      'nilai3': nilai.nilai3,
                      'rata': _hitungRataRata(nilai),
                    });
                  }
                  // Perbarui tampilan jika diperlukan
                  getDataFromFirestore();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error updating data: $e');
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  double _hitungRataRata(NilaiLaporan nilai) {
    // Hitung nilai rata-rata
    return (nilai.nilai1 + nilai.nilai2 + nilai.nilai3) / 3;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredNilaiLaporan.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: Text(
                            "NIM",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Nama",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Nilai 1",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Nilai 2",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Nilai 3",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Rata-Rata",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Aksi",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(
                          data: filteredNilaiLaporan,
                          context: context,
                          editNilai: editNilai),
                      rowsPerPage:
                          calculateRowsPerPage(filteredNilaiLaporan.length),
                    )
                  : const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 50;
    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class NilaiLaporan {
  String kode;
  int nim;
  String nama;
  double nilai1;
  double nilai2;
  double nilai3;
  double rata;
  NilaiLaporan({
    required this.nim,
    required this.nama,
    required this.kode,
    this.nilai1 = 0.0,
    this.nilai2 = 0.0,
    this.nilai3 = 0.0,
    this.rata = 0.0,
  });
}

DataRow dataFileDataRow(
    NilaiLaporan fileInfo, int index, VoidCallback editCallback) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(Text(fileInfo.nim.toString())),
      DataCell(Text(getLimitedText(fileInfo.nama, 15))),

      DataCell(Text(fileInfo.nilai1.toString())),
      DataCell(Text(fileInfo.nilai2.toString())),
      DataCell(Text(fileInfo.nilai3.toString())),
      DataCell(Text(getLimitedText(fileInfo.rata.toString(), 6))),
      // DataCell(Text(fileInfo.rata.toString())),
      DataCell(
        // Tambahkan tombol untuk mengedit nilai
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Panggil fungsi editCallback saat tombol di tekan
            editCallback();
          },
        ),
      ),
    ],
  );
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

class DataSource extends DataTableSource {
  final List<NilaiLaporan> data;
  final BuildContext context;
  final void Function(NilaiLaporan) editNilai;
  DataSource({
    required this.data,
    required this.context,
    required this.editNilai,
  });
  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, () {
      // Panggil fungsi editNilai saat tombol edit di tekan
      editNilai(fileInfo);
    });
  }

  @override
  int get rowCount => data.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}
