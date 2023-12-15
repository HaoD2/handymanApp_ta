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

  int _rating = 0;
  bool isChatDone = false;
  bool _notProfessional = false;
  bool _badService = false;
  bool _poorCommunication = false;
  bool _unclearCost = false;
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
                String _ratingComment = '';
                return AlertDialog(
                  title: Text('Beri Rating'),
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Score: $_rating/5'),
                          Slider(
                            value: _rating.toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            onChanged: (value) {
                              setState(() {
                                _rating = value.round();
                              });
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Tambahkan komentar (opsional)',
                            ),
                            onChanged: (value) {
                              _ratingComment = value;
                            },
                          ),
                        ],
                      );
                    },
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
                        // Lakukan sesuatu dengan nilai _rating
                        print('Rating: $_rating');
                        try {
                          QuerySnapshot querySnapshot = await FirebaseFirestore
                              .instance
                              .collection('request_handyman')
                              .where('uid',
                                  isEqualTo: this.widget.uid_pemesanan)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            // Ambil nilai tipe_pekerjaan dari dokumen pertama yang cocok dengan kondisi
                            String tipePekerjaan =
                                querySnapshot.docs.first['tipe_pekerjaan'];
                            tambahRatingLayanan(
                                tipePekerjaan, _rating, _ratingComment);
                            updateIsRatingDone();
                          } else {
                            return null; // Tidak ada dokumen dengan kondisi yang diberikan
                          }
                        } catch (e) {
                          print('Error: $e');
                          return null;
                        }

                        setState(() {
                          isChatDone = true;
                          _rating =
                              0; // Reset rating setelah disubmit jika diperlukan
                        });
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
                          onPressed: () {
                            // Handle submit here

                            tambahReport(
                                FirebaseAuth.instance.currentUser!.email
                                    .toString(),
                                this.widget.pengirimEmail,
                                DateTime.now(),
                                _reportComment,
                                _notProfessional,
                                _badService,
                                _poorCommunication,
                                _unclearCost);
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
        )
      ],
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

  Future<DocumentReference> tambahRatingLayanan(
    String namaLayanan,
    int nilaiRating,
    String komentar,
  ) async {
    CollectionReference ratingLayananCollection =
        FirebaseFirestore.instance.collection('rating_layanan');

    return await ratingLayananCollection.add({
      'nama_layanan': namaLayanan,
      'nilai_Rating': nilaiRating,
      'komentar': komentar,
    });
  }

// Fungsi untuk menambahkan data report ke dalam dokumen rating yang ada
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
        FirebaseFirestore.instance.collection('pelanggaran_handyman');
    await reportCollection.add({
      'nama_pelapor': namaPelapor,
      'nama_terlapor': namaTerlapor,
      'tanggal_pelanggaran': tanggalPelanggaran,
      'option_keterangan': {
        'tidak_professional': notProfessional,
        'Pelayanan Buruk': badService,
        'Komunikasi Kurang': poorCommunication,
        'Ketidakjelasan': unclearCost
      },
      'keterangan_pelanggaran': keteranganPelanggaran,
    });
  }

  Future<void> updateIsRatingDone() async {
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
              .update({'isRatingDone': true});
        });
      });
    } catch (e) {
      print('Error updating isRatingDone: $e');
      // Handle error jika diperlukan
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
                var isRatingDone =
                    snapshot.data!.docs.first['isRatingDone'] ?? false;

                return isRatingDone
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
                                      var pengirimUID =
                                          message['pengirimEmail'];
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
            }));
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
