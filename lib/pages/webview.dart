import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WEBVIEWSCREEN extends StatelessWidget {

  final String htmlContent = '''
    <!DOCTYPE html>
    <html>
      <head>
        <title>WebView Demo</title>
      </head>
      <body>
        <h1>Welcome to my website</h1>
        <p>This is a sample paragraph.</p>
        <p>Here's another paragraph.</p>
      </body>
    </html>
  ''';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('WebView Demo'),
        ),
        body: WebView(
          initialUrl: htmlContent,
        javascriptMode: JavascriptMode.unrestricted,
        )

      ),
    );
  }
}
