import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TokenAsistenScreen extends StatelessWidget {
  final String kodeKelas;

  const TokenAsistenScreen({Key? key, required this.kodeKelas})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kodeKelas),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('deskripsiKelas')
            .where('kodeKelas',
                isEqualTo: kodeKelas) // Filter berdasarkan kodeKelas
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Tidak ada data untuk kelas'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Kode Kelas: ${data['kodeKelas']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deskripsi Kelas: ${data['deskripsi_kelas']}'),
                    Text('Prosesor: ${data['prosesor']}'),
                    Text('RAM: ${data['ram']}'),
                    Text('Sistem Operasi: ${data['sistemOperasi']}'),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
