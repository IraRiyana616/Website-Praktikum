import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TabelDataMahasiswa extends StatefulWidget {
  final String mataKuliah;
  final String idkelas;
  final String kode;
  const TabelDataMahasiswa({
    super.key,
    required this.mataKuliah,
    required this.idkelas,
    required this.kode,
  });

  @override
  State<TabelDataMahasiswa> createState() => _TabelDataMahasiswaState();
}

class _TabelDataMahasiswaState extends State<TabelDataMahasiswa> {
  //== List Data Tabel ==//
  List<DataMahasiswa> demoDataMahasiswa = [];
  List<DataMahasiswa> filteredDataMahasiswa = [];

  //== Fungsi untuk mengaktifkan loading ==//
  bool isLoading = true;

//== Fungsi untuk memanggil Firestore ==//
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _fetchDataAsisten();
  }

//== Fungsi untuk menampilkan data dari database ==//
  Future<void> _fetchDataAsisten() async {
    try {
      var akunSnapshot = await _firestore.collection('akun_mahasiswa').get();
      List<DataMahasiswa> dataMahasiswaList = [];

      if (akunSnapshot.docs.isNotEmpty) {
        for (var akunDoc in akunSnapshot.docs) {
          var nim = akunDoc['nim'];

          var dataMahasiswaSnapshot = await _firestore
              .collection('dataMahasiswaPraktikum')
              .where('nim', isEqualTo: nim)
              .where('idKelas', isEqualTo: widget.idkelas)
              .where('kodeMatakuliah', isEqualTo: widget.kode)
              .get();

          if (dataMahasiswaSnapshot.docs.isNotEmpty) {
            var combinedDocs = dataMahasiswaSnapshot.docs;

            // Memperbaiki iterasi untuk memasukkan dataMahasiswa ke dalam list
            // ignore: unused_local_variable
            for (var dataMahasiswaDoc in combinedDocs) {
              dataMahasiswaList.add(
                DataMahasiswa(
                  id: dataMahasiswaDoc.id,
                  nim: akunDoc['nim'] ?? 0,
                  nama: akunDoc['nama'] ?? '',
                  email: akunDoc['email'] ?? '',
                  nohp: akunDoc['no_hp'] ?? 0,
                  angkatan: akunDoc['angkatan'] ?? 0,
                  password: akunDoc['password'] ?? '',
                ),
              );
            }
          }
        }
      }

      dataMahasiswaList.sort((a, b) => a.nama.compareTo(b.nama));
      setState(() {
        demoDataMahasiswa = dataMahasiswaList;
        filteredDataMahasiswa = dataMahasiswaList;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  //=== Fungsi Search ===//
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = _textController.text.isNotEmpty;
      filterData(_textController.text);
    });
  }

  void filterData(String query) {
    setState(() {
      filteredDataMahasiswa = demoDataMahasiswa
          .where((data) => (data.nama
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              data.nim.toString().toLowerCase().contains(query.toLowerCase()) ||
              data.nohp.toString().toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void clearSearchField() {
    setState(() {
      _textController.clear();
      filterData('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 1020.0),
          child: SizedBox(
            width: 300.0,
            height: 40.0,
            child: Row(
              children: [
                const Text("Search :",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              ],
            ),
          ),
        ),
        //== Tabel ==//
        Padding(
          padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 25.0),
          child: SizedBox(
            width: double.infinity,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredDataMahasiswa.isNotEmpty
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
                              "Nama Lengkap",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Email",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Nomor Handphone",
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
                          filteredDataMahasiswa,
                          deleteData,
                          context,
                        ),
                        rowsPerPage:
                            calculateRowsPerPage(filteredDataMahasiswa.length),
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
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 25;

    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }

  //== Menghapus Data ==//
  void deleteData(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('dataMahasiswaPraktikum')
          .doc(id)
          .delete();
      _fetchDataAsisten();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting data: $error');
      }
    }
  }
}

class DataMahasiswa {
  final String id;
  final int nim;
  final String nama;
  final String email;
  final int nohp;
  final int angkatan;
  final String password;

  DataMahasiswa({
    required this.id,
    required this.nim,
    required this.nama,
    required this.email,
    required this.nohp,
    required this.angkatan,
    required this.password,
  });
}

DataRow dataFileDataRow(DataMahasiswa fileInfo, int index,
    Function(String) onDelete, BuildContext context) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      //== NIM ==//
      DataCell(SizedBox(width: 140.0, child: Text(fileInfo.nim.toString()))),
      //== Nama Lengkap ==//
      DataCell(SizedBox(
          width: 250.0, child: Text(getLimitedText(fileInfo.nama, 30)))),
      //== Email ==//
      DataCell(SizedBox(
          width: 250.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getLimitedText(fileInfo.email, 30)),
              IconButton(
                  onPressed: () {
                    copyToClipboard(fileInfo.email);
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.grey,
                  ))
            ],
          ))),
      //== Nomor Handphone ==//
      DataCell(SizedBox(
          width: 145.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fileInfo.nohp.toString()),
              IconButton(
                  onPressed: () {
                    copyToClipboard(fileInfo.nohp.toString());
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.grey,
                  ))
            ],
          ))),
      //== Icon Delete ==//
      DataCell(IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Hapus Data Mahasiswa',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                content: const Text('Apakah Anda yakin ingin menghapusnya?'),
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
        icon: const Icon(Icons.delete, color: Colors.grey),
        tooltip: 'Hapus Data',
      ))
    ],
  );
}

Color getRowColor(int index) {
  return index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent;
}

//== Fungsi untuk menduplikasi data ==//
void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

//== Fungsi untuk membatasi text ==//
String getLimitedText(String text, int limit) {
  return text.length <= limit ? text : text.substring(0, limit);
}

class DataSource extends DataTableSource {
  final List<DataMahasiswa> data;
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
