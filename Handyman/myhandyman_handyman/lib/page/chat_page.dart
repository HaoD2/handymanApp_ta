import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myhandyman_handyman/model/message.dart';
import 'package:myhandyman_handyman/page/userHandyman.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:myhandyman_handyman/service/messagingService.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  final String pengirimUser;
  final String pengirimHandyman;
  final String uid_pemesanan;

  const ChatPage(this.pengirimHandyman, this.pengirimUser, this.uid_pemesanan);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _pesanController = TextEditingController();
  bool isChatDone = false;
  bool _notProfessional = false;
  bool _badService = false;
  int _rating = 1;
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
              .update({'isReportDoneHandyman': true});
        });
      });
    } catch (e) {
      print('Error updating isRatingDone: $e');
      // Handle error jika diperlukan
    }
  }

  void Retrieve(String email) async {
    final messaging = MessagingService();
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();
    print(email);

    if (querySnapshot.docs.isNotEmpty) {
      final token_sent = querySnapshot.docs.first['token_messaging'];
      messaging.sendFCMMessage(messaging.getToken().toString(), token_sent,
          "pesan", "Ada Pesan Baru!");
    } else {
      print('No document found with the provided email.');
    }
  }

  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
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
                if (_pesanController.text.isNotEmpty) {
                  _kirimPesan();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pesan tidak boleh kosong!'),
                      duration:
                          Duration(seconds: 2), // Optional, durasi snackbar
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

//Fungsi ketika sudah submit
  Widget buildMessageOnly() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('log_pesan')
            .where('pengirimUser', isEqualTo: widget.pengirimUser)
            .where('pengirimHandyman', isEqualTo: widget.pengirimHandyman)
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

//tambh rating nilai layanan
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
              .update({'isRatingDoneHandyman': true});
        });
      });
    } catch (e) {
      print('Error updating isRatingDone: $e');
      // Handle error jika diperlukan
    }
  }

// Fungsi untuk menampilkan tombol "Rating" dan "Report"
  Widget buildRatingAndReportButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: Text('Rating Layanan'),
          onPressed: () async {
            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection('kontak')
                .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
                .where('isRatingDoneHandyman', isEqualTo: false)
                .get();

            if (querySnapshot.docs.isNotEmpty) {
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
                              min: 1,
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
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Warning'),
                    content: Text('Kamu sudah memberikan rating!'),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
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
                                    this.widget.pengirimUser,
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
    final sendMessage = MessagingService();
    QuerySnapshot querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();
    final token_sent = querySnapshot.docs.first['token_messaging'];
    sendMessage.sendFCMMessage(sendMessage.getAccessToken().toString(),
        token_sent, "Pemesanan MyHandyman", "Pemesanan kamu Sudah Selesai !");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat dengan ${widget.pengirimUser}'),
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
                      doc.reference
                          .update({'isDoneHandyman': true}).then((value) {
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
                            var updatedIsDone =
                                updatedDocs.first['isDoneHandyman'];

                            // Jika isDone sudah true, panggil fungsi isDone()
                            if (updatedIsDone) {
                              print("isdone alert masuk");
                              iSDone(this.widget.pengirimUser);
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
                    snapshot.data!.docs.first['isReportDoneHandyman'] ?? false;
                return isReportdone
                    ? buildMessageOnly()
                    : Column(
                        children: <Widget>[
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('log_pesan')
                                  .where('pengirimUser',
                                      isEqualTo: this.widget.pengirimUser)
                                  .where('pengirimHandyman',
                                      isEqualTo: this.widget.pengirimHandyman)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                var messages = snapshot.data!.docs;
                                messages.sort((a, b) {
                                  Timestamp timeA = a['waktu'] as Timestamp;
                                  Timestamp timeB = b['waktu'] as Timestamp;
                                  return timeB.compareTo(
                                      timeA); // Mengurutkan dari yang terlama ke yang terbaru
                                });
                                return ListView.builder(
                                    reverse: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      var message = messages[index];
                                      var isiPesan = message['isiPesan'];
                                      var sent = message['sent'];
                                      var pengirimUID =
                                          message['pengirimHandyman'];
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
                                        isDone =
                                            contacts.first['isDoneHandyman'];
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
      ),
    );
  }

  void _kirimPesan() {
    var pesan = _pesanController.text;
    _pesanController.clear();

    var message = Message_Log(
      pengirimUser:
          this.widget.pengirimUser, // Gantilah dengan ID pengirim yang sesuai
      pengirimHandyman: this.widget.pengirimHandyman,
      isiPesan: pesan,
      sent: FirebaseAuth.instance.currentUser!.email.toString(),
      isDone: false,
      waktu: DateTime.now(),
      uid_pemesanan: this.widget.uid_pemesanan,
    );

    FirebaseFirestore.instance.collection('log_pesan').add(message.toMap());
    Retrieve(this.widget.pengirimUser);
    print(this.widget.pengirimUser);
  }
}
