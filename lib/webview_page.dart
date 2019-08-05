import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class LinkednPage extends StatelessWidget {
  final String url;

  LinkednPage(this.url);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Linkedn page"),
      ),
      body: WebView(
        initialUrl: this.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

