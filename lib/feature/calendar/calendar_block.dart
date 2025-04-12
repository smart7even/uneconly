import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/widget/app_button.dart';
import 'package:uneconly/feature/calendar/calendar_permission_modal.dart';
import 'package:uneconly/feature/settings/bloc/settings_bloc.dart';
import 'package:uneconly/feature/settings/widget/settings_tile.dart';
import 'package:url_launcher/url_launcher.dart';

/// {@template calendar_block}
/// CalendarBlock widget
/// {@endtemplate}
class CalendarBlock extends StatelessWidget {
  final ValueChanged<bool>? onChanged;

  /// {@macro calendar_block}
  const CalendarBlock({
    super.key,
    this.onChanged,
  });

  Future<bool> _requestCalendarPermission() async {
    try {
      final deviceCalendarPlugin = DeviceCalendarPlugin();
      var permissionsGranted = await deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess &&
          (permissionsGranted.data == null ||
              permissionsGranted.data == false)) {
        permissionsGranted = await deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess ||
            permissionsGranted.data == null ||
            permissionsGranted.data == false) {
          return false;
        }
      }
    } on PlatformException catch (e) {
      print(e);

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBLoC>(
      create: (context) =>
          SettingsBLoC(repository: Dependencies.of(context).settingsRepository)
            ..add(
              const SettingsEvent.read(),
            ),
      child: BlocConsumer<SettingsBLoC, SettingsState>(
        listenWhen: (previous, current) {
          final previousCalendarSettings = previous.data?.calendarSettings;
          final currentCalendarSettings = current.data?.calendarSettings;

          if (previousCalendarSettings == null ||
              currentCalendarSettings == null) {
            return false;
          }

          return previousCalendarSettings.isCalendarSyncingEnabled !=
              currentCalendarSettings.isCalendarSyncingEnabled;
        },
        listener: (context, state) {
          print('CalendarBlock listener');

          final data = state.data;

          if (data == null) {
            return;
          }

          final isCalendarSyncingEnabled =
              data.calendarSettings.isCalendarSyncingEnabled;

          onChanged?.call(isCalendarSyncingEnabled);
        },
        builder: (context, state) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 4,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.string.calendar,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SettingsTile.withoutPadding(
                    title: AppLocalizations.of(context)!.syncWithCalendar,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    trailing: CupertinoSwitch(
                      value: state.data?.calendarSettings
                              .isCalendarSyncingEnabled ??
                          false,
                      onChanged: (value) async {
                        final loggingRepository =
                            Dependencies.of(context).loggingRepository;

                        final data = state.data;

                        if (data == null) {
                          return;
                        }

                        final bloc = context.read<SettingsBLoC>();

                        loggingRepository.logEvent(
                          'calendar/enable/start',
                          {},
                        );

                        if (value) {
                          bool hasPermissions =
                              await _requestCalendarPermission();

                          loggingRepository.logEvent(
                            'calendar/permission',
                            {
                              'granted': hasPermissions,
                            },
                          );

                          if (!hasPermissions) {
                            await showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return const CalendarPermissionModal();
                              },
                            );

                            return;
                          }
                        }

                        if (value) {
                          loggingRepository.logEvent(
                            'calendar/enable/success',
                            {},
                          );
                        } else {
                          loggingRepository.logEvent(
                            'calendar/disable',
                            {},
                          );
                        }

                        bloc.add(
                          SettingsEvent.update(
                            entity: data.copyWith.calendarSettings(
                              isCalendarSyncingEnabled: value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.string.syncWithCalendarDescription,
                    style: const TextStyle(
                        // color: Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: AppButton(
                      title: context.string.openCalendar,
                      onPressed: () async {
                        final loggingRepository =
                            Dependencies.of(context).loggingRepository;

                        loggingRepository.logEvent(
                          'calendar/open',
                          {
                            'source': 'calendar_block',
                          },
                        );

                        if (Platform.isIOS) {
                          await launchUrl(
                            Uri.parse(
                              'calshow://',
                            ),
                          );
                        } else if (Platform.isAndroid) {
                          final millis = DateTime.now().millisecondsSinceEpoch;
                          final uri = Uri.parse(
                            'content://com.android.calendar/time/$millis',
                          );

                          await launchUrl(
                            uri,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
