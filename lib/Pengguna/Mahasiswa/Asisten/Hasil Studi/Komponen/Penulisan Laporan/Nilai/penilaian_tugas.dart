import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PenilaianTugasAsisten extends StatefulWidget {
  const PenilaianTugasAsisten({super.key});

  @override
  State<PenilaianTugasAsisten> createState() => _PenilaianTugasAsistenState();
}

class _PenilaianTugasAsistenState extends State<PenilaianTugasAsisten> {
  List<NilaiTugas> demoNilaiTugas = [];
  List<NilaiTugas> filteredNilaiTugas = [];

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      //Fetching data dari 'dataKelas'
      QuerySnapshot dataKelasSnapshot =
          await FirebaseFirestore.instance.collection('dataKelas').get();

      //Fetching data dari 'tokenKelas'
      QuerySnapshot tokenKelasSnapshot =
          await FirebaseFirestore.instance.collection('tokenKelas').get();

      //Grouping 'tokenKelas' yang berdasarkan 'kodeKelas'
      Map<String, List<QueryDocumentSnapshot>> groupedTokenData = {};
      for (var tokenDoc in tokenKelasSnapshot.docs) {
        String kodeKelas = tokenDoc['kodeKelas'];
        groupedTokenData.putIfAbsent(kodeKelas, () => []);
        groupedTokenData[kodeKelas]!.add(tokenDoc);
      }

