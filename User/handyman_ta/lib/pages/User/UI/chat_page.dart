import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handyman_ta/pages/Model/message.dart';
import 'package:handyman_ta/pages/User/home.dart';
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

  String formatTimeAgo(Timestamp timestamp) {
    DateTime dateTime =
        timestamp.toDate(); // Konversi Timestamp menjadi DateTime
    final timeAgo = timeago
        .format(dateTime); // Gunakan package timeago untuk memformat waktu
    return timeAgo.toString();
  }

  double _rating = 0;
  bool _notProfessional = false;
  bool _badService = false;
  bool _poorCommunication = false;
  bool _unclearCost = false;
  bool _fraudulent = false;
  void Retrieve(String email) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();
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

  Widget buildRatingAndReportButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: Text('Rating'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Beri Rating'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Score: $_rating/5'),
                      Slider(
                        value: _rating,
                        min: 0,
                        max: 5,
                        divisions: 5,
                        onChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Tutup dialog
                      },
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Lakukan sesuatu dengan nilai _rating
                        Navigator.of(context).pop(); // Tutup dialog
                      },
                      child: Text('Submit'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        SizedBox(width: 10),
        ElevatedButton(
          child: Text('Report'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Report User'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CheckboxListTile(
                        title: Text('Tidak Professional'),
                        value: _notProfessional,
                        onChanged: (value) {
                          setState(() {
                            _notProfessional = value!;
                          });
                        },
                      ),
                      // CheckboxListTile lainnya disini
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Tutup dialog
                      },
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Lakukan sesuatu dengan variabel boolean yang sudah diperbarui
                        Navigator.of(context).pop(); // Tutup dialog
                      },
                      child: Text('Submit'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget buildSubmitButton() {
    return Padding(
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
    );
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
                  return userHomepage(
                    email: FirebaseAuth.instance.currentUser?.email,
                  );
                },
              ),
              (_) => false,
            ); // Kembali ke halaman sebelumnya
          },
        ),
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
                return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      var isiPesan = message['isiPesan'];
                      var sent = message['sent'];
                      var pengirimUID = message['pengirimEmail'];
                      var waktu = message['waktu'];
                      bool isCurrentUser =
                          sent == FirebaseAuth.instance.currentUser!.email;

                      var reversedIndex = (messages.length - 1) - index;
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
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
                              // Tambahkan bagian lain seperti informasi pengirim, status, dll. sesuai kebutuhan
                            ],
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('kontak')
                        .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      var contacts = snapshot.data!.docs;
                      bool isDone = false;

                      if (contacts.isNotEmpty) {
                        isDone = contacts.first['isDone'];
                      }

                      // Tampilkan tombol berdasarkan nilai isDone
                      if (isDone) {
                        return buildRatingAndReportButtons();
                      } else {
                        return buildSubmitButton();
                      }
                    },
                  ),
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
    Retrieve(this.widget.pengirimEmail);
  }
}
