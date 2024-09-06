import 'package:flutter/material.dart';

class LessonProperty extends StatelessWidget {
  final IconData icon;
  final String text;

  const LessonProperty({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.secondary,
        // rounded corners
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            // color: Colors.white,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            text,
            style: const TextStyle(
                // color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
        ],
      ),
    );
  }
} // DayScheduleWidget
