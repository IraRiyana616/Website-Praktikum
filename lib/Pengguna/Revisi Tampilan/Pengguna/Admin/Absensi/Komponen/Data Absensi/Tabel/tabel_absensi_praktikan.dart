import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabelAbsensiPraktikan extends StatefulWidget {
  final String mataKuliah;
  final String idkelas;
  final String kode;

  const TabelAbsensiPraktikan({
    Key? key,
    required this.mataKuliah,
    required this.idkelas,
    required this.kode,
  }) : super(key: key);

  @override
  State<TabelAbsensiPraktikan> createState() => _TabelAbsensiPraktikanState();
}

class _TabelAbsensiPraktikanState extends State<TabelAbsensiPraktikan> {
  // List Data Tabel
  List<AbsensiMahasiswa> demoDataAbsensi = [];
  List<AbsensiMahasiswa> filteredDataAbsensi = [];

  // Judul Materi
  String selectedModul = 'Judul Modul';
  List<String> availableModuls = ['Judul Modul'];

  // Menampilkan data dari Firestore
  @override
  void initState() {
    super.initState();
    textController.addListener(_onTextChanged);
    fetchData();
  }

  // Fungsi untuk mengambil data dari Firestore 'absenMahasiswa'
  Future<void> fetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('absenMahasiswa')
              .where('idKelas', isEqualTo: widget.idkelas)
              .get();

      List<AbsensiMahasiswa> absensiList = querySnapshot.docs.map((doc) {
        Map<String, dynamic>? data = doc.data();
        String modul = data['judulModul'] ?? '';
        if (!availableModuls.contains(modul)) {
          availableModuls.add(modul);
        }
        return AbsensiMahasiswa(
            id: doc.id,
            idkelas: doc['idKelas'] ?? '',
            nim: doc['nim'] ?? 0,
            nama: doc['nama'] ?? '',
            modul: modul,
            waktu: doc['waktuAbsensi'] ?? '',
            pertemuan: doc['pertemuan'] ?? '');
      }).toList();
      absensiList.sort((a, b) => a.nim.compareTo(b.nim));
      setState(() {
        demoDataAbsensi = absensiList;
        filteredDataAbsensi = List.from(demoDataAbsensi);
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

//== Filtering Data dengan judul modul ==//
  void _filterData(String? modul) {
    setState(() {
      selectedModul = modul ?? 'Judul Modul';
      if (modul != 'Judul Modul') {
        filteredDataAbsensi = demoDataAbsensi
            .where((absensi) => absensi.modul == selectedModul)
            .toList();
      } else {
        filteredDataAbsensi = demoDataAbsensi;
      }
    });
  }

  //== Fungsi Controller pada Search ==//
  final TextEditingController textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  //== Fungsi dari Filtering Search ==//
  void filterData(String query) {
    setState(() {
      filteredDataAbsensi = demoDataAbsensi
          .where((data) =>
              (data.nama.toLowerCase().contains(query.toLowerCase()) ||
                  data.nim.toString().contains(query.toLowerCase()) ||
                  data.waktu.toString().contains(query.toLowerCase()) ||
                  data.pertemuan.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      textController.clear();
      filterData('');
    });
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = textController.text.isNotEmpty;
      filterData(textController.text);
    });
  }

  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
  }

  Future<void> _onRefresh() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //== Judul ==//
            Padding(
              padding: const EdgeInsets.only(left: 42.0, top: 20.0),
              child: Text(
                'Data Absensi Praktikan ',
                style: GoogleFonts.quicksand(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            // Dropdown Button Judul Modul
            Padding(
              padding:
                  const EdgeInsets.only(left: 42.0, top: 25.0, right: 42.0),
              child: Container(
                height: 47.0,
                width: 1300.0,
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
                        padding: const EdgeInsets.only(left: 15.0),
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
            // Search Tab
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //== Search ==//
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 960.0),
                  child: SizedBox(
                    width: 300.0,
                    height: 40.0,
                    child: Row(children: [
                      const Text(
                        'Search :',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                          child: TextField(
                        onChanged: (value) {
                          filterData(value);
                        },
                        controller: textController,
                        decoration: InputDecoration(
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10.0),
                            suffixIcon: Visibility(
                                visible: _isTextFieldNotEmpty,
                                child: IconButton(
                                    onPressed: clearSearchField,
                                    icon: const Icon(Icons.clear))),
                            labelStyle: const TextStyle(fontSize: 16.0),
                            filled: true,
                            fillColor: Colors.white),
                      )),
                      const SizedBox(
                        width: 27.0,
                      )
                    ]),
                  ),
                ),
              ],
            ),
            // Data Tabel
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 45.0, right: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredDataAbsensi.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Waktu Absensi",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
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
                                  "Pertemuan",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                  label: Text(
                                '       Aksi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
                            ],
                            source: DataSource(
                                filteredDataAbsensi, deleteData, context),
                            rowsPerPage: calculateRowsPerPage(
                                filteredDataAbsensi.length),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(35.0),
                            child: Center(
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 50;

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }

//== Fungsi untuk menghapus data ke dalam database 'absenMahasiswa' ===//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('absenMahasiswa')
          .doc(id)
          .delete();
      await fetchData();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data: $error');
      }
    }
  }
}

class AbsensiMahasiswa {
  String id;
  int nim;
  String nama;
  String modul;
  String waktu;
  String pertemuan;
  String idkelas;

  AbsensiMahasiswa(
      {required this.id,
      required this.nim,
      required this.nama,
      required this.modul,
      required this.waktu,
      required this.pertemuan,
      required this.idkelas});
}

DataRow dataFileDataRow(AbsensiMahasiswa fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      //=== Waktu ===//
      DataCell(SizedBox(
          width: 200.0,
          child: Text(
            fileInfo.waktu,
          ))),
      //=== NIM ===//
      DataCell(
        SizedBox(
          width: 200.0,
          child: Text(
            fileInfo.nim.toString(),
          ),
        ),
      ),
      //== Nama ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.nama,
          ),
        ),
      ),
      //== Pertemuan =//
      DataCell(SizedBox(
        width: 200.0,
        child: Text(fileInfo.pertemuan),
      )),
      //== Ikon ==//
      DataCell(Row(
        children: [
          const Icon(
            Icons.delete,
            color: Colors.grey,
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Text('Hapus Data Absensi',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0)),
                    ),
                    content:
                        const Text('Apakah Anda yakin ingin menghapusnya?'),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextButton(
                            onPressed: () {
                              onDelete(fileInfo.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Hapus')),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Batal'),
                        ),
                      )
                    ],
                  );
                },
              );
            },
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                'Hapus Data',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          )
        ],
      ))
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
  final List<AbsensiMahasiswa> data;
  final Function(String) onDelete;
  final BuildContext context;

  DataSource(this.data, this.onDelete, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final fileInfo = data[index];
    return dataFileDataRow(fileInfo, index, onDelete, context);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
