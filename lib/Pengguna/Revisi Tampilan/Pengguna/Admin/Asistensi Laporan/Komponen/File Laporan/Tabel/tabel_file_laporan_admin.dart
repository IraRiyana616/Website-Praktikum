// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class TabelFileLaporanAdmin extends StatefulWidget {
  final String idkelas;
  final String nama;
  final int nim;
  const TabelFileLaporanAdmin(
      {super.key,
      required this.idkelas,
      required this.nama,
      required this.nim});

  @override
  State<TabelFileLaporanAdmin> createState() => _TabelFileLaporanAdminState();
}

class _TabelFileLaporanAdminState extends State<TabelFileLaporanAdmin> {
  //== List Data Tabel ==//
  List<AsistensiLaporan> demoAsistensiLaporan = [];
  List<AsistensiLaporan> filteredAsistenLaporan = [];

  //=====//
  late int userNim;
  late String userName;
  late String selectedRevisi = 'Status Revisi';
  String selectedModul = 'Tampilkan Semua';
  List<String> availableModuls = ['Tampilkan Semua'];

  //== Filtering Data ==//
  void _filterData(String? modul) {
    if (modul != null) {
      setState(() {
        selectedModul = modul;
        if (modul == 'Tampilkan Semua') {
          filteredAsistenLaporan = List.from(demoAsistensiLaporan);
        } else {
          filteredAsistenLaporan = demoAsistensiLaporan
              .where((asistensi) => asistensi.modul == modul)
              .toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Container(
                  height: 47.0,
                  width: 1195.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButton<String>(
                    value: selectedModul,
                    onChanged: (modul) => _filterData(modul),
                    items: availableModuls
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(value),
                        ),
                      );
                    }).toList(),
                    style: const TextStyle(color: Colors.black),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    iconSize: 24,
                    elevation: 16,
                    isExpanded: true,
                    underline: Container(),
                  ),
                ),
              ),
              Padding(
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
                                'Waktu Pengumpulan',
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
                                '         File Asistensi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          source: DataSource(
                              filteredAsistenLaporan, context, deleteData),
                          rowsPerPage: calculateRowsPerPage(
                              filteredAsistenLaporan.length),
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
            ],
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
            .collection('pengumpulanLaporan')
            .where('idKelas', isEqualTo: widget.idkelas)
            .where('nama', isEqualTo: widget.nama)
            .where('nim', isEqualTo: widget.nim)
            .get();

    if (laporanSnapshot.docs.isNotEmpty) {
      List<AsistensiLaporan> fetchedData =
          laporanSnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return AsistensiLaporan(
          id: document.id,
          modul: data['judulModul'] ?? '',
          kode: data['idKelas'] ?? '',
          koreksi: data['namaAsisten'] ?? '',
          file: data['namaFile'] ?? '',
          nim: data['nim'] ?? '',
          waktu: data['waktuAsistensi'] ?? '',
          status: data['statusRevisi'] ?? '',
        );
      }).toList();

      setState(() {
        demoAsistensiLaporan = fetchedData;
        availableModuls = ['Tampilkan Semua'] +
            demoAsistensiLaporan
                .map((asistensi) => asistensi.modul)
                .toSet()
                .toList();
        // Memastikan selectedModul ada di availableModuls
        if (!availableModuls.contains(selectedModul)) {
          selectedModul = 'Tampilkan Semua';
        }
        _filterData(
            selectedModul); // Memanggil _filterData setelah data diambil
      });
    }
  }

  //== Menghapus Data dari Database 'Laporan' ==//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('pengumpulanLaporan')
          .doc(id)
          .delete();
      checkAndFetchData();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data:$error');
      }
    }
  }
}

class AsistensiLaporan {
  String id;
  String modul;
  String kode;
  int nim;
  String file;
  String koreksi;
  String waktu;
  String status;

  AsistensiLaporan({
    required this.id,
    required this.modul,
    required this.kode,
    required this.koreksi,
    required this.file,
    required this.waktu,
    required this.status,
    required this.nim,
  });
}

