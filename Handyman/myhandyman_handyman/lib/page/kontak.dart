import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myhandyman_handyman/page/chat_page.dart';

class KontakPage extends StatefulWidget {
  @override
  _KontakPageState createState() => _KontakPageState();
}

class _KontakPageState extends State<KontakPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kontak'),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('kontak')
              .where('pengirimHandyman',
                  isEqualTo: FirebaseAuth.instance.currentUser?.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            var contacts = snapshot.data!.docs;
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                var contact = contacts[index];
                var pengirimHandyman = contact['pengirimHandyman'];
                var pengirimUser = contact['pengirimUser'];
                var uid_pemesanan = contact['uid_pemesanan'];
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection(
                          'request_handyman') // Ganti dengan nama koleksi yang sesuai
                      .where('uid',
                          isEqualTo:
                              uid_pemesanan) // Ganti dengan nama dokumen atau UID yang sesuai
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      // Ambil data dari snapshot yang diperoleh
                      var data = snapshot.data!.docs.first.data();
                      if (data is Map<String, dynamic>) {
                        var tipe_pekerjaan = data['tipe_pekerjaan'];
                        var pemesananUID = data['uid'];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                    'assets/images/icon_profile.png'),
                              )
                            ],
                          ),
                          title: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .start, // Untuk membuat teks menjadi rata di kiri
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Untuk mengatur teks ke kiri
                              children: [
                                Text(
                                  pengirimHandyman,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  tipe_pekerjaan + " - " + pemesananUID,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return ChatPage(pengirimHandyman,
                                      pengirimUser, uid_pemesanan);
                                },
                              ),
                              (_) => false,
                            );
                          },
                        );
                      }
                    }

                    return CircularProgressIndicator(); // Tampilkan loading jika data sedang diambil
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
