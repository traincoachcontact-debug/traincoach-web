import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProgressAssistantScreen extends StatefulWidget {
  const ProgressAssistantScreen({super.key});

  @override
  State<ProgressAssistantScreen> createState() => _ProgressAssistantScreenState();
}

class _ProgressAssistantScreenState extends State<ProgressAssistantScreen> {
  late final WebViewController _controller;

  // CORRECCIÓN: Apunta a la URL real de tu página de progreso.
  final String webUrl = 'https://traincoach-2ef9d.web.app/progress';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(webUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}