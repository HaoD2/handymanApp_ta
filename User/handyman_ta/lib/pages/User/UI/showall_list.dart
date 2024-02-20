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
        .where('user', isEqualTo: user.email)
        .where('status_done', isEqualTo: false)
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
            ),
          ),
        ),
        title: const Text("Details"),
        centerTitle: true,
      ),
      body: Container(
        constraints: BoxConstraints(
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: 700,
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
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
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

                  // Set icon based on the status name

                  return Card(
                    margin: EdgeInsets.all(15),
                    child: Container(
                      height: 350,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildProgressIndicator(
                                  'Pending',
                                  data['status'] == 'pending',
                                  Icons.pending_actions),
                              _buildProgressLine(),
                              _buildProgressIndicator(
                                  'On Progress',
                                  data['status'] == 'on-progress',
                                  Icons.hourglass_empty),
                              _buildProgressLine(),
                              _buildProgressIndicator(
                                  'Success',
                                  data['status'] == 'success',
                                  Icons.check_circle),
                            ],
                          ),
                        ],
                      ),
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
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
      String label, bool isActive, IconData statusIcon) {
    return Column(
      children: [
        Container(
          width: 50, // Ubah lebar sesuai kebutuhan Anda
          height: 50, // Ubah tinggi sesuai kebutuhan Anda
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          child: Icon(
            statusIcon,
            color: Colors.white,
            size: 30, // Ubah ukuran ikon sesuai kebutuhan Anda
          ),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    );
  }

  Widget _buildProgressLine() {
    return Container(
      height: 2,
      width: 80, // Lebar garis
      color: Colors.grey,
    );
  }
}
