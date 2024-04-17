import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PenilaianPercobaanAsisten extends StatefulWidget {
  final String kodeKelas;
  const PenilaianPercobaanAsisten({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  State<PenilaianPercobaanAsisten> createState() =>
      _PenilaianPercobaanAsistenState();
}

class _PenilaianPercobaanAsistenState extends State<PenilaianPercobaanAsisten> {
  List<PenilaianPercobaan> demoPenilaianPercobaan = [];
  List<PenilaianPercobaan> filteredPenilaianPercobaan = [];

  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
  }

  void editNilai(PenilaianPercobaan nilai) {
    //Perhitungan rata-rata
    double rata = _hitungRataRata(nilai);
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
                          'rata': rata,
                        });
                      }

                      // Perbarui state dengan nilai yang baru
                      setState(() {
                        // Memperbarui nilai yang ada di dalam state
                        demoPenilaianPercobaan =
                            demoPenilaianPercobaan.map((item) {
                          if (item.nim == nilai.nim) {
                            return nilai;
                          } else {
                            return item;
                          }
                        }).toList();
                        // Filter kembali data yang ditampilkan
                        filteredPenilaianPercobaan =
                            List.from(demoPenilaianPercobaan);
                      });
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error updating data: $e');
                      }
                    }
                    // Tutup dialog setelah nilai diperbarui
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: const Text('Simpan'),
                ),
              )
            ],
          );
        });
  }

  double _hitungRataRata(PenilaianPercobaan nilai) {
    return ((nilai.percobaan * 0.2) +
            (nilai.percobaan2 * 0.2) +
            (nilai.percobaan3 * 0.2) +
            (nilai.percobaan4 * 0.2) +
            (nilai.percobaan5 * 0.2)) /
        5;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('nilaiPercobaan')
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
            child: Text('Error: ${snapshot.error}'),
          );
        }
        demoPenilaianPercobaan.clear();
        for (var doc in snapshot.data!.docs) {
          double percobaan1 = doc['percobaan'].toDouble();
          double percobaan2 = doc['percobaan2'].toDouble();
          double percobaan3 = doc['percobaan3'].toDouble();
          double percobaan4 = doc['percobaan4'].toDouble();
          double percobaan5 = doc['percobaan5'].toDouble();

          double rata =
              (percobaan1 + percobaan2 + percobaan3 + percobaan4 + percobaan5) /
                  5;

          demoPenilaianPercobaan.add(PenilaianPercobaan(
            nim: doc['nim'] ?? 0,
            nama: doc['nama'] ?? '',
            kode: doc['kodeKelas'] ?? '',
            percobaan: percobaan1,
            percobaan2: percobaan2,
            percobaan3: percobaan3,
            percobaan4: percobaan4,
            percobaan5: percobaan5,
            rata: rata, // Masukkan rata-rata ke dalam objek PenilaianPercobaan
          ));
        }

        filteredPenilaianPercobaan = List.from(demoPenilaianPercobaan);
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                child: SizedBox(
                  width: double.infinity,
                  child: filteredPenilaianPercobaan.isNotEmpty
                      ? PaginatedDataTable(
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'NIM',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Nama',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Percobaan 1',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Percobaan 2',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Percobaan 3',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Percobaan 4',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Percobaan 5',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Rata-rata',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          source: DataSource(
                              data: filteredPenilaianPercobaan,
                              context: context,
                              editNilai: editNilai),
                          rowsPerPage: calculateRowsPerPage(
                            filteredPenilaianPercobaan.length,
                          ),
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
        );
      },
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;
    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }

  Future<void> getDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('nilaiPercobaan').get();
      setState(() {
        demoPenilaianPercobaan = querySnapshot.docs
            .map((DocumentSnapshot doc) => PenilaianPercobaan(
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
        filteredPenilaianPercobaan = demoPenilaianPercobaan;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }
}

class PenilaianPercobaan {
  String kode;
  int nim;
  String nama;
  double percobaan;
  double percobaan2;
  double percobaan3;
  double percobaan4;
  double percobaan5;
  double rata;

  PenilaianPercobaan(
      {required this.nim,
      required this.nama,
      required this.kode,
      this.percobaan = 0.0,
      this.percobaan2 = 0.0,
      this.percobaan3 = 0.0,
      this.percobaan4 = 0.0,
      this.percobaan5 = 0.0,
      this.rata = 0.0});
}

DataRow dataFileDataRow(PenilaianPercobaan fileInfo, int index,
    void Function(PenilaianPercobaan) editNilai) {
  return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        return getRowColor(index);
      }),
      cells: [
        DataCell(Text(fileInfo.nim.toString())),
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
              editNilai(
                  fileInfo); // Memanggil fungsi editNilai dengan parameter fileInfo
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
  final List<PenilaianPercobaan> data;
  final BuildContext context;
  final void Function(PenilaianPercobaan) editNilai;

  DataSource(
      {required this.data, required this.context, required this.editNilai});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, editNilai);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
