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
          builder: (context, kontakSnapshot) {
            if (!kontakSnapshot.hasData) {
              return CircularProgressIndicator();
            }

            var contacts = kontakSnapshot.data!.docs;

            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                var contact = contacts[index];
                var pengirimHandyman = contact['pengirimHandyman'];
                var pengirimUser = contact['pengirimUser'];
                var uid_pemesanan = contact['uid_pemesanan'];

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('request_handyman')
                      .where('uid', isEqualTo: uid_pemesanan.toString())
                      .where('taken_by',
                          isEqualTo: FirebaseAuth.instance.currentUser?.email)
                      .where('status_done', isEqualTo: false)
                      .get(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    // Ambil dokumen pertama dari QuerySnapshot
                    var requestData = snapshot.data!.docs.isNotEmpty
                        ? snapshot.data!.docs.first
                        : null;

                    print(
                        'Snapshot data length: ${snapshot.data!.docs.length}'); // Debugging

                    if (requestData == null) {
                      // Debugging
                      return Container();
                    }
                    // Akses data dari dokumen
                    var tipe_pekerjaan = requestData['tipe_pekerjaan'];
                    var uid = requestData['uid'];

                    // Dapatkan nama pengguna dari koleksi 'users'
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: pengirimUser)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> userSnapshot) {
                        if (userSnapshot.hasError) {
                          return Text("Error: ${userSnapshot.error}");
                        }

                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        var users = userSnapshot.data!.docs;
                        var namaPengguna = users.isNotEmpty
                            ? users.first['nama']
                            : 'Nama Tidak Ditemukan';

                        return Padding(
                          padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 8.0,
                              bottom: 8.0), // Tambahkan jarak vertikal di sini
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(
                                      'assets/images/icon_profile.png'),
                                ),
                              ],
                            ),
                            title: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height:
                                          8), // Tambahkan jarak vertikal di sini
                                  Text(
                                    namaPengguna,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          4), // Tambahkan jarak vertikal di sini
                                  Text(
                                    '$tipe_pekerjaan - $uid',
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
                          ),
                        );
                      },
                    );
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
