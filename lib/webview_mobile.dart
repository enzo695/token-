import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_interface.dart';

class DiscordWebViewImpl extends DiscordWebView {
  const DiscordWebViewImpl({
    super.key,
    required super.initialUrl,
    required super.onControllerCreated,
  });

  @override
  State<DiscordWebViewImpl> createState() => _DiscordWebViewImplState();
}

class _DiscordWebViewImplState extends State<DiscordWebViewImpl> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _controller.runJavaScript('''
              (function() {
                if (window._ds_sniffer) return;
                window._ds_sniffer = true;
                window._ds_token = null;

                const originalSetRequestHeader = XMLHttpRequest.prototype.setRequestHeader;
                XMLHttpRequest.prototype.setRequestHeader = function(h, v) {
                  if (h.toLowerCase() === 'authorization' && v && v.includes('.') && !v.includes('Basic')) {
                    window._ds_token = v;
                  }
                  return originalSetRequestHeader.apply(this, arguments);
                };
              })();
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
    
    widget.onControllerCreated(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

Future<String> executeJS(dynamic controller, String code) async {
  final result = await (controller as WebViewController).runJavaScriptReturningResult(code);
  return result.toString();
}
