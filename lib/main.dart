import 'package:flutter/material.dart';
import 'package:uneconly/common/app_scroll_configuration.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      scrollBehavior: AppScrollBehavior(),
      home: const SchedulePage(),
    );
  }
}