DataRow dataFileDataRow(AsistensiLaporan fileInfo, int index,
    BuildContext context, Function(String) onDelete) {
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
          getLimitedText(fileInfo.waktu, 23),
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
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
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
              child: IconButton(
                onPressed: () {
                  uploadFile(fileInfo.kode, fileInfo.file, fileInfo.modul,
                      fileInfo.nim, context);
                },
                icon: const Icon(Icons.upload, color: Colors.grey),
                tooltip: 'Upload File',
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Hapus Data',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          content: const Text(
                              'Apakah Anda yakin ingin menghapusnya ?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  onDelete(fileInfo.id);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Hapus')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Batal'))
                          ],
                        );
                      });
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                tooltip: 'Hapus Data',
              ),
            ),
            MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  onPressed: () {
                    showInfoDialog(fileInfo, context);
                  },
                  icon: const Icon(Icons.info, color: Colors.grey),
                  tooltip: 'Info Asistensi',
                )),
          ],
        ),
      )),
    ],
  );
}

//== Fungsi Menampilkan Informasi ==//
Future<void> showInfoDialog(
    AsistensiLaporan fileInfo, BuildContext context) async {
  try {
    final QuerySnapshot<Map<String, dynamic>> asistensiSnapshot =
        await FirebaseFirestore.instance
            .collection('asistensiLaporan')
            .where('idKelas', isEqualTo: fileInfo.kode)
            .where('judulModul', isEqualTo: fileInfo.modul)
            .where('statusRevisi', isEqualTo: fileInfo.status)
            .where('nim', isEqualTo: fileInfo.nim)
            .get();

    if (asistensiSnapshot.size > 0) {
      final DocumentSnapshot<Map<String, dynamic>> asistensiDocument =
          asistensiSnapshot.docs.first;

      final namaPemeriksa = asistensiDocument['namaAsisten'];
      final waktuPengumpulan = asistensiDocument['waktuAsistensi'];
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
            title: Text('Data Asistensi Laporan',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
            content: Text('Belum Melakukan Asistensi Laporan',
                style: GoogleFonts.quicksand(fontSize: 16.0)),
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

//== Fungsi Upload File ==//
Future<void> uploadFile(
  String idkelas,
  String fileName,
  String modul,
  int nim,
  BuildContext context,
) async {
  String selectedRevisi = 'Status Asistensi';

  // Menampilkan dialog untuk memilih status revisi
  selectedRevisi = await showDialog<String>(
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
                      Navigator.pop(
                          context); // Menutup dialog tanpa melanjutkan proses ke upload file
                    },
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (selectedRevisi != 'Status Asistensi') {
                        Navigator.pop(context, selectedRevisi);
                      } else {
                        // Bisa tambahkan feedback untuk user bahwa harus memilih status revisi
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Harap pilih status revisi')));
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      ) ??
      'Status Asistensi';

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

      // Pengecekan data di Firestore
      QuerySnapshot existingData = await FirebaseFirestore.instance
          .collection('asistensiLaporan')
          .where('idKelas', isEqualTo: idkelas)
          .where('judulModul', isEqualTo: modul)
          .where('statusRevisi', isEqualTo: selectedRevisi)
          .get();

      if (existingData.docs.isNotEmpty) {
        Navigator.pop(context); // Menutup dialog loading

        // Menampilkan dialog bahwa data sudah ada
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Data Sudah Ada'),
              content: const Text('Data telah terdapat pada database.'),
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
        return;
      }

      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('asistensiLaporan/$idkelas/$modul/$fileName');

      await storageRef.putData(Uint8List.fromList(file.bytes!));

      await FirebaseFirestore.instance.collection('asistensiLaporan').add({
        'namaFile': fileName,
        'waktuAsistensi': DateTime.now(),
        'namaAsisten': 'Admin',
        'idKelas': idkelas,
        'judulModul': modul,
        'statusRevisi': selectedRevisi,
        'nim': nim
      });

      Navigator.pop(context); // Menutup dialog loading

      // Menampilkan dialog sukses setelah file di-upload
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
}

//== Fungsi Download File ==//
void downloadFile(String idkelas, String fileName, String judulModul) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('laporan/$idkelas/$judulModul/$fileName');

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
  final Function(String) onDelete;

  DataSource(this.data, this.context, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, context, onDelete);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
