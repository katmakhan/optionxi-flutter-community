import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserLite_Widget extends StatefulWidget {
  final String url;
  const BrowserLite_Widget(this.url, {super.key});

  @override
  State<BrowserLite_Widget> createState() => _BrowserLite_WidgetState();
}

class _BrowserLite_WidgetState extends State<BrowserLite_Widget> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Uri uri =
        Uri.tryParse(widget.url) ?? Uri.parse("https://in.tradingview.com/");
    if (!uri.hasScheme) {
      uri = Uri.parse("https://${widget.url}");
    }

    _controller = WebViewController()
      ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
            print("Widget Loaded: $url");
          },
          onWebResourceError: (WebResourceError error) {
            print("WebView Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
      ],
    );
  }
}
