import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/routing/app_route_path.dart';
import 'package:uneconly/common/routing/app_router.dart';
import 'package:uneconly/constants.dart';
import 'package:uneconly/feature/select/bloc/group_bloc.dart';
import 'package:uneconly/feature/select/data/group_network_data_provider.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';
import 'package:uneconly/feature/select/model/faculty.dart';
import 'package:uneconly/feature/select/widget/select_course_page.dart';
import 'package:uneconly/feature/select/widget/select_faculty_page.dart';

/// {@template select_page}
/// SelectPage widget
/// {@endtemplate}
class SelectPage extends StatefulWidget {
  /// {@macro select_page}
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
} // SelectPage

/// State for widget SelectPage
class _SelectPageState extends State<SelectPage> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void didUpdateWidget(SelectPage oldWidget) {
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

  void onPressed(int groupId, String groupName) {
    AppRouter.navigate(
      context,
      (configuration) => AppRoutePath.schedule(
        groupId: groupId,
        groupName: groupName,
      ),
    );
  }

  Future<void> onFacultySelectPressed(
    BuildContext context,
    GroupState state,
  ) async {
    final bloc = context.read<GroupBloc>();

    final result = await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return SelectFacultyPage(
          faculties: state.faculties,
        );
      },
    );

    if (result is Faculty) {
      bloc.add(
        GroupEvent.facultySelected(
          faculty: result,
        ),
      );
    }
  }

  Future<void> onCourseSelectPressed(
    BuildContext context,
    GroupState state,
  ) async {
    final bloc = context.read<GroupBloc>();

    final result = await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return const SelectCoursePage(
          courses: [1, 2, 3, 4],
        );
      },
    );

    if (result is int) {
      bloc.add(
        GroupEvent.courseSelected(
          course: result,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = GroupBloc(
          groupRepository: GroupRepository(
            networkDataProvider: GroupNetworkDataProvider(
              dio: Dio(
                BaseOptions(
                  baseUrl: serverAddress,
                ),
              ),
            ),
          ),
        );
        bloc.add(
          const GroupEvent.intiial(),
        );

        return bloc;
      },
      child: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          Faculty? selectedFaculty = state.selectedFacultyId == null
              ? null
              : state.faculties.firstWhereOrNull(
                  (faculty) => faculty.id == state.selectedFacultyId,
                );

          int? selectedCourse = state.selectedCourse;

          var selectedGroups = state.groups;

          if (selectedFaculty != null) {
            selectedGroups = selectedGroups
                .where(
                  (group) => group.facultyId == selectedFaculty.id,
                )
                .toList();
          }

          if (selectedCourse != null) {
            selectedGroups = selectedGroups
                .where(
                  (group) => group.course == selectedCourse,
                )
                .toList();
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.selectGroup,
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            await onFacultySelectPressed(context, state);
                          },
                          child: Text(
                            selectedFaculty != null
                                ? selectedFaculty.name
                                : AppLocalizations.of(context)!.faculty,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            await onCourseSelectPressed(context, state);
                          },
                          child: Text(
                            selectedCourse != null
                                ? AppLocalizations.of(context)!
                                    .nCourse(selectedCourse)
                                : AppLocalizations.of(context)!.course,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedGroups.length,
                    itemBuilder: (context, index) {
                      final group = selectedGroups[index];

                      return ListTile(
                        title: Text(group.name),
                        onTap: () => onPressed(
                          group.id,
                          group.name,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} // _SelectPageState
