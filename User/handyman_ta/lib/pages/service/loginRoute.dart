import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/Handyman/home.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:handyman_ta/pages/loginpage.dart';

class loginRoutePass extends StatefulWidget {
  static const routeName = '/loginRoute';
  const loginRoutePass({super.key});

  @override
  State<loginRoutePass> createState() => _loginRoutePassState();
}

class _loginRoutePassState extends State<loginRoutePass> {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future logout() async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
  }

  getData() async {
    QuerySnapshot querySnapshot = await _users
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(allData);
    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Menu'),
      ),
      body: Center(
        child: Card(
          elevation: 4.0,
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<dynamic>(
                  initialData: const {},
                  future: getData(),
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data.isEmpty ||
                        snapshot.hasError) {
                      if (snapshot.data == {}) {
                        return Container();
                      } else {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    }
                    final userData = snapshot.data[0];
                    final bool isHandyman = userData["status_handyman"] == 1;
                    return Container(
                      child: ListView(
                        children: [
                          SizedBox(
                            height: 350,
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    userHomepage.routeName,
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(
                                  Icons.message_sharp,
                                  size: 24.0,
                                ),
                                label: const Text('Halaman User Pemesanan'),
                              ),
                            ),
                          ),
                          if (isHandyman)
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => handymanHome(
                                        email: FirebaseAuth
                                            .instance.currentUser?.email,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.message_sharp,
                                  size: 24.0,
                                ),
                                label: const Text('Halaman User Handyman'),
                              ),
                            ),
                          Container(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await logout();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  LoginPage.routeName,
                                  (route) => false,
                                );
                              },
                              icon: const Icon(
                                Icons.message_sharp,
                                size: 24.0,
                              ),
                              label: const Text('Logout'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
