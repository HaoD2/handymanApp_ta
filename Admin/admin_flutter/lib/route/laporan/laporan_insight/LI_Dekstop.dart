import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Analytics with Firestore'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            sendDataToAnalytics(); // Memanggil fungsi untuk mengirim data
          },
          child: Text('Send Data to Analytics'),
        ),
      ),
    );
  }
}
