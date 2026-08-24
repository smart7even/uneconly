import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RoomMapPage extends StatefulWidget {
  const RoomMapPage({
    super.key,
    required this.uri,
    required this.roomLabel,
  });

  final Uri uri;
  final String roomLabel;

  @override
  State<RoomMapPage> createState() => _RoomMapPageState();
}

class _RoomMapPageState extends State<RoomMapPage> {
  WebViewController? _controller;
  String? _error;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _controller = null;
      _error = null;
      _progress = 0;
    });

    if (!Platform.isAndroid && !Platform.isIOS) {
      setState(() {
        _error = 'Встроенная схема доступна на Android и iOS.';
      });
      return;
    }

    try {
      // The university occasionally leaves the map link in the schedule while
      // the target responds with an empty 204 page. Detect that state before
      // presenting a blank WebView.
      final response = await Dio().getUri<List<int>>(
        widget.uri,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (_) => true,
        ),
      );
      final bytes = response.data ?? Uint8List(0);
      if (response.statusCode != 200 || bytes.isEmpty) {
        throw StateError('empty room map response');
      }

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              if (mounted) setState(() => _progress = progress);
            },
            onWebResourceError: (error) {
              if ((error.isForMainFrame ?? true) && mounted) {
                setState(() {
                  _error = 'Не удалось загрузить схему университета.';
                });
              }
            },
          ),
        )
        ..loadRequest(widget.uri);

      if (mounted) {
        setState(() => _controller = controller);
      }
    } on Object {
      if (mounted) {
        setState(() {
          _error = 'Сайт университета сейчас не возвращает схему. '
              'Попробуйте позже.';
        });
      }
    }
  }

  Future<void> _openExternally() => launchUrl(
        widget.uri,
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Схема: ${widget.roomLabel}'),
        actions: [
          TextButton.icon(
            onPressed: _openExternally,
            style: TextButton.styleFrom(
              foregroundColor: context.palette.accent,
            ),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('В браузере'),
          ),
        ],
        bottom: _controller != null && _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(value: _progress / 100),
              )
            : null,
      ),
      body: switch ((_controller, _error)) {
        (_, final String error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: context.palette.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Повторить'),
                  ),
                  TextButton(
                    onPressed: _openExternally,
                    child: const Text('Открыть на сайте университета'),
                  ),
                ],
              ),
            ),
          ),
        (final WebViewController controller, _) => WebViewWidget(
            controller: controller,
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
