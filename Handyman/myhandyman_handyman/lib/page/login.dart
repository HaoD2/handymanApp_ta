import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:myhandyman_handyman/page/userHandyman.dart';
import 'package:myhandyman_handyman/service/authservice.dart';
import 'package:myhandyman_handyman/service/fcmAPI.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/loginHandyman';
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
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return userHandyman();
                },
              ),
              (_) => false,
            );
          } // Ganti dengan rute yang sesuai
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
        child: SafeArea(
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
                ],
              ),
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
}
