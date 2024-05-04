import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Table Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const MyDialog();
              },
            );
          },
          child: const Text('Buat Tabel'),
        ),
      ),
    );
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final TextEditingController _controller = TextEditingController();
  int _numberOfCells = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Masukkan Jumlah Data Cell'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Jumlah Data Cell'),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _numberOfCells = int.parse(_controller.text);
            });
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return TableDialog(
                  numberOfCells: _numberOfCells,
                );
              },
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class TableDialog extends StatelessWidget {
  final int numberOfCells;

  const TableDialog({super.key, required this.numberOfCells});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tabel dengan $numberOfCells Data Cell'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: List.generate(
              numberOfCells,
              (index) => DataColumn(
                label: Text('Kolom $index'),
              ),
            ),
            rows: [
              DataRow(
                  cells: List.generate(
                numberOfCells,
                (index) => DataCell(
                  Text('Data $index'),
                ),
              )),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
