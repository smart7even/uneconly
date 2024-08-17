import 'package:flutter/material.dart';

enum ScheduleAction {
  share,
  favorite;
}

class ScheduleActionConfig {
  final ScheduleAction action;
  final VoidCallback onPressed;
  final Widget child;

  ScheduleActionConfig(
    this.child, {
    required this.action,
    required this.onPressed,
  });
}

class ScheduleActionsPopup extends StatelessWidget {
  final List<ScheduleActionConfig> actions;

  const ScheduleActionsPopup({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 300),
      ),
      offset: const Offset(0, 40),
      onSelected: (value) {
        for (final action in actions) {
          if (action.action == value) {
            action.onPressed();

            return;
          }
        }
      },
      itemBuilder: (context) {
        return actions
            .map(
              (e) => PopupMenuItem(
                value: e.action,
                child: e.child,
              ),
            )
            .toList();
      },
    );
  }
} // _SchedulePageState
