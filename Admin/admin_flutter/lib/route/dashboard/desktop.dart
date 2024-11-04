import 'dart:convert';

import 'package:admin_flutter/constants/app_colors.dart';
import 'package:admin_flutter/messagingService.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_responsive.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_responsive.dart';
import 'package:admin_flutter/route/dashboard/detail_dashboard/detail_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardDekstop extends StatefulWidget {
  const DashboardDekstop({super.key});

  @override
  State<DashboardDekstop> createState() => _DashboardDekstopState();
}

class _DashboardDekstopState extends State<DashboardDekstop> {
  late Stream<QuerySnapshot> _dataStream;
  final CollectionReference handymarReqFormCollection =
      FirebaseFirestore.instance.collection('handyman_req_forms');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final Mesagging = MessagingService();
  Future<void> updateData(String email) async {
    try {
      // Update handymar_req_form collection
      await handymarReqFormCollection
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          handymarReqFormCollection.doc(doc.id).update({'status': 1});
        });
      });

      // Update users collection
      await usersCollection
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          usersCollection.doc(doc.id).update({'status_handyman': 1});
          await handymarReqFormCollection
              .where('email', isEqualTo: email)
              .get()
              .then((querySnapshot) {
            querySnapshot.docs.forEach((doc) async {
              // Remove request
              handymarReqFormCollection.doc(doc.id).delete();
              await handymarReqFormCollection
                  .where('email', isEqualTo: email)
                  .get()
                  .then((querySnapshot) {
                querySnapshot.docs.forEach((doc1) {
                  // Remove request
                  handymarReqFormCollection.doc(doc1.id).delete();
                });
              });
            });
          });
        });
      });

      String token_sent = '';
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Menggunakan firstOrNull() untuk mendapatkan data dari dokumen pertama jika ada
        var userData = querySnapshot.docs.firstOrNull?.data();

        // Mendapatkan nilai token_messaging dari data pengguna
        token_sent = userData?['token_messaging'];
        Mesagging.sendFCMMessage(token_sent, token_sent, "Request Handyman",
            "Request Handymanmu Diterima, selamat!");
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Data updated successfully!"),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error updating data: $e");
      // Handle error and show AlertDialog if necessary
    }
  }

  Future<void> cancelRequest(String email) async {
    try {
      // Update handymar_req_form collection
      await handymarReqFormCollection
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          // Remove request
          handymarReqFormCollection.doc(doc.id).delete();
        });
      });
      String token_sent = '';
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Menggunakan firstOrNull() untuk mendapatkan data dari dokumen pertama jika ada
        var userData = querySnapshot.docs.firstOrNull?.data();

        // Mendapatkan nilai token_messaging dari data pengguna
        token_sent = userData?['token_messaging'];
      }

      // Show success AlertDialog for cancellation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Maaf!"),
            content: Text("Permintaan dibatalkan!"),
            actions: [
              TextButton(
                onPressed: () async {
                  final res = await http.post(
                      Uri.parse("https://fcm.googleapis.com/fcm/send"),
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
                          'title':
                              'Maaf Request Handymanmu ditolak, Mohon melengkapi kebutuhan yang dibutuhkan!',
                        },
                        'notification': {
                          'body': 'MyHandyman',
                          'title':
                              'Maaf Request Handymanmu ditolak, Mohon melengkapi kebutuhan yang dibutuhkan!',
                          'android_channel_id': "dbFood"
                        },
                        "to": token_sent
                      }));
                  if (res.statusCode == 200) {
                    print('>>>>>>>>>>>>>>>>>>>>success');
                  } else {
                    print(res.body);
                    print(res.statusCode.toString() + ">>>>>");
                    print('>>>>>>>>>>>>>>>>>>>>gagal');
                  }
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error cancelling request: $e");
      // Handle error and show AlertDialog if necessary
    }
  }

  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance
        .collection('handyman_req_forms')
        .snapshots(); // Mengambil stream dari koleksi 'handyman_req_forms'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NavigationHeaderResponsive(),
          Expanded(
            child: Row(
              children: [
                NavigationSideResponsive(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Request Handyman'),
                          SizedBox(
                            height: 24,
                          ),
                          //Now let's add the Table
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: _dataStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Error: ${snapshot.error.toString()}'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  List<DocumentSnapshot> documents =
                                      snapshot.data!.docs;

                                  List<DataRow> rows =
                                      documents.asMap().entries.map((entry) {
                                    Map<String, dynamic> data = entry.value
                                        .data() as Map<String, dynamic>;
                                    int index = entry.key + 1;

                                    return DataRow(cells: [
                                      DataCell(Text(
                                        index.toString(),
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['name'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['email'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Text(
                                        data['skill'] ?? '',
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextContent),
                                      )),
                                      DataCell(Row(
                                        children: [
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Detail_Dashboard(
                                                            email:
                                                                data['email'],
                                                          )),
                                                );
                                              },
                                              child: Text(
                                                "Detail",
                                                style: TextStyle(
                                                    fontSize:
                                                        sizeTableDesktopTextContent),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                updateData(data['email']);
                                              },
                                              child: Text(
                                                "Terima",
                                                style: TextStyle(
                                                    fontSize:
                                                        sizeTableDesktopTextContent),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                cancelRequest(data['email']);
                                              },
                                              child: Text(
                                                "Tolak",
                                                style: TextStyle(
                                                    fontSize:
                                                        sizeTableDesktopTextContent),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ]);
                                  }).toList();

                                  return DataTable(
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.grey.shade200),
                                    columns: [
                                      DataColumn(
                                          label: Text(
                                        "No",
                                        style: TextStyle(
                                            fontSize:
                                                sizeTableDesktopTextTitle),
                                      )),
                                      DataColumn(
                                          label: Text("Nama",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Email",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Skill",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Action",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                    ],
                                    rows: rows,
                                  );
                                },
                              ),

                              //Now let's set the pagination
                              SizedBox(
                                height: 40.0,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
