import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:handyman_ta/pages/register.dart';
import 'package:handyman_ta/pages/service/authServices.dart';
import 'package:handyman_ta/pages/service/fcmAPI.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthServices _authService = AuthServices();

  void loginCheck() async {
    String username = usernameController.text.toString();
    String password = passwordController.text.toString();

    // Mengecek apakah pengguna ada dalam koleksi users
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Pengguna ditemukan, cek status_akun
      var userData = querySnapshot.docs.first.data();
      int statusAkun = userData['status_akun'];

      if (statusAkun == 1) {
        loginUser();
        print('Login berhasil');
      } else {
        // Status akun bukan 1, beri peringatan
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Status Akun Terkena Ban"),
              content:
                  Text("Anda tidak dapat login karena akun Anda terkena ban."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Pengguna tidak ditemukan
      // Tambahkan logika untuk menangani kasus ini sesuai kebutuhan Anda
      print('Pengguna tidak ditemukan');
    }
  }

  void loginUser() async {
    // Ganti dengan email dan password sesuai input pengguna

    if (_formKey.currentState!.validate()) {
      print(FirebaseAuth.instance.currentUser?.email);
      final loginResult = await _authService.Login(
          usernameController.text.trim(), passwordController.text.trim());
      if (loginResult == null) {
        // Login berhasil, arahkan ke halaman UserHome
        final fcmToken = await FirebaseMessaging.instance.getToken();
        ;
        if (FirebaseAuth.instance.currentUser != null) {
          String? email = FirebaseAuth.instance.currentUser!.email;
          if (email != null) {
            final usersCollection =
                FirebaseFirestore.instance.collection('users');

// Lakukan query untuk mencari dokumen yang sesuai dengan email pengguna
            usersCollection
                .where('email', isEqualTo: email)
                .get()
                .then((querySnapshot) {
              if (querySnapshot.docs.isNotEmpty) {
                for (QueryDocumentSnapshot doc in querySnapshot.docs) {
                  // Dokumen ditemukan, update nilai token di dalamnya
                  usersCollection.doc(doc.id).update({
                    'token_messaging':
                        fcmToken, // Gantilah dengan nilai token yang baru
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
          }
          Navigator.pushReplacementNamed(context, userHomepage.routeName);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loginResult),
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: 600,
        ),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/home_decoration.png',
            ),
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 180, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'Email',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: usernameController,
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'password',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RegisterPage.routeName,
                          (route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor:
                            Colors.blue, // warna latar belakang biru
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white, // warna teks putih
                        ),
                      ),
                    ),
                    SizedBox(width: 200),
                    TextButton(
                      onPressed: () async {
                        loginCheck();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor:
                            Colors.blue, // warna latar belakang biru
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white, // warna teks putih
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logoutFromFirebase() async {
    await FirebaseAuth.instance.signOut();
    usernameController.clear(); // Membersihkan username
    passwordController.clear(); // Membersihkan password
  }

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _showMyDialog() {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return Center(
  //         child: AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(
  //               Radius.circular(10.0),
  //             ),
  //           ),
  //           icon: Container(
  //             width: 120,
  //             height: 120,
  //             child: Icon(Icons.account_circle_rounded),
  //           ),
  //           content: SingleChildScrollView(
  //             child: ListBody(
  //               children: const <Widget>[
  //                 Text(
  //                   'Akun Verifikasi',
  //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 Text(
  //                   'Apakah anda ingin melakukan Verifikasi akun ini?',
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: <Widget>[
  //             Container(
  //               padding: EdgeInsets.all(20),
  //               child: Row(
  //                 children: [
  //                   Container(
  //                     width: 108,
  //                     height: 36,
  //                     child: TextButton(
  //                       style: TextButton.styleFrom(
  //                         backgroundColor: Color.fromARGB(255, 239, 248, 255),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10.0),
  //                         ),
  //                       ),
  //                       child: const Text(
  //                         'Tidak',
  //                         style: TextStyle(
  //                           color: Color.fromARGB(255, 24, 72, 169),
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     width: 2,
  //                   ),
  //                   Container(
  //                     width: 108,
  //                     height: 36,
  //                     child: TextButton(
  //                       style: TextButton.styleFrom(
  //                         backgroundColor: colors.primary,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10.0),
  //                         ),
  //                       ),
  //                       child: const Text(
  //                         'Ya',
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                       onPressed: () {
  //                         Navigator.of(context, rootNavigator: true)
  //                             .pushAndRemoveUntil(
  //                           MaterialPageRoute(
  //                             builder: (BuildContext context) {
  //                               return verificationPage(
  //                                   email: usernameController.text.trim());
  //                             },
  //                           ),
  //                           (_) => false,
  //                         );
  //                       },
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
