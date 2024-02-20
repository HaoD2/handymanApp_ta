//pekerjaan
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/UI/custom_pemesanan/pemesanan_option.dart';
import 'package:handyman_ta/pages/User/UI/option_menu.dart';
import 'package:handyman_ta/pages/User/UI/showall_list.dart';
import 'package:handyman_ta/pages/loginpage.dart';
import 'package:handyman_ta/pages/service/authServices.dart';

import '../../Model/pekerjaan.dart';

class requestPekerjaan extends StatefulWidget {
  final email;
  const requestPekerjaan({super.key, this.email});
  static const routeName = '/User/request_pekerjaan';
  @override
  State<requestPekerjaan> createState() => _requestPekerjaanState();
}

class _requestPekerjaanState extends State<requestPekerjaan> {
  final CollectionReference _request_handyman =
      FirebaseFirestore.instance.collection('request_handyman');

  getdata() async {
    QuerySnapshot querySnapshot = await _request_handyman
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    return allData;
  }

  int currentIndex = 0;
  Future<List<Pekerjaan>> getDatas() async {
    await Firebase.initializeApp();

    PekerjaanService pekerjaanService = PekerjaanService();
    List<Pekerjaan> dataList = await pekerjaanService.getPekerjaanList();
    return dataList;
  }

