import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:myhandyman_handyman/page/history_pemesanan.dart';
import 'package:myhandyman_handyman/page/login.dart';
import 'package:myhandyman_handyman/page/userHandyman.dart';
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
  final NumberFormat formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  int tempSaldo = 0;

  TextEditingController saldoController = TextEditingController();
  TextEditingController norekController = TextEditingController();
  String bankValue = 'BCA';
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
    norekController.dispose();
    super.dispose();
  }

  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  getData() async {
    QuerySnapshot querySnapshot = await _users
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

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
    setState(() {});
    // Periksa status otentikasi pengguna saat halaman diinisialisasi
    _checkAuthentication();
    getData();
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
                            StreamBuilder<QuerySnapshot>(
                              stream: _users
                                  .where("email",
                                      isEqualTo: FirebaseAuth
                                          .instance.currentUser?.email)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // Tampilkan indikator loading jika data masih diambil
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.data == null ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Text('No data available');
                                }

                                final List<DocumentSnapshot> documents =
                                    snapshot.data!.docs;
                                final allData =
                                    documents.map((doc) => doc.data()).toList();

                                return Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: allData.length,
                                        itemBuilder: (_, index) {
                                          final List<
                                                  QueryDocumentSnapshot<
                                                      Object?>> documents =
                                              snapshot.data!.docs;
                                          if (index >= documents.length) {
                                            // Handle case when index is out of bounds
                                            return Container();
                                          }
                                          final Map<String, dynamic>? data =
                                              documents[index].data()
                                                  as Map<String, dynamic>?;
                                          if (data == null) {
                                            // Handle case when data is null
                                            return Container();
                                          }
                                          final saldo = data['saldo'];
                                          final status = data['status'];
                                          final nama = data['nama'];
                                          final statusHandyman =
                                              data['status_handyman'];

                                          // Menampilkan berdasarkan status
                                          if (status == 1 &&
                                              statusHandyman == 1) {
                                            return Container(
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundImage: AssetImage(
                                                          "assets/images/icon_profile.png"),
                                                      radius: 20,
                                                    ),
                                                    title: Text(
                                                      "${nama}",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    trailing: IconButton(
                                                      icon: Icon(Icons.edit),
                                                      onPressed: () {
                                                        // Tambahkan logika untuk tombol edit di sini
                                                      },
                                                    ),
                                                  ),
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
                                                    leading:
                                                        Icon(Icons.money_sharp),
                                                    title: Text('Saldo : ' +
                                                        formatCurrency.format(
                                                            int.parse(saldo
                                                                .toString()))),
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
                                                                context, saldo),
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

                                          return Container(); // Return a default empty container if conditions are not met
                                        },
                                      ),
                                    ],
                                  ),
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
                              ),
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return history_pemesanan();
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

  Widget SaldoBox(BuildContext context1, int saldo) {
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
            'Jumlah Saldo : ' + saldo.toString(),
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
          SizedBox(
            height: 20,
          ),
          DropdownButtonFormField<String>(
            value: bankValue,
            onChanged: (String? newValue) {
              setState(() {
                bankValue = newValue!;
              });
            },
            items: <String>['BCA', 'BRI', 'Mandiri']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Pilih Bank',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FormBuilderTextField(
            name: 'No Rekening',
            controller: norekController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Masukkan No Rekening Saldo ',
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  if (saldoController.text.isEmpty ||
                      norekController.text.isEmpty ||
                      saldoController.text == '' ||
                      norekController.text == '') {
                    print('masuk');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Peringatan'),
                          content: Text('Mohon lengkapi semua field.'),
                          actions: [
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
                  } else {
                    double saldopay = double.parse(saldoController.text) ?? 0.0;
                    double pajak = saldopay * 0.05;
                    double totalPengambilan = saldopay - pajak;
                    print(saldo);
                    print(saldopay);
                    showDialog(
                      context: context1,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Ringkasan Pengambilan Saldo'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  'Total Pengambilan Saldo: ${formatCurrency.format(saldopay)}'),
                              SizedBox(height: 10),
                              Text(
                                  'Pajak (5%): ${formatCurrency.format(pajak)}'),
                              SizedBox(height: 10),
                              Text(
                                  'Total yang diterima: ${formatCurrency.format(totalPengambilan)}'),
                            ],
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Tutup dialog
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                _submitSaldo(context1);

                                Navigator.of(context).pop();
                                setState(() {
                                  norekController.clear();
                                  saldoController.clear();
                                });
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Submit'),
              ),
              SizedBox(
                width: 80,
              ),
              ElevatedButton(
                onPressed: () {
                  saldoController.text = "";
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
    }

    int? saldo = int.tryParse(saldoText.toString());
    if (saldo == null || saldo < 50000) {
      _showErrorDialog('Saldo minimal yang bisa diambil adalah 50,000.');
    }

    if (saldo! > tempSaldo) {
      _showErrorDialog('Saldo tidak mencukupi.');
    }

    String? email = FirebaseAuth.instance.currentUser!.email;
    String tanggal = DateTime.now().toString();
    String noRekening = norekController.text;

    FirebaseFirestore.instance.collection('request_saldo_handyman').add({
      'email': email,
      'no_rekening': noRekening,
      'bank': bankValue,
      'total_saldo': saldo,
      'tanggal': tanggal,
    }).then((value) {
      Navigator.of(context1).pop(); // Tutup dialog setelah submit
      print('Data berhasil ditambahkan!');

      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data();
          if (userData is Map<String, dynamic>) {
            var saldoCurrent = userData['saldo'] as int;
            print('Saldo user sebelum: $saldoCurrent');

            int newSaldo = saldoCurrent - saldo;
            FirebaseFirestore.instance
                .collection('users')
                .doc(querySnapshot.docs.first.id)
                .update({'saldo': newSaldo}).then((_) {
              print('Saldo berhasil diupdate.');
            }).catchError((error) {
              print('Error saat melakukan update saldo: $error');
            });
          } else {
            print('Data saldo tidak valid.');
          }
        } else {
          print('Email tidak ditemukan di database users.');
        }
      }).catchError((error) {
        print('Error saat mengambil data user: $error');
      });

      ScaffoldMessenger.of(context1).showSnackBar(
        SnackBar(
          content: Text('Request saldo berhasil dikirim!'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        saldoController.clear();
        norekController.clear();
      });
      // Tambahkan navigasi dan efek refresh di sini
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

void _showSuccessSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Request saldo berhasil dikirim!'),
      duration: Duration(seconds: 2),
    ),
  );
}
