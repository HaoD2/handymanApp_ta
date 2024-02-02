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

  @override
  void initState() {
    super.initState();
    fetchFavouriteUser();
  }

  Future<void> fetchFavouriteUser() async {
    try {
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
    } catch (error) {
      print("Error fetching favourite user data: $error");
    }
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
      body: favouriteUser != null &&
              favouriteUser!.like.keys
                  .where((key) => favouriteUser!.like[key] == true)
                  .isNotEmpty
          ? Column(
              children: favouriteUser!.like.keys.map((key) {
                if (favouriteUser!.like[key] == true) {
                  return ListTile(
                    title: Text('Menu  $key'),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return option_menu(layanan: key);
                          },
                        ),
                        (_) => false,
                      );
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              }).toList(),
            )
          : Center(
              child: Text('Belum ada layanan yang kamu suka'),
            ),
    );
  }
}
