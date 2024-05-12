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

  @override
  void initState() {
    super.initState();
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

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.amber,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.red,
      fontSize: 12,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('\$ ${value + 0.5}', style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cutOffYValue = 5.0;

    return AspectRatio(
      aspectRatio: 2,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 28,
          top: 22,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 4),
                  FlSpot(1, 3.5),
                  FlSpot(2, 4.5),
                  FlSpot(3, 1),
                  FlSpot(4, 4),
                  FlSpot(5, 6),
                  FlSpot(6, 6.5),
                  FlSpot(7, 6),
                  FlSpot(8, 4),
                  FlSpot(9, 6),
                  FlSpot(10, 6),
                  FlSpot(11, 7),
                ],
                isCurved: true,
                barWidth: 8,
                color: Colors.blue,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.black,
                  cutOffY: cutOffYValue,
                  applyCutOffY: true,
                ),
                aboveBarData: BarAreaData(
                  show: true,
                  color: Colors.purple,
                  cutOffY: cutOffYValue,
                  applyCutOffY: true,
                ),
                dotData: const FlDotData(
                  show: false,
                ),
              ),
            ],
            minY: 0,
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  '2019',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 18,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameSize: 20,
                axisNameWidget: const Text(
                  'Value',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                  getTitlesWidget: leftTitleWidgets,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.red,
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              checkToShowHorizontalLine: (double value) {
                return value == 1 || value == 6 || value == 4 || value == 5;
              },
            ),
          ),
        ),
      ),
    );
  }
}
