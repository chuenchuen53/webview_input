import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_input/core_web_view_helper.dart' as web_view_helper;

class Core {
  static bool get isWindows => Platform.isWindows;
}

class CoreWebView extends StatefulWidget {
  const CoreWebView({
    this.isAutoSize = false,
    this.initialUrl,
    this.initialHtml,
    this.initialAssetFilePath,
    this.onLoadStop,
    this.onEvent,
    this.onWebViewCreated,
    super.key,
  }) : assert(
          initialUrl != null ||
              initialHtml != null ||
              initialAssetFilePath != null,
          'initialUrl or initialHtml or initialAssetFilePath must not be null',
        );

  static const javaScriptChannelName = 'FlutterJavaScriptChannel';

  final bool isAutoSize;
  final String? initialHtml;
  final String? initialUrl;
  final String? initialAssetFilePath;
  final Function(InAppWebViewController controller)? onLoadStop;
  final Function(String event, dynamic data)? onEvent;
  final Function(InAppWebViewController controller)? onWebViewCreated;

  @override
  State<CoreWebView> createState() => _CoreWebViewState();
}

class _CoreWebViewState extends State<CoreWebView> {
  Size? _size;

  InAppWebViewController? _controller;

  @override
  void dispose() {
    final onEvent = widget.onEvent;
    if (onEvent != null) {
      web_view_helper.CoreWebViewHelper.removeJavaScriptHandler(
        controller: _controller,
        onEvent: onEvent,
      );
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CoreWebView oldWidget) {
    if (oldWidget.initialUrl != widget.initialUrl ||
        oldWidget.initialHtml != widget.initialHtml ||
        oldWidget.initialAssetFilePath != widget.initialAssetFilePath) {
      _loadRequest();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _listenEvent() {
    final onEvent = widget.onEvent;
    if (onEvent != null) {
      web_view_helper.CoreWebViewHelper.addJavaScriptHandler(
        controller: _controller,
        onEvent: onEvent,
      );
    }
  }

  Future<void> _loadRequest() async {
    final controller = _controller;

    if (controller == null) {
      return;
    }

    final initialAssetFilePath = widget.initialAssetFilePath;
    final initialHtml = widget.initialHtml;
    final initialUrl = widget.initialUrl;

    if (initialAssetFilePath != null && initialAssetFilePath.isNotEmpty) {
      await controller.loadFile(assetFilePath: initialAssetFilePath);
    } else if (initialUrl != null &&
        initialUrl.isNotEmpty &&
        initialUrl.startsWith('http')) {
      final uri = WebUri(initialUrl);
      await controller.loadUrl(urlRequest: URLRequest(url: uri));
    } else if (initialHtml != null && initialHtml.isNotEmpty) {
      await controller.loadData(data: initialHtml);
    }
  }

  Future<void> _updateSize(InAppWebViewController controller) async {
    if (Core.isWindows) {
      final width = await controller.evaluateJavascript(
          source: 'document.body.scrollWidth');
      final height = await controller.evaluateJavascript(
          source: 'document.body.scrollHeight');
      if (width != null && height != null) {
        final size = Size('$width'.asDouble(), '$height'.asDouble());
        if (mounted) {
          setState(() {
            _size = size;
          });
        }
      }
    } else {
      final width = await controller.getContentWidth();
      final height = await controller.getContentHeight();
      if (width != null && height != null) {
        final size = Size(width.toDouble(), height.toDouble());
        if (mounted) {
          setState(() {
            _size = size;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final webView = InAppWebView(
      onWebViewCreated: (controller) {
        _controller = controller;
        _listenEvent();
        _loadRequest();
        widget.onWebViewCreated?.call(controller);
      },
      onLoadStop: (controller, url) {
        if (widget.isAutoSize) {
          _updateSize(controller);
        }
        widget.onLoadStop?.call(controller);
      },
      initialSettings: InAppWebViewSettings(
        supportZoom: false,
      ),
      gestureRecognizers: {
        // This allows the underlying WebView to handle the scroll instead of the Flutter gesture system, fix iPad bug
        Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer()..onStart = (_) {}),
      },
    );

    final child = Core.isWindows
        ? Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                GestureBinding.instance.pointerSignalResolver.register(
                  event,
                  (e) {},
                );
              }
            },
            child: webView,
          )
        : webView;

    return SizedBox.fromSize(
      size: _size,
      child: child,
    );
  }
}

extension on String {
  double asDouble() {
    try {
      return double.parse(this);
    } catch (error) {
      return 0.0;
    }
  }
}
