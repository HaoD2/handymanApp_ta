import 'dart:math';
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
  double temp = 0.0;
  List<FlSpot> _spots = [];
  List<FlSpot> _data_Money = [];
  Map<int, Widget> _titleCache = {};
  List<String> _jobTypes = [];
  double maxY = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchDataMoney();
  }

  Future<void> _fetchData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot =
        await firestore.collection('request_handyman').get();
    Map<String, int> jobTypeCounts = {};

    for (var doc in querySnapshot.docs) {
      String jobType = doc['tipe_pekerjaan'];

      if (jobTypeCounts.containsKey(jobType)) {
        jobTypeCounts[jobType] = jobTypeCounts[jobType]! + 1;
      } else {
        jobTypeCounts[jobType] = 1;
      }
    }
    print(jobTypeCounts);
    // Convert keys to a set to remove duplicates, then back to a list
    List<String> jobTypes = jobTypeCounts.keys.toSet().toList();
    print(jobTypes);
    List<FlSpot> spots = jobTypeCounts.entries.map((entry) {
      int index = jobTypes.indexOf(entry.key);
// Debugging print
      return FlSpot(index.toDouble(), entry.value.toDouble());
    }).toList();

    setState(() {
      _spots = spots;
      _jobTypes = jobTypes;
    });
  }

  Future<void> _fetchDataMoney() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('request_handyman')
        .where('status', whereIn: ['pending', 'on-progress', 'success']).get();

    Map<String, double> monthlyEarnings = {};

    for (var doc in querySnapshot.docs) {
      DateTime date = doc['created_date'].toDate();
      String monthYear = DateFormat('yyyy-MM').format(date);
      double price = doc['price'].toDouble();

      if (monthlyEarnings.containsKey(monthYear)) {
        monthlyEarnings[monthYear] = monthlyEarnings[monthYear]! + price;
      } else {
        monthlyEarnings[monthYear] = price;
      }
    }

    List<FlSpot> spots_money = [];
    List<String> sortedKeys = monthlyEarnings.keys.toList()..sort();
    for (int i = 0; i < sortedKeys.length; i++) {
      double totalPrice = monthlyEarnings[sortedKeys[i]]!;
      spots_money.add(FlSpot(i.toDouble(), totalPrice));
      if (totalPrice > maxY) {
        maxY = totalPrice;
      }
    }

    setState(() {
      _data_Money = spots_money;
    });
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
                  child: Column(children: [
                    Expanded(
                      child: Center(
                        child: Column(children: [
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                              width: 500,
                              height: 300,
                              child: _spots.isEmpty
                                  ? CircularProgressIndicator()
                                  : LineChart(LineChartData(
                                      minY: 0,
                                      maxY: temp + 20,
                                      gridData: FlGridData(
                                        show: true,
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        leftTitles: AxisTitles(
                                          axisNameSize: 15,
                                          axisNameWidget: Container(
                                              child: Text(
                                                  'Banyak Pesanan dalam Layanan')),
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget:
                                                (double value, TitleMeta meta) {
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                child: Text(
                                                  value.toString(),
                                                  style: TextStyle(fontSize: 7),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget:
                                                (double value, TitleMeta meta) {
                                              int index = value.toInt();
                                              if (!_titleCache
                                                  .containsKey(index)) {
                                                print(
                                                    'Rendering index: $index');
                                              }

                                              // Caching title widget
                                              if (index >= 0 &&
                                                  index < _jobTypes.length) {
                                                if (!_titleCache
                                                    .containsKey(index)) {
                                                  _titleCache[index] =
                                                      SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: Text(
                                                      _jobTypes[index],
                                                      style: TextStyle(
                                                          fontSize: 7),
                                                    ),
                                                  );
                                                  print(
                                                      'Index $index is valid and corresponds to: ${_jobTypes[index]}'); // Debugging print
                                                }
                                                return _titleCache[index]!;
                                              } else {
                                                if (!_titleCache
                                                    .containsKey(index)) {
                                                  _titleCache[index] =
                                                      SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: Text(''),
                                                  );
                                                  print(
                                                      'Index $index is invalid'); // Debugging print
                                                }
                                                return _titleCache[index]!;
                                              }
                                            },
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: true),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _spots,
                                          isCurved: true,
                                          color: Colors.blue,
                                          barWidth: 4,
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                      ],
                                    ))),
                        ]),
                      ),
                    )
                  ]),
                ),
                Container(
                  width: 500,
                  height: 300,
                  child: _data_Money.isEmpty
                      ? CircularProgressIndicator()
                      : LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: maxY + 20,
                            gridData: FlGridData(
                              show: true,
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              leftTitles: AxisTitles(
                                axisNameSize: 15,
                                axisNameWidget:
                                    Container(child: Text('Total Uang (IDR)')),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        value.toString(),
                                        style: TextStyle(fontSize: 7),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    int index = value.toInt();
                                    if (index >= 0 &&
                                        index < _data_Money.length) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          DateFormat('MMM').format(
                                              DateTime(2024, index + 1)),
                                          style: TextStyle(fontSize: 7),
                                        ),
                                      );
                                    } else {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(''),
                                      );
                                    }
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _data_Money,
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 4,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.3),
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
