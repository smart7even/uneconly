import 'package:flutter/material.dart';

/// {@template settings_page}
/// SettingsPage widget
/// {@endtemplate}
class SettingsPage extends StatelessWidget {
  /// {@macro settings_page}
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SettingsPage'),
      ),
      body: const Center(
        child: Text('SettingsPage'),
      ),
    );
  }
} // SettingsPage
