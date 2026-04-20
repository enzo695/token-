import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
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
  final _controller = WebviewController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _controller.initialize();
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36');
      await _controller.loadUrl(widget.initialUrl);
      
      // Inject token sniffer on every page load (URL change)
      _controller.url.listen((url) {
        _controller.executeScript('''
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
      });

      widget.onControllerCreated(_controller);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing webview_windows: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Webview(_controller)
        : const Center(child: CircularProgressIndicator());
  }
}

Future<String> executeJS(dynamic controller, String code) async {
  return await (controller as WebviewController).executeScript(code);
}
