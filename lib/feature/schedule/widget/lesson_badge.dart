import 'package:flutter/material.dart';

/// {@template lesson_badge}
/// LessonBadge widget
/// {@endtemplate}
class LessonBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// {@macro lesson_badge}
  LessonBadge.text({
    super.key,
    required String text,
    this.onTap,
  }) : child = Text(
          text,
          style: const TextStyle(
            color: Colors.white,
          ),
        );

  LessonBadge.icon({
    super.key,
    required IconData icon,
    this.onTap,
  }) : child = Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        );

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 0),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          disabledBackgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        child: child,
      );
} // LessonBadge
