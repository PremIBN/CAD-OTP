import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  final String title;
  final String url;
  final String? token;
  const WebviewScreen({super.key, required this.title, required this.url, this.token});

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
    super.initState();
    final urlStr = widget.url.trim();
    final isHttp = urlStr.startsWith('http://') || urlStr.startsWith('https://');
    final isData = urlStr.startsWith('data:');
    if (urlStr.isNotEmpty && (isHttp || isData)) {
      url = Uri.parse(urlStr);
      webViewController = WebViewController();
      _initAndLoad();
    } else {
      url = null;
      webViewController = WebViewController();
    }
  }

  Future<void> _initAndLoad() async {
    try {
      await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
      await webViewController.setBackgroundColor(Colors.white);
      await webViewController.enableZoom(true);
      if (url == null || !mounted) return;
      final isDataUrl = url!.scheme == 'data';
      if (isDataUrl) {
        final dataUrlStr = widget.url.trim();
        final mime = _mimeFromDataUrl(dataUrlStr);
        final html = _htmlForDataUrl(dataUrlStr, mime);
        if (mounted) await webViewController.loadHtmlString(html, baseUrl: 'about:blank');
      } else {
        final token = widget.token;
        final headers = token != null && token.isNotEmpty
            ? <String, String>{'tokenID': token}
            : <String, String>{};
        if (mounted) await webViewController.loadRequest(url!, headers: headers);
      }
    } catch (_) {
      // Load failed; WebView will show blank instead of crashing
    }
  }

  static String _mimeFromDataUrl(String dataUrl) {
    if (!dataUrl.startsWith('data:')) return 'application/octet-stream';
    final semicolon = dataUrl.indexOf(';', 5);
    if (semicolon < 0) return 'application/octet-stream';
    return dataUrl.substring(5, semicolon).trim().toLowerCase();
  }

  static String _htmlForDataUrl(String dataUrl, String mime) {
    // Data URL payload is base64; no need to escape for use in quoted src.
    if (mime.startsWith('image/')) {
      return '''
<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"/></head>
<body style="margin:0;background:#fff;display:flex;justify-content:center;align-items:center;min-height:100vh">
<img src="$dataUrl" style="max-width:100%;height:auto;display:block"/>
</body></html>''';
    }
    if (mime == 'application/pdf') {
      return '''
<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"/></head>
<body style="margin:0;background:#525252;height:100vh">
<embed src="$dataUrl" type="application/pdf" width="100%" height="100%"/>
</body></html>''';
    }
    return '''
<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"/></head>
<body style="margin:0;background:#fff;height:100vh">
<embed src="$dataUrl" type="$mime" width="100%" height="100%"/>
</body></html>''';
  }


  Future<void> _openInBrowser() async {
    final u = url;
    if (u == null || u.scheme != 'http' && u.scheme != 'https') return;
    try {
      if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isHttp = url != null && (url!.scheme == 'http' || url!.scheme == 'https');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (isHttp)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: _openInBrowser,
              tooltip: 'Open in browser',
            ),
        ],
      ),
      body: url != null
          ? WebViewWidget(
              controller: webViewController,
              gestureRecognizers: gestureRecognizers,
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load document. The URL was missing or invalid.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
    );
  }
}
