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
            image: AssetImage('assets/images/home_decoration.png'),
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
            if (kontakSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (kontakSnapshot.hasError) {
              return Center(child: Text("Error: ${kontakSnapshot.error}"));
            }
            if (!kontakSnapshot.hasData || kontakSnapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tidak ada Kontak'));
            }

            var contacts = kontakSnapshot.data!.docs;
            List<DocumentSnapshot> filteredContacts = [];

            return FutureBuilder(
              future: Future.wait(contacts.map((contact) async {
                var uid_pemesanan = contact['uid_pemesanan'];

                var requestSnapshot = await FirebaseFirestore.instance
                    .collection('request_handyman')
                    .where('uid', isEqualTo: uid_pemesanan.toString())
                    .where('taken_by',
                        isEqualTo: FirebaseAuth.instance.currentUser?.email)
                    .where('status_done', isEqualTo: false)
                    .get();

                // Hanya tambahkan data kontak yang memiliki request yang belum selesai
                if (requestSnapshot.docs.isNotEmpty) {
                  filteredContacts.add(contact);
                }
              })),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Jika tidak ada kontak yang memenuhi syarat, tampilkan pesan "Tidak ada Kontak"
                if (filteredContacts.isEmpty) {
                  return Center(child: Text('Tidak ada Kontak'));
                }

                return ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    var contact = filteredContacts[index];
                    var pengirimHandyman = contact['pengirimHandyman'];
                    var pengirimUser = contact['pengirimUser'];
                    var uid_pemesanan = contact['uid_pemesanan'];

                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('request_handyman')
                          .where('uid', isEqualTo: uid_pemesanan.toString())
                          .where('taken_by',
                              isEqualTo:
                                  FirebaseAuth.instance.currentUser?.email)
                          .where('status_done', isEqualTo: false)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }

                        var requestData = snapshot.data!.docs.first;
                        var tipe_pekerjaan = requestData['tipe_pekerjaan'];
                        var uid = requestData['uid'];

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('email', isEqualTo: pengirimUser)
                              .snapshots(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (userSnapshot.hasError) {
                              return Text("Error: ${userSnapshot.error}");
                            }

                            var users = userSnapshot.data!.docs;
                            var namaPengguna = users.isNotEmpty
                                ? users.first['nama']
                                : 'Nama Tidak Ditemukan';

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
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
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      namaPengguna,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
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
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return ChatPage(
                                            pengirimHandyman,
                                            pengirimUser,
                                            uid_pemesanan,
                                            namaPengguna);
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
            );
          },
        ),
      ),
    );
  }
}
