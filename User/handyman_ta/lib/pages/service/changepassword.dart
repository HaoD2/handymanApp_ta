import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../User/home.dart';

void main() {
  runApp(const changepassword());
}

class changepassword extends StatelessWidget {
  final email;
  const changepassword({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Change App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PasswordChangeScreen(),
    );
  }
}

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _currentPassword = '';
  String _newPassword = '';

  void _changePassword() async {
    final User? user = _auth.currentUser;

    if (user != null && _formKey.currentState!.validate()) {
      try {
        // Reauthenticate user with current password
        final AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: _currentPassword);
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(_newPassword);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Password Changed'),
              content:
                  const Text('Your password has been changed successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(
                  'An error occurred while changing the password: ${error.toString()}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const userHomepage(),
              )),
        ),
      ),
      body: Container(
        constraints: BoxConstraints(
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: 300,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Current Password'),
                  onChanged: (value) {
                    setState(() {
                      _currentPassword = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  onChanged: (value) {
                    setState(() {
                      _newPassword = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
