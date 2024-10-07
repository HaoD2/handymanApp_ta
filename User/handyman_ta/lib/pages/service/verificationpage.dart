import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:handyman_ta/pages/loginpage.dart';
import 'package:handyman_ta/pages/service/authServices.dart';
import 'package:handyman_ta/pages/service/fcmAPI.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage(
      {Key? key, this.email, this.nama, this.date, this.notelp})
      : super(key: key);
  final email, date, nama, notelp;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool isEmailVerified = false;
  bool canResentEmail = false;
  int timeResend = 60;
  Timer? time;
  final _auth = FirebaseAuth.instance;
  final AuthServices authServices = AuthServices();

  @override
  void initState() {
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();
      time = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerified());
    }
    super.initState();
  }

  @override
  void dispose() {
    time?.cancel();
    super.dispose();
  }

  Future<bool> _showExitConfirmationDialog() async {
    Completer<bool> completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda ingin keluar dari verifikasi email?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              completer.complete(
                  false); // Memberi nilai false saat tombol "Tidak" ditekan
              Navigator.of(context).pop();
            },
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              completer.complete(
                  true); // Memberi nilai true saat tombol "Ya" ditekan

              FirebaseAuth.instance.currentUser?.delete();
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
            child: Text('Ya'),
          ),
        ],
      ),
    );

    return completer.future;
  }

  sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      if (user == null) {
        print('No user is signed in');
      }
      await user.sendEmailVerification();

      setState(() => canResentEmail = false);
      await Future.delayed(Duration(seconds: timeResend));
      setState(() {
        if (timeResend > 0) {
          timeResend--;
        }
      });
      setState(() => canResentEmail = true);
      setState(() {
        timeResend = 60;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      var user = _auth.currentUser;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email Successfully Verified")));
      time?.cancel();
      String? fcmToken = await firebaseAPI().initNotification();
      CollectionReference ref = FirebaseFirestore.instance.collection('users');
      await ref.doc(user!.uid).set({
        'uid': _auth.currentUser?.uid,
        'email': FirebaseAuth.instance.currentUser!.email,
        'nama': widget.nama,
        'date': widget.date,
        'notelp': widget.notelp,
        'saldo': 0,
        'status': 1,
        'status_verif': 1,
        'status_handyman': 0,
        'status_pesan': false,
        'status_kerja': false,
        'status_akun': 1,
        'token_messaging': fcmToken,
      });

      Navigator.pushReplacementNamed(context, userHomepage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hapus tombol kembali otomatis
      ),
      body: WillPopScope(
        onWillPop: _showExitConfirmationDialog,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Check your \n Email',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'We have sent you an email to ${_auth.currentUser?.email}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'Verifying email....',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 57),
              Text(
                'Resend Time: $timeResend seconds',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ElevatedButton(
                    child: const Text('Resend'),
                    onPressed: canResentEmail ? sendVerificationEmail : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
