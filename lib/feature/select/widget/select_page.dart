import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/theme/app_theme.dart';
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
    Dependencies.of(context).settingsRepository.getFavoriteGroups().then(
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
    _searchController.dispose();
    _searchFocusNode.dispose();
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

    final settingsRepository = Dependencies.of(context).settingsRepository;

    await settingsRepository.saveGroup(group);

    if (context.mounted) {
      Octopus.of(context).setState(
        (state) {
          return state
            ..removeWhere((node) => true)
            ..add(
              Routes.loading.node(),
            );
        },
      );
    }
  }

  Future<void> onAddToFavoritesPressed(
    BuildContext context,
    Group group,
  ) async {
    final settingsRepository = Dependencies.of(context).settingsRepository;
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
    } else {
      await settingsRepository.addGroupToFavorites(group);
      setState(() => _favoriteGroups.add(group));
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Удалено из избранного' : 'Добавлено в избранное',
        ),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () => onAddToFavoritesPressed(context, group),
        ),
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
          courses: [1, 2, 3, 4, 5],
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
        final dependenciesScope = Dependencies.of(context);

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

          if (searchText != null && searchText.trim().isNotEmpty) {
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
              title: Text(context.string.selectGroup),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Номер группы',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<GroupBloc>().add(
                                          const GroupEvent.searchTextChanged(
                                            newText: '',
                                          ),
                                        );
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          context.read<GroupBloc>().add(
                                GroupEvent.searchTextChanged(newText: value),
                              );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  onFacultySelectPressed(context, state),
                              icon: const Icon(Icons.school_outlined, size: 18),
                              label: Text(
                                selectedFaculty?.name ?? context.string.faculty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  onCourseSelectPressed(context, state),
                              icon: const Icon(Icons.filter_list, size: 18),
                              label: Text(
                                selectedCourse != null
                                    ? context.string.nCourse(selectedCourse)
                                    : context.string.course,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                state.maybeMap(
                  processing: (_) => Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 7,
                      itemBuilder: (_, __) => Container(
                        height: 58,
                        margin: const EdgeInsets.only(bottom: 1),
                        color: context.palette.nestedSurface,
                      ),
                    ),
                  ),
                  orElse: () {
                    return Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: selectedGroups.length,
                        separatorBuilder: (_, __) => Divider(
                          indent: 20,
                          color: context.palette.hairline,
                        ),
                        itemBuilder: (context, index) {
                          final group = selectedGroups[index];
                          final isFavorite = _favoriteGroups.any(
                            (favoriteGroup) => favoriteGroup.id == group.id,
                          );

                          return ListTile(
                            title: Text(
                              group.name,
                              semanticsLabel:
                                  '${context.string.group} ${group.name}',
                            ),
                            subtitle: Text(
                              _groupSubtitle(group, state.faculties),
                              style: TextStyle(color: context.palette.muted),
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
                                        ? context.string.removeFromFavorites
                                        : context.string.addToFavorites,
                                    icon: isFavorite
                                        ? Icon(Icons.star,
                                            color: context.palette.accent)
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

  String _groupSubtitle(Group group, List<Faculty> faculties) {
    final faculty = faculties.firstWhereOrNull(
      (item) => item.id == group.facultyId,
    );
    final parts = <String>[
      if (faculty != null) faculty.name,
      if (group.course > 0) '${group.course} курс',
    ];
    return parts.join(' · ');
  }
} // _SelectPageState
