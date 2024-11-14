import 'package:admin_flutter/firebase_option.dart';
import 'package:admin_flutter/loginpage.dart';
import 'package:admin_flutter/route/dashboard/main_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'OpenSans'),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika snapshot memiliki data, berarti user sudah login
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            // Jika tidak ada user yang login, arahkan ke halaman login
            return loginPage();
          }
          // Jika sudah login, arahkan ke halaman dashboard
          return MainDashboardScreen();
        }

        // Tampilkan indikator loading saat cek status login
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
