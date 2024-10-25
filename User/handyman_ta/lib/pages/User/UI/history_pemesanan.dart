import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/Model/history.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:provider/provider.dart';

class history_pemesanan extends StatefulWidget {
  const history_pemesanan({super.key});

  @override
  State<history_pemesanan> createState() => _history_pemesananState();
}

class _history_pemesananState extends State<history_pemesanan> {
  late List<dynamic> historyData = [];
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = FirebaseAuth.instance.currentUser?.email;
    getHistoryStream();
  }

  Stream<List<Map<String, dynamic>>> getHistoryStream() {
    return FirebaseFirestore.instance
        .collection('request_handyman')
        .where('user', isEqualTo: _userEmail)
        .where('status', isEqualTo: 'success')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .asyncMap((requestHandymanSnapshot) async {
      List<Map<String, dynamic>> combinedData = [];

      for (var doc in requestHandymanSnapshot.docs) {
        var requestHandymanData = doc.data() as Map<String, dynamic>;

        final ratingSnapshot = await FirebaseFirestore.instance
            .collection('rating_layanan')
            .where('uid_pemesanan', isEqualTo: requestHandymanData['uid'])
            .get();

        if (ratingSnapshot.docs.isEmpty) {
          requestHandymanData['rate_now'] = null;
          requestHandymanData['rate'] = null;
        } else {
          // Jika terdapat data, ambil data rating pertama
          var ratingData = ratingSnapshot.docs.first.data();
          requestHandymanData['rate_now'] = ratingData['rate_now'];
          requestHandymanData['rate'] = ratingData['rate'];
          requestHandymanData['tipe_pekerjaan'] = ratingData['tipe_pekerjaan'];
        }

        combinedData.add(requestHandymanData);
      }

      return combinedData;
    });
  }

  Future<DocumentSnapshot> getUserName(String email) async {
    final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      return userSnapshot.docs.first;
    } else {
      throw Exception("User not found");
    }
  }

  String _getBalance(String balance) {
    String balanceWithComma = balance.toString();

    balanceWithComma = balanceWithComma.replaceAllMapped(
        new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return balanceWithComma;
  }

  @override
  Widget build(BuildContext context) {
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sept",
      "Oct",
      "Nov",
      "Dec"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('History Pemesanan'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return userHomepage(
                        email: FirebaseAuth.instance.currentUser?.email,
                      );
                    },
                  ),
                  (_) => false,
                )),
      ),
      body: Container(
        constraints: BoxConstraints(
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_decoration.png'),
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('request_handyman')
              .where('user', isEqualTo: _userEmail)
              .orderBy('dateTime', descending: true)
              .snapshots(),
          builder: (context, requestSnapshot) {
            if (!requestSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var requestDocs = requestSnapshot.data!.docs;

            return ListView.builder(
              itemCount: requestDocs.length,
              itemBuilder: (context, index) {
                var requestData =
                    requestDocs[index].data() as Map<String, dynamic>;
                var requestId = requestDocs[index].id;
                DateTime dateTimeInstance =
                    (requestData['dateTime'] as Timestamp).toDate();
                String date = dateTimeInstance.day.toString();
                int month = dateTimeInstance.month;
                String hour = dateTimeInstance.hour.toString();
                String minute = dateTimeInstance.minute.toString();
                String second = dateTimeInstance.second.toString();

                Color? _getStatusColor(String status) {
                  switch (status) {
                    case 'success':
                      return Colors.green[800];
                    case 'on-progress':
                      return Colors.blue[800];
                    case 'pending':
                      return Colors.red[800];
                    default:
                      return Colors.black;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Card(
                    margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('rating_layanan')
                          .where('uid_pemesanan', isEqualTo: requestId)
                          .snapshots(),
                      builder: (context, ratingSnapshot) {
                        if (!ratingSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var ratingDocs = ratingSnapshot.data!.docs;
                        var rateNow = false;
                        var rate;
                        var tipePekerjaan;

                        if (ratingDocs.isNotEmpty) {
                          var ratingData =
                              ratingDocs.first.data() as Map<String, dynamic>;
                          rateNow = ratingData['rate_now'];
                          rate = ratingData['rate'];
                          tipePekerjaan = ratingData['tipe_pekerjaan'];
                        }

                        return ListTile(
                          leading: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    date + "\u1d57\u02b0",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: "Roboto"),
                                  ),
                                  Text(
                                    months[month - 1],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  width: 120,
                                  child: FutureBuilder<DocumentSnapshot>(
                                    future: getUserName(
                                        requestData['taken_by'] ?? ''),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.hasData) {
                                        var userName = userSnapshot
                                                .data!['nama'] ??
                                            'User belum mendapatkan Handyman';
                                        return Text(
                                          userName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey[800]),
                                        );
                                      } else {
                                        return Text(
                                          'User belum mendapatkan Handyman',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey[800]),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_right_alt_rounded),
                              Flexible(
                                child: Container(
                                  width: 120,
                                  child: Text(
                                      tipePekerjaan ??
                                          requestData['tipe_pekerjaan'],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[800])),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '-\Rp. ' +
                                        _getBalance(requestData['price']),
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    hour + ":" + minute + ":" + second,
                                    style: TextStyle(
                                        letterSpacing: 1.0,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        fontFamily: "Roboto"),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Status :  ",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(requestData['status'],
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: _getStatusColor(
                                                  requestData['status']),
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Roboto",
                                              letterSpacing: 1)),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              if ((rateNow == false || rateNow == null) &&
                                  (requestData['status'] == "success" &&
                                      requestData['status_done'] == true))
                                GestureDetector(
                                  onTap: () => _showRatingDialog(
                                      requestId, requestData['tipe_pekerjaan']),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Rate now",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showRatingDialog(String uidPemesanan, String namaPekerjaan) {
    double _rating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Rate Layanan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Berikan rating untuk layanan ini:"),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                        ),
                        color: Colors.amber,
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Batal"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Kirim"),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('rating_layanan')
                        .add({
                          'uid_pemesanan': uidPemesanan,
                          'nama_layanan': namaPekerjaan,
                          'nilai_Rating': _rating,
                          'rate_now': true,
                        })
                        .then((value) => {
                              Navigator.of(context).pop(),
                              setState(() {
                                getHistoryStream();
                              })
                            })
                        .catchError(
                            (error) => print("Failed to add rating: $error"));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
