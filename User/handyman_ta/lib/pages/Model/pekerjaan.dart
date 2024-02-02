import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class Pekerjaan {
  final String title;
  final String imageName;
  final double price;

  Pekerjaan(this.title, this.imageName, this.price);

  factory Pekerjaan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String title = data['title'] ?? '';
    String imageName = data['imageName'] ?? '';
    double price = _parseDouble(data['price']);

    return Pekerjaan(title, imageName, price);
  }
  static double _parseDouble(value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }
}

class PekerjaanService {
  final CollectionReference pekerjaanCollection =
      FirebaseFirestore.instance.collection('pekerjaan');

  Future<List<Pekerjaan>> getPekerjaanList() async {
    try {
      QuerySnapshot querySnapshot = await pekerjaanCollection.get();
      List<Pekerjaan> pekerjaanList = querySnapshot.docs
          .map((doc) => Pekerjaan.fromFirestore(doc))
          .toList();
      return pekerjaanList;
    } catch (e) {
      print('Error fetching pekerjaan: $e');
      return [];
    }
  }

  Future<List<Pekerjaan>> getPekerjaanListRand() async {
    try {
      List<Pekerjaan> pekerjaanList = [];

      // Query and add data from first query
      QuerySnapshot querySnapshot1 = await pekerjaanCollection
          .where('title', isEqualTo: 'Layanan Pembersihan')
          .get();
      pekerjaanList.addAll(querySnapshot1.docs
          .map((doc) => Pekerjaan.fromFirestore(doc))
          .toList());

      // Query and add data from second query
      QuerySnapshot querySnapshot2 = await pekerjaanCollection
          .where('title', isEqualTo: 'Layanan Jasa Titip')
          .get();
      pekerjaanList.addAll(querySnapshot2.docs
          .map((doc) => Pekerjaan.fromFirestore(doc))
          .toList());

      // Query and add data from third query
      QuerySnapshot querySnapshot3 = await pekerjaanCollection
          .where('title', isEqualTo: 'Layanan Perbaikan')
          .get();
      pekerjaanList.addAll(querySnapshot3.docs
          .map((doc) => Pekerjaan.fromFirestore(doc))
          .toList());

      return pekerjaanList;
    } catch (e) {
      print('Error fetching pekerjaan: $e');
      return [];
    }
  }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    PekerjaanService pekerjaanService = PekerjaanService();
    List<Pekerjaan> dataList = await pekerjaanService.getPekerjaanList();
  }
}
