import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LPDDekstop extends StatefulWidget {
  final uid;
  const LPDDekstop({super.key, this.uid});

  @override
  State<LPDDekstop> createState() => _LPDDekstopState();
}

class _LPDDekstopState extends State<LPDDekstop> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = FirebaseFirestore.instance
        .collection('pelanggaran_user')
        .doc(this.widget.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pelanggaran'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('Data not found'),
            );
          }

          // Mengambil data dari DocumentSnapshot
          Map<String, dynamic> data = snapshot.data!.data()!;
          Map<String, dynamic> optionKeterangan =
              data['option_keterangan'] ?? {};

          // Format tanggal dan waktu
          String formattedDate = DateFormat('dd/MMM/yyyy')
              .format(data['tanggal_pelanggaran'].toDate());
          String formattedTime =
              DateFormat('HH:mm').format(data['tanggal_pelanggaran'].toDate());

          return Card(
            elevation: 3,
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Keterangan Pelanggaran: ${data['keterangan_pelanggaran']}'),
                  Text('Nama Terlapor: ${data['nama_terlapor']}'),
                  Text('Nama Pelapor: ${data['nama_pelapor']}'),
                  Text('Option Keterangan:'),
                  buildOptionKeteranganWidgets(optionKeterangan),
                  Text('Tanggal Pelanggaran: $formattedDate'),
                  Text('Waktu Pelanggaran: $formattedTime'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Fungsi untuk membangun widget untuk Option Keterangan
  Widget buildOptionKeteranganWidgets(Map<String, dynamic> optionKeterangan) {
    List<Widget> widgets = [];

    optionKeterangan.forEach((key, value) {
      widgets.add(Row(
        children: [
          Icon(
            value ? Icons.check : Icons.clear,
            color: value ? Colors.green : Colors.red,
          ),
          SizedBox(width: 5),
          Text('$key'),
        ],
      ));
    });

    return Column(children: widgets);
  }
}
