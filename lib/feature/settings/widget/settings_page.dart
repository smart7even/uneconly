import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l/l.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/common/utils/pubspec.yaml.g.dart';
import 'package:uneconly/feature/calendar/calendar_permission_modal.dart';
import 'package:uneconly/feature/calendar/calendar_permissions.dart';
import 'package:uneconly/feature/settings/bloc/settings_bloc.dart';
import 'package:uneconly/feature/settings/model/settings_entity.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingsBLoC(repository: Dependencies.of(context).settingsRepository)
            ..add(const SettingsEvent.read()),
      child: Scaffold(
        appBar: AppBar(title: Text(context.string.settings)),
        body: BlocBuilder<SettingsBLoC, SettingsState>(
          builder: (context, state) {
            final data = state.data;
            if (data == null) return const _SettingsSkeleton();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                const _SectionTitle('Оформление'),
                _SettingsSurface(
                  children: [
                    _SettingsRow(
                      icon: Icons.brightness_6_outlined,
                      title: 'Тема',
                      subtitle: _themeLabel(data.themeColor),
                      onTap: () => _selectTheme(context, data),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const _SectionTitle('Расписание'),
                _SettingsSurface(
                  children: [
                    _SettingsRow(
                      icon: Icons.calendar_today_outlined,
                      title: context.string.syncWithCalendar,
                      subtitle:
                          'Пары появятся в календаре телефона вместе с напоминаниями',
                      trailing: Switch.adaptive(
                        value: data.calendarSettings.isCalendarSyncingEnabled,
                        onChanged: (value) =>
                            _toggleCalendar(context, data, value),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.delete_outline,
                      title: context.string.cache,
                      subtitle: 'Сохранённые расписания для офлайн-доступа',
                      onTap: () => _clearCache(context),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const _SectionTitle('О приложении'),
                _SettingsSurface(
                  children: [
                    _SettingsRow(
                      icon: Icons.info_outline,
                      title: context.string.appVersion,
                      trailing: Text(
                        Pubspec.version.representation,
                        style: TextStyle(color: context.palette.muted),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.description_outlined,
                      title: context.string.licenses,
                      subtitle: context.string.showLicenses,
                      onTap: () => showLicensePage(context: context),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectTheme(BuildContext context, SettingsEntity data) async {
    var draft = AppThemePreference.parse(data.themeColor);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Тема', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                const _SectionTitle('Оформление'),
                RadioGroup<ThemeMode>(
                  groupValue: draft.mode,
                  onChanged: (value) {
                    if (value == null) return;
                    setSheetState(() => draft = draft.copyWith(mode: value));
                  },
                  child: Column(
                    children: [
                      for (final option in const [
                        (
                          ThemeMode.system,
                          'Как в системе',
                          Icons.brightness_auto_outlined,
                        ),
                        (ThemeMode.light, 'Светлая', Icons.light_mode_outlined),
                        (ThemeMode.dark, 'Тёмная', Icons.dark_mode_outlined),
                      ])
                        RadioListTile<ThemeMode>(
                          contentPadding: EdgeInsets.zero,
                          value: option.$1,
                          title: Text(option.$2),
                          secondary: Icon(option.$3),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Акцент'),
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    for (final accent in AppAccent.values)
                      _AccentOption(
                        accent: accent,
                        selected: draft.accent == accent,
                        onTap: () => setSheetState(
                          () => draft = draft.copyWith(accent: accent),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                const _SectionTitle('Предпросмотр'),
                _ThemePreview(preference: draft),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(sheetContext, draft.storageValue),
                    child: const Text('Готово'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    context.read<SettingsBLoC>().add(
      SettingsEvent.update(entity: data.copyWith(themeColor: selected)),
    );
  }

  Future<void> _toggleCalendar(
    BuildContext context,
    SettingsEntity data,
    bool enabled,
  ) async {
    if (enabled && !await requestCalendarPermission()) {
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        builder: (_) => const CalendarPermissionModal(),
      );
      return;
    }
    if (!context.mounted) return;
    context.read<SettingsBLoC>().add(
      SettingsEvent.update(
        entity: data.copyWith.calendarSettings(
          isCalendarSyncingEnabled: enabled,
        ),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    final repository = Dependencies.of(context).settingsRepository;
    try {
      final empty = await repository.isAppCacheEmpty();
      if (!empty) await repository.clearAppCache();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(empty ? 'Кэш уже пуст' : 'Кэш очищен')),
      );
    } on Exception catch (error) {
      l.e(error);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.string.errorWhileCleaningCache)),
      );
    }
  }
}

String _themeLabel(String value) {
  final preference = AppThemePreference.parse(value);
  final mode = switch (preference.mode) {
    ThemeMode.light => 'Светлая',
    ThemeMode.dark => 'Тёмная',
    ThemeMode.system => 'Как в системе',
  };
  return '$mode · ${preference.accent.label}';
}

class _AccentOption extends StatelessWidget {
  const _AccentOption({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final AppAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: accent.label,
    child: InkResponse(
      onTap: onTap,
      radius: 28,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? context.palette.ink : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? accent.dark
                      : accent.lightDisplay,
                ),
                child: selected
                    ? Icon(
                        Icons.check,
                        size: 20,
                        color: context.palette.surface,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              accent.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.preference});

  final AppThemePreference preference;

  @override
  Widget build(BuildContext context) {
    final brightness = preference.mode == ThemeMode.dark
        ? Brightness.dark
        : preference.mode == ThemeMode.light
        ? Brightness.light
        : Theme.of(context).brightness;
    final palette = brightness == Brightness.dark
        ? AppPalette.dark(preference.accent)
        : AppPalette.light(preference.accent);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.currentSurface,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                '09:30\n11:00',
                style: TextStyle(
                  color: palette.accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Микроэкономика',
                    style: TextStyle(
                      color: palette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Лекция · ауд. 2043',
                    style: TextStyle(color: palette.muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'СЕЙЧАС',
                    style: TextStyle(
                      color: palette.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: context.palette.muted,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      ),
    ),
  );
}

class _SettingsSurface extends StatelessWidget {
  const _SettingsSurface({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    color: context.palette.nestedSurface,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1)
            Divider(indent: 56, color: context.palette.hairline),
        ],
      ],
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, size: 22),
    title: Text(title),
    subtitle: subtitle == null
        ? null
        : Text(subtitle!, style: TextStyle(color: context.palette.muted)),
    trailing:
        trailing ??
        (onTap == null
            ? null
            : Icon(Icons.chevron_right, color: context.palette.muted)),
    onTap: onTap,
  );
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(20),
    itemCount: 6,
    itemBuilder: (_, index) => Container(
      height: 62,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.palette.nestedSurface,
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}
