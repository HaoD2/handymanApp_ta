import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:handyman_ta/pages/register.dart';
import 'package:handyman_ta/pages/service/authservice.dart';
import 'package:handyman_ta/pages/service/fcmAPI.dart';
import 'package:handyman_ta/pages/service/loginRoute.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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
  final AuthService _authService = AuthService();
  void loginUser() async {
    // Ganti dengan email dan password sesuai input pengguna

    if (_formKey.currentState!.validate()) {
      final loginResult = await _authService.signInWithEmailAndPassword(
          usernameController.text.trim(), passwordController.text.trim());

      if (loginResult == null) {
        // Login berhasil, arahkan ke halaman UserHome
        String? fcmToken = await firebaseAPI().initNotification();
        if (FirebaseAuth.instance.currentUser != null) {
          String? email = FirebaseAuth.instance.currentUser!.email;
          print("ini + $email");
          print("ini + $fcmToken");
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
        // Login gagal, tampilkan pesan kesalahan kepada pengguna
        // Kamu dapat menggunakan pesan kesalahan dari loginResult
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
      body: SafeArea(
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
                        name: 'username',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                        decoration: InputDecoration(
                          labelText: 'Username',
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
                TextButton(
                  onPressed: () async {
                    loginUser();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
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
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
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
