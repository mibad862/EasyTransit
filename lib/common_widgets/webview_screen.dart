import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  double _progress = 0;
  late InAppWebViewController webController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Bus Schedule", showicon: true),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: WebUri.uri(Uri.parse("https://pkbuses.com/bus-services/"))),
        onWebViewCreated: (InAppWebViewController controller) {
          webController = controller;
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          setState(() {
            _progress = progress / 100;
          });
        },
      ),
    );
  }
}
