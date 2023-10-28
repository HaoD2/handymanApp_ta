import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handyman_ta/pages/Handyman/home.dart';
import 'package:handyman_ta/pages/Transaction/transaction_menu.dart';
import 'package:handyman_ta/pages/User/UI/module_pemesanan.dart';
import 'package:handyman_ta/pages/User/UI/profile.dart';
import 'package:handyman_ta/pages/User/UI/request_handyman.dart';
import 'package:handyman_ta/pages/User/UI/request_pekerjaan.dart';
import 'package:handyman_ta/pages/User/UI/showall_list.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:handyman_ta/pages/loginpage.dart';
import 'package:handyman_ta/pages/register.dart';
import 'package:handyman_ta/pages/service/fcmAPI.dart';
import 'package:handyman_ta/pages/service/loginRoute.dart';
import 'package:handyman_ta/pages/service/verificationpage.dart';
import 'constants/dimens.dart' as dimens;
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await firebaseAPI().initNotification();
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        handymanHome.routeName: (context) => const handymanHome(),
        userHomepage.routeName: (context) => const userHomepage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        loginRoutePass.routeName: (context) => const loginRoutePass(),
        module.routeName: (context) => const ModulePemesanan(),
        profile.routeName: (context) => const profile(),
        formRequestHandyman.routeName: (context) => const formRequestHandyman(),
        requestPekerjaan.routeName: (context) => const requestPekerjaan(),
        showAll_list.routeName: (context) => const showAll_list(),
      },
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
      home: const userHomepage(),
    );
  }
}

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.emailVerified) {
            // Email terverifikasi, periksa status_verif di Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                } else {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  if (data['status_verif'] == 0) {
                    // Email terverifikasi tetapi status_verif = 0 (belum diverifikasi di Firestore)
                    return verificationPage(email: user.email);
                  } else {
                    // Email terverifikasi dan status_verif = 1 (sudah diverifikasi di Firestore)
                    return const userHomepage();
                  }
                }
              },
            );
          } else {
            // Email belum terverifikasi, tampilkan LoginPage
            return const userHomepage();
          }
        } else {
          // Tidak ada user yang terautentikasi, tampilkan LoginPage
          return const userHomepage();
        }
      },
    );
  }
}
