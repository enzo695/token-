import 'package:flutter/material.dart';
import 'webview_interface.dart';

// Este arquivo decide qual versão do WebView carregar
// Para evitar erros de compilação em diferentes plataformas

import 'webview_mobile.dart' as mobile;
import 'webview_windows.dart' as windows;
import 'dart:io';

Widget getWebView(String url, Function(dynamic) onCreated) {
  if (Platform.isWindows) {
    return windows.DiscordWebViewImpl(initialUrl: url, onControllerCreated: onCreated);
  } else {
    // Para Android e iOS
    return mobile.DiscordWebViewImpl(initialUrl: url, onControllerCreated: onCreated);
  }
}

Future<String> runJS(dynamic controller, String code) {
  if (Platform.isWindows) {
    return windows.executeJS(controller, code);
  } else {
    return mobile.executeJS(controller, code);
  }
}
