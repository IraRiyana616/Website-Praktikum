import 'package:flutter/material.dart';

class TabelPengumpulanUjiPemahaman extends StatefulWidget {
  final String kodeKelas;
  const TabelPengumpulanUjiPemahaman({super.key, required this.kodeKelas});

  @override
  State<TabelPengumpulanUjiPemahaman> createState() =>
      _TabelPengumpulanUjiPemahamanState();
}

class _TabelPengumpulanUjiPemahamanState
    extends State<TabelPengumpulanUjiPemahaman> {
  List<Pengumpulan> demoPengumpulan = [];
  List<Pengumpulan> filteredPengumpulan = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 70.0, right: 100.0),
            child: SizedBox(
              width: double.infinity,
              child: filteredPengumpulan.isNotEmpty
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
                            '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      source: DataSource(filteredPengumpulan),
                      rowsPerPage:
                          calculateRowsPerPage(filteredPengumpulan.length),
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
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
    );
  }

  int calculateRowsPerPage(int rowCount) {
    const int defaultRowsPerPage = 50;

    return rowCount <= defaultRowsPerPage ? rowCount : defaultRowsPerPage;
  }
}

class Pengumpulan {
  final String kode;
  final String nama;
  final int nim;
  final String file;
  final String timestap;

  Pengumpulan({
    required this.kode,
    required this.nama,
    required this.nim,
    required this.file,
    required this.timestap,
  });
}

DataRow dataFileDataRow(Pengumpulan fileInfo, int index) {
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return getRowColor(index);
      },
    ),
    cells: [
      DataCell(
        SizedBox(
          width: 130.0,
          child: Text(getLimitedText(fileInfo.timestap, 19)),
        ),
      ),
      DataCell(Text(fileInfo.nim.toString())),
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(getLimitedText(fileInfo.nama, 20)),
        ),
      ),
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
            onTap: () {},
            child: const Text(
              'Download',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          )
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
  final List<Pengumpulan> data;

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
