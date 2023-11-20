import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myhandyman_handyman/model/message.dart';
import 'package:myhandyman_handyman/page/userHandyman.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  final String penerimaEmail;
  final String pengirimEmail;
  final String uid_pemesanan;

  const ChatPage(this.penerimaEmail, this.pengirimEmail, this.uid_pemesanan);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _pesanController = TextEditingController();
  var isiPesan = "";
  String formatTimeAgo(Timestamp timestamp) {
    DateTime dateTime =
        timestamp.toDate(); // Konversi Timestamp menjadi DateTime
    final timeAgo = timeago
        .format(dateTime); // Gunakan package timeago untuk memformat waktu
    return timeAgo.toString();
  }

  void Retrieve(String email) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();
    print(email);
    final token_sent = querySnapshot.docs.first['token_messaging'];
    final res =
        await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAABgovCRU:APA91bF15_FRtWqDNVDRCh4pVO8jZ02d_HgZ_NJ3QwlNSV-xdUfVgHMCvU9yBqXOGISrAIIdTfwyQjDd_q79A2ngZb_wqHWbgpbh6MnJXz535dlZdSSZQuHswin78LEmYuZowrtvAv-D'
            },
            body: jsonEncode(<String, dynamic>{
              'priority': 'high',
              'data': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'body': 'MyHandyman',
                'title': 'Halo ' + email + 'kamu mendapatkan Chat',
              },
              'notification': {
                'body': 'MyHandyman',
                'title': 'Halo ' + email + 'kamu mendapatkan Chat',
                'android_channel_id': "dbFood"
              },
              "to": token_sent
            }));
    if (res.statusCode == 200) {
      print('>>>>>>>>>>>>>>>>>>>>success');
      final responseData = jsonDecode(res.body);
    } else {
      print(res.body);
      print(res.statusCode.toString() + ">>>>>");
      print('>>>>>>>>>>>>>>>>>>>>gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat dengan ${widget.penerimaEmail}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return userHandyman();
                },
              ),
              (_) => false,
            ); // Kembali ke halaman sebelumnya
          },
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: Text('Done'),
                value: 'done',
              ),
              PopupMenuItem(
                child: Text('Cancel'),
                value: 'cancel',
              ),
            ],
            onSelected: (value) async {
              // Tambahkan logika sesuai dengan item yang dipilih
              if (value == 'done') {
                await FirebaseFirestore.instance
                    .collection('kontak')
                    .where('penerimaEmail', isEqualTo: widget.penerimaEmail)
                    .where('pengirimEmail', isEqualTo: widget.pengirimEmail)
                    .get()
                    .then((querySnapshot) {
                  querySnapshot.docs.forEach((doc) {
                    // Perbarui nilai isDone menjadi false
                    doc.reference.update({'isDone': false});
                  });
                });
              } else if (value == 'cancel') {
                // Logika ketika Cancel dipilih
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('log_pesan')
                  .where('penerimaEmail', isEqualTo: this.widget.penerimaEmail)
                  .where('pengirimEmail', isEqualTo: this.widget.pengirimEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var messages = snapshot.data!.docs;
                messages.sort((a, b) {
                  Timestamp timeA = a['waktu'] as Timestamp;
                  Timestamp timeB = b['waktu'] as Timestamp;
                  return timeA.compareTo(
                      timeB); // Mengurutkan dari yang terbaru ke yang terlama
                });

                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var isiPesan = message['isiPesan'];
                  if (isiPesan != null || isiPesan.isNotEmpty) {
                    var isDone = message['isDone'];
                    var sent = message['sent'];
                    var pengirimUID = message['pengirimEmail'];
                    var waktu = message['waktu'];
                    bool isCurrentUser =
                        sent == FirebaseAuth.instance.currentUser!.email;
                    messageWidgets.add(Align(
                      alignment: isCurrentUser
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue : Colors.grey,
                          borderRadius: isCurrentUser
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                  topRight: Radius.circular(30))
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                        ),
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Text(
                              isiPesan,
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              formatTimeAgo(waktu),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ));
                  }
                }
                return Column(
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _pesanController,
                    decoration: InputDecoration(labelText: 'Pesan'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _kirimPesan();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _kirimPesan() {
    var pesan = _pesanController.text;
    _pesanController.clear();

    var message = Message_Log(
      pengirimEmail:
          this.widget.pengirimEmail, // Gantilah dengan ID pengirim yang sesuai
      penerimaEmail: this.widget.penerimaEmail,
      isiPesan: pesan,
      sent: FirebaseAuth.instance.currentUser!.email.toString(),
      isDone: true,
      waktu: DateTime.now(),
      uid_pemesanan: this.widget.uid_pemesanan,
    );

    FirebaseFirestore.instance.collection('log_pesan').add(message.toMap());
    Retrieve(this.widget.penerimaEmail);
    print(this.widget.penerimaEmail);
  }
}