  Future<List<DocumentSnapshot>?> getDataReqList() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null; // Pengguna tidak masuk, mengembalikan null
    }

    // Mengambil semua dokumen dengan kondisi status adalah "pending" atau "acquired"
    QuerySnapshot querySnapshot = await _request_handyman
        .where('status', whereIn: ['pending', 'on-progress', 'success'])
        .where('status_done', isEqualTo: false)
        .where('user', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs;
    } else {
      return null; // Tidak ada dokumen yang cocok, mengembalikan null
    }
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.all(25.0),
                      child: const Text("Pesan Handyman",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              fontFamily: 'OpenSans')),
                    ),
                    Container(
                      // Membuat Background Kotak
                      width: MediaQuery.of(context).size.width - 55,
                      height: MediaQuery.of(context).size.height / 4,
                      padding: const EdgeInsets.only(bottom: 15, right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: const Color.fromARGB(255, 151, 148, 148),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: FutureBuilder<List<Pekerjaan>>(
                          future: getDatas(), // Ganti dengan metode yang sesuai
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Pekerjaan>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<Pekerjaan> dataList = snapshot.data!;
                              return Container(
                                child: Wrap(
                                  alignment:
                                      WrapAlignment.start, // Mulai dari kiri
                                  spacing: 30, // Jarak antara menu
                                  runSpacing: 15,
                                  children: <Widget>[
                                    for (int i = 0; i < dataList.length; i++)
                                      GestureDetector(
                                        onTap: () async {
                                          AuthServices authService =
                                              AuthServices();
                                          User? user = await authService
                                              .getCurrentUser();
                                          if (user != null) {
                                            if (dataList[i].title ==
                                                "Lain - Lainnya") {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) {
                                                    return PemesananOption(
                                                        layanan:
                                                            dataList[i].title);
                                                  },
                                                ),
                                                (_) => false,
                                              );
                                            } else {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) {
                                                    return option_menu(
                                                        layanan:
                                                            dataList[i].title);
                                                  },
                                                ),
                                                (_) => false,
                                              );
                                            }
                                          } else {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Login Required'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
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
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
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
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              8.0), // Menambah jarak di sini
                                          child: SizedBox.fromSize(
                                            size: const Size(55, 55),
                                            child: ClipOval(
                                              child: Material(
                                                color: Colors.amberAccent,
                                                child: InkWell(
                                                  splashColor: Colors.green,
                                                  onTap: () async {
                                                    if (dataList[i]
                                                        .title
                                                        .isNotEmpty) {
                                                      // Periksa apakah judul tidak kosong
                                                      AuthServices authService =
                                                          AuthServices();
                                                      User? user =
                                                          await authService
                                                              .getCurrentUser();
                                                      if (user != null) {
                                                        if (dataList[i].title ==
                                                            "Lain - Lainnya") {
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return PemesananOption(
                                                                    layanan: dataList[
                                                                            i]
                                                                        .title);
                                                              },
                                                            ),
                                                            (_) => false,
                                                          );
                                                        } else {
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return option_menu(
                                                                    layanan: dataList[
                                                                            i]
                                                                        .title);
                                                              },
                                                            ),
                                                            (_) => false,
                                                          );
                                                        }
                                                      } else {
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Login Required'),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context,
                                                                              rootNavigator: true)
                                                                          .pushAndRemoveUntil(
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return LoginPage();
                                                                          },
                                                                        ),
                                                                        (_) =>
                                                                            false,
                                                                      );
                                                                    },
                                                                    child: Text(
                                                                        'Login'),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          16),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context,
                                                                              rootNavigator: true)
                                                                          .pushAndRemoveUntil(
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return LoginPage();
                                                                          },
                                                                        ),
                                                                        (_) =>
                                                                            false,
                                                                      );
                                                                    },
                                                                    child: Text(
                                                                        'Sign Up'),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          16),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        'Cancel'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      const Icon(
                                                        Icons.anchor,
                                                        size: 15,
                                                      ),
                                                      AutoSizeText(
                                                        dataList[i].title,
                                                        maxLines: 3,
                                                        wrapWords: true,
                                                        textAlign:
                                                            TextAlign.center,
                                                        minFontSize: 6,
                                                        maxFontSize: 7,
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'OpenSans',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 55,
                height: MediaQuery.of(context).size.height / 3,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3,
                      padding: const EdgeInsets.only(bottom: 25, right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: const Color.fromARGB(255, 151, 148, 148),
                      ),
                      child: Container(
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width / 5),
                              alignment: Alignment.topCenter,
                              child: Row(
                                children: [
                                  const Text("Pesanan Saya",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          fontFamily: 'OpenSans')),
                                  Container(
                                    margin: const EdgeInsets.only(left: 15),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                              fontFamily: 'OpenSans')),
                                      onPressed: () async {
                                        AuthServices authService =
                                            AuthServices();
                                        User? user =
                                            await authService.getCurrentUser();
                                        if (user != null) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return showAll_list(
                                                    email: widget.email);
                                              },
                                            ),
                                            (_) => false,
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            barrierDismissible:
                                                false, // Mencegah pengguna menutup dialog dengan mengklik latar belakang
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Login Required'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
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
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
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
                                                        Navigator.of(context)
                                                            .pop();
                                                        // Tutup dialog jika tombol Cancel ditekan
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: Container(
                                          margin: EdgeInsets.all(2),
                                          child: const Text('Lihat Semua')),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: FutureBuilder<List<DocumentSnapshot>?>(
                                future: getDataReqList(),
                                builder: (context,
                                    AsyncSnapshot<List<DocumentSnapshot>?>
                                        snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null &&
                                      snapshot.data!.isNotEmpty) {
                                    var data = snapshot.data![0].data()
                                        as Map<String, dynamic>;
                                    return Column(
                                      children: [
                                        ListTile(
                                          tileColor: Colors
                                              .white, // Warna latar belakang tile
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8.0), // Bentuk kotak dengan sudut melengkung
                                          ),
                                          onTap: () {
                                            // Fungsi ketika tile ditekan
                                          },
                                          contentPadding: EdgeInsets.all(
                                              12.0), // Padding untuk konten dalam tile
                                          title: Container(
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .blue, // Warna latar belakang teks
                                              borderRadius: BorderRadius.circular(
                                                  8), // Bentuk kotak dengan sudut melengkung
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(
                                                          0.5), // Warna shadow
                                                  spreadRadius:
                                                      3, // Radius penyebaran shadow
                                                  blurRadius:
                                                      5, // Radius blur shadow
                                                  offset: Offset(
                                                      0, 2), // Posisi shadow
                                                ),
                                              ],
                                            ),
                                            padding: EdgeInsets.all(
                                                8.0), // Padding teks
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${data['tipe_pekerjaan']}',
                                                  style: TextStyle(
                                                    color: Colors
                                                        .white, // Warna teks
                                                    // Gaya teks untuk tipe pekerjaan
                                                  ),
                                                ),
                                                Text(
                                                  'Status: ${data['status']}',
                                                  style: TextStyle(
                                                    color: Colors
                                                        .white, // Warna teks
                                                    // Gaya teks untuk status
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  } else {
                                    return Text('No data available');
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
