import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:intl/intl.dart';

class showAll_list extends StatefulWidget {
  final email;
  const showAll_list({super.key, this.email});
  static const routeName = '/User/activity_list';
  @override
  State<showAll_list> createState() => _showAll_listState();
}

class _showAll_listState extends State<showAll_list> {
  final CollectionReference _request_handyman =
      FirebaseFirestore.instance.collection('request_handyman');

  final currencyFormatter = NumberFormat('#,##0.00', 'ID');
  Future<List<DocumentSnapshot>?> getDataReqList() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null; // Pengguna tidak masuk, mengembalikan null
    }

    // Mengambil semua dokumen dengan kondisi status adalah "pending" atau "acquired"
    QuerySnapshot querySnapshot = await _request_handyman
        .where('status', whereIn: ['pending', 'acquired'])
        .where('user', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs;
    } else {
      return null; // Tidak ada dokumen yang cocok, mengembalikan null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const userHomepage(),
                )),
          ),
          title: const Text("Details"),
          centerTitle: true,
        ),
        body: Container(
          child: FutureBuilder<List<DocumentSnapshot>?>(
            future: getDataReqList(),
            builder:
                (context, AsyncSnapshot<List<DocumentSnapshot>?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.isNotEmpty) {
                List<DocumentSnapshot> documents = snapshot.data!;
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    var data = documents[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text('${data['tipe_Pekerjaan']}')),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text('Option: ${data['Option'].join(', ')}'),
                          ), // Join the array elements
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text('End Time: ${data['end_time']}')),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text('Start Time: ${data['start_time']}')),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text('Address: ${data['address']}')),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text('Status: ${data['status']}')),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Text('No data available');
              }
            },
          ),
        ));
  }
}
