import 'package:admin_flutter/firebase_option.dart';
import 'package:admin_flutter/route/dashboard/main_dashboard.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options == null) {
    print('Firebase options are null. Please check your configuration.');
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'OpenSans')),
      home: MainDashboardScreen(),
    );
  }
}
