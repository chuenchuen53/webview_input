import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CoreWebViewHelper {
  static void addJavaScriptHandler({
    required Function(String event, dynamic data) onEvent,
    required InAppWebViewController? controller,
  }) {
    controller?.addJavaScriptHandler(
      handlerName: 'FlutterJavaScriptChannel',
      callback: (args) {
        if (args is List) {
          final message = args.firstOrNull;
          final messageData = jsonDecode(message) as Map<String, dynamic>?;
          final event = messageData?['event'] as String;
          final eventData = messageData?['data'];
          onEvent(event, eventData);
        }
      },
    );
  }

  static void removeJavaScriptHandler({
    required InAppWebViewController? controller,
    required Function(String event, dynamic data) onEvent,
  }) {
    controller?.removeJavaScriptHandler(
        handlerName: 'FlutterJavaScriptChannel');
  }
}
