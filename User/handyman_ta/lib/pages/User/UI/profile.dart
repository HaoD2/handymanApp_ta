import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handyman_ta/pages/Admin/showReqHandyman.dart';
import 'package:handyman_ta/pages/User/UI/favourites.dart';
import 'package:handyman_ta/pages/User/UI/request_handyman.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:handyman_ta/pages/loginpage.dart';
import 'package:handyman_ta/pages/service/authServices.dart';

import 'package:handyman_ta/pages/service/changepassword.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/service/loginRoute.dart';

class profile extends StatefulWidget {
  final email;
  static const routeName = '/User/profile';
  const profile({super.key, this.email});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final AuthServices _authService = AuthServices();
  final bool _isVerifying = false;
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

  Future logout() async {
    const CircularProgressIndicator();
    if (FirebaseAuth.instance.currentUser != null) {
      String? email = FirebaseAuth.instance.currentUser!.email;
      if (email != null) {
        final usersCollection = FirebaseFirestore.instance.collection('users');

// Lakukan query untuk mencari dokumen yang sesuai dengan email pengguna
        usersCollection
            .where('email', isEqualTo: email)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            for (QueryDocumentSnapshot doc in querySnapshot.docs) {
              // Dokumen ditemukan, update nilai token di dalamnya
              usersCollection.doc(doc.id).update({
                'token_messaging': "", // Gantilah dengan nilai token yang baru
              }).then((_) {
                print('Dokumen berhasil di-update.');
              }).catchError((error) {
                print('Gagal meng-update dokumen: $error');
              });
            }
          } else {
            print('Dokumen tidak ditemukan berdasarkan email.');
          }
        }).catchError((error) {
          print('Gagal melakukan query: $error');
        });
// Ganti dengan rute yang sesuai
      }
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
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
                        maxHeight: 200,
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
                        child: Column(
                          children: [
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (_, index) {
                                    final data = snapshot.data[index];
                                    final status = data['status'];
                                    final nama = data['nama'];
                                    final statusHandyman =
                                        data['status_handyman'];
                                    if (data == null) {
                                      logout();
                                    }
                                    // Menampilkan berdasarkan status
                                    if (status == 1 && statusHandyman == 1) {
                                      return Container(
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    "assets/images/icon_profile.png"),
                                                radius:
                                                    20, // Atur sesuai kebutuhan Anda
                                              ),
                                              title: Text("$nama}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  )),
                                              trailing: IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  // Tambahkan logika untuk tombol edit di sini
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return changepassword(
                                                            email: FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.email);
                                                      },
                                                    ),
                                                    (_) => false,
                                                  );
                                                },
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.verified),
                                              title: Text('Verified'),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.verified),
                                              title: Text('Handyman Verified'),
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
                                              leading: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    "assets/images/icon_profile.png"),
                                                radius:
                                                    20, // Atur sesuai kebutuhan Anda
                                              ),
                                              title: Text("$nama",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  )),
                                              trailing: IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  // Tambahkan logika untuk tombol edit di sini
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return changepassword(
                                                            email: FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.email);
                                                      },
                                                    ),
                                                    (_) => false,
                                                  );
                                                },
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.verified),
                                              title: Text('Verified'),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.warning),
                                              title:
                                                  Text('Handyman Unverified'),
                                              onTap: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (BuildContext context) {
                                                      return formRequestHandyman(
                                                          email: FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              ?.email);
                                                    },
                                                  ),
                                                  (_) => false,
                                                );
                                              },
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
                                child: const Icon(Icons.favorite),
                              ),
                              title: const Text(
                                'My Favourites',
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
                                      return favourite_page();
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
                                onTap: () async {
                                  return showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Konfirmasi Logout"),
                                        content:
                                            Text("Anda yakin ingin logout?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              await logout();
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) {
                                                    return const userHomepage();
                                                  },
                                                ),
                                                (_) => false,
                                              );
                                            },
                                            child: Text("Ya"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Jika user memilih "Tidak", maka tutup dialog box
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text("Tidak"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Stack(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minWidth: 0,
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: 175,
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/home_decoration.png'),
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                // Overlay gelap
                Container(
                  color: Colors.black.withOpacity(0.5),
                ),
                // Kotak putih dengan judul "Login Required"
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width:
                          300, // Sesuaikan lebar kotak putih sesuai kebutuhan
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Login Required',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return LoginPage();
                                  },
                                ),
                                (_) => false,
                              );
                            },
                            child: Text('Login'),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return LoginPage();
                                  },
                                ),
                                (_) => false,
                              );
                            },
                            child: Text('Sign Up'),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return userHomepage();
                                  },
                                ),
                                (_) => false,
                              ); // Tutup dialog jika tombol Cancel ditekan
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }
      }),
    );
  }
}
