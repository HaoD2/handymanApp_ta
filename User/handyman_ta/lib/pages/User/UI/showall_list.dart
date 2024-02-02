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
    QuerySnapshot querySnapshot =
        await _request_handyman.where('user', isEqualTo: user.email).get();

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
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: 600,
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/home_decoration.png',
              ),
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),
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

                    // Set color based on the status
                    Color statusColor;
                    switch (data['status']) {
                      case 'pending':
                        statusColor = const Color.fromARGB(212, 255, 235,
                            59); // Set your desired color for pending status
                        break;
                      case 'on-progress':
                        statusColor = Colors
                            .blue; // Set your desired color for on-progress status
                        break;
                      case 'success':
                        statusColor = const Color.fromARGB(255, 64, 255,
                            71); // Set your desired color for success status
                        break;
                      default:
                        statusColor = Colors
                            .black; // Set default color or any other color
                    }

                    return Card(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${data['uid']}',
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${data['tipe_pekerjaan']}',
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Option: ${data['Option'].join(', ')}',
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Harga: ${data['price']}',
                            ),
                          ),
                          // ... (Repeat the process for other Text widgets)
                          Container(
                            margin: EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Status: ${data['status']}',
                              style: TextStyle(color: statusColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                    child: Text(
                  'Belum ada Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black87,
                    fontFamily: 'OpenSans',
                  ),
                ));
              }
            },
          ),
        ));
  }
}
