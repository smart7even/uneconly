import 'package:flutter/material.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/feature/select/model/faculty.dart';

/// {@template select_faculty_page}
/// SelectFacultyPage widget
/// {@endtemplate}
class SelectFacultyPage extends StatelessWidget {
  final List<Faculty> faculties;

  /// {@macro select_faculty_page}
  const SelectFacultyPage({
    super.key,
    required this.faculties,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectFaculty),
      ),
      body: ListView.builder(
        itemCount: faculties.length,
        itemBuilder: (context, index) {
          final faculty = faculties[index];

          return ListTile(
            title: Text(faculty.name),
            onTap: () {
              Navigator.of(context).pop(faculty);
            },
          );
        },
      ),
    );
  }
} // SelectFacultyPage
