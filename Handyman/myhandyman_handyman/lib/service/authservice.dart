import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return null; // Login berhasil, kembalikan null
    } catch (e) {
      if (e is FirebaseAuthException) {
        print(
            "Firebase Auth Exception - Code: ${e.code}, Message: ${e.message}");
        // Handle specific Firebase Auth exceptions using e.code
        switch (e.code) {
          case "invalid-email":
            return "Your email address appears to be malformed.";
          case "wrong-password":
            return "Your password is wrong.";
          case "user-not-found":
            return "User with this email doesn't exist.";
          // ... other cases ...
          default:
            return "An undefined Error happened.";
        }
      }
      return "An error occurred."; // Error umum jika tidak ada pesan kesalahan yang spesifik
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
