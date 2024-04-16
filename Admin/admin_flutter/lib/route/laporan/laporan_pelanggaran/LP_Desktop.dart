import 'dart:convert';

import 'package:admin_flutter/constants/app_colors.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_responsive.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_responsive.dart';
import 'package:admin_flutter/route/laporan/laporan_pelanggaran/LP_Detail/LPD_main.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LaporanPelanggaranDekstop extends StatefulWidget {
  const LaporanPelanggaranDekstop({super.key});

  @override
  State<LaporanPelanggaranDekstop> createState() =>
      _LaporanPelanggaranDekstopState();
}

class _LaporanPelanggaranDekstopState extends State<LaporanPelanggaranDekstop> {
  late Stream<QuerySnapshot> _dataStream;
  String selectedUID = "";
  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance
        .collection('pelanggaran_user')
        .snapshots(); // Mengambil stream dari koleksi 'handyman_req_forms'
  }

  Future<void> updateBan(String email) async {
    try {
      // Melakukan query untuk mendapatkan dokumen pengguna dengan email yang sesuai
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Jika ditemukan dokumen pengguna dengan email yang sesuai
      if (userQuery.docs.isNotEmpty) {
        // Mendapatkan referensi dokumen pengguna yang ditemukan
        final userDocRef = userQuery.docs.first.reference;

        // Melakukan pembaruan status_akun menjadi 0 untuk dilarang
        await userDocRef.update({'status_akun': 0});

        final tokenMessaging = userQuery.docs.first['token_messaging'];
        // Selanjutnya, kirim pemberitahuan kepada pengguna bahwa mereka telah dilarang
        await sendNotification(
            tokenMessaging, 'Peringatan, Akun Anda Telah Diblokir!');
      } else {
        print('Pengguna dengan email $email tidak ditemukan');
      }
    } catch (e) {
      print('Error saat memperbarui status akun: $e');
    }
  }

  void deletePelanggaran(String pelapor, String terlapor) async {
    try {
      // Lakukan query untuk mendapatkan dokumen yang sesuai dengan kriteria
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('pelanggaran_user')
          .where('nama_pelapor', isEqualTo: pelapor)
          .where('nama_terlapor', isEqualTo: terlapor)
          .get();

      // Iterasi melalui setiap dokumen yang sesuai dan hapus satu per satu
      querySnapshot.docs.forEach((doc) async {
        await doc.reference.delete();
      });

      print('Data berhasil dihapus');
    } catch (e) {
      print('Error saat menghapus data: $e');
    }
  }

  // Fungsi untuk memperbarui peringatan
  void updateWarning(String email) async {
    // Lakukan apa pun yang diperlukan untuk memperbarui peringatan di sini

    // Selanjutnya, kirim pemberitahuan peringatan kepada pengguna
    await sendNotification(
        email, 'Peringatan, Anda Telah Melakukan Pelanggaran!');
  }

  // Fungsi untuk mengirim pemberitahuan menggunakan FCM
  Future<void> sendNotification(String tokenMessaging, String message) async {
    try {
      // Di sini token_sent harus diambil dari database berdasarkan email pengguna

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
                  'title': message,
                },
                'notification': {
                  'body': message,
                  'title': message,
                  'android_channel_id': "dbFood"
                },
                "to": tokenMessaging
              }));

      if (res.statusCode == 200) {
        print('Pemberitahuan berhasil dikirim');
      } else {
        print('Gagal mengirim pemberitahuan: ${res.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                    padding: EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Laporan Pelanggaran'),
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
                                    Timestamp t = data['tanggal_pelanggaran'];
                                    DateTime date = t.toDate();
                                    String tempID =
                                        entry.value.id; // Ambil ID dari dokumen
                                    return DataRow(cells: [
                                      DataCell(Text(index.toString(),
                                          style: TextStyle(
                                              fontSize:
                                                  sizeTableDesktopTextContent))),
                                      DataCell(Text(data['nama_pelapor'] ?? '',
                                          style: TextStyle(
                                              fontSize:
                                                  sizeTableDesktopTextContent))),
                                      DataCell(Text(data['nama_terlapor'] ?? '',
                                          style: TextStyle(
                                              fontSize:
                                                  sizeTableDesktopTextContent))),
                                      DataCell(Text(date.toString())),
                                      DataCell(Row(
                                        children: [
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedUID = tempID;
                                                });
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LPDMain(
                                                            uid: selectedUID,
                                                          )),
                                                );
                                              },
                                              child: Text("Detail",
                                                  style: TextStyle(
                                                      fontSize:
                                                          sizeTableDesktopTextContent)),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Pilih Aksi"),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: ListBody(
                                                          children: <Widget>[
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                updateWarning(data[
                                                                    'nama_terlapor']);

                                                                // Aksi jika tombol "Warning" ditekan
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                // Tambahkan aksi yang ingin dilakukan saat tombol "Warning" ditekan
                                                              },
                                                              child: Text(
                                                                  "Warning"),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                updateBan(data[
                                                                    'nama_terlapor']);
                                                                // Aksi jika tombol "Ban" ditekan
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                // Tambahkan aksi yang ingin dilakukan saat tombol "Ban" ditekan
                                                              },
                                                              child:
                                                                  Text("Ban"),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text("Submit",
                                                  style: TextStyle(
                                                      fontSize:
                                                          sizeTableDesktopTextContent)),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ButtonTheme(
                                            minWidth: 150.0,
                                            height: 100.0,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Konfirmasi"),
                                                      content: Text(
                                                          "Apakah Anda yakin ingin menolak pelanggaran ini?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text("Tidak"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deletePelanggaran(
                                                                data[
                                                                    'nama_pelapor'],
                                                                data[
                                                                    'nama_terlapor']); // Panggil fungsi untuk menghapus data
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text("Ya"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text("Tolak",
                                                  style: TextStyle(
                                                      fontSize:
                                                          sizeTableDesktopTextContent)),
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
                                          label: Text("No",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Nama Pelapor",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("Nama Terlapor",
                                              style: TextStyle(
                                                  fontSize:
                                                      sizeTableDesktopTextTitle))),
                                      DataColumn(
                                          label: Text("tanggal_pelanggaran",
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
