import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/UI/option_menu.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:handyman_ta/pages/service/favourites_service.dart';

class favourite_page extends StatefulWidget {
  const favourite_page({super.key});

  @override
  State<favourite_page> createState() => _favourite_pageState();
}

class _favourite_pageState extends State<favourite_page> {
  FavouriteUserService? favouriteUser;
  Future<void> fetchFavouriteUser() async {
    // Ambil data FavouriteUser dari Firestore berdasarkan email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('favourites_users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Jika ditemukan, ambil dokumen pertama
      DocumentSnapshot doc = querySnapshot.docs[0];

      setState(() {
        favouriteUser = FavouriteUserService.fromFirestore(doc);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFavouriteUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourites'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return userHomepage();
                },
              ),
              (_) => false,
            );
          },
        ),
      ),
      body: favouriteUser != null
          ? Column(
              children: [
                if (favouriteUser?.like['Layanan Jasa Titip'] == true)
                  ListTile(
                    title: Text('Menu Layanan Jasa Titip'),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return option_menu(layanan: "Layanan Jasa Titip");
                          },
                        ),
                        (_) => false,
                      );
                    },
                    // Tambahkan aksi yang diperlukan ketika menu ini diklik
                  ),
                if (favouriteUser?.like['Layanan Pembersihan'] == true)
                  ListTile(
                    title: Text('Menu Layanan Pembersihan'),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return option_menu(layanan: "Layanan Pembersihan");
                          },
                        ),
                        (_) => false,
                      );
                    },
                    // Tambahkan aksi yang diperlukan ketika menu ini diklik
                  ),
                if (favouriteUser?.like['Layanan Perbaikan'] == true)
                  ListTile(
                    title: Text('Menu Layanan Perbaikan'),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return option_menu(layanan: "Layanan Perbaikan");
                          },
                        ),
                        (_) => false,
                      );
                    },
                    // Tambahkan aksi yang diperlukan ketika menu ini diklik
                  ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
