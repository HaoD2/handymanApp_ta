import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class detail_desktop extends StatefulWidget {
  final email;
  const detail_desktop({super.key, this.email});

  @override
  State<detail_desktop> createState() => _detail_desktopState();
}

class _detail_desktopState extends State<detail_desktop> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<QuerySnapshot> _future;

  @override
  void initState() {
    print(this.widget.email.toString());
    super.initState();
    _future = _firestore
        .collection('handyman_req_forms')
        .where('email', isEqualTo: this.widget.email.toString())
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Handyman'),
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
            var timestamp = (data['date'] as Timestamp).toDate();
            var formattedDate =
                "${timestamp.day}/${timestamp.month}/${timestamp.year}";

            return Card(
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.topLeft,
                      child: Text('Gambar Sertifikat')),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Image.network(
                      data['certificateImage'],
                      width: 300,
                      height: 300,
                    ),
                  ),
                  ListTile(
                    title: Text('Name: ${data['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${data['email']}'),
                        Text('Date: $formattedDate'),
                        Text('Skill: ${data['skill']}'),
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
