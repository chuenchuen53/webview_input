import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class CoreWebView2 extends StatefulWidget {
  const CoreWebView2({
    super.key,
    this.initialUrl,
    this.initialHtml,
  }) : assert(
          initialUrl != null || initialHtml != null,
          'initialUrl or initialHtml must not be null',
        );

  final String? initialUrl;
  final String? initialHtml;

  @override
  State<CoreWebView2> createState() => _CoreWebView2State();
}

class _CoreWebView2State extends State<CoreWebView2> {
  static bool get _isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  final WebviewController _controller = WebviewController();
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    if (_isWindows) {
      _initFuture = _init();
    }
  }

  @override
  void didUpdateWidget(covariant CoreWebView2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isWindows) return;

    final initialUrl = widget.initialUrl;
    if (initialUrl != null &&
        initialUrl != oldWidget.initialUrl &&
        _controller.value.isInitialized) {
      unawaited(_controller.loadUrl(initialUrl));
    }

    final initialHtml = widget.initialHtml;
    if (initialHtml != null &&
        initialHtml != oldWidget.initialHtml &&
        _controller.value.isInitialized) {
      unawaited(_controller.loadStringContent(initialHtml));
    }
  }

  Future<void> _init() async {
    await _controller.initialize();

    final initialUrl = widget.initialUrl;
    final initialHtml = widget.initialHtml;

    if (initialUrl != null && initialUrl.isNotEmpty) {
      await _controller.loadUrl(initialUrl);
    } else if (initialHtml != null && initialHtml.isNotEmpty) {
      await _controller.loadStringContent(initialHtml);
    }
  }

  @override
  void dispose() {
    final initFuture = _initFuture;
    if (initFuture != null) {
      unawaited(_controller.dispose().catchError((_) {}));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isWindows) {
      return const Text('Only support window');
    }

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('WebView init failed: ${snapshot.error}');
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Webview(_controller);
      },
    );
  }
}
