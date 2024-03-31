import 'package:file_picker/file_picker.dart';
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
                            'Download File',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                            label: Text(
                          'File Asistensi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
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
    final CollectionReference<Map<String, dynamic>> laporanRef =
        FirebaseFirestore.instance.collection('laporan');
    final QuerySnapshot<Map<String, dynamic>> laporanSnapshot = await laporanRef
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .where('nama', isEqualTo: widget.nama)
        .get();

    if (laporanSnapshot.docs.isNotEmpty) {
      List<AsistensiLaporan> fetchedData =
          laporanSnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return AsistensiLaporan(
          userUid: data['UserUid'] ?? 0,
          modul: data['judulMateri'] ?? '',
          kode: data['kodeKelas'] ?? '',
          nama: data['nama'] ?? '',
          file: data['namaFile'] ?? '',
          nim: data['nim'] ?? 0,
          waktu: (data['waktuPengumpulan'] as Timestamp).toDate(),
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
  int userUid;

  AsistensiLaporan({
    required this.modul,
    required this.kode,
    required this.nama,
    required this.file,
    required this.nim,
    required this.waktu,
    required this.userUid,
  });
}

DataRow dataFileDataRow(
    AsistensiLaporan fileInfo, int index, BuildContext context) {
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
        width: 250.0,
        child: Text(
          getLimitedText(fileInfo.modul, 40),
        ),
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
                    fileInfo.nama,
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
    final CollectionReference<Map<String, dynamic>> asistensiRef =
        FirebaseFirestore.instance.collection('asistensiLaporan');
    final QuerySnapshot<Map<String, dynamic>> asistensiSnapshot =
        await asistensiRef
            .where('kodeKelas', isEqualTo: fileInfo.kode)
            .where('judulMateri', isEqualTo: fileInfo.modul)
            .where('UserUid', isEqualTo: fileInfo.userUid)
            .get();

    if (asistensiSnapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> document =
          asistensiSnapshot.docs.first;
      final namaPemeriksa = document['namaPemeriksa'];
      final waktuPengumpulan = document['waktuPengumpulan'];

      // ignore: use_build_context_synchronously
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
                      'Waktu Asistensi   :', // Menggunakan toDate() untuk mengonversi Timestamp menjadi DateTime
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
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Data Asisten'),
            content: const Text('Belum Melakukan Asistensi Laporan'),
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
  String nama,
  String modul,
  BuildContext context,
) async {
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

      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('asistensiLaporan/$kodeKelas/$modul/$fileName');

      await storageRef.putData(Uint8List.fromList(file.bytes!));
// Mengambil referensi ke jumlah dokumen saat ini dalam koleksi 'laporan'
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('asistensiLaporan').get();
      int userUid = querySnapshot.docs.length + 1;
      await FirebaseFirestore.instance.collection('asistensiLaporan').add({
        'UserUid': userUid,
        'namaFile': fileName,
        'waktuPengumpulan': DateTime.now(),
        'namaPemeriksa': nama,
        'kodeKelas': kodeKelas,
        'judulMateri': modul,
      });

      // Menutup dialog loading setelah upload selesai
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Menampilkan dialog sukses setelah file di-upload
      // ignore: use_build_context_synchronously
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
      // Menutup dialog loading jika tidak ada file yang dipilih
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  } catch (e) {
    // Menutup dialog loading jika terjadi error
    Navigator.pop(context);

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

String getLimitedText(
  String text,
  int limit,
) {
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
