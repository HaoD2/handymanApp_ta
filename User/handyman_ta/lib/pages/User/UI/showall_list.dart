import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/UI/chat_page.dart';
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

  final NumberFormat formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  Future<void> _refresh() {
    setState(() {
      getDataReqList();
    });
    return Future.delayed(Duration(seconds: 2));
  }

  String userName = '';
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
    List<DocumentSnapshot> filteredDocs = querySnapshot.docs.where((doc) {
      return doc['status'] != 'success' && doc['status'] != 'cancel';
    }).toList();

    // Mengembalikan hasil jika tidak kosong, atau null jika tidak ada hasil
    if (filteredDocs.isNotEmpty) {
      return filteredDocs;
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
      body: RefreshIndicator(
        child: Container(
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
            builder:
                (context, AsyncSnapshot<List<DocumentSnapshot>?> snapshot) {
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
                    String pengirimHandyman = data['taken_by'] ?? "";
                    String pengirimUser = data['user'];
                    String uid_pemesanan = data['uid'];
                    // Set icon based on the status name

                    return Card(
                      margin: EdgeInsets.all(15),
                      child: Container(
                        height: 400,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${data['uid']}',
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                              margin: EdgeInsets.all(5),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${data['tipe_pekerjaan']}',
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                              margin: EdgeInsets.all(5),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Option: ${data['Option'].join(', ')}',
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Harga: ',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    alignment: Alignment.centerRight,
                                    child: Text(formatCurrency.format(
                                        int.parse(data['price'].toString()))),
                                  ),
                                ),
                              ],
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
                            SizedBox(
                              height: 40,
                            ),
                            Container(
                              margin: EdgeInsets.all(5),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Taken By',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),

                            // This is the Card you want below
                            Card(
                              elevation: 3,
                              child: ListTile(
                                leading: CircleAvatar(
                                  // Example icon, you can replace this with your own icon
                                  child: Icon(Icons.person_2_rounded),
                                ),
                                title: FutureBuilder<List<DocumentSnapshot>>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .where('email',
                                          isEqualTo: data['taken_by'])
                                      .get()
                                      .then((snapshot) => snapshot
                                          .docs), // Mengonversi ke List<DocumentSnapshot>
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<DocumentSnapshot>>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Loading...');
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Text('Belum mendapatkan Handyman');
                                    }

                                    // Ambil data nama pengguna dari snapshot
                                    userName = snapshot.data!.first[
                                        'nama']; // Ganti 'nama' dengan field yang sesuai
                                    return Text(userName);
                                  },
                                ),
                                subtitle: StreamBuilder<List<DocumentSnapshot>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('rating_user')
                                      .where('nama_user',
                                          isEqualTo: data['taken_by'])
                                      .snapshots()
                                      .map((query) => query
                                          .docs), // Konversi QuerySnapshot ke List<DocumentSnapshot>
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<DocumentSnapshot>>
                                          snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!.isNotEmpty) {
                                      double totalRating = 0;
                                      int count = snapshot.data!.length;

                                      for (var document in snapshot.data!) {
                                        totalRating += double.parse(
                                            document['nilai_Rating']
                                                .toString());
                                      }

                                      double averageRating =
                                          totalRating / count;

                                      return Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.blueAccent),
                                          SizedBox(width: 4),
                                          Text(
                                              'Rating: ${averageRating.toStringAsFixed(1)}'),
                                        ],
                                      );
                                    } else {
                                      return Container(); // Placeholder jika data rating belum tersedia
                                    }
                                  },
                                ),
                                trailing: (pengirimHandyman != null &&
                                        pengirimHandyman != "")
                                    ? IconButton(
                                        onPressed: () {
                                          // Handle navigation to other page here
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  pengirimHandyman,
                                                  pengirimUser,
                                                  uid_pemesanan,
                                                  userName),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.message),
                                      )
                                    : null, // Tidak menampilkan ikon jika tidak ada handyman // Tidak menampilkan ikon jika tidak ada handyman
                              ),
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
        onRefresh: _refresh,
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
      width: 50, // Lebar garis
      color: Colors.grey,
    );
  }
}
