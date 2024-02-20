import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/Model/kontak.dart';
import 'package:handyman_ta/pages/User/UI/chat_page.dart';

class Kontak_User extends StatefulWidget {
  final email;
  const Kontak_User({super.key, this.email});

  @override
  State<Kontak_User> createState() => _Kontak_UserState();
}

class _Kontak_UserState extends State<Kontak_User> {
  Future<List<kontak_user>> getDatas() async {
    kontakService kontak_userService = kontakService();
    List<kontak_user> dataList = await kontak_userService
        .getkontakListRand(FirebaseAuth.instance.currentUser!.email.toString());

    print(dataList.length);
    return dataList;
  }

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
              .where('pengirimUser',
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
                      .where('user',
                          isEqualTo: FirebaseAuth.instance.currentUser?.email)
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
                          .where('email', isEqualTo: pengirimHandyman)
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaPengguna,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                            // Navigator.of(context, rootNavigator: true)
                            //     .pushAndRemoveUntil(
                            //   MaterialPageRoute(
                            //     builder: (BuildContext context) {
                            //       return ChatPage(pengirimUser,
                            //           pengirimHandyman, uidPemesanan);
                            //     },
                            //   ),
                            //   (_) => false,
                            // );
