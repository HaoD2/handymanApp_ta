import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:myhandyman_handyman/page/login.dart';
import 'package:myhandyman_handyman/service/authservice.dart';
import 'package:http/http.dart' as http;
import 'package:myhandyman_handyman/service/changepassword.dart';

class profileHandyman extends StatefulWidget {
  static const routeName = '/Handyman/profile';
  const profileHandyman({super.key});

  @override
  State<profileHandyman> createState() => _profileHandymanState();
}

class _profileHandymanState extends State<profileHandyman> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int tempSaldo = 0;
  TextEditingController saldoController = TextEditingController();

  final AuthService _authService = AuthService();
  void _checkAuthentication() {
    final User? user = _auth.currentUser;

    if (user == null) {
      // Pengguna belum login, arahkan ke halaman login
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }

  @override
  void dispose() {
    saldoController.dispose();
    super.dispose();
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
                        maxHeight: 300,
                      ),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/home_decoration.png'),
                          fit: BoxFit.fill,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      child: ListTile(
                        title: Column(
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
                                return Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/images/icon_profile.png"),
                                            radius:
                                                20, // Atur sesuai kebutuhan Anda
                                          ),
                                          title: Text(
                                              "${FirebaseAuth.instance.currentUser?.email}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 15,
                                              )),
                                          trailing: IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              // Tambahkan logika untuk tombol edit di sini
                                            },
                                          ),
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (_, index) {
                                            final data = snapshot.data[index];
                                            final saldo = data['saldo'];
                                            tempSaldo = int.parse(
                                                saldo.toString() ?? '0');
                                            final status = data['status'];
                                            final statusHandyman =
                                                data['status_handyman'];

                                            // Menampilkan berdasarkan status
                                            if (status == 1 &&
                                                statusHandyman == 1) {
                                              return Container(
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading:
                                                          Icon(Icons.verified),
                                                      title: Text('Verified'),
                                                    ),
                                                    ListTile(
                                                      leading:
                                                          Icon(Icons.verified),
                                                      title: Text(
                                                          'Handyman Verified'),
                                                    ),
                                                    ListTile(
                                                      leading: Icon(
                                                          Icons.money_sharp),
                                                      title: Text('Saldo : ' +
                                                          saldo.toString()),
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Dialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              child: SaldoBox(
                                                                  context),
                                                            );
                                                          },
                                                        );
                                                      },
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
                                                      leading:
                                                          Icon(Icons.verified),
                                                      title: Text('Verified'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ));
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
                              onTap: () async {
                                await logout();
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

  Widget SaldoBox(BuildContext context1) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Jumlah Saldo : ' + tempSaldo.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          FormBuilderTextField(
            name: 'Saldo',
            controller: saldoController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Masukkan Saldo ',
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.numeric(),
              FormBuilderValidators.min(50000)
            ]),
          ),
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _submitSaldo(context1);
                },
                child: Text('Submit'),
              ),
              SizedBox(
                width: 80,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context1).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _submitSaldo(BuildContext context1) {
    String saldoText = saldoController.text;
    if (saldoText.isEmpty) {
      _showErrorDialog('Silakan masukkan jumlah saldo.');
      return;
    }

    int? saldo = int.tryParse(saldoText.toString());
    if (saldo == null || saldo < 50000) {
      _showErrorDialog('Saldo minimal yang bisa diambil adalah 50,000.');
      return;
    }

    if (saldo > tempSaldo) {
      _showErrorDialog('Saldo tidak mencukupi.');
      return;
    }

    String? email = FirebaseAuth.instance.currentUser!.email;
    String tanggal = DateTime.now().toString(); // Mengambil tanggal saat ini

    // Menambahkan data ke Firebase Firestore
    FirebaseFirestore.instance.collection('request_saldo_handyman').add({
      'email': email,
      'total_saldo': saldo,
      'tanggal': tanggal,
    }).then((value) {
      Navigator.of(context1).pop(); // Tutup dialog setelah submit
      print('Data berhasil ditambahkan!');
      // Mengambil saldo dari database users berdasarkan email
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data();
          // Update saldo user
          // Memeriksa dan mengambil saldo jika userData adalah Map<String, dynamic>
          if (userData is Map<String, dynamic>) {
            var saldoCurrent = userData['saldo'] as int;
            print('Saldo user sebelum: $saldoCurrent');

            // Update saldo user
            int newSaldo = saldoCurrent - saldo;
            FirebaseFirestore.instance
                .collection('users')
                .doc(querySnapshot
                    .docs.first.id) // Dokumen yang sesuai dengan query
                .update({'saldo': newSaldo}).then((_) {
              print('Saldo berhasil diupdate.');
              // Tambahkan penanganan setelah saldo berhasil diupdate jika diperlukan
            }).catchError((error) {
              print('Error saat melakukan update saldo: $error');
              // Tambahkan penanganan error jika update saldo gagal
            });
          } else {
            print('Data saldo tidak valid.');
            // Tambahkan penanganan jika data saldo tidak valid
          }
        } else {
          print('Email tidak ditemukan di database users.');
          // Tambahkan penanganan ketika email tidak ditemukan di database users
        }
      }).catchError((error) {
        print('Error saat mengambil data user: $error');
        // Tambahkan penanganan error saat mengambil data user
      });
      ScaffoldMessenger.of(context1).showSnackBar(
        SnackBar(
          content: Text('Request saldo berhasil dikirim!'),
          duration: Duration(seconds: 2), // Durasi tampilan snack bar
        ),
      );
      // Tambahkan kode lain yang perlu dieksekusi setelah data ditambahkan
    }).catchError((error) {
      print('Error: $error');
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
