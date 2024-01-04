import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/dependencies/dependencies_scope.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/select/bloc/group_bloc.dart';
import 'package:uneconly/feature/select/data/group_network_data_provider.dart';
import 'package:uneconly/feature/select/data/group_repository.dart';
import 'package:uneconly/feature/select/model/faculty.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/select/widget/select_course_page.dart';
import 'package:uneconly/feature/select/widget/select_faculty_page.dart';

enum SelectPageMode {
  view,
  select,
  favorite;

  factory SelectPageMode.fromName(String name) {
    return SelectPageMode.values.where((element) => element.name == name).first;
  }
}

/// {@template select_page}
/// SelectPage widget
/// {@endtemplate}
class SelectPage extends StatefulWidget {
  final SelectPageMode mode;

  /// {@macro select_page}
  const SelectPage({
    super.key,
    required this.mode,
  });

  @override
  State<SelectPage> createState() => _SelectPageState();
} // SelectPage

/// State for widget SelectPage
class _SelectPageState extends State<SelectPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  bool _isSearch = false;
  final _favoriteGroups = <Group>[];

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
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
    context
        .read<DependenciesScope>()
        .settingsRepository
        .getFavoriteGroups()
        .then(
      (value) {
        setState(
          () {
            _favoriteGroups.clear();
            _favoriteGroups.addAll(value);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  Future<void> onPressed(BuildContext context, Group group) async {
    if (widget.mode == SelectPageMode.view) {
      Octopus.of(context).setState(
        (state) {
          return state
            ..removeByName(Routes.select.name)
            ..add(
              Routes.schedule.node(
                arguments: {
                  'groupId': group.id.toString(),
                  'groupName': group.name,
                  'isViewMode': true.toString(),
                },
              ),
            );
        },
      );

      return;
    } else if (widget.mode == SelectPageMode.favorite) {
      await onAddToFavoritesPressed(context, group);

      return;
    }

    final settingsRepository =
        context.read<DependenciesScope>().settingsRepository;

    Octopus.of(context).setState(
      (state) {
        return state
          ..removeWhere((node) => true)
          ..add(
            Routes.schedule.node(
              arguments: {
                'groupId': group.id.toString(),
                'groupName': group.name,
              },
            ),
          );
      },
    );

    await settingsRepository.saveGroup(group);
  }

  Future<void> onAddToFavoritesPressed(
    BuildContext context,
    Group group,
  ) async {
    final settingsRepository =
        context.read<DependenciesScope>().settingsRepository;
    final isFavorite = _favoriteGroups.any(
      (favoriteGroup) => favoriteGroup.id == group.id,
    );

    if (isFavorite) {
      await settingsRepository.removeGroupFromFavorites(group);

      setState(() {
        _favoriteGroups.removeWhere(
          (favoriteGroup) => favoriteGroup.id == group.id,
        );
      });

      return;
    }

    await settingsRepository.addGroupToFavorites(group);

    setState(() {
      _favoriteGroups.add(group);
    });
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
        final dependenciesScope = context.read<DependenciesScope>();

        final bloc = GroupBloc(
          groupRepository: GroupRepository(
            networkDataProvider: GroupNetworkDataProvider(
              dio: dependenciesScope.dio,
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

          String? searchText = state.searchText;

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

          if (_isSearch && searchText != null) {
            final searchQuery = searchText.toLowerCase();

            selectedGroups = selectedGroups
                .where(
                  (group) =>
                      group.name.toLowerCase().contains(searchQuery) ||
                      group.name
                          .replaceAll('-', '')
                          .toLowerCase()
                          .contains(searchQuery),
                )
                .toList();
          }

          return Scaffold(
            appBar: AppBar(
              title: _isSearch
                  ? TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchThreeDots,
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        context.read<GroupBloc>().add(
                              GroupEvent.searchTextChanged(
                                newText: value,
                              ),
                            );
                      },
                    )
                  : Text(
                      AppLocalizations.of(context)!.selectGroup,
                    ),
              actions: [
                // search
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearch = !_isSearch;
                      if (_isSearch) {
                        _searchFocusNode.requestFocus();
                      } else {
                        _searchFocusNode.unfocus();
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (!(Platform.isAndroid || Platform.isIOS))
                          const SizedBox(
                            height: 8,
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
                state.maybeMap(
                  processing: (_) => const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  orElse: () {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: selectedGroups.length,
                        itemBuilder: (context, index) {
                          final group = selectedGroups[index];
                          final isFavorite = _favoriteGroups.any(
                            (favoriteGroup) => favoriteGroup.id == group.id,
                          );

                          return ListTile(
                            title: Text(
                              group.name,
                              semanticsLabel:
                                  '${AppLocalizations.of(context)!.group} ${group.name}',
                            ),
                            trailing: widget.mode == SelectPageMode.view ||
                                    widget.mode == SelectPageMode.favorite
                                ? IconButton(
                                    onPressed: () async {
                                      await onAddToFavoritesPressed(
                                        context,
                                        group,
                                      );
                                    },
                                    tooltip: isFavorite
                                        ? AppLocalizations.of(context)!
                                            .removeFromFavorites
                                        : AppLocalizations.of(context)!
                                            .addToFavorites,
                                    icon: isFavorite
                                        ? const Icon(Icons.star)
                                        : const Icon(
                                            Icons.star_outline,
                                          ),
                                  )
                                : null,
                            onTap: () => onPressed(
                              context,
                              group,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} // _SelectPageState
