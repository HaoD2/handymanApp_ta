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
  const SnapScreen({super.key, this.redirect_url, this.order_id});

  @override
  _SnapScreenState createState() => _SnapScreenState();
}

class _SnapScreenState extends State<SnapScreen> {
  late bool _isSuccess = false;
  late WebViewController webViewController;
  bool _isLoading = false;
  late final WebViewController _controller;
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
          onPageFinished: (String url) {
            print(url);
            _isLoading = false;
            if (url.contains(
                'https://famous-mastiff-sunny.ngrok-free.app/api/transaction/finish_trans?status_code=200&transaction_status=settlement&merchant_id=G494846640&order_id=${this.widget.order_id.toString()}')) {
              setState(() {
                _isSuccess = true;
              });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_isSuccess)
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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
    );
  }
}
