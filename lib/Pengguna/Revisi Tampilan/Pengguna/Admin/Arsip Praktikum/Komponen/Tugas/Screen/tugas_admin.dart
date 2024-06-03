import 'package:flutter/material.dart';

class TugasAdminScreen extends StatefulWidget {
  final String kodeKelas;
  final String mataKuliah;
  const TugasAdminScreen(
      {super.key, required this.kodeKelas, required this.mataKuliah});

  @override
  State<TugasAdminScreen> createState() => _TugasAdminScreenState();
}

class _TugasAdminScreenState extends State<TugasAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
