import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class showRequestHandyman extends StatefulWidget {
  final email;
  const showRequestHandyman({super.key, this.email});

  @override
  State<showRequestHandyman> createState() => _showRequestHandymanState();
}

class _showRequestHandymanState extends State<showRequestHandyman> {
  Future<List<String>> getImageUrls() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('request_handyman')
          .where('user', isEqualTo: this.widget.email)
          .get();

      final List<String> imageUrls = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final imageUrl = data['image'] as String;
        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (e) {
      print('Error getting image URLs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<List<String>>(
        future: getImageUrls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Text('Gambar tidak ditemukan.');
          } else {
            return Column(
              children: snapshot.data!.map((imageUrl) {
                print(imageUrl);
                return Image.network(imageUrl);
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
