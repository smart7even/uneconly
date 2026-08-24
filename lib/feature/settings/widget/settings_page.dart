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
      create: (context) => SettingsBLoC(
        repository: Dependencies.of(context).settingsRepository,
      )..add(const SettingsEvent.read()),
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

  Future<void> _selectTheme(
    BuildContext context,
    SettingsEntity data,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Тема',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              RadioGroup<String>(
                groupValue: _normalizedTheme(data.themeColor),
                onChanged: (value) => Navigator.pop(sheetContext, value),
                child: Column(
                  children: [
                    for (final option in const [
                      (
                        'system',
                        'Как в системе',
                        Icons.brightness_auto_outlined,
                      ),
                      ('light', 'Светлая', Icons.light_mode_outlined),
                      ('dark', 'Тёмная', Icons.dark_mode_outlined),
                    ])
                      RadioListTile<String>(
                        value: option.$1,
                        title: Text(option.$2),
                        secondary: Icon(option.$3),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    context.read<SettingsBLoC>().add(
          SettingsEvent.update(
            entity: data.copyWith(themeColor: selected),
          ),
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

String _normalizedTheme(String value) =>
    const {'system', 'light', 'dark'}.contains(value) ? value : 'system';

String _themeLabel(String value) => switch (_normalizedTheme(value)) {
      'light' => 'Светлая',
      'dark' => 'Тёмная',
      _ => 'Как в системе',
    };

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
        trailing: trailing ??
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
