import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  final String title;
  final String url;
  const WebviewScreen({super.key, required this.title, required this.url});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {

  late WebViewController webViewController;
  Uri? url;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    url = Uri.parse(widget.url);
    webViewController = WebViewController()..loadRequest(url!);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: WebViewWidget(
        controller: webViewController,
        gestureRecognizers: gestureRecognizers,
      ),

    );
  }
}
