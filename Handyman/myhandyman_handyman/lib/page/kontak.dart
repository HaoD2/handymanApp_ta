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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kontak')
            .where('pengirimEmail',
                isEqualTo: FirebaseAuth.instance.currentUser?.email)
            .where('isDone', isEqualTo: true)
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
              var penerimaUID = contact['penerimaEmail'];
              var pengirimUID = contact['pengirimEmail'];
              var uid_pemesanan = contact['uid_pemesanan'];
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
                title: Text(
                  penerimaUID,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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
            },
          );
        },
      ),
    );
  }
}
