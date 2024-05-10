import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handyman_ta/pages/Model/message.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  final String pengirimHandyman; //penerimaEmail
  final String pengirimUser; //pengirimEmail
  final String uid_pemesanan;

  const ChatPage(this.pengirimHandyman, this.pengirimUser, this.uid_pemesanan);
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

  bool confirmation = false;
  int _rating = 1;
  bool isChatDone = false;
  bool _notProfessional = false;
  bool _badService = false;
  bool _poorCommunication = false;
  bool _unclearCost = false;

  @override
  void initState() {
    super.initState();
    // Panggil ConfirmationCheck() dan tangani hasilnya menggunakan then
    ConfirmationCheck();
  }

  Future<void> ConfirmationCheck() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('kontak')
          .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
          .get();

      bool isConfirmed = false;

      querySnapshot.docs.forEach((doc) {
        isConfirmed = doc['isDoneUser'];
      });
    } catch (e) {
      print('Error: $e');
      // Handle error here
    }
  }

  //kirim pesan
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

  //ketika sudah konfirmasi pemesanan
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
                .where('isRatingDoneUser', isEqualTo: false)
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
                          // Lakukan sesuatu dengan nilai _rating
                          print('Rating: $_rating');
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
                                  querySnapshot.docs.first['taken_by'];
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
              // Tidak ada dokumen yang memenuhi kondisi
              // Tampilkan pesan atau tindakan lain yang sesuai
              print('Tidak ada dokumen yang memenuhi kondisi');
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
                          onPressed: () {
                            // Handle submit here

                            tambahReport(
                                this.widget.pengirimUser,
                                this.widget.pengirimHandyman,
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

//ketika dia sudah accept pemesanan
  Widget buildMessageOnly() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('log_pesan')
            .where('pengirimHandyman', isEqualTo: widget.pengirimHandyman)
            .where('pengirimUser', isEqualTo: widget.pengirimUser)
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

  //submit button
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

//rating layanan
  Future<DocumentReference> tambahRatingLayanan(
    String namaUser,
    int nilaiRating,
    String komentar,
  ) async {
    CollectionReference ratingLayananCollection =
        FirebaseFirestore.instance.collection('rating_user');

    return await ratingLayananCollection.add({
      'nama_user': namaUser,
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
              .update({'isRatingDoneUser': true});
        });
      });
    } catch (e) {
      print('Error updating isRatingDone: $e');
      // Handle error jika diperlukan
    }
  }

// Membuat fungsi untuk mengupdate status request_handyman menjadi success
  Future<void> updateRequestAndUserBalance(BuildContext context) async {
    print("updateRequestAndUserBalance");
    // Ambil nilai price dari request_handyman
    int price = 0;
    await FirebaseFirestore.instance
        .collection('request_handyman')
        .where('uid', isEqualTo: widget.uid_pemesanan)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        price = int.parse(doc['price']);
        // Update status request_handyman menjadi success
        FirebaseFirestore.instance
            .collection('request_handyman')
            .doc(doc.id)
            .update({'status': 'success', 'status_done': true});
      });
    });

// Ambil saldo pengguna
    int saldo = 0;
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.pengirimHandyman)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // Mengecek apakah dokumen adalah dokumen yang valid dan memiliki field saldo
        if (doc.exists &&
            doc.data() is Map<String, dynamic> &&
            (doc.data() as Map<String, dynamic>).containsKey('saldo')) {
          saldo = doc['saldo'] + price;
          // Update saldo pengguna
          FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .update({'saldo': saldo, 'status_kerja': false}).then((_) {
            // Berhasil mengupdate saldo
          }).catchError((error) {
            // Gagal mengupdate saldo
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal mengupdate saldo: $error'),
            ));
          });
        } else {
          // Jika dokumen tidak memiliki field saldo, tambahkan field saldo beserta nilainya
          saldo = price;
          FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .set({'saldo': saldo}, SetOptions(merge: true)).then((_) {
            // Berhasil menambahkan field saldo
          }).catchError((error) {
            // Gagal menambahkan field saldo
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal menambahkan field saldo: $error'),
            ));
          });
        }
      });
    });
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.pengirimUser)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // Mengecek apakah dokumen adalah dokumen yang valid dan memiliki field saldo
        if (doc.exists &&
            doc.data() is Map<String, dynamic> &&
            (doc.data() as Map<String, dynamic>).containsKey('saldo')) {
          saldo = doc['saldo'] + price;
          // Update saldo pengguna
          FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .update({'status_pesan': false}).then((_) {
            // Berhasil mengupdate saldo
          }).catchError((error) {
            // Gagal mengupdate saldo
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal mengupdate saldo: $error'),
            ));
          });
        }
      });
    });
  }

