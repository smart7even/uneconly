import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/room_map_page.dart';

class LessonTile extends StatefulWidget {
  const LessonTile({
    super.key,
    required this.cluster,
    required this.currentTime,
    required this.scheduleInfo,
    required this.choiceRepository,
    required this.onChoiceChanged,
    required this.appConfig,
  });

  final LessonCluster cluster;
  final DateTime currentTime;
  final ScheduleInfo scheduleInfo;
  final LessonChoiceRepository choiceRepository;
  final VoidCallback onChoiceChanged;
  final AppConfig appConfig;

  @override
  State<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<LessonTile> {
  LessonChoiceResolution? get _resolution => widget.choiceRepository.resolve(
    info: widget.scheduleInfo,
    lesson: widget.cluster.lesson,
  );

  Lesson? get _selectedLesson {
    if (!widget.cluster.hasAlternatives) return widget.cluster.lesson;
    final resolution = _resolution;
    if (resolution == null) return null;
    for (final lesson in widget.cluster.alternatives) {
      if (lessonAlternativeId(lesson) == resolution.alternativeId) {
        return lesson;
      }
    }
    return null;
  }

  Future<void> _showChoiceSheet({bool replacement = false}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LessonChoiceSheet(
        alternatives: widget.cluster.alternatives,
        scheduleInfo: widget.scheduleInfo,
        repository: widget.choiceRepository,
        resolution: _resolution,
        initialScope: replacement
            ? LessonChoiceScope.date
            : LessonChoiceScope.subject,
        isReplacement: replacement,
      ),
    );
    if (changed == true && mounted) {
      setState(() {});
      widget.onChoiceChanged();
    }
  }

  void _openProfessor(Lesson lesson) {
    final professor = lesson.professor;
    final professorId = lesson.professorId;
    if (professor == null || professorId == null) return;
    Octopus.of(context).push(
      Routes.schedule,
      arguments: {
        'professorId': professorId.toString(),
        'professorName': professor,
        'isViewMode': 'true',
      },
    );
  }

