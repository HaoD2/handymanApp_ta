import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/UI/module_pemesanan.dart';
import 'package:handyman_ta/pages/User/home.dart';

class option_menu extends StatefulWidget {
  final layanan;
  const option_menu({super.key, this.layanan});

  @override
  State<option_menu> createState() => _option_menuState();
}

class _option_menuState extends State<option_menu> {
  bool isFavourite = false;
  List<String> optionLayanan = [];
  Future<void> getOptionData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("option_layanan")
          .where('nama_layanan', isEqualTo: widget.layanan)
          .get();

      setState(() {
        optionLayanan = querySnapshot.docs
            .map((doc) => List<String>.from(doc.get('option')))
            .expand((options) => options)
            .toList();
      });
      print("Option Layanan: $optionLayanan");
    } catch (e) {
      print("Error fetching option data: $e");
    }
  }

  Future<void> updateFavouriteStatus(bool newStatus) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('favourites_users')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Dokumen ditemukan, ambil dokumen pertama
        DocumentSnapshot doc = querySnapshot.docs[0];

        // Update status favourites berdasarkan email
        await doc.reference.update({
          'like.${widget.layanan}': newStatus,
        });
        print("Favourite status updated!");
      } else {
        // Dokumen tidak ditemukan, buat dokumen baru
        await FirebaseFirestore.instance.collection('favourites_users').add({
          'email': FirebaseAuth.instance.currentUser?.email,
          'like': {
            '${widget.layanan}': newStatus,
          },
        });
        print("New document created!");
      }
    } catch (error) {
      print("Failed to update or create document: $error");
    }
  }

  @override
  void initState() {
    print(this.widget.layanan);
    super.initState();
    getOptionData();

    // Pengecekan data dari Firestore
    FirebaseFirestore.instance
        .collection('favourites_users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.exists) {
          // Set nilai isFavourite sesuai dengan data di Firestore
          setState(() {
            isFavourite = doc['like'][widget.layanan] ?? false;
          });
        }
      });
    }).catchError((error) {
      print("Error fetching document: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: (() => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const userHomepage(),
              ))),
        ),
        title: Text("${this.widget.layanan}"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Ubah status layanan favourites
              setState(() {
                isFavourite = !isFavourite;
              });
              updateFavouriteStatus(isFavourite);
            },
            icon: Icon(
              isFavourite ? Icons.favorite : Icons.favorite_border,
              color: isFavourite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
                minWidth: 0,
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height / 2),
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/home_decoration.png',
                ),
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
            ),
            child: ListView.builder(
              itemCount: optionLayanan.length,
              itemBuilder: (BuildContext context, int index) {
                String option = optionLayanan[index];
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    if (option == "Lain - Lain") {
                    } else {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return module(layanan: option);
                          },
                        ),
                        (_) => false,
                      );
                    }
                  },
                  // Add onTap handler if needed
                );
              },
            ),
          )
        ],
      )),
    );
  }
}
