import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  late final WebViewController _controller;

  // CORRECCIÓN: Apunta a la URL real de tu página de nutrición.
  final String webUrl = 'https://traincoach-2ef9d.web.app/nutrition';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // Fondo transparente
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Puedes usar esto para mostrar una barra de progreso si quieres.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            // Maneja los errores si la página no se puede cargar.
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
      // CORRECCIÓN: Se reemplaza loadHtmlString por loadRequest para cargar la URL en vivo.
      ..loadRequest(Uri.parse(webUrl));
  }

  @override
  Widget build(BuildContext context) {
    // El Scaffold ahora contiene el WebView que muestra tu página web.
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}