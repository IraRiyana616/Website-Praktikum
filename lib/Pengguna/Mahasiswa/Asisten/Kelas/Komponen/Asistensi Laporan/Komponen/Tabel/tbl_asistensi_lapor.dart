// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class TabelAsistensiLaporan extends StatefulWidget {
  final String kodeKelas;
  final String nama;
  final String modul;

  const TabelAsistensiLaporan({
    Key? key,
    required this.kodeKelas,
    required this.nama,
    required this.modul,
  }) : super(key: key);

  @override
  State<TabelAsistensiLaporan> createState() => _TabelAsistensiLaporanState();
}

class _TabelAsistensiLaporanState extends State<TabelAsistensiLaporan> {
  List<AsistensiLaporan> demoAsistensiLaporan = [];
  List<AsistensiLaporan> filteredAsistenLaporan = [];
  late int userNim;
  late String userName;
  late String selectedRevisi = 'Status Revisi';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 18.0, right: 25.0, top: 20.0, bottom: 20.0),
            child: SizedBox(
              width: 1195.0,
              child: filteredAsistenLaporan.isNotEmpty
                  ? PaginatedDataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Timestamp',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama Modul',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Download File',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'File Asistensi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredAsistenLaporan, context),
                      rowsPerPage:
                          calculateRowsPerPage(filteredAsistenLaporan.length),
                    )
                  : const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;
    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }

  @override
  void initState() {
    super.initState();

    checkAndFetchData();
  }

  Future<void> checkAndFetchData() async {
    final QuerySnapshot<Map<String, dynamic>> laporanSnapshot =
        await FirebaseFirestore.instance
            .collection('laporan')
            .where('kodeKelas', isEqualTo: widget.kodeKelas)
            .where('nama', isEqualTo: widget.nama)
            .get();

    if (laporanSnapshot.docs.isNotEmpty) {
      List<AsistensiLaporan> fetchedData =
          laporanSnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return AsistensiLaporan(
          modul: data['judulMateri'] ?? '',
          kode: data['kodeKelas'] ?? '',
          nama: data['nama'] ?? '',
          file: data['namaFile'] ?? '',
          nim: data['nim'] ?? 0,
          waktu: (data['waktuPengumpulan'] as Timestamp).toDate(),
          status: data['statusRevisi'] ?? '',
        );
      }).toList();

      setState(() {
        demoAsistensiLaporan = fetchedData;
        filteredAsistenLaporan = fetchedData;
      });
    }
  }
}

class AsistensiLaporan {
  String modul;
  String kode;
  String nama;
  String file;
  int nim;
  DateTime waktu;
  String status;

  AsistensiLaporan({
    required this.modul,
    required this.kode,
    required this.nama,
    required this.file,
    required this.nim,
    required this.waktu,
    required this.status,
  });
}

DataRow dataFileDataRow(
  AsistensiLaporan fileInfo,
  int index,
  BuildContext context,
) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(
        width: 150.0,
        child: Text(
          getLimitedText(fileInfo.waktu.toString(), 19),
        ),
      )),
      DataCell(SizedBox(
        width: 200.0,
        child: Text(
          getLimitedText(fileInfo.modul, 30),
        ),
      )),
      DataCell(Text(
        fileInfo.status,
      )),
      DataCell(Row(
        children: [
          const Icon(
            Icons.download,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 5.0,
          ),
          GestureDetector(
            onTap: () {
              downloadFile(fileInfo.kode, fileInfo.file, fileInfo.modul);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                getLimitedText(fileInfo.file, 20),
              ),
            ),
          ),
        ],
      )),
      DataCell(Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  uploadFile(
                    fileInfo.kode,
                    fileInfo.file,
                    fileInfo.modul,
                    context,
                  );
                },
                child: const Icon(
                  Icons.upload,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(
              width: 2.0,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  showInfoDialog(fileInfo, context); // Pass context here
                },
                child: const Icon(
                  Icons.info,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      )),
    ],
  );
}

Future<void> showInfoDialog(
    AsistensiLaporan fileInfo, BuildContext context) async {
  try {
    final QuerySnapshot<Map<String, dynamic>> laporanSnapshot =
        await FirebaseFirestore.instance
            .collection('laporan')
            .where('kodeKelas', isEqualTo: fileInfo.kode)
            .where('judulMateri', isEqualTo: fileInfo.modul)
            .where('statusRevisi', isEqualTo: fileInfo.status)
            .get();

    final QuerySnapshot<Map<String, dynamic>> asistensiSnapshot =
        await FirebaseFirestore.instance
            .collection('asistensiLaporan')
            .where('kodeKelas', isEqualTo: fileInfo.kode)
            .where('judulMateri', isEqualTo: fileInfo.modul)
            .where('statusRevisi', isEqualTo: fileInfo.status)
            .get();

    if (laporanSnapshot.docs.isNotEmpty && asistensiSnapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> laporanDocument =
          laporanSnapshot.docs.first;
      final DocumentSnapshot<Map<String, dynamic>> asistensiDocument =
          asistensiSnapshot.docs.first;

      final String statusRevisiLaporan = laporanDocument['statusRevisi'];
      final String statusRevisiAsistensi = asistensiDocument['statusRevisi'];

      if (statusRevisiLaporan == statusRevisiAsistensi) {
        final namaPemeriksa = asistensiDocument['namaPemeriksa'];
        final waktuPengumpulan = asistensiDocument['waktuPengumpulan'];
        final statusRevisi = asistensiDocument['statusRevisi'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Data Asisten',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 13.0,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Nama Pemeriksa : ',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        '$namaPemeriksa',
                        style: const TextStyle(fontSize: 14.0),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Waktu Asistensi   :',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        ' ${DateFormat('dd-MM-yyyy HH:mm:ss').format(waktuPengumpulan.toDate())}',
                        style: const TextStyle(fontSize: 14.0),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Status Revisi         : ',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        '$statusRevisi',
                        style: const TextStyle(fontSize: 14.0),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Data Asisten'),
              content: const Text(
                  'Status revisi pada laporan dan asistensi tidak sama.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Data Asisten'),
            content: const Text(
                'Belum Melakukan Asistensi Laporan atau data laporan tidak ditemukan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching info: $e');
    }
  }
}

Future<void> uploadFile(
  String kodeKelas,
  String fileName,
  String modul,
  BuildContext context,
) async {
  String selectedRevisi = 'Status Asistensi';

  // Menampilkan dialog untuk memilih status revisi
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pilih Status Revisi'),
            content: DropdownButton<String>(
              isExpanded: true,
              value: selectedRevisi,
              onChanged: (String? value) {
                setState(() {
                  selectedRevisi = value!;
                });
              },
              items: <String>[
                'Status Asistensi',
                'Revisi 1',
                'Revisi 2',
                'Revisi 3',
                'Revisi 4',
                'Revisi 5',
                'ACC'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Menutup dialog tanpa melanjutkan proses ke upload file
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedRevisi != 'Status Asistensi') {
                    Navigator.pop(context, selectedRevisi);
                  } else {
                    // Bisa tambahkan feedback untuk user bahwa harus memilih status revisi
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );

  // Jika user membatalkan dialog, maka keluar dari fungsi uploadFile
  if (selectedRevisi == 'Status Asistensi') {
    return;
  }

  // Menampilkan loading dialog
  showDialog(
    context: context,
    barrierDismissible: false, // Mencegah dialog ditutup secara manual
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.fourRotatingDots(
                color: Colors.blue,
                size: 50,
              ),
              const SizedBox(width: 20),
              const Text("Uploading..."),
            ],
          ),
        ),
      );
    },
  );

  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      User? user = FirebaseAuth.instance.currentUser;
      String nama = '';

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .doc(user.uid)
            .get();
        nama = userDoc['nama'];
      }

      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('asistensiLaporan/$kodeKelas/$modul/$fileName');

      await storageRef.putData(Uint8List.fromList(file.bytes!));

      String nextDocumentId = '';
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference counterRef = FirebaseFirestore.instance
            .collection('counters')
            .doc('asistensiLaporan');
        DocumentSnapshot counterSnapshot = await transaction.get(counterRef);
        int currentCount =
            counterSnapshot.exists ? counterSnapshot.get('count') : 0;
        nextDocumentId = '${currentCount + 1}';
        transaction.set(counterRef, {'count': currentCount + 1});
      });

      await FirebaseFirestore.instance
          .collection('asistensiLaporan')
          .doc(nextDocumentId)
          .set({
        'namaFile': fileName,
        'waktuPengumpulan': DateTime.now(),
        'namaPemeriksa': nama,
        'kodeKelas': kodeKelas,
        'judulMateri': modul,
        'statusRevisi': selectedRevisi,
      });

      Navigator.pop(context); // Menutup dialog loading

      // Menampilkan dialog sukses setelah file di-upload
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 20.0,
            width: 50.0,
            child: AlertDialog(
              title: Column(
                children: [
                  Center(
                    child: SizedBox(
                      height: 120.0,
                      width: 120.0,
                      child: Image.asset(
                        'assets/images/upload.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Data berhasil diupload.',
                      style: GoogleFonts.quicksand(
                          fontSize: 17.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.pop(
          context); // Menutup dialog loading jika tidak ada file yang dipilih
    }
  } catch (e) {
    Navigator.pop(context); // Menutup dialog loading jika terjadi error

    // Menampilkan pesan error
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Error uploading file: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void downloadFile(String kodeKelas, String fileName, String judulMateri) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('laporan/$kodeKelas/$judulMateri/$fileName');

  try {
    final url = await ref.getDownloadURL();
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error downloading file: $e');
    }
  }
}

String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

class DataSource extends DataTableSource {
  final List<AsistensiLaporan> data;
  final BuildContext context;

  DataSource(this.data, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, context);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