//UI Konfirmasi Button
  Widget konfirmasiButton() {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Konfirmasi'),
              content: Text(
                  'Apakah Pekerjaan yang dilakukan Handyman Telah Selesai ?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Kembali dengan nilai true (ya)
                  },
                  child: Text('Ya'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Kembali dengan nilai false (tidak)
                  },
                  child: Text('Tidak'),
                ),
              ],
            );
          },
        ).then((isConfirmed) async {
          if (isConfirmed != null && isConfirmed) {
            // Jika "Ya" ditekan, lakukan pembaruan ke Firestore
            await FirebaseFirestore.instance
                .collection('kontak')
                .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
                .get()
                .then((QuerySnapshot querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                FirebaseFirestore.instance
                    .collection('kontak')
                    .doc(doc.id)
                    .update({'isDoneUser': true});
              });
            });
            await updateRequestAndUserBalance(context);
          } else {
            // Jika "Tidak" ditekan, lakukan pembaruan ke Firestore
            await FirebaseFirestore.instance
                .collection('kontak')
                .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
                .get()
                .then((QuerySnapshot querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                FirebaseFirestore.instance
                    .collection('kontak')
                    .doc(doc.id)
                    .update({'isDoneHandyman': false});
              });
            });
          }
          await FirebaseFirestore.instance
              .collection('kontak')
              .where('uid_pemesanan', isEqualTo: widget.uid_pemesanan)
              .get()
              .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              // Dapatkan nilai isDoneUser
              bool isUserDone = doc['isDoneUser'] ?? false;
              // Masukkan ke dalam variabel confirmation
              setState(() {
                confirmation = isUserDone;
              });
            });
          });
        });
      },
      child: Text('Konfirmasi'),
    );
  }

//UI MEssagenya
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text('Chat dengan ${widget.pengirimHandyman}'),
            ],
          ),
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
          backgroundColor: Colors.yellow,
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
                    snapshot.data!.docs.first['isRatingDoneUser'] ?? false;

                return isRatingDone
                    ? buildMessageOnly()
                    : Column(
                        children: <Widget>[
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('log_pesan')
                                  .where('pengirimHandyman',
                                      isEqualTo: this.widget.pengirimHandyman)
                                  .where('pengirimUser',
                                      isEqualTo: this.widget.pengirimUser)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                var messages = snapshot.data!.docs;
                                messages.sort((b, a) {
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
                                      bool isDoneHandyman = false;

                                      if (contacts.isNotEmpty) {
                                        isDoneHandyman =
                                            contacts.first['isDoneHandyman'];
                                        confirmation =
                                            contacts.first['isDoneUser'];
                                      }

                                      // Tampilkan tombol berdasarkan nilai isDone
                                      if (isDoneHandyman) {
                                        if (confirmation) {
                                          return buildRatingAndReportButtons();
                                        } else {
                                          return konfirmasiButton();
                                        }
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

//kirimpesan
  void _kirimPesan() {
    var pesan = _pesanController.text;
    _pesanController.clear();

    var message = Message_Log(
      pengirimUser:
          this.widget.pengirimUser, // Gantilah dengan ID pengirim yang sesuai
      pengirimHandyman: this.widget.pengirimHandyman,
      isiPesan: pesan,
      sent: FirebaseAuth.instance.currentUser!.email.toString(),
      isDone: true,
      waktu: DateTime.now(),
      uid_pemesanan: this.widget.uid_pemesanan,
    );

    FirebaseFirestore.instance.collection('log_pesan').add(message.toMap());
    Retrieve(this.widget.pengirimHandyman);
  }
}
