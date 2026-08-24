import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/feature/calendar/calendar_permission_modal.dart';
import 'package:uneconly/feature/calendar/calendar_permissions.dart';
import 'package:uneconly/feature/settings/bloc/settings_bloc.dart';
import 'package:uneconly/feature/settings/model/settings_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarBlock extends StatelessWidget {
  const CalendarBlock({super.key, this.onChanged});

  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBLoC>(
      create: (context) => SettingsBLoC(
        repository: Dependencies.of(context).settingsRepository,
      )..add(const SettingsEvent.read()),
      child: BlocConsumer<SettingsBLoC, SettingsState>(
        listenWhen: (previous, current) =>
            previous.data?.calendarSettings.isCalendarSyncingEnabled !=
            current.data?.calendarSettings.isCalendarSyncingEnabled,
        listener: (context, state) {
          final enabled = state.data?.calendarSettings.isCalendarSyncingEnabled;
          if (enabled != null) onChanged?.call(enabled);
        },
        builder: (context, state) {
          final data = state.data;
          return Material(
            color: context.palette.nestedSurface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(context.string.syncWithCalendar),
                  subtitle: const Text(
                    'Пары появятся в календаре телефона вместе с напоминаниями',
                  ),
                  trailing: Switch.adaptive(
                    value: data?.calendarSettings.isCalendarSyncingEnabled ??
                        false,
                    onChanged: data == null
                        ? null
                        : (value) => _toggle(context, data, value),
                  ),
                ),
                Divider(indent: 56, color: context.palette.hairline),
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: Text(context.string.openCalendar),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.palette.muted,
                  ),
                  onTap: () => _openCalendar(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggle(
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

  Future<void> _openCalendar(BuildContext context) async {
    Dependencies.of(context).loggingRepository.logEvent(
      'calendar/open',
      {'source': 'calendar_block'},
    );
    if (Platform.isIOS) {
      await launchUrl(Uri.parse('calshow://'));
    } else if (Platform.isAndroid) {
      final millis = DateTime.now().millisecondsSinceEpoch;
      await launchUrl(
        Uri.parse('content://com.android.calendar/time/$millis'),
      );
    }
  }
}
