import 'package:admin_flutter/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDrT_0nzeqNQ1cxIWwA3Acet5yOLrivu2k",
          authDomain: "database-ta-1aec7.firebaseapp.com",
          projectId: "database-ta-1aec7",
          storageBucket: "database-ta-1aec7.appspot.com",
          messagingSenderId: "25940658453",
          appId: "1:25940658453:web:f915e513af44542212011c",
          measurementId: "G-P3ZHMZ6BHF"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'OpenSans')),
      home: home_view(),
    );
  }
}
