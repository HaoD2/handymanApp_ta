import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class MessagingService {
  Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "database-ta-1aec7",
      "private_key_id": "a0e3aa3bc5d16b07238ffd9ec60f3a96390f27c1",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC54QOvC6bTyRfl\nIfvnIlSrVVPjfhJwpL7VJe4ZWhUWNzPtaZh1O1QYQEo/8Hzw00h9SH9kywJvPcnR\nPn5/7hf3TMErV6eZBwyfdgfFWzrnODDwHC0AgwHo6VFzWBak8nqvBqjHjcJx9qU6\n7DCHjrzMK3iEgDNmAqCmzrjQeF9c8dDW3o+HMlqRDVwJQ+ObJBkxgp8UYd4U0iTm\nRdmXf/mQ8irFm7CwEkK1b7pUSe17nferlP/lVMX6dNlX8g5T8yo6Rz0Fkz3mFygQ\ntjKzHTKSHryj2usZ9bhT8Ybb4d+sELa1hnO4yaFJAGEvcRh5XG2XqbAFIcibLNS4\nvDHPQjgnAgMBAAECggEAF5PkPLr0oV6bqlPiORJQvR7osi2WtzUeg7j497xGenfs\nHUxMq2ooI59cC7o8juuuAT5F8ooRt/yVcfZEY4PXBGZ3BkFrH+0V+9Aj8jO9SAEH\nrB1W0/7KKjoWO9RLowai6zqkBBQGOyB3Gv9EtJ01c4x8EAqW+nSQ3jfQl5j9N7O5\nSC12x2BIMDcEEmATe8Zb56JYAQzdP57SWboVv5mzal/W0klCQFgOUl/Xv9e6nMRl\n/4yixWHwM8i2+Ujh99szJzU2uyFx5urxuc4pv6rYVoQU/ecSJxs1y0FAo8ZX7T9d\nAsBjcZw7LwtXJAlpprFfjCrT+Jxis0Scsqbx9e+VgQKBgQDl4+VrZ1uJSdNwz4AM\nab9oXt4/AKPgHHOmVgxPT4cF6EHw9vLAcDDtRRaeYtEFe1T5aUKR6kI1tKgYrQec\nmPWs8FyPaUgHOTtQ1GxUk9twHixIJz7PQOIZt4fggWVeXLuG/KLJPgmpyd21JR6E\nPGlQyfjXNh9ALZva9TDxos4KZwKBgQDO/Xtvyv8kSWAoV4oSwV2OXP87azRUHrza\nAg+dA6eu1FkZrx+LeCIq9Ygw7KdM7quDmofRinaw/FM+EMJ+w8rcphNEnolTjMZj\nNQY5dzhlz11r9PxvLJT2VP9RRAGkRmSrHWRx+G9SFmKQ9bQd637qQIOqinLs9DlN\njJ3NIG1MQQKBgQC4s+zM6WMLH+yo855u2ru1sJshxXLlChcFKpeDVWMnpN7uKosJ\ngFpfGCY/JSfJHrk8Fo0szSlbGwX/pW27LM4en5POiYkcfKginjlXjuA86ZEse5Ok\nUv4WKXYbM/ts4Fau8uYbiCOdbhoag3NMTXlUNqIez1Y2ay6QsnUbf3HJuwKBgQCd\nGbyvG8ZMdzh5Rf+wvnxQifrZ0UMVOYMif//zrwt84QSDPuxVQafFLTfh0iwkct1Q\ndF/zRQFS0SAo8jV8WwRENfRX12/pLuZ/84W25eqzMxD32CgkBRVGZTqnJlOMqDTN\nvvA2pFVxWzYSSbocH1njV3XXYV9awv4fAsPeJWdvQQKBgQCXmql0Zs291emZhBaN\neUx287o93SkO1yGd9Z/+sWqRhvMu14LhFebrcAUNQkEMFnVArbX5b9EUdk35B4hL\nnfAblPVXl1zQ38xYJYFfx3DzxIDcGCAKKor852ZVfp4xvLHNsrWNifgtOq35AzTc\n407YeHF37W9m3OqvLEALOaSxNw==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-1fysd@database-ta-1aec7.iam.gserviceaccount.com",
      "client_id": "104510291209893779852",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-1fysd%40database-ta-1aec7.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }

  Future<String?> getToken() async {
    final currentFCMToken = await FirebaseMessaging.instance.getToken();
    return currentFCMToken;
  }

  Future<String> sendFCMMessage(String FcmSend, String FcmDeliver, String body,
      String messageAlert) async {
    final String serverKey = await getAccessToken(); // Your FCM server key
    final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/database-ta-1aec7/messages:send';
    final Map<String, dynamic> message = {
      'message': {
        'token':
            FcmDeliver, // Token of the device you want to send the message to
        'notification': {'body': body, 'title': messageAlert},
        'data': {
          'current_user_fcm_token':
              FcmSend, // Include the current user's FCM token in data payload
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return "success".toString();
    } else {
      return "failed".toString();
    }
  }
}
