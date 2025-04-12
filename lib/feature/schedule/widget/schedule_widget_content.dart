import 'package:flutter/material.dart';

/// {@template schedule_widget_content}
/// ScheduleWidgetContent widget
/// {@endtemplate}
class ScheduleWidgetContent extends StatelessWidget {
  final Widget child;

  /// {@macro schedule_widget_content}
  const ScheduleWidgetContent({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // left - 16, right - 16, bottom - 16
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: child,
    );
  }
} // ScheduleWidgetContent
