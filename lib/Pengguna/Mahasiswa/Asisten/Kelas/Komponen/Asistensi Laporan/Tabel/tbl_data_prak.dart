import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laksi/Pengguna/Mahasiswa/Asisten/Kelas/Komponen/Asistensi%20Laporan/Komponen/Screen/asistensi_lapor.dart';

class TabelDataPraktikan extends StatefulWidget {
  final String kodeKelas;
  const TabelDataPraktikan({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  State<TabelDataPraktikan> createState() => _TabelDataPraktikanState();
}

class _TabelDataPraktikanState extends State<TabelDataPraktikan> {
  List<DataPraktikan> filteredDataPraktikan = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  void fetchDataFromFirestore() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tokenKelas')
        .where('kodeKelas', isEqualTo: widget.kodeKelas)
        .get();

    final data = querySnapshot.docs
        .map((doc) => DataPraktikan.fromFirestore(doc))
        .toList();

    setState(() {
      filteredDataPraktikan = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: SizedBox(
                width: 1195.0,
                child: filteredDataPraktikan.isNotEmpty
                    ? PaginatedDataTable(
                        columnSpacing: 10,
                        columns: const [
                          DataColumn(
                              label: Text('NIM',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Nama',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text(
                            '',
                          )),
                        ],
                        source: DataSource(filteredDataPraktikan, context),
                        rowsPerPage:
                            calculateRowsPerPage(filteredDataPraktikan.length),
                      )
                    : const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      )),
          ),
        )
      ],
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

class DataPraktikan {
  int nim;
  String nama;
  String kode;
  String tahun;
  String matkul;
  String dosen;
  String dosenPengampu;

  DataPraktikan(
      {required this.nim,
      required this.nama,
      required this.kode,
      required this.tahun,
      required this.matkul,
      required this.dosen,
      required this.dosenPengampu});

  factory DataPraktikan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DataPraktikan(
      nim: data['nim'] ?? 0,
      nama: data['nama'] ?? '',
      kode: data['kodeKelas'] ?? '',
      tahun: data['tahunAjaran'] ?? '',
      matkul: data['mataKuliah'] ?? '',
      dosen: data['dosenPengampu'] ?? '',
      dosenPengampu: data['dosenPengampu2'] ?? '',
    );
  }
}

DataRow dataFileDataRow(
    DataPraktikan fileInfo, int index, BuildContext context) {
  return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return getRowColor(index);
        },
      ),
      cells: [
        DataCell(Text(fileInfo.nim.toString())),
        DataCell(SizedBox(
            width: 250.0, child: Text(getLimitedText(fileInfo.nama, 40)))),
        DataCell(GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AsistensiLaporan(
                          kodeKelas: fileInfo.kode,
                          nama: fileInfo.nama,
                          modul: fileInfo.matkul,
                          nim: fileInfo.nim,
                        )));
          },
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  'Lihat Detail',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
        ))
      ]);
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
  final List<DataPraktikan> data;
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
