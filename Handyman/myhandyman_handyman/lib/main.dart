import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myhandyman_handyman/page/login.dart';
import 'package:myhandyman_handyman/page/userHandyman.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myhandyman_handyman/service/fcmAPI.dart';
import 'constants/dimens.dart' as dimens;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final _firestoreInstance = FirebaseFirestore.instance;

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    firebaseAPI().request_permission();
    firebaseAPI().initInfo();
    print("uid : ");
    print(FirebaseAuth.instance.currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      routes: {userHandyman.routeName: (context) => const userHandyman()},
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme:
            GoogleFonts.interTextTheme(Theme.of(context).textTheme).copyWith(),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.blueAccent),
            overlayColor: MaterialStateProperty.all<Color>(Colors.lightBlue),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(dimens.bottomSheetBorderRadius),
              topRight: Radius.circular(dimens.bottomSheetBorderRadius),
            ),
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}
