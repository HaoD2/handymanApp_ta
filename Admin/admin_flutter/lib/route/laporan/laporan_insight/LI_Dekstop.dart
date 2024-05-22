import 'dart:math';
import 'package:d_chart/d_chart.dart';
import 'package:intl/intl.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_responsive.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fl_chart/fl_chart.dart';

class LaporanInsightDekstop extends StatefulWidget {
  const LaporanInsightDekstop({super.key});

  @override
  State<LaporanInsightDekstop> createState() => _LaporanInsightDekstopState();
}

class _LaporanInsightDekstopState extends State<LaporanInsightDekstop> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // _fetchDataPekerjaan();
    // _fetchDataMoney();
  }

  // Future<Map<String, int>> _fetchDataPekerjaan() async {
  //   try {
  //     QuerySnapshot snapshot =
  //         await FirebaseFirestore.instance.collection('request_handyman').get();
  //     Map<String, int> pekerjaanCount = {};
  //     Map<String, Set<String>> monthSet = {};
  //     List<String> months = [
  //       'January',
  //       'February',
  //       'March',
  //       'April',
  //       'May',
  //       'June',
  //       'July',
  //       'August',
  //       'September',
  //       'October',
  //       'November',
  //       'December'
  //     ];

  //     for (var doc in snapshot.docs) {
  //       String tipePekerjaan = doc['tipe_pekerjaan'];
  //       Timestamp createdDate = doc['created_date'];
  //       DateTime date = createdDate.toDate();
  //       String month = months[date.month - 1]; // Mengambil nama bulan

  //       // Menghitung jumlah pesanan berdasarkan tipe pekerjaan
  //       if (pekerjaanCount.containsKey(tipePekerjaan)) {
  //         pekerjaanCount[tipePekerjaan] = pekerjaanCount[tipePekerjaan]! + 1;
  //       } else {
  //         pekerjaanCount[tipePekerjaan] = 1;
  //       }

  //       // Menyimpan bulan tanpa duplikasi untuk tipe pekerjaan tersebut
  //       if (!monthSet.containsKey(tipePekerjaan)) {
  //         monthSet[tipePekerjaan] = <String>{};
  //       }
  //       monthSet[tipePekerjaan]!.add(month);
  //     }

  //     // Mengkonversi monthSet ke pekerjaanCount untuk bulan
  //     for (var key in monthSet.keys) {
  //       pekerjaanCount[key] = monthSet[key]!.length;
  //     }

  //     return pekerjaanCount;
  //   } catch (e) {
  //     print("Error fetching data: $e");
  //     throw e;
  //   }
  // }

  Future<void> sendDataToAnalytics() async {
    // Mendapatkan data dari Firestore
    QuerySnapshot querySnapshot =
        await firestore.collection('request_handyman').get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    // Mengirim data ke Firebase Analytics
    for (var document in documents) {
      if (document.exists) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        if (data != null) {
          // Memeriksa apakah bidang 'price' ada dalam data
          if (data.containsKey('tipe_pekerjaan')) {
            String dataValue = data['tipe_pekerjaan'];
            analytics.logEvent(
              name: 'Top Pekerjaan Count',
              parameters: {'data_value': dataValue},
            );
          } else {
            // Menangani jika bidang 'price' tidak ada dalam data
            print('Error: Field "price" not found in document');
            // Atau Anda bisa menambahkan handling khusus lainnya sesuai kebutuhan aplikasi Anda
          }
        } else {
          // Menangani jika data kosong atau null
          print('Error: Document data is empty or null');
          // Atau Anda bisa menambahkan handling khusus lainnya sesuai kebutuhan aplikasi Anda
        }
      } else {
        // Menangani jika dokumen tidak ditemukan
        print('Error: Document does not exist');
        // Atau Anda bisa menambahkan handling khusus lainnya sesuai kebutuhan aplikasi Anda
      }
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
                Container(child: NavigationSideResponsive()),
                // Container(
                //   width: 250,
                //   height: 500,
                //   child: FutureBuilder<Map<String, int>>(
                //     future: _fetchDataPekerjaan(),
                //     builder: (context, snapshot) {
                //       if (snapshot.connectionState == ConnectionState.waiting) {
                //         return Center(child: CircularProgressIndicator());
                //       } else if (snapshot.hasError) {
                //         return Center(child: Text('Error: ${snapshot.error}'));
                //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                //         return Center(child: Text('No data available'));
                //       } else {
                //         Map<String, int> pekerjaanData = snapshot.data!;
                //         List<String> pekerjaanKeys =
                //             pekerjaanData.keys.toList();
                //         List<int> pekerjaanValues =
                //             pekerjaanData.values.toList();

                //         // Membuat chart berdasarkan data yang diambil
                //         return AspectRatio(
                //           aspectRatio: 16 / 9,
                //           child: DChartBarO(
                //             groupList: pekerjaanKeys.map((key) {
                //               return OrdinalGroup(
                //                 id: key,
                //                 data: [
                //                   OrdinalData(
                //                       domain: key,
                //                       measure: pekerjaanData[key] ?? 0),
                //                 ],
                //               );
                //             }).toList(),
                //           ),
                //         );
                //       }
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
