import 'dart:math';
import 'package:intl/intl.dart';
import 'package:admin_flutter/navigation/navigation_header/nav_responsive.dart';
import 'package:admin_flutter/navigation/navigation_side/nav_responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    _fetchDataPekerjaan();
    _fetchDataMoney();
    _fetchDataRatingLayanan();
    sendDataToAnalytics();
  }

  String selectedMonth = 'All';

// Fungsi untuk mengambil data jumlah pekerjaan
  Future<Map<String, int>> _fetchDataPekerjaan() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('request_handyman').get();
      Map<String, int> pekerjaanCount = {};

      for (var doc in snapshot.docs) {
        String tipePekerjaan = doc['tipe_pekerjaan'];

        if (pekerjaanCount.containsKey(tipePekerjaan)) {
          pekerjaanCount[tipePekerjaan] = pekerjaanCount[tipePekerjaan]! + 1;
        } else {
          pekerjaanCount[tipePekerjaan] = 1;
        }
      }

      return pekerjaanCount;
    } catch (e) {
      print("Error fetching data: $e");
      throw e;
    }
  }

// Fungsi untuk mengambil data rating layanan
  Future<Map<String, int>> _fetchDataRatingLayanan() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('rating_layanan').get();

      Map<String, double> layananRatings = {};
      Map<String, int> layananCount = {};

      for (var doc in snapshot.docs) {
        String layanan = doc['nama_layanan'];
        double rating = doc['nilai_Rating'];

        if (layananRatings.containsKey(layanan)) {
          layananRatings[layanan] = layananRatings[layanan]! + rating;
          layananCount[layanan] = layananCount[layanan]! + 1;
        } else {
          layananRatings[layanan] = rating;
          layananCount[layanan] = 1;
        }
      }

      Map<String, int> layananAverageRatings = {};
      layananRatings.forEach((key, value) {
        layananAverageRatings[key] = (value / layananCount[key]!).round();
      });

      return layananAverageRatings;
    } catch (e) {
      print("Error fetching data: $e");
      throw e;
    }
  }

  Future<Map<String, Map<String, double>>> _fetchDataMoney() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('request_handyman').get();

      Map<String, Map<String, double>> monthlyRevenue = {
        'pending': {
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
        },
        'on-progress': {
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
        },
        'success': {
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
        },
        'cancel': {
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
        }
      };

      for (var doc in querySnapshot.docs) {
        Timestamp timestamp = doc['created_date'];
        String priceString =
            doc['price']; // Ambil harga dari database sebagai string
        double price =
            double.tryParse(priceString) ?? 0.0; // Konversi ke double
        DateTime date = timestamp.toDate();
        String monthAbbreviation = DateFormat('MMM').format(date);
        String status = doc['status'];

        if (monthlyRevenue.containsKey(status)) {
          monthlyRevenue[status]!
              .update(monthAbbreviation, (value) => value + price);
        }
      }

      return monthlyRevenue;
    } catch (e) {
      print("Error fetching data: $e");
      throw e;
    }
  }

  Future<void> sendDataToAnalytics() async {
    QuerySnapshot querySnapshot =
        await firestore.collection('request_handyman').get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    for (var document in documents) {
      if (document.exists) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        if (data != null) {
          if (data.containsKey('tipe_pekerjaan')) {
            analytics.logEvent(
              name: 'PURCHASE',
              parameters: {
                'value': 20000.0,
                'currency': 'IDR',
              },
            );
          } else {
            print('Error: Field "price" not found in document');
          }
        } else {
          print('Error: Document data is empty or null');
        }
      } else {
        print('Error: Document does not exist');
      }
    }
  }

  List<ChartData> _generateChartData(Map<String, double> revenueData) {
    List<ChartData> chartData = [];
    revenueData.forEach((month, value) {
      chartData.add(ChartData(x: month, y: value));
    });
    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 300;
    return Scaffold(
      body: Column(
        children: [
          NavigationHeaderResponsive(),
          Expanded(
            child: Row(
              children: [
                Container(
                  child: NavigationSideResponsive(),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 400,
                          width: screenWidth,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: FutureBuilder<Map<String, int>>(
                                future: _fetchDataRatingLayanan(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Center(
                                        child: Text('No data available'));
                                  } else {
                                    Map<String, int> ratingData =
                                        snapshot.data!;
                                    List<BarSeriesData> chartData =
                                        ratingData.entries
                                            .map((entry) => BarSeriesData(
                                                  x: entry.key,
                                                  y: entry.value.toDouble(),
                                                ))
                                            .toList();

                                    return Column(
                                      children: [
                                        Container(
                                          child: Text(
                                              'Data Rating Tiap Pekerjaan'),
                                        ),
                                        Container(
                                          width: screenWidth,
                                          height: 300,
                                          child: SfCartesianChart(
                                            primaryXAxis: CategoryAxis(),
                                            series: <ChartSeries>[
                                              ColumnSeries<BarSeriesData,
                                                  String>(
                                                name: 'Rating',
                                                dataSource: chartData,
                                                xValueMapper:
                                                    (BarSeriesData data, _) =>
                                                        data.x,
                                                yValueMapper:
                                                    (BarSeriesData data, _) =>
                                                        data.y,
                                                color: Colors
                                                    .blue, // Warna grafik untuk rating
                                              ),
                                            ],
                                            legend: Legend(isVisible: true),
                                            tooltipBehavior:
                                                TooltipBehavior(enable: true),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

// FutureBuilder untuk mengambil data jumlah pekerjaan
                        Container(
                          height: 400,
                          width: screenWidth,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: FutureBuilder<Map<String, int>>(
                                future: _fetchDataPekerjaan(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Center(
                                        child: Text('No data available'));
                                  } else {
                                    Map<String, int> pekerjaanData =
                                        snapshot.data!;
                                    List<BarSeriesData> chartData =
                                        pekerjaanData.entries
                                            .map((entry) => BarSeriesData(
                                                  x: entry.key,
                                                  y: entry.value.toDouble(),
                                                ))
                                            .toList();

                                    return Column(
                                      children: [
                                        Container(
                                          child: Text('Data Jumlah Pekerjaan'),
                                        ),
                                        Container(
                                          width: screenWidth,
                                          height: 300,
                                          child: SfCartesianChart(
                                            primaryXAxis: CategoryAxis(),
                                            series: <ChartSeries>[
                                              ColumnSeries<BarSeriesData,
                                                  String>(
                                                name: 'Jumlah Pekerjaan',
                                                dataSource: chartData,
                                                xValueMapper:
                                                    (BarSeriesData data, _) =>
                                                        data.x,
                                                yValueMapper:
                                                    (BarSeriesData data, _) =>
                                                        data.y,
                                                color: Colors
                                                    .green, // Warna grafik untuk jumlah pekerjaan
                                              ),
                                            ],
                                            legend: Legend(isVisible: true),
                                            tooltipBehavior:
                                                TooltipBehavior(enable: true),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 400,
                          width: screenWidth,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Container(
                                    child: Text('Data Pendapatan (RP)'),
                                  ),
                                  // DropdownButton
                                  Expanded(
                                    child: FutureBuilder<
                                        Map<String, Map<String, double>>>(
                                      future: _fetchDataMoney(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Center(
                                              child: Text('No data available'));
                                        } else {
                                          Map<String, Map<String, double>>
                                              revenueData = snapshot.data!;
                                          List<ChartData> pendingData =
                                              _generateChartData(
                                                  revenueData['pending']!);
                                          List<ChartData> successData =
                                              _generateChartData(
                                                  revenueData['success']!);

                                          return SfCartesianChart(
                                            primaryXAxis:
                                                CategoryAxis(), // Since we're only showing yearly data
                                            series: <ChartSeries>[
                                              ColumnSeries<ChartData, dynamic>(
                                                name: 'Pending',
                                                dataSource: pendingData,
                                                xValueMapper:
                                                    (ChartData data, _) =>
                                                        data.x,
                                                yValueMapper:
                                                    (ChartData data, _) =>
                                                        data.y,
                                              ),
                                              ColumnSeries<ChartData, dynamic>(
                                                name: 'Success',
                                                dataSource: successData,
                                                xValueMapper:
                                                    (ChartData data, _) =>
                                                        data.x,
                                                yValueMapper:
                                                    (ChartData data, _) =>
                                                        data.y,
                                              ),
                                            ],
                                            legend: Legend(isVisible: true),
                                            tooltipBehavior:
                                                TooltipBehavior(enable: true),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

class BarSeriesData {
  BarSeriesData({required this.x, required this.y});
  final String x;
  final double y;
}

class ChartData {
  ChartData({required this.x, required this.y});
  final String x;
  final double y;
}
