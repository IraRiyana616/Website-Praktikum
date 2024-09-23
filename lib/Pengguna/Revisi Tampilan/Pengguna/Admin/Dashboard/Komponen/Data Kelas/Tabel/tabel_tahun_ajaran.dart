import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Kelas Praktikum/Silabus Praktikum/Screen/silabus.dart';
import '../../Tambah Data Asisten/form_asisten.dart';
import '../Komponen/Edit Kelas Praktikum/edit_tahun_ajaran.dart';
import '../Komponen/Tambah Kelas Praktikum/form_tahun_ajaran.dart';

class TabelTahunAjaran extends StatefulWidget {
  final String mataKuliah;
  final String kodeMatakuliah;

  const TabelTahunAjaran({
    super.key,
    required this.mataKuliah,
    required this.kodeMatakuliah,
  });

  @override
  State<TabelTahunAjaran> createState() => _TabelTahunAjaranState();
}

class _TabelTahunAjaranState extends State<TabelTahunAjaran> {
  //== List Data Kelas Pada Tabel ==//
  List<DataTahunAjaran> demoDataTahunAjaran = [];
  List<DataTahunAjaran> filteredDataTahunAjaran = [];

//== Fungsi Controller 'Search' ==//
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

//== Fungsi Pada 'Search' ==//
  void _onTextChanged() {
    _isTextFieldNotEmpty = _textController.text.isNotEmpty;
    filterData(_textController.text);
  }

//== Fungsi Untuk Filtering Data ==//
  void filterData(String query) {
    setState(() {
      filteredDataTahunAjaran = demoDataTahunAjaran
          .where((data) =>
              data.tahun.toLowerCase().contains(query.toLowerCase()) ||
              data.kode.toLowerCase().contains(query.toLowerCase()) ||
              data.semester.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

//== Loading Perbaharui Data ==//
  Future<void> _onRefresh() async {
    fetchDataFromFirestore();
  }

//== Fungsi untuk menampilkan data dari firestore 'dataMatakuliah' ==//
  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    fetchDataFromFirestore();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

//== Firestore 'dataMatakuliah' ==//
  void fetchDataFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dataKelasPraktikum')
          .where('kodeMatakuliah', isEqualTo: widget.kodeMatakuliah)
          .get();
      List<DataTahunAjaran> fetchedData = snapshot.docs.map((doc) {
        return DataTahunAjaran(
            id: doc.id,
            kode: widget.kodeMatakuliah,
            matkul: widget.mataKuliah,
            idkelas: doc['idKelas'] ?? '',
            tahun: doc['tahunAjaran'] ?? '',
            semester: doc['semester'] ?? '');
      }).toList();

      // Urutkan fetchedData berdasarkan kodeMatakuliah
      fetchedData.sort((a, b) => b.tahun.compareTo(a.tahun));

      if (mounted) {
        setState(() {
          demoDataTahunAjaran = fetchedData;
          filteredDataTahunAjaran = fetchedData;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

//== Fungsi 'Search' ==//
  void clearSearchField() {
    _textController.clear();
    filterData('');
  }

//== Fungsi Untuk Menambahkan Warna Pada Tabel ==//
  Color getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0),
            child: Text('Data Tahun Ajaran Praktikum',
                style: GoogleFonts.quicksand(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //== Search ==//
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 25.0),
                    child: SizedBox(
                      width: 300.0,
                      height: 35.0,
                      child: Row(
                        children: [
                          const Text("Search :",
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                filterData(value);
                              },
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                suffixIcon: Visibility(
                                  visible: _isTextFieldNotEmpty,
                                  child: IconButton(
                                    onPressed: clearSearchField,
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 27.0),
                        ],
                      ),
                    ),
                  ),
                  //== ElevatedButton Tambah Kelas ==//
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0, top: 10.0),
                    child: SizedBox(
                      height: 40.0,
                      width: 145.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3CBEA9),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      FormTahunAjaran(
                                mataKuliah: widget.mataKuliah,
                                kodeMatakuliah: widget.kodeMatakuliah,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: const Material(
                          color: Colors.transparent,
                          child: Text(
                            "+ Tambah Data",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  //== == == ==//
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 25.0),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SizedBox(
                    width: double.infinity,
                    child: filteredDataTahunAjaran.isNotEmpty
                        ? PaginatedDataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Kode Matakuliah",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Kode Kelas Praktikum",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Tahun Ajaran",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Semester",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "           Aksi",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: DataSource(
                                filteredDataTahunAjaran, deleteData, context),
                            rowsPerPage: calculateRowsPerPage(
                                filteredDataTahunAjaran.length),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;

    if (rowCount <= defaultRowsPerPage) {
      return rowCount;
    } else {
      return defaultRowsPerPage;
    }
  }

//== Fungsi menghapus data ==//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('dataKelasPraktikum')
          .doc(id)
          .delete();
      fetchDataFromFirestore();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data: $error');
      }
    }
  }
}

class DataTahunAjaran {
  String id;
  String idkelas;
  String kode;
  String matkul;
  String tahun;
  String semester;

  DataTahunAjaran(
      {required this.id,
      required this.idkelas,
      required this.kode,
      required this.matkul,
      required this.tahun,
      required this.semester});
}

DataRow dataFileDataRow(DataTahunAjaran fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      //== Kode Matakuliah ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.kode,
          ),
        ),
      ),
      //== Kode Kelas Praktikum =//
      DataCell(SizedBox(
          width: 250.0,
          child: GestureDetector(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                fileInfo.idkelas,
                style: TextStyle(
                  color: Colors.lightBlue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SilabusScreen(
                    mataKuliah: fileInfo.matkul,
                    idkelas: fileInfo.idkelas,
                    kodeMatakuliah: fileInfo.kode,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
          ))),

      //== Tahun Ajaran ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.tahun,
          ),
        ),
      ),
      //== Semester ==//
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(
            fileInfo.semester,
          ),
        ),
      ),
      //== Aksi ==//
      DataCell(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //== Data Asisten ==//

          IconButton(
            onPressed: () async {
              final firestore = FirebaseFirestore.instance;

              // Mengambil idKelas dari fileInfo
              final idKelas = fileInfo.idkelas;

              // Mengambil koleksi dataAsisten dan memeriksa keberadaan idKelas
              final snapshot = await firestore
                  .collection('dataAsisten')
                  .where('idKelas', isEqualTo: idKelas)
                  .get();

              // Memeriksa apakah data dengan idKelas sudah ada
              if (snapshot.docs.isNotEmpty) {
                // Menampilkan dialog jika data sudah ada
                // ignore: use_build_context_synchronously
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'Data Sudah Ada',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22.0),
                    ),
                    content: const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Anda telah memasukkan data Asisten pada database.\n\nLakukan perubahan data pada Edit Asisten.'),
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
              } else {
                // Navigasi ke FormDataAsisten jika data belum ada
                // ignore: use_build_context_synchronously
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FormDataAsisten(
                      idkelas: fileInfo.idkelas,
                      mataKuliah: fileInfo.matkul,
                      kodeMatakuliah: fileInfo.kode,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.people,
              color: Colors.grey,
            ),
            tooltip: 'Tambah Data Asisten',
          ),
          //== EDIT DATA ==//
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      EditTahunAjaran(
                    mataKuliah: fileInfo.matkul,
                    kodeMatakuliah: fileInfo.kode,
                    tahun: fileInfo.tahun,
                    idkelas: fileInfo.idkelas,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.edit_document, color: Colors.grey),
            tooltip: 'Edit Data',
          ),
          //== REMOVE DATA ==//
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Hapus Kelas',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0)),
                      content:
                          const Text('Apakah Anda yakin ingin menghapusnya?'),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: TextButton(
                              onPressed: () {
                                onDelete(fileInfo.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Hapus')),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Batal'),
                          ),
                        )
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
        ],
      )),
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
  final List<DataTahunAjaran> data;
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