  void _openRoomMap(Lesson lesson) {
    final uri = Uri.tryParse(lesson.roomUrl ?? '');
    if (uri == null || uri.scheme != 'https' || uri.host != 'staff.unecon.ru') {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RoomMapPage(
          uri: uri,
          roomLabel: _roomLabel(cleanLessonLocation(lesson.location)),
        ),
      ),
    );
  }

  Future<void> _showLessonDetails(Lesson lesson) async {
    final isGroupSchedule = widget.scheduleInfo.map(
      group: (_) => true,
      professor: (_) => false,
    );
    final canOpenProfessor =
        isGroupSchedule &&
        lesson.professor != null &&
        lesson.professorId != null;
    final canOpenMap =
        widget.appConfig.roomMapButtonEnabled && lesson.roomUrl != null;
    final canChange = widget.cluster.hasAlternatives;
    final location = cleanLessonLocation(
      lesson.location,
      removeMapCaption: !widget.appConfig.roomMapCaptionEnabled,
    );

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              lessonDisplayName(lesson),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: context.palette.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${DateFormat('HH:mm').format(lesson.start)}–'
              '${DateFormat('HH:mm').format(lesson.end)}'
              '${_lessonTypeSuffix(lesson.lessonType)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.palette.muted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (lesson.professor case final professor?) ...[
              const SizedBox(height: 14),
              Text(professor, style: Theme.of(context).textTheme.bodyLarge),
            ],
            if (location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                location,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.palette.muted),
              ),
            ],
            if (canOpenProfessor || canOpenMap || canChange) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
            ],
            if (canOpenProfessor)
              _DetailAction(
                icon: Icons.person_outline,
                label: context.string.professorSchedule,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openProfessor(lesson);
                },
              ),
            if (canOpenMap)
              _DetailAction(
                icon: Icons.map_outlined,
                label: context.string.roomMap,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openRoomMap(lesson);
                },
              ),
            if (canChange)
              _DetailAction(
                icon: Icons.swap_horiz,
                label: context.string.changeProfessor,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showChoiceSheet(replacement: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final selected = _selectedLesson;
    final lesson = selected ?? widget.cluster.lesson;
    final location = compactLessonLocation(
      lesson.location,
      removeMapCaption: !widget.appConfig.roomMapCaptionEnabled,
    );
    final resolution = _resolution;
    final savedChoiceMissing =
        widget.cluster.hasAlternatives &&
        resolution != null &&
        selected == null;
    final isGroupSchedule = widget.scheduleInfo.map(
      group: (_) => true,
      professor: (_) => false,
    );
    final sameDay = DateUtils.isSameDay(widget.currentTime, lesson.day);
    final isCurrent =
        sameDay &&
        widget.currentTime.isAfter(lesson.start) &&
        widget.currentTime.isBefore(lesson.end);
    final isPast = sameDay && widget.currentTime.isAfter(lesson.end);
    final canOpenDetails =
        selected != null &&
        ((isGroupSchedule && lesson.professorId != null) ||
            (widget.appConfig.roomMapButtonEnabled && lesson.roomUrl != null) ||
            widget.cluster.hasAlternatives);
    final VoidCallback? onTap =
        widget.cluster.hasAlternatives && selected == null
        ? () => _showChoiceSheet(replacement: savedChoiceMissing)
        : canOpenDetails
        ? () => _showLessonDetails(lesson)
        : null;
    final professor = lesson.professor;
    final group = lesson.group;
    final metadata = [
      if (isGroupSchedule && professor != null) compactPersonName(professor),
      if (location.isNotEmpty) location,
      if (!isGroupSchedule && group != null && group.isNotEmpty) group,
    ].join(' · ');
    final semanticLabel = [
      '${DateFormat('HH:mm').format(lesson.start)}–${DateFormat('HH:mm').format(lesson.end)}',
      lessonDisplayName(lesson),
      if (widget.cluster.hasAlternatives && selected == null)
        '${widget.cluster.alternatives.length} подгрупп, подгруппа не выбрана, выбрать'
      else ...[
        ?professor,
        if (location.isNotEmpty) location,
        if (selected != null && widget.cluster.hasAlternatives)
          context.string.yourSubgroup,
      ],
    ].join(', ');

    return Semantics(
      key: ValueKey('lesson-${lesson.start.toIso8601String()}-${lesson.name}'),
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 180),
          child: Material(
            color: isCurrent ? palette.currentSurface : Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 54,
                      child: Text(
                        '${DateFormat('HH:mm').format(lesson.start)}\n'
                        '${DateFormat('HH:mm').format(lesson.end)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.45,
                          color: isPast
                              ? palette.muted.withValues(alpha: 0.65)
                              : palette.muted,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  lessonDisplayName(lesson),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    height: 1.2,
                                    color: palette.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (_isImportantType(lesson.lessonType)) ...[
                                const SizedBox(width: 7),
                                _ImportantTypeLabel(
                                  label: lesson.lessonType!.toUpperCase(),
                                ),
                              ] else if (isCurrent) ...[
                                const SizedBox(width: 7),
                                Text(
                                  context.string.currentLesson.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: palette.accent,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (widget.cluster.hasAlternatives &&
                              selected == null &&
                              !savedChoiceMissing)
                            _InlinePrompt(
                              text: context.string.subgroupPrompt(
                                widget.cluster.alternatives.length,
                              ),
                            )
                          else if (savedChoiceMissing)
                            _InlinePrompt(
                              text: context.string.professorMissingToday,
                              warning: true,
                            )
                          else if (metadata.isNotEmpty)
                            Text(
                              metadata,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.35,
                                color: palette.muted,
                              ),
                            ),
                          if (selected != null &&
                              widget.cluster.hasAlternatives) ...[
                            const SizedBox(height: 4),
                            Text(
                              '● ${context.string.yourSubgroup}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: palette.muted,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: palette.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlinePrompt extends StatelessWidget {
  const _InlinePrompt({required this.text, this.warning = false});

  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: warning ? context.palette.accent : context.palette.ink,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ImportantTypeLabel extends StatelessWidget {
  const _ImportantTypeLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: context.palette.danger,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: context.palette.muted),
      title: Text(label),
      trailing: Icon(Icons.chevron_right, color: context.palette.muted),
      onTap: onTap,
    );
  }
}

class _LessonChoiceSheet extends StatefulWidget {
  const _LessonChoiceSheet({
    required this.alternatives,
    required this.scheduleInfo,
    required this.repository,
    required this.resolution,
    required this.initialScope,
    required this.isReplacement,
  });

  final List<Lesson> alternatives;
  final ScheduleInfo scheduleInfo;
  final LessonChoiceRepository repository;
  final LessonChoiceResolution? resolution;
  final LessonChoiceScope initialScope;
  final bool isReplacement;

  @override
  State<_LessonChoiceSheet> createState() => _LessonChoiceSheetState();
}

class _LessonChoiceSheetState extends State<_LessonChoiceSheet> {
  String? _selectedId;
  late LessonChoiceScope _scope;
  late bool _showRules;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.resolution?.alternativeId;
    _scope = widget.isReplacement
        ? widget.initialScope
        : widget.resolution?.scope ?? widget.initialScope;
    _showRules = widget.isReplacement;
  }

  Future<void> _save() async {
    final selectedId = _selectedId;
    if (selectedId == null || _saving) return;
    setState(() => _saving = true);
    final selected = widget.alternatives.firstWhere(
      (lesson) => lessonAlternativeId(lesson) == selectedId,
    );
    await widget.repository.save(
      info: widget.scheduleInfo,
      lesson: selected,
      alternativeId: selectedId,
      scope: _scope,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.alternatives.first;
    final weekday = _weekdayRuleLabel(lesson.day.weekday);
    final date = DateFormat('d MMMM', 'ru').format(lesson.day);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.58,
      maxChildSize: 0.96,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.string.whoTeachesSubject(
                    lessonDisplayName(lesson).toLowerCase(),
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: context.palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.string.parallelSubgroupsDescription(
                    widget.alternatives.length,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.muted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RadioGroup<String>(
              groupValue: _selectedId,
              onChanged: (value) => setState(() => _selectedId = value),
              child: ListView.separated(
                controller: scrollController,
                itemCount: widget.alternatives.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 56),
                itemBuilder: (context, index) {
                  final alternative = widget.alternatives[index];
                  final id = lessonAlternativeId(alternative);
                  return RadioListTile<String>(
                    value: id,
                    activeColor: context.palette.ink,
                    selected: _selectedId == id,
                    selectedTileColor: context.palette.currentSurface,
                    title: Text(
                      alternative.professor ?? context.string.professorUnknown,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      compactLessonLocation(alternative.location),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: context.palette.ink,
                  ),
                  onPressed: () => setState(() => _showRules = !_showRules),
                  child: Text(
                    _showRules
                        ? context.string.hideChoiceRules
                        : context.string.choiceRules,
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: _showRules
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DropdownButtonFormField<LessonChoiceScope>(
                      initialValue: _scope,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: LessonChoiceScope.subject,
                          child: Text(context.string.rememberForSubject),
                        ),
                        DropdownMenuItem(
                          value: LessonChoiceScope.date,
                          child: Text(context.string.onlyOnDate(date)),
                        ),
                        DropdownMenuItem(
                          value: LessonChoiceScope.weekday,
                          child: Text(context.string.onWeekdays(weekday)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _scope = value);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.palette.ink,
                      foregroundColor: context.palette.surface,
                      disabledBackgroundColor: context.palette.hairline,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _selectedId == null || _saving ? null : _save,
                    child: Text(
                      _saving
                          ? context.string.saving
                          : context.string.saveSubgroup,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool _isImportantType(String? type) {
  final normalized = type?.toLowerCase() ?? '';
  return normalized.contains('экзамен') ||
      normalized.contains('зачет') ||
      normalized.contains('зачёт');
}

String _lessonTypeSuffix(String? type) {
  if (type == null || type.isEmpty) return '';
  return ' · $type';
}

String _roomLabel(String location) {
  final match = RegExp(
    r'^(.+?\s+ауд\.)',
    caseSensitive: false,
  ).firstMatch(location.trim());
  return match?.group(1) ?? location.trim();
}

String _weekdayRuleLabel(int weekday) => switch (weekday) {
  DateTime.monday => 'понедельникам',
  DateTime.tuesday => 'вторникам',
  DateTime.wednesday => 'средам',
  DateTime.thursday => 'четвергам',
  DateTime.friday => 'пятницам',
  DateTime.saturday => 'субботам',
  DateTime.sunday => 'воскресеньям',
  _ => 'этому дню недели',
};
