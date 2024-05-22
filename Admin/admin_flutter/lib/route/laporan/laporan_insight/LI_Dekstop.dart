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
  NumericGroup _numericGroup = NumericGroup(id: '1', data: []);
  @override
  void initState() {
    super.initState();
    _fetchDataPekerjaan();
    _fetchDataMoney();
  }

  Future<Map<String, int>> _fetchDataPekerjaan() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('request_handyman').get();
      Map<String, int> pekerjaanCount = {};

      for (var doc in snapshot.docs) {
        String tipePekerjaan = doc['tipe_pekerjaan'];

        // Menghitung jumlah pesanan berdasarkan tipe pekerjaan
        if (pekerjaanCount.containsKey(tipePekerjaan)) {
          pekerjaanCount[tipePekerjaan] = pekerjaanCount[tipePekerjaan]! + 1;
        } else {
          pekerjaanCount[tipePekerjaan] = 1;
        }
      }

      // Print the count of each job type

      return pekerjaanCount;
    } catch (e) {
      print("Error fetching data: $e");
      throw e;
    }
  }

  Future<Map<String, double>> _fetchDataMoney() async {
    // Mendapatkan data dari Firebase
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('revenues').get();

    // Mengonversi data menjadi Map<String, double>
    Map<String, double> monthlyRevenue = {
      'Jan': 0.0,
      'Feb': 0.0,
      'Mar': 0.0,
      'Apr': 0.0,
      'May': 0.0,
      'Jun': 0.0,
      'Jul': 0.0,
      'Aug': 0.0,
      'Sep': 0.0,
      'Oct': 0.0,
      'Nov': 0.0,
      'Dec': 0.0,
    };

    for (var doc in querySnapshot.docs) {
      Timestamp timestamp = doc['created_date'];
      String priceString =
          doc['price']; // Ambil harga dari database sebagai string
      double price = double.tryParse(priceString) ?? 0.0; // Konversi ke double
      DateTime date = timestamp.toDate();
      String monthAbbreviation = DateFormat('MMM').format(date);
      monthlyRevenue.update(monthAbbreviation, (value) => value + price);
    }

    return monthlyRevenue;
  }

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
                Container(
                  width: 550,
                  height: 500,
                  child: FutureBuilder<Map<String, int>>(
                    future: _fetchDataPekerjaan(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No data available'));
                      } else {
                        Map<String, int> pekerjaanData = snapshot.data!;
                        List<String> pekerjaanKeys =
                            pekerjaanData.keys.toList();

                        // Membuat chart berdasarkan data yang diambil
                        return Container(
                          child: DChartBarO(
                            groupList: pekerjaanKeys.map((key) {
                              return OrdinalGroup(
                                id: key,
                                data: [
                                  OrdinalData(
                                    domain: key,
                                    measure: pekerjaanData[key] ?? 0,
                                  ),
                                ],
                              );
                            }).toList(),
                            barLabelValue: (group, ordinalData, index) {
                              return ordinalData.measure.round().toString();
                            },
                            configRenderBar: ConfigRenderBar(
                                maxBarWidthPx: 500, minBarLengthPx: 500),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  width: 700,
                  height: 500,
                  child: FutureBuilder<Map<String, double>>(
                    future: _fetchDataMoney(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No data available'));
                      } else {
                        Map<String, double> revenueData = snapshot.data!;
                        List<String> monthAbbreviations = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];

                        // Membuat chart berdasarkan data yang diambil
                        return Container(
                          child: DChartBarO(
                            groupList: [
                              OrdinalGroup(
                                id: 'Revenue',
                                data: monthAbbreviations.map((month) {
                                  return OrdinalData(
                                    domain: month,
                                    measure: revenueData[month] ?? 0,
                                  );
                                }).toList(),
                              ),
                            ],
                            barLabelValue: (group, ordinalData, index) {
                              return ordinalData.measure.round().toString();
                            },
                            configRenderBar: ConfigRenderBar(
                              maxBarWidthPx: 500,
                              minBarLengthPx: 500,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
