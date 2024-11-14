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

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

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
  Future<Map<String, double>> _fetchDataRatingLayanan() async {
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

      Map<String, double> layananAverageRatings = {};
      layananRatings.forEach((key, value) {
        layananAverageRatings[key] = value / layananCount[key]!;
      });

      return layananAverageRatings; // Mengembalikan Map<String, double>
    } catch (e) {
      print("Error fetching data: $e");
      throw e;
    }
  }

  String formatTextWithLineBreaks(String text) {
    // Pisahkan teks berdasarkan spasi
    List<String> words = text.split(' ');

    // Tentukan format kata berdasarkan jumlah kata
    if (words.length == 1) {
      return words[0]; // Jika hanya satu kata
    } else if (words.length == 2) {
      return "${words[0]}\n${words[1]}"; // Dua kata, dipisah satu baris
    } else if (words.length == 3) {
      return "${words[0]}\n${words[1]} ${words[2]}"; // Tiga kata, dua kata di baris bawah
    } else if (words.length > 3) {
      // Jika lebih dari tiga kata, pisahkan tiga kata pertama sesuai format yang diinginkan
      return "${words[0]}\n${words[1]} ${words[2]}\n${words.sublist(3).join(' ')}";
    }

    return text; // Jika terjadi sesuatu yang tidak terduga, kembalikan teks asli
  }

  Future<Map<String, Map<String, dynamic>>> _fetchDataMoney() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('request_handyman').get();

      Map<String, Map<String, dynamic>> monthlyRevenue = {
        'pending': {
          'Jan': {'revenue': 0.0, 'transactions': 0},
          'Feb': {'revenue': 0.0, 'transactions': 0},
          'Mar': {'revenue': 0.0, 'transactions': 0},
          'Apr': {'revenue': 0.0, 'transactions': 0},
          'May': {'revenue': 0.0, 'transactions': 0},
          'Jun': {'revenue': 0.0, 'transactions': 0},
          'Jul': {'revenue': 0.0, 'transactions': 0},
          'Aug': {'revenue': 0.0, 'transactions': 0},
          'Sep': {'revenue': 0.0, 'transactions': 0},
          'Oct': {'revenue': 0.0, 'transactions': 0},
          'Nov': {'revenue': 0.0, 'transactions': 0},
          'Dec': {'revenue': 0.0, 'transactions': 0},
        },
        'cancel': {
          'Jan': {'revenue': 0.0, 'transactions': 0},
          'Feb': {'revenue': 0.0, 'transactions': 0},
          'Mar': {'revenue': 0.0, 'transactions': 0},
          'Apr': {'revenue': 0.0, 'transactions': 0},
          'May': {'revenue': 0.0, 'transactions': 0},
          'Jun': {'revenue': 0.0, 'transactions': 0},
          'Jul': {'revenue': 0.0, 'transactions': 0},
          'Aug': {'revenue': 0.0, 'transactions': 0},
          'Sep': {'revenue': 0.0, 'transactions': 0},
          'Oct': {'revenue': 0.0, 'transactions': 0},
          'Nov': {'revenue': 0.0, 'transactions': 0},
          'Dec': {'revenue': 0.0, 'transactions': 0},
        },
        'success': {
          'Jan': {'revenue': 0.0, 'transactions': 0},
          'Feb': {'revenue': 0.0, 'transactions': 0},
          'Mar': {'revenue': 0.0, 'transactions': 0},
          'Apr': {'revenue': 0.0, 'transactions': 0},
          'May': {'revenue': 0.0, 'transactions': 0},
          'Jun': {'revenue': 0.0, 'transactions': 0},
          'Jul': {'revenue': 0.0, 'transactions': 0},
          'Aug': {'revenue': 0.0, 'transactions': 0},
          'Sep': {'revenue': 0.0, 'transactions': 0},
          'Oct': {'revenue': 0.0, 'transactions': 0},
          'Nov': {'revenue': 0.0, 'transactions': 0},
          'Dec': {'revenue': 0.0, 'transactions': 0},
        },
      };

      for (var doc in querySnapshot.docs) {
        Timestamp timestamp = doc['created_date'];
        String priceString = doc['price'];
        double price = double.tryParse(priceString) ?? 0.0;
        DateTime date = timestamp.toDate();
        String monthAbbreviation = DateFormat('MMM').format(date);
        String status = doc['status'];

        if (monthlyRevenue.containsKey(status)) {
          monthlyRevenue[status]![monthAbbreviation]!['revenue'] += price;
          monthlyRevenue[status]![monthAbbreviation]!['transactions'] += 1;
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
                              child: FutureBuilder<Map<String, double>>(
                                future:
                                    _fetchDataRatingLayanan(), // Tipe data future disesuaikan dengan fungsi
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
                                    Map<String, double> ratingData =
                                        snapshot.data!;
                                    // Menggunakan double di sini
                                    List<BarSeriesData> chartData =
                                        ratingData.entries
                                            .map((entry) => BarSeriesData(
                                                  x: entry.key,
                                                  y: double.parse(entry.value
                                                      .toStringAsFixed(2)),
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
                                            tooltipBehavior: TooltipBehavior(
                                              enable: true,
                                            ),
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
                                          child: Text(
                                              'Data Jumlah Layanan Yang Digunakan'),
                                        ),
                                        Container(
                                          width: screenWidth,
                                          height: 300,
                                          child: SfCartesianChart(
                                            primaryXAxis: CategoryAxis(),
                                            series: <ChartSeries>[
                                              ColumnSeries<BarSeriesData,
                                                  String>(
                                                name: 'Jumlah Pekerjaan : ',
                                                dataSource: chartData,
                                                xValueMapper: (BarSeriesData
                                                            data,
                                                        _) =>
                                                    formatTextWithLineBreaks(
                                                        data.x.toLowerCase()),
                                                yValueMapper:
                                                    (BarSeriesData data, _) =>
                                                        data.y,
                                                color: Colors
                                                    .green, // Warna grafik untuk jumlah pekerjaan
                                              ),
                                            ],
                                            legend: Legend(isVisible: true),
                                            tooltipBehavior: TooltipBehavior(
                                              enable: true,
                                              header: '',
                                              format:
                                                  'point.x : point.y', // Gunakan `formatTextWithLineBreaks` di sini jika perlu
                                            ),
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
                                    child: Text(
                                        'Data Transaksi Penggunaan Layanan Handyman (RP)'),
                                  ),
                                  Expanded(
                                    child: FutureBuilder<
                                        Map<String, Map<String, dynamic>>>(
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
                                          Map<String, Map<String, dynamic>>
                                              revenueData = snapshot.data!;
                                          List<ChartDataMoney> pendingData =
                                              ChartDataMoney
                                                  ._generateChartDataMoney(
                                                      revenueData['pending']!);
                                          List<ChartDataMoney> successData =
                                              ChartDataMoney
                                                  ._generateChartDataMoney(
                                                      revenueData['success']!);
                                          List<ChartDataMoney> cancelData =
                                              ChartDataMoney
                                                  ._generateChartDataMoney(
                                                      revenueData['cancel']!);
                                          int totalTransactions = pendingData
                                                  .fold<num>(
                                                      0,
                                                      (num sum, data) =>
                                                          sum +
                                                          data.transactions)
                                                  .toInt() +
                                              successData
                                                  .fold<num>(
                                                      0,
                                                      (num sum, data) =>
                                                          sum +
                                                          data.transactions)
                                                  .toInt() +
                                              cancelData
                                                  .fold<num>(
                                                      0,
                                                      (num sum, data) =>
                                                          sum +
                                                          data.transactions)
                                                  .toInt();

                                          return Column(
                                            children: [
                                              // Display total revenue
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Total Transactions: ${totalTransactions}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),

                                              // Display chart
                                              SfCartesianChart(
                                                primaryXAxis: CategoryAxis(),
                                                tooltipBehavior:
                                                    TooltipBehavior(
                                                  enable: true,
                                                  builder: (dynamic data,
                                                      dynamic point,
                                                      dynamic series,
                                                      int pointIndex,
                                                      int seriesIndex) {
                                                    final chartData =
                                                        data as ChartDataMoney;
                                                    return Container(
                                                      width: 150,
                                                      height: 150,
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${series.name} (${chartData.x})',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'Revenue: ${currencyFormat.format(chartData.revenue)}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Text(
                                                            'Transactions: ${chartData.transactions}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                series: <ChartSeries>[
                                                  ColumnSeries<ChartDataMoney,
                                                      String>(
                                                    name: 'Pending',
                                                    dataSource: pendingData,
                                                    xValueMapper:
                                                        (ChartDataMoney data,
                                                                _) =>
                                                            data.x,
                                                    yValueMapper:
                                                        (ChartDataMoney data,
                                                                _) =>
                                                            data.revenue,
                                                    color: Colors.red,
                                                  ),
                                                  ColumnSeries<ChartDataMoney,
                                                      String>(
                                                    name: 'Success',
                                                    dataSource: successData,
                                                    xValueMapper:
                                                        (ChartDataMoney data,
                                                                _) =>
                                                            data.x,
                                                    yValueMapper:
                                                        (ChartDataMoney data,
                                                                _) =>
                                                            data.revenue,
                                                    color: Colors.green,
                                                  ),
                                                  ColumnSeries<ChartDataMoney,
                                                      String>(
                                                    name: 'Cancel',
                                                    dataSource: cancelData,
                                                    xValueMapper:
                                                        (ChartDataMoney data,
                                                                _) =>
                                                            data.x,
                                                    yValueMapper:
                                                        (ChartDataMoney data,
                                                                _) =>
                                                            data.revenue,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                                legend: Legend(isVisible: true),
                                              ),
                                            ],
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

class ChartDataMoney {
  final String x;
  final double revenue;
  final int transactions;

  @override
  String toString() {
    return 'ChartDataMoney(x: $x, revenue: $revenue, transactions: $transactions)';
  }

  static List<ChartDataMoney> _generateChartDataMoney(
      Map<String, dynamic> dataMap) {
    return dataMap.entries.map((entry) {
      String month = entry.key;
      double revenue = (entry.value['revenue'] as num).toDouble();
      int transactions = (entry.value['transactions'] as num).toInt();

      return ChartDataMoney(month, revenue, transactions);
    }).toList();
  }

  ChartDataMoney(this.x, this.revenue, this.transactions);
}
