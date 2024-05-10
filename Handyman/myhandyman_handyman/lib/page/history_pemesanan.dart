import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myhandyman_handyman/page/userHandyman.dart';

class history_pemesanan extends StatefulWidget {
  const history_pemesanan({super.key});

  @override
  State<history_pemesanan> createState() => _history_pemesananState();
}

class _history_pemesananState extends State<history_pemesanan> {
  late List<dynamic> historyData = [];

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  Future<void> getHistory() async {
    final QuerySnapshot historySnapshot = await FirebaseFirestore.instance
        .collection('request_handyman')
        .where('taken_by', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .orderBy('dateTime', descending: true)
        .get();

    setState(() {
      historyData = historySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<String?> getUserName(String email) async {
    final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Ambil nama pengguna dari dokumen pertama yang ditemukan
      return userSnapshot.docs.first['nama'];
    } else {
      return null; // Kembalikan null jika tidak ada data yang ditemukan
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
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const userHandyman(),
              )),
        ),
      ),
      body: Container(
        constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/home_decoration.png',
            ),
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
          ),
        ),
        child: historyData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: historyData.length,
                itemBuilder: (context, index) {
                  var data = historyData[index];
                  DateTime dateTimeInstance = data['dateTime'].toDate();
                  String date = dateTimeInstance.day.toString();
                  int month = dateTimeInstance.month;
                  String hour = dateTimeInstance.hour.toString();
                  String minute = dateTimeInstance.minute.toString();
                  String second = dateTimeInstance.second.toString();

                  Color? _getStatusColor(String status) {
                    switch (status) {
                      case 'success':
                        return Colors.green[800]; // Hijau tua
                      case 'on-progress':
                        return Colors.blue[800]; // Biru tua
                      case 'pending':
                        return Colors.red[800]; // Merah
                      default:
                        return Colors
                            .black; // Warna default jika status tidak sesuai
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Card(
                      margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                      child: ListTile(
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
                                child: FutureBuilder<String?>(
                                  future: getUserName(data['user'] ?? ''),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                        snapshot.data ??
                                            'User belum mendapatkan Handyman',
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
                                child: Text(data['tipe_pekerjaan'],
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
                                    '-\Rp. ' + _getBalance(data['price']),
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                ]),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    Text(data['status'],
                                        style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                _getStatusColor(data['status']),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Roboto",
                                            letterSpacing: 1))
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
