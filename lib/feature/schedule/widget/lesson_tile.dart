import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';

class LessonTile extends StatefulWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.isEditMode,
    required this.isSelected,
    this.onSelected,
  });

  final Lesson lesson;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback? onSelected;

  @override
  State<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<LessonTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String subtitle = '';

    String? professor = widget.lesson.professor;

    if (professor != null) {
      subtitle = professor;
    }

    String location = widget.lesson.location.replaceAll('\n', ' ').trim();

    subtitle = '$subtitle $location';

    return ListTile(
      title: Text(
        widget.lesson.name,
        maxLines: _isExpanded ? 5 : 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: widget.isEditMode
          ? IconButton(
              icon: Icon(
                widget.isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: widget.isSelected ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                widget.onSelected?.call();
              },
            )
          : null,
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
          ),
          // show rounded and filled select button only in edit mode
          // if (widget.isEditMode)
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       ElevatedButton(
          //         onPressed: () {},
          //         // Rounded and filled button
          //         style: ElevatedButton.styleFrom(
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(30.0),
          //           ),
          //           elevation: 1,
          //         ),
          //         child: Text(
          //           AppLocalizations.of(context)!
          //               .hide_all_other_lessons_at_this_time,
          //         ),
          //       ),
          //     ],
          //   ),
        ],
      ),
      trailing: Text(
        '${DateFormat('HH:mm').format(
          widget.lesson.start,
        )} - ${DateFormat('HH:mm').format(
          widget.lesson.end,
        )}',
      ),
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
    );
  }
} // LessonTile