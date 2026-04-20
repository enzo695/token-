import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

// Import our cross-platform factory instead of a specific implementation
import 'webview_platform.dart' as webview_platform;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Discord Token Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5865F2), // Discord Blue
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic _controller;
  bool _webViewVisible = false;
  bool _isControllerReady = false;

  final String discordUrl = 'https://discord.gg/nwPhFWmzFU';

  Future<void> _launchDiscord() async {
    if (!await launchUrl(Uri.parse(discordUrl))) {
      throw Exception('Could not launch $discordUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discord Token Helper'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_webViewVisible)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _webViewVisible = false),
            )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1214), Color(0xFF1E2124)],
          ),
        ),
        child: Stack(
          children: [
            // Home Screen UI
            if (!_webViewVisible)
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Neon Store Logo
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                image: AssetImage('assets/logo.png'),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5865F2).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.key_rounded, size: 100, color: Color(0xFF5865F2)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Discord Token Grabber',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Seguro, rápido e desenvolvido pela Neon Store.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton.icon(
                            onPressed: _openWebView,
                            icon: const Icon(Icons.flash_on),
                            label: const Text('ABRIR DISCORD E PEGAR TOKEN'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5865F2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        const Text(
                          'Aplicativo desenvolvido pela equipe Neon Store',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: _launchDiscord,
                          icon: const Icon(Icons.discord, size: 24),
                          label: const Text('ENTRAR EM CONTATO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5865F2).withOpacity(0.15),
                            foregroundColor: const Color(0xFF5865F2),
                            side: const BorderSide(color: Color(0xFF5865F2), width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            // WebView Overlay
            if (_webViewVisible)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: webview_platform.getWebView(
                    'https://discord.com/login',
                    (c) => setState(() {
                      _controller = c;
                      _isControllerReady = true;
                    }),
                  ),
                ),
              ),

            // Action Button
            if (_webViewVisible && _isControllerReady)
              Positioned(
                bottom: 30,
                right: 30,
                child: FloatingActionButton.extended(
                  onPressed: _getToken,
                  label: const Text('Extrair Token'),
                  icon: const Icon(Icons.bolt),
                  backgroundColor: const Color(0xFF5865F2),
                  elevation: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openWebView() {
    setState(() {
      _webViewVisible = true;
      _isControllerReady = false;
    });
  }

  Future<void> _getToken() async {
    try {
      const String jsCode = '''
        (function() {
          let token = window._ds_token; // Prioridade 1: Header interceptado
          
          if (!token) {
            try {
              // Prioridade 2: LocalStorage
              token = window.localStorage.getItem('token') || window.localStorage.getItem('__auth_token');
            } catch (e) {}
          }

          if (!token) {
            try {
              // Prioridade 3: Webpack Injection
              window.webpackChunkdiscord_app.push([[''], {}, e => {
                for (let c in e.c) {
                  if (e.c[c].exports?.default?.getToken) {
                    token = e.c[c].exports.default.getToken();
                  }
                  for (let t in e.c[c].exports) {
                    if (e.c[c].exports?.[t]?.getToken && e.c[c].exports[t][Symbol.toStringTag] !== "IntlMessagesProxy") {
                      token = e.c[c].exports[t].getToken();
                    }
                  }
                }
              }]);
            } catch (e) {}
          }

          return token ? token.replace(/"/g, '') : 'TOKEN_NOT_FOUND';
        })();
      ''';

      String token = await webview_platform.runJS(_controller, jsCode);

      if (token == 'TOKEN_NOT_FOUND' || token == 'null') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token não encontrado. Certifique-se de estar logado no Discord!')),
        );
        return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2C2F33),
          title: Row(
            children: [
              const Icon(Icons.verified, color: Colors.green),
              const SizedBox(width: 10),
              const Text('Token Encontrado!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NUNCA compartilhe este token. Ele dá acesso total à sua conta.',
                style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5865F2).withOpacity(0.5)),
                ),
                child: SelectableText(
                  token,
                  style: const TextStyle(fontSize: 14, color: Colors.greenAccent, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: token));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Token copiado para a área de transferência!'),
                    backgroundColor: Color(0xFF5865F2),
                  ),
                );
              },
              child: const Text('COPIAR TOKEN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('FECHAR', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }
}
