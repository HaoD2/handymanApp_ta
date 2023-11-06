import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class firebaseAPI {
  final _messaging = FirebaseMessaging.instance;

  Future<String?> initNotification() async {
    await _messaging.requestPermission();
    final fcm_token = await _messaging.getToken();
    return fcm_token;
  }

  void request_permission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('grant permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('grant provisional permission');
    } else {
      print("user Declined");
    }
  }

  initInfo() {
    var androidInit =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInit = const IOSInitializationSettings();
    var InitSetting =
        InitializationSettings(android: androidInit, iOS: iosInit);
    FlutterLocalNotificationsPlugin().initialize(InitSetting,
        onSelectNotification: (String? payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
        } else {}
      } catch (e) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContent: true,
      );
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('dbFood', 'dbFood',
              importance: Importance.high,
              styleInformation: bigTextStyleInformation,
              priority: Priority.high,
              playSound: true);
      NotificationDetails platformspecifics = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const IOSNotificationDetails());
      await FlutterLocalNotificationsPlugin().show(
          0,
          message.notification!.title,
          message.notification!.body,
          platformspecifics,
          payload: message.data['title']);
    });
  }
}
