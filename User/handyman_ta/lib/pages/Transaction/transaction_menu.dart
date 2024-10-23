import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:handyman_ta/pages/service/messagingService.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_ta/pages/User/home.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SnapScreen extends StatefulWidget {
  final redirect_url;
  final order_id;
  final Map<String, dynamic> requestData;
  const SnapScreen(
      {super.key, this.redirect_url, this.order_id, required this.requestData});

  @override
  _SnapScreenState createState() => _SnapScreenState();
}

class _SnapScreenState extends State<SnapScreen> {
  late bool _isSuccess = false;
  final messaging = MessagingService();
  late WebViewController webViewController;
  bool _isLoading = false;
  bool _dataInserted = false;
  late final WebViewController _controller;
  Future<void> _insertPaymentData() async {
    if (_dataInserted) return;
    _dataInserted = true; // Set flag

    try {
      await FirebaseFirestore.instance
          .collection('request_handyman')
          .add(this.widget.requestData);
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .update({'status_pesan': true});
        });
      });
      final currentFCMToken = await FirebaseMessaging.instance.getToken();
      messaging.sendFCMMessage(currentFCMToken!, currentFCMToken!, "Pembayaran",
          "Pembayaran ${this.widget.order_id} anda Berhasil!");
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _isLoading = true;
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            print(url);
            _isLoading = false;
            if (url.contains(
                'https://famous-mastiff-sunny.ngrok-free.app/api/transaction/finish_trans?status_code=200&transaction_status=settlement&merchant_id=G494846640&order_id=${this.widget.order_id.toString()}')) {
              setState(() {
                _isSuccess = true;
              });
            }
            if (url.contains(
                'https://famous-mastiff-sunny.ngrok-free.app/api/transaction/finish_trans?order_id=${this.widget.order_id.toString()}&status_code=200&transaction_status=settlement')) {
              setState(() {
                _isSuccess = true;
              });
            }
            if (url.endsWith('https://simulator.sandbox.midtrans.com/')) {
              setState(() {
                _isSuccess = true;
              });
            }
            if (_isSuccess) {
              await _insertPaymentData();
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(this.widget.redirect_url));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  void didUpdateWidget(SnapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> insertToFirestore() async {
    String password = '';
    String basicAuth = 'Basic ' +
        base64.encode(
            utf8.encode('SB-Mid-server-jHCvz3LmqB9xqdY7KYD5Tu9d:$password'));
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': basicAuth, // Ganti basicAuth dengan nilai yang sesuai
    };
    final res = await http.post(
        Uri.parse(
            "https://famous-mastiff-sunny.ngrok-free.app/api/transaction/cancelPurchase"),
        headers: headers,
        body: jsonEncode({"order_id": this.widget.order_id}));
    if (res.statusCode == 200) {
      print('>>>>>>>>>>>>>>>>>>>>success');
      final responseData = jsonDecode(res.body);
    } else {
      print(res.statusCode.toString() + ">>>>>");
      print('>>>>>>>>>>>>>>>>>>>>gagal');
    }
    Map<String, dynamic> requestDataCancel = {};
    requestDataCancel.addAll(this.widget.requestData);
    // Ubah nilai status menjadi "cancel"
    requestDataCancel['status'] = 'cancel';
    await FirebaseFirestore.instance
        .collection('request_handyman')
        .add(requestDataCancel);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Konfirmasi'),
              content: Text('Apakah Anda yakin ingin Membatalkan Pembayaran?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Tidak'),
                ),
                TextButton(
                  onPressed: () async {
                    await insertToFirestore();
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Ya'),
                ),
              ],
            );
          },
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              if (_isSuccess)
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return userHomepage();
                        },
                      ),
                      (_) => false,
                    );
                  },
                ),
              Text(
                'PAYMENT',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
          elevation: 2,
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isLoading,
          child: Stack(
            children: <Widget>[
              Container(
                child: _isSuccess
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 80,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Terima kasih telah memesan jasa handyman',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ) // Tampilkan widget Success jika _isSuccess true
                    : Visibility(
                        visible: !_isSuccess, // Tambahkan kondisi ini
                        child: WebViewWidget(controller: _controller),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
