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
  bool isChatDone = false;
  bool _notProfessional = false;
  bool _badService = false;
  bool _poorCommunication = false;
  bool _unclearCost = false;
  var isiPesan = "";
  String formatTimeAgo(Timestamp timestamp) {
    DateTime dateTime =
        timestamp.toDate(); // Konversi Timestamp menjadi DateTime
    final timeAgo = timeago
        .format(dateTime); // Gunakan package timeago untuk memformat waktu
    return timeAgo.toString();
  }

  Future<void> updateIsReportDone() async {
    try {
      await FirebaseFirestore.instance
          .collection('kontak')
          .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          FirebaseFirestore.instance
              .collection('kontak')
              .doc(doc.id)
              .update({'isReportDone': true});
        });
      });
    } catch (e) {
      print('Error updating isRatingDone: $e');
      // Handle error jika diperlukan
    }
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

  Widget buildMessageOnly() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('log_pesan')
            .where('penerimaEmail', isEqualTo: widget.penerimaEmail)
            .where('pengirimEmail', isEqualTo: widget.pengirimEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var messages = snapshot.data!.docs;
          messages.sort((a, b) {
            Timestamp timeA = a['waktu'] as Timestamp;
            Timestamp timeB = b['waktu'] as Timestamp;
            return timeA.compareTo(timeB);
          });
          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              var isiPesan = message['isiPesan'];
              var sent = message['sent'];
              var waktu = message['waktu'];
              bool isCurrentUser =
                  sent == FirebaseAuth.instance.currentUser!.email;

              var reversedIndex = (messages.length - 1) - index;
              return Align(
                alignment:
                    isCurrentUser ? Alignment.topRight : Alignment.topLeft,
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

// Fungsi untuk menampilkan tombol "Rating" dan "Report"
  Widget buildRatingAndReportButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 10),
        ElevatedButton(
          child: Text('Report'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                String _reportComment = '';
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      title: Text('Report User - Pilih Pelanggaran'),
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
                          CheckboxListTile(
                            title: Text('Kualitas Buruk'),
                            value: _badService,
                            onChanged: (value) {
                              setState(() {
                                _badService = value!;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: Text('Tidak Responsif'),
                            value: _poorCommunication,
                            onChanged: (value) {
                              setState(() {
                                _poorCommunication = value!;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: Text('Kesalahan Biaya'),
                            value: _unclearCost,
                            onChanged: (value) {
                              setState(() {
                                _unclearCost = value!;
                              });
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Tambahkan komentar (opsional)',
                            ),
                            onChanged: (value) {
                              _reportComment = value;
                            },
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Tutup dialog
                          },
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Handle submit here
                            try {
                              QuerySnapshot querySnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('request_handyman')
                                      .where('uid',
                                          isEqualTo: this.widget.uid_pemesanan)
                                      .get();
                              if (querySnapshot.docs.isNotEmpty) {
                                // Ambil nilai tipe_pekerjaan dari dokumen pertama yang cocok dengan kondisi
                                String tipePekerjaan =
                                    querySnapshot.docs.first['tipe_pekerjaan'];
                                tambahReport(
                                    FirebaseAuth.instance.currentUser!.email
                                        .toString(),
                                    this.widget.penerimaEmail,
                                    DateTime.now(),
                                    _reportComment,
                                    _notProfessional,
                                    _badService,
                                    _poorCommunication,
                                    _unclearCost);
                                updateIsReportDone();
                              } else {
                                return null; // Tidak ada dokumen dengan kondisi yang diberikan
                              }
                            } catch (e) {
                              print('Error: $e');
                              return null;
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> tambahReport(
    String namaPelapor,
    String namaTerlapor,
    DateTime tanggalPelanggaran,
    String keteranganPelanggaran,
    bool notProfessional,
    bool badService,
    bool poorCommunication,
    bool unclearCost,
  ) async {
    CollectionReference reportCollection =
        FirebaseFirestore.instance.collection('pelanggaran_user');
    await reportCollection.add({
      'nama_pelapor': namaPelapor,
      'nama_terlapor': namaTerlapor,
      'tanggal_pelanggaran': tanggalPelanggaran,
      'option_keterangan': {
        'Pelayanan Buruk': badService,
        'Komunikasi Kurang': poorCommunication,
        'Ketidakjelasan': unclearCost
      },
      'keterangan_pelanggaran': keteranganPelanggaran,
    });
  }

  void iSDone(String email) async {
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
                'title': ' Pemesanan kamu Sudah Selesai !',
              },
              'notification': {
                'body': 'MyHandyman',
                'title': ' Pemesanan kamu Sudah Selesai !',
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
                    .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
                    .get()
                    .then((querySnapshot) {
                  querySnapshot.docs.forEach((doc) {
                    // Perbarui nilai isDone menjadi true
                    doc.reference.update({'isDone': true}).then((value) {
                      print('Nilai isDone telah diperbarui menjadi true');

                      // Lakukan pengecekan isDone
                      FirebaseFirestore.instance
                          .collection('kontak')
                          .where('uid_pemesanan',
                              isEqualTo: this.widget.uid_pemesanan)
                          .get()
                          .then((updatedSnapshot) {
                        var updatedDocs = updatedSnapshot.docs;
                        if (updatedDocs.isNotEmpty) {
                          var updatedIsDone = updatedDocs.first['isDone'];

                          // Jika isDone sudah true, panggil fungsi isDone()
                          if (updatedIsDone) {
                            print("isdone alert masuk");
                            iSDone(this.widget.penerimaEmail);
                          }
                        }
                        // Jika isDone sudah true, panggil fungsi isDone()
                      });
                    }).catchError((error) {
                      print('Gagal memperbarui nilai isDone: $error');
                    });
                  });
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('kontak')
              .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Jika tidak ada data atau dokumen kosong
              return Center(
                child: Text('Tidak ada data'),
              );
            } else {
              var isReportdone =
                  snapshot.data!.docs.first['isReportDone'] ?? false;
              return isReportdone
                  ? buildMessageOnly()
                  : Column(
                      children: <Widget>[
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('log_pesan')
                                .where('penerimaEmail',
                                    isEqualTo: this.widget.penerimaEmail)
                                .where('pengirimEmail',
                                    isEqualTo: this.widget.pengirimEmail)
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
                                    bool isCurrentUser = sent ==
                                        FirebaseAuth
                                            .instance.currentUser!.email;

                                    var reversedIndex =
                                        (messages.length - 1) - index;
                                    return Align(
                                      alignment: isCurrentUser
                                          ? Alignment.topRight
                                          : Alignment.topLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isCurrentUser
                                              ? Colors.blue
                                              : Colors.grey,
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
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              formatTimeAgo(waktu),
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                      .where('uid_pemesanan',
                                          isEqualTo: widget.uid_pemesanan)
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
                    );
            }
          }),
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
      isDone: false,
      waktu: DateTime.now(),
      uid_pemesanan: this.widget.uid_pemesanan,
    );

    FirebaseFirestore.instance.collection('log_pesan').add(message.toMap());
    Retrieve(this.widget.penerimaEmail);
    print(this.widget.penerimaEmail);
  }
}
