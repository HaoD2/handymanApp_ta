import 'package:firebase_messaging/firebase_messaging.dart';

class firebaseAPI {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _messaging.requestPermission();
    final fcm_token = await _messaging.getToken();
    print(fcm_token);
  }
}
