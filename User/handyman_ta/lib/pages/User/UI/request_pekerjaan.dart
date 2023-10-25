//pekerjaan
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/UI/showall_list.dart';
import 'package:handyman_ta/pages/loginpage.dart';
import 'package:handyman_ta/pages/service/authservice.dart';

import '../../Model/pekerjaan.dart';
import 'module_pemesanan.dart';

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

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    height: MediaQuery.of(context).size.height / 3,
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
                              child: Column(
                                children: [
                                  for (int i = 0;
                                      i < dataList.length && i < 8;
                                      i += 4)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        // Menu dari Database
                                        for (int j = i;
                                            j < i + 4 &&
                                                j < dataList.length &&
                                                j < 8;
                                            j++)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical:
                                                    15), // Tambahkan jarak kiri dan kanan
                                            child: GestureDetector(
                                              child: SizedBox.fromSize(
                                                size: const Size(55, 55),
                                                child: ClipOval(
                                                  child: Material(
                                                    color: Colors.amberAccent,
                                                    child: InkWell(
                                                      splashColor: Colors.green,
                                                      onTap: () async {
                                                        AuthService
                                                            authService =
                                                            AuthService();
                                                        User? user =
                                                            await authService
                                                                .getCurrentUser();
                                                        if (user != null) {
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return module(
                                                                    layanan: dataList[
                                                                            j]
                                                                        .title);
                                                              },
                                                            ),
                                                            (_) => false,
                                                          );
                                                        } else {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false, // Mencegah pengguna menutup dialog dengan mengklik latar belakang
                                                            builder:
                                                                (BuildContext
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
                                                                        Navigator.of(context,
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
                                                                        Navigator.of(context,
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
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        // Tutup dialog jika tombol Cancel ditekan
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
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          const Icon(
                                                            Icons.anchor,
                                                            size: 15,
                                                          ), // <-- Icon
                                                          AutoSizeText(
                                                            dataList[j].title,
                                                            maxLines: 3,
                                                            wrapWords:
                                                                true, // Jumlah maksimal baris teks
                                                            textAlign: TextAlign
                                                                .center,
                                                            minFontSize:
                                                                6, // Ukuran font minimum
                                                            maxFontSize:
                                                                7, // Ukuran font maksimum
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'OpenSans',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ), // <-- Text
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
                                  left: MediaQuery.of(context).size.width / 4),
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
                                        AuthService authService = AuthService();
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
                                      child: const Text('Lihat Semua'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: FutureBuilder<dynamic>(
                              initialData: const {},
                              future: getdata(),
                              builder:
                                  (context, AsyncSnapshot<dynamic> snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data == null ||
                                    snapshot.data.isEmpty ||
                                    snapshot.hasError) {
                                  if (snapshot.data == {}) {
                                    return Container();
                                  } else {
                                    // print("masuk");

                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              200,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                }
                                print("email ini ${widget.email}");

                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 200,
                                  child: ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (_, int index) {
                                      return Container(
                                        child: Text(snapshot.data[index]
                                                ["nama_layanan"]
                                            .toString()),
                                      );
                                    },
                                  ),
                                );
                              },
                            )),
                          ],
                        )),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
