import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabelDataMahasiswaAdmin extends StatefulWidget {
  final String kodeKelas;
  const TabelDataMahasiswaAdmin({
    super.key,
    required this.kodeKelas,
  });

  @override
  State<TabelDataMahasiswaAdmin> createState() =>
      _TabelDataMahasiswaAdminState();
}

class _TabelDataMahasiswaAdminState extends State<TabelDataMahasiswaAdmin> {
  final TextEditingController _textController = TextEditingController();
  bool _isTextFieldNotEmpty = false;

  void _onTextChanged() {
    setState(() {
      _isTextFieldNotEmpty = _textController.text.isNotEmpty;
      filterData(_textController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  Stream<List<DataMahasiswa>> fetchData() {
    return FirebaseFirestore.instance
        .collection('tokenKelas')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .snapshots()
        .asyncMap((snapshot) async {
      List<DataMahasiswa> dataMahasiswa = [];
      for (var tokenDoc in snapshot.docs) {
        int nim = tokenDoc['nim'];
        var mahasiswaSnapshot = await FirebaseFirestore.instance
            .collection('akun_mahasiswa')
            .where('nim', isEqualTo: nim)
            .get();
        for (var mahasiswaDoc in mahasiswaSnapshot.docs) {
          dataMahasiswa.add(DataMahasiswa(
            nim: nim,
            kode: widget.kodeKelas,
            nama: mahasiswaDoc['nama'] ?? '',
            email: mahasiswaDoc['email'] ?? '',
            nohp: mahasiswaDoc['no_hp'] ?? 0,
            angkatan: mahasiswaDoc['angkatan'] ?? 0,
          ));
        }
      }
      return dataMahasiswa;
    });
  }

  List<DataMahasiswa> filteredDataMahasiswa = [];

  void filterData(String query) {
    setState(() {
      filteredDataMahasiswa = filteredDataMahasiswa
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
    return StreamBuilder<List<DataMahasiswa>>(
      stream: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        } else {
          filteredDataMahasiswa = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 35.0, left: 35.0),
                child: Text(
                  'Data Mahasiswa Praktikum',
                  style: GoogleFonts.quicksand(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 960.0),
                child: SizedBox(
                  width: 300.0,
                  height: 40.0,
                  child: Row(
                    children: [
                      const Text("Search :", style: TextStyle(fontSize: 16)),
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
              Padding(
                padding:
                    const EdgeInsets.only(left: 35.0, right: 35.0, top: 25.0),
                child: SizedBox(
                  width: double.infinity,
                  child: filteredDataMahasiswa.isNotEmpty
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
                                "Angkatan",
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
                          ],
                          source: DataSource(filteredDataMahasiswa),
                          rowsPerPage: calculateRowsPerPage(
                              filteredDataMahasiswa.length),
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
          );
        }
      },
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
}

class DataMahasiswa {
  final String kode;
  final int nim;
  final String nama;
  final String email;
  final int nohp;
  final int angkatan;

  DataMahasiswa({
    required this.nim,
    required this.nama,
    required this.email,
    required this.nohp,
    required this.kode,
    required this.angkatan,
  });
}

DataRow dataFileDataRow(DataMahasiswa fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(SizedBox(width: 140.0, child: Text(fileInfo.nim.toString()))),
      DataCell(SizedBox(width: 140, child: Text(fileInfo.angkatan.toString()))),
      DataCell(SizedBox(
          width: 250.0, child: Text(getLimitedText(fileInfo.nama, 30)))),
      DataCell(SizedBox(
          width: 250.0, child: Text(getLimitedText(fileInfo.email, 30)))),
      DataCell(SizedBox(width: 140.0, child: Text(fileInfo.nohp.toString()))),
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
  final List<DataMahasiswa> data;

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
