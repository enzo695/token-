import 'package:flutter/material.dart';

abstract class DiscordWebView extends StatefulWidget {
  final String initialUrl;
  final Function(dynamic controller) onControllerCreated;

  const DiscordWebView({
    super.key,
    required this.initialUrl,
    required this.onControllerCreated,
  });
}
