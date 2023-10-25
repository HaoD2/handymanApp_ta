import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myhandyman_handyman/page/login.dart';
import 'package:myhandyman_handyman/service/authservice.dart';
import 'package:myhandyman_handyman/service/changepassword.dart';

class profileHandyman extends StatefulWidget {
  const profileHandyman({super.key});

  @override
  State<profileHandyman> createState() => _profileHandymanState();
}

class _profileHandymanState extends State<profileHandyman> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  void _checkAuthentication() {
    final User? user = _auth.currentUser;

    if (user == null) {
      // Pengguna belum login, arahkan ke halaman login
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }

  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  getData() async {
    QuerySnapshot querySnapshot = await _users
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(allData);
    return allData;
  }

  @override
  void initState() {
    super.initState();

    // Periksa status otentikasi pengguna saat halaman diinisialisasi
    _checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _authService.getCurrentUser(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return Container(
              child: Container(
                child: ListView(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 0,
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: 175,
                      ),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/home_decoration.png'),
                          fit: BoxFit.fill,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        child: ListTile(
                          leading: Image.asset(
                            "assets/images/icon_profile.png",
                            fit: BoxFit.cover,
                          ),
                          trailing: Container(
                            margin: const EdgeInsets.all(2),
                            child: const Icon(Icons.edit),
                          ),
                          title: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: Text(
                                  "${FirebaseAuth.instance.currentUser?.email}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              FutureBuilder<dynamic>(
                                initialData: const {},
                                future: getData(),
                                builder:
                                    (context, AsyncSnapshot<dynamic> snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data == null ||
                                      snapshot.data.isEmpty ||
                                      snapshot.hasError) {
                                    if (snapshot.data == {}) {
                                      return Container();
                                    }
                                  }
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (_, index) {
                                      final data = snapshot.data[index];
                                      final status = data['status'];
                                      final statusHandyman =
                                          data['status_handyman'];

                                      // Menampilkan berdasarkan status
                                      if (status == 1 && statusHandyman == 1) {
                                        return Container(
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: Icon(Icons.verified),
                                                title: Text('Verified'),
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.verified),
                                                title:
                                                    Text('Handyman Verified'),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (status == 1 &&
                                          statusHandyman == 0) {
                                        return Container(
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: Icon(Icons.verified),
                                                title: Text('Verified'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.black54, width: 1))),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(5),
                            child: ListTile(
                                trailing: Container(
                                  margin: const EdgeInsets.all(5),
                                  child: const Icon(Icons.history_rounded),
                                ),
                                title: const Text(
                                  'History Pemesanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                )),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            child: ListTile(
                                trailing: Container(
                                  margin: const EdgeInsets.all(5),
                                  child: const Icon(Icons.contact_support),
                                ),
                                title: const Text(
                                  'Contact Support',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                )),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            child: ListTile(
                              trailing: Container(
                                margin: const EdgeInsets.all(5),
                                child: const Icon(Icons.lock),
                              ),
                              title: const Text(
                                'Change Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return changepassword(
                                          email: FirebaseAuth
                                              .instance.currentUser?.email);
                                    },
                                  ),
                                  (_) => false,
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            child: ListTile(
                              trailing: Container(
                                margin: const EdgeInsets.all(5),
                                child: const Icon(Icons.star_rate),
                              ),
                              title: const Text(
                                'Rate Us',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Rate Us'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                  'Would you like to rate our app on the store?'),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  for (int i = 1; i <= 5; i++)
                                                    IconButton(
                                                      icon: Icon(
                                                        i <= 3
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        size: 20,
                                                        color: Colors.orange,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child:
                                                    const Text('Maybe Later'),
                                              ),
                                            ]),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            child: ListTile(
                              trailing: Container(
                                margin: const EdgeInsets.all(5),
                                child: const Icon(Icons.exit_to_app),
                              ),
                              title: const Text(
                                'Keluar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return const LoginPage();
                                    },
                                  ),
                                  (_) => false,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return LoginPage();
          }
        }
      }),
    );
  }
}