      //Menghubungkan data dengan 'kodeKelas'
      for (QueryDocumentSnapshot dataKelasDoc in dataKelasSnapshot.docs) {
        String kodeKelas = dataKelasDoc['kodeKelas'];

        //Finding all tokenKelas that match kodeKelas
        List<QueryDocumentSnapshot>? tokenKelasDocs =
            groupedTokenData[kodeKelas];
        if (tokenKelasDocs != null && tokenKelasDocs.isNotEmpty) {
          //Menambahkan data ke nilai tugas
          for (QueryDocumentSnapshot tokenKelasDoc in tokenKelasDocs) {
            int nim = int.parse(tokenKelasDoc['nim'].toString());
            String nama = tokenKelasDoc['nama'];

            //Checking if data already exists in demoNilaiTugas
            bool dataExists = demoNilaiTugas
                .any((data) => data.nim == nim && data.kode == kodeKelas);

            if (!dataExists) {
              //Membuat Nilai Tugas
              NilaiTugas nilaiTugas = NilaiTugas(
                  nim: nim,
                  nama: nama,
                  kode: kodeKelas,
                  //
                  //Nilai Percobaan
                  percobaan: 0.0,
                  percobaan2: 0.0,
                  percobaan3: 0.0,
                  percobaan4: 0.0,
                  percobaan5: 0.0,
                  //
                  //Nilai Latihan
                  // latihan: 0.0,
                  // latihan2: 0.0,
                  // latihan3: 0.0,
                  // latihan4: 0.0,
                  // latihan5: 0.0,
                  rata: 0.0);
              //Menambahkan nilai tugas ke demoNilaiTugas
              setState(() {
                demoNilaiTugas.add(nilaiTugas);
                filteredNilaiTugas = List.from(demoNilaiTugas);
              });
              //Menambahkan data ke Firestore 'nilaiTugas'
              await addDataToFirestore(nilaiTugas);
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

  Future<void> addDataToFirestore(NilaiTugas nilaiTugas) async {
    try {
      //Mengecheck data jika sudah ada di Firestore
      bool firestoreDataExists = await checkFirestoreDataExists(nilaiTugas);

      if (!firestoreDataExists) {
        //Menambahkan data ke Firestore 'nilaiPercobaan'
        await FirebaseFirestore.instance.collection('nilaiPercobaan').add({
          'nim': nilaiTugas.nim,
          'nama': nilaiTugas.nama,
          'kodeKelas': nilaiTugas.kode,
          'percobaan': nilaiTugas.percobaan,
          'percobaan2': nilaiTugas.percobaan2,
          'percobaan3': nilaiTugas.percobaan3,
          'percobaan4': nilaiTugas.percobaan4,
          'percobaan5': nilaiTugas.percobaan5,
          'rata': calculateAverage(nilaiTugas)
        });
        //Mengupdate nilai rata-rata di data list
        setState(() {
          int index = demoNilaiTugas.indexWhere((data) =>
              data.nim == nilaiTugas.nim && data.kode == nilaiTugas.kode);
          if (index != -1) {
            demoNilaiTugas[index].rata = calculateAverage(nilaiTugas);
            filteredNilaiTugas = List.from(demoNilaiTugas);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding data to Firestore: $e');
      }
    }
  }

  double calculateAverage(NilaiTugas nilaiTugas) {
    return (((nilaiTugas.percobaan * 0.2) +
                (nilaiTugas.percobaan2 * 0.2) +
                (nilaiTugas.percobaan3 * 0.2) +
                (nilaiTugas.percobaan4 * 0.2) +
                (nilaiTugas.percobaan5 * 0.2)) /
            5) *
        0.05;
  }

  Future<bool> checkFirestoreDataExists(NilaiTugas nilaiTugas) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('nilaiPercobaan')
          .where('nim', isEqualTo: nilaiTugas.nim)
          .where('kode', isEqualTo: nilaiTugas.kode)
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
          await FirebaseFirestore.instance.collection('nilaiPercobaan').get();
      setState(() {
        demoNilaiTugas = querySnapshot.docs
            .map((DocumentSnapshot doc) => NilaiTugas(
                nim: doc['nim'],
                nama: doc['nama'],
                kode: doc['kodeKelas'],
                percobaan: doc['percobaan'].toDouble(),
                percobaan2: doc['percobaan2'].toDouble(),
                percobaan3: doc['percobaan3'].toDouble(),
                percobaan4: doc['percobaan4'].toDouble(),
                percobaan5: doc['percobaan5'].toDouble(),
                rata: doc['rata'].toDouble()))
            .toList();
        filteredNilaiTugas = demoNilaiTugas;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  void filterData(String query) {
    setState(() {
      filteredNilaiTugas = demoNilaiTugas
          .where(
              (data) => (data.kode.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
  }

  void editNilai(NilaiTugas nilai) {
    TextEditingController percobaanController =
        TextEditingController(text: nilai.percobaan.toString());
    TextEditingController percobaan2Controller =
        TextEditingController(text: nilai.percobaan2.toString());
    TextEditingController percobaan3Controller =
        TextEditingController(text: nilai.percobaan3.toString());
    TextEditingController percobaan4Controller =
        TextEditingController(text: nilai.percobaan4.toString());
    TextEditingController percobaan5Controller =
        TextEditingController(text: nilai.percobaan5.toString());
    TextEditingController nilaiRataController =
        TextEditingController(text: _hitungRataRata(nilai).toString());

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formulir Nilai Percobaan',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Divider(
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
            content: SizedBox(
              height: 230.0,
              width: 350.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Nilai Percobaan, Nilai Percobaan 2, Nilai Percobaan 3
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Nilai Percobaan 1
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: SizedBox(
                              width: 150.0,
                              child: TextField(
                                controller: percobaanController,
                                onChanged: (newValue) {
                                  //Perbaharui nilai percobaan saat pengguna mengubah nilai
                                  setState(() {
                                    nilai.percobaan = double.parse(newValue);
                                    //Perbaharui nilai rata-rata
                                    nilaiRataController.text =
                                        _hitungRataRata(nilai).toString();
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Nilai Percobaan',
                                ),
                              ),
                            ),
                          ),
                          //Nilai Percobaan 2
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              width: 150.0,
                              child: TextField(
                                controller: percobaan2Controller,
                                onChanged: (newValue) {
                                  //Perbaharui nilai percobaan saat pengguna mengubah nilai
                                  setState(() {
                                    nilai.percobaan2 = double.parse(newValue);
                                    //Perbaharui nilai rata-rata
                                    nilaiRataController.text =
                                        _hitungRataRata(nilai).toString();
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Nilai Percobaan 2',
                                ),
                              ),
                            ),
                          ),
                          //Nilai Percobaan 3
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              width: 150.0,
                              child: TextField(
                                controller: percobaan3Controller,
                                onChanged: (newValue) {
                                  //Perbaharui nilai percobaan saat pengguna mengubah nilai
                                  setState(() {
                                    nilai.percobaan3 = double.parse(newValue);
                                    //Perbaharui nilai rata-rata
                                    nilaiRataController.text =
                                        _hitungRataRata(nilai).toString();
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Nilai Percobaan 3',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //Nilai Percobaan 4, Nilai Percobaan 5, Nilai Rata-rata
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Nilai Percobaan 4
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: SizedBox(
                              width: 150.0,
                              child: TextField(
                                controller: percobaan4Controller,
                                onChanged: (newValue) {
                                  //Perbaharui nilai percobaan saat pengguna mengubah nilai
                                  setState(() {
                                    nilai.percobaan4 = double.parse(newValue);
                                    //Perbaharui nilai rata-rata
                                    nilaiRataController.text =
                                        _hitungRataRata(nilai).toString();
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Nilai Percobaan 4',
                                ),
                              ),
                            ),
                          ),
                          //Nilai Percobaan 5
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              width: 150.0,
                              child: TextField(
                                controller: percobaan5Controller,
                                onChanged: (newValue) {
                                  //Perbaharui nilai percobaan saat pengguna mengubah nilai
                                  setState(() {
                                    nilai.percobaan5 = double.parse(newValue);
                                    //Perbaharui nilai rata-rata
                                    nilaiRataController.text =
                                        _hitungRataRata(nilai).toString();
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Nilai Percobaan 5',
                                ),
                              ),
                            ),
                          ),
                          //Nilai Rata-Rata
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                                width: 150.0,
                                child: TextField(
                                  controller: nilaiRataController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Nilai Rata-rata'),
                                )),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
                child: TextButton(
                    onPressed: () async {
                      try {
                        //Mencari dokumen dengan Nim yang sama
                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('nilaiPercobaan')
                            .where('nim', isEqualTo: nilai.nim)
                            .get();

                        //Memperbaharui nilai pada dokumen yang ditemukan
                        if (querySnapshot.docs.isNotEmpty) {
                          await querySnapshot.docs[0].reference.update({
                            'percobaan': nilai.percobaan,
                            'percobaan2': nilai.percobaan2,
                            'percobaan3': nilai.percobaan3,
                            'percobaan4': nilai.percobaan4,
                            'percobaan5': nilai.percobaan5,
                            'rata': _hitungRataRata(nilai)
                          });
                        }

                        //Perbaharui tampilan jika diperlukan
                        getDataFromFirestore();
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error updating data: $e');
                        }
                      }
                    },
                    child: const Text('Simpan')),
              )
            ],
          );
        });
  }

  double _hitungRataRata(NilaiTugas nilai) {
    return ((nilai.percobaan * 0.2) +
            (nilai.percobaan2 * 0.2) +
            (nilai.percobaan3 * 0.2) +
            (nilai.percobaan4 * 0.2) +
            (nilai.percobaan5 * 0.2) / 5) *
        0.05;
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
                child: filteredNilaiTugas.isNotEmpty
                    ? PaginatedDataTable(
                        columnSpacing: 10,
                        columns: const [
                          DataColumn(
                              label: Text(
                            'Kode Kelas',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'NIM',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Nama',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Percobaan 1',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Percobaan 2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Percobaan 3',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Percobaan 4',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Percobaan 5',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            'Rata-Rata',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ],
                        source: DataSource(
                            data: filteredNilaiTugas,
                            context: context,
                            editNilai: editNilai),
                        rowsPerPage:
                            calculateRowsPerPage(filteredNilaiTugas.length),
                      )
                    : const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      )),
          )
        ],
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;

    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class NilaiTugas {
  String kode;
  int nim;
  String nama;
  double percobaan;
  double percobaan2;
  double percobaan3;
  double percobaan4;
  double percobaan5;
  double rata;

  NilaiTugas({
    required this.nim,
    required this.nama,
    required this.kode,
    this.percobaan = 0.0,
    this.percobaan2 = 0.0,
    this.percobaan3 = 0.0,
    this.percobaan4 = 0.0,
    this.percobaan5 = 0.0,
    this.rata = 0.0,
  });
}

DataRow dataFileDataRow(
    NilaiTugas fileInfo, int index, VoidCallback editCallback) {
  return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        return getRowColor(index);
      }),
      cells: [
        DataCell(Text(fileInfo.nim.toString())),
        DataCell(Text(fileInfo.kode)),
        DataCell(SizedBox(
            width: 180.0, child: Text(getLimitedText(fileInfo.nama, 30)))),
        DataCell(Text(fileInfo.percobaan.toString())),
        DataCell(Text(fileInfo.percobaan2.toString())),
        DataCell(Text(fileInfo.percobaan3.toString())),
        DataCell(Text(fileInfo.percobaan4.toString())),
        DataCell(Text(fileInfo.percobaan5.toString())),
        DataCell(Text(getLimitedText(fileInfo.rata.toString(), 6))),
        DataCell(IconButton(
            onPressed: () {
              editCallback();
            },
            icon: const Icon(Icons.edit)))
      ]);
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

class DataSource extends DataTableSource {
  final List<NilaiTugas> data;
  final BuildContext context;
  final void Function(NilaiTugas) editNilai;

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
