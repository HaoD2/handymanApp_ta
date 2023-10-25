import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myhandyman_handyman/page/login.dart';

class MessageMain extends StatefulWidget {
  const MessageMain({super.key});

  @override
  State<MessageMain> createState() => _MessageMainState();
}

class _MessageMainState extends State<MessageMain> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _checkAuthentication() {
    final User? user = _auth.currentUser;

    if (user == null) {
      // Pengguna belum login, arahkan ke halaman login
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }

  @override
  void initState() {
    super.initState();

    // Periksa status otentikasi pengguna saat halaman diinisialisasi
    _checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
