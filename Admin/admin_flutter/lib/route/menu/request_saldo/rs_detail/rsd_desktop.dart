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
      body: Container(
        child: FutureBuilder<QuerySnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Data not found'));
            } else {
              var data =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Container with gradient background for the title and text
                    Container(
                      height: 250,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue, // First color of the gradient
                            Colors.purple, // Second color of the gradient
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Display the card's title in white color for better contrast
                            Container(
                              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Display the card's text
                                  Text(
                                    'Email: ${data['email']}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'No rekening: ${data['no_rekening']}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Date: ${data['tanggal'].toString().substring(0, 19)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Bank Destination: ${data['bank']}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // Add a row with two buttons spaced apart and aligned to the right side of the card
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(height: 5),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
