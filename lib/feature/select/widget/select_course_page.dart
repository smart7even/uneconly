import 'package:flutter/material.dart';
import 'package:uneconly/common/localization/localization.dart';

/// {@template select_course_page}
/// SelectCoursePage widget
/// {@endtemplate}
class SelectCoursePage extends StatelessWidget {
  final List<int> courses;

  /// {@macro select_course_page}
  const SelectCoursePage({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectCourse),
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];

          return ListTile(
            title: Text(
              AppLocalizations.of(context)!.nCourse(
                course,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop(course);
            },
          );
        },
      ),
    );
  }
} // SelectCoursePage
