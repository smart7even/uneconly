import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/feature/schedule/bloc/schedule_bloc.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule_rule.dart';

/// {@template schedule_edit_widget}
/// ScheduleEditWidget widget
/// {@endtemplate}
class ScheduleEditWidget extends StatefulWidget {
  final VoidCallback onClose;
  final Lesson? Function() getSelectedLesson;

  /// {@macro schedule_edit_widget}
  const ScheduleEditWidget({
    super.key,
    required this.onClose,
    required this.getSelectedLesson,
  });

  @override
  State<ScheduleEditWidget> createState() => _ScheduleEditWidgetState();
} // ScheduleEditWidget

/// State for widget ScheduleEditWidget
class _ScheduleEditWidgetState extends State<ScheduleEditWidget> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void didUpdateWidget(ScheduleEditWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget configuration changed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      // rounded top corners
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        // 1 px black border
        border: Border(
          top: BorderSide(
            // primary color of the app
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          right: BorderSide(
            // primary color of the app
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          left: BorderSide(
            // primary color of the app
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onClose();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              final selectedLesson = widget.getSelectedLesson();

              if (selectedLesson == null) {
                return;
              }

              final bloc = BlocProvider.of<ScheduleBLoC>(context);

              final groupId = bloc.state.shortGroupInfo?.groupId;

              if (groupId == null) {
                return;
              }

              final professor = selectedLesson.professor;

              if (professor == null) {
                return;
              }

              final scheduleRule = ScheduleRule(
                id: 1,
                groupId: groupId,
                lesson: selectedLesson.name,
                lessonType: selectedLesson.lessonType,
                professor: professor,
              );

              bloc.add(
                ScheduleEvent.updateRules(
                  rules: [
                    scheduleRule,
                  ],
                ),
              );

              Navigator.of(context).pop();

              widget.onClose();
            },
            child: Text(
              AppLocalizations.of(context)!.hide_all_other_lessons_at_this_time,
            ),
          ),
        ],
      ),
    );
  }
} // _ScheduleEditWidgetState
