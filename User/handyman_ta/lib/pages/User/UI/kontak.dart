import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/UI/chat_page.dart';

class Kontak_User extends StatefulWidget {
  final email;
  const Kontak_User({super.key, this.email});

  @override
  State<Kontak_User> createState() => _Kontak_UserState();
}

class _Kontak_UserState extends State<Kontak_User> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kontak')
          .where('penerimaEmail',
              isEqualTo: FirebaseAuth.instance.currentUser?.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var contacts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              var contact = contacts[index];
              var penerimaUID = contact['penerimaEmail'];
              var pengirimUID = contact['pengirimEmail'];
              var uid_pemesanan = contact['uid_pemesanan'];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('request_handyman')
                    .where('uid', isEqualTo: uid_pemesanan)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
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
                              backgroundImage:
                                  AssetImage('assets/images/icon_profile.png'),
                            )
                          ],
                        ),
                        title: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pengirimUID,
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
                                return ChatPage(
                                    penerimaUID, pengirimUID, uid_pemesanan);
                              },
                            ),
                            (_) => false,
                          );
                        },
                      );
                    }
                  }

                  return CircularProgressIndicator();
                },
              );
            },
          );
        }
      },
    );
  }
}
