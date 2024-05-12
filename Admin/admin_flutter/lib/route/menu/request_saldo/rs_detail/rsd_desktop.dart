import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class rsdDesktop extends StatefulWidget {
  final email;
  const rsdDesktop({super.key, this.email});

  @override
  State<rsdDesktop> createState() => _rsdDesktopState();
}

class _rsdDesktopState extends State<rsdDesktop> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<QuerySnapshot> _future;
  @override
  void initState() {
    print(this.widget.email.toString());
    super.initState();
    _future = _firestore
        .collection('request_saldo_handyman')
        .where('email', isEqualTo: this.widget.email.toString())
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Saldo Handyman'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Text('Data not found');
          } else {
            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

            return Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Email: ${data['email']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No rekening: ${data['no_rekening']}'),
                        Text(
                            'Date: ${data['tanggal'].toString().substring(0, 19)}'),
                        Text('Bank Destination: ${data['bank']}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
