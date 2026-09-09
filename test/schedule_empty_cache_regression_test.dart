import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/schedule_widget.dart';
import 'package:uneconly/l10n/app_localizations.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  const info = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 2601, groupName: 'БИ-2601'),
  );

  void configurePhoneViewport(WidgetTester tester) {
    // Keep these regressions focused on which empty state is rendered rather
    // than on the test runner's synthetic viewport height.
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpSchedule(WidgetTester tester, Schedule schedule) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScheduleWidget(
            schedule: schedule,
            showCalendarBlock: false,
            onUpdate: () {},
            appConfig: const AppConfig.safeDefaults(),
          ),
        ),
      );

  testWidgets(
    'a cached unpublished week never renders as seven confirmed free days',
    (tester) async {
      configurePhoneViewport(tester);

      final database = MyDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final provider = ScheduleLocalDataProvider(database);

      await provider.saveSchedule(
        Schedule(
          week: 3,
          info: info,
          daySchedules: const [],
          academicYearStart: 2026,
          periodStart: DateTime(2026, 9, 14),
          periodEnd: DateTime(2026, 9, 20),
        ),
      );

      final cached = await provider.getSchedule(3, info, 2026);
      expect(cached, isNotNull);
      expect(cached!.schedule.daySchedules, isEmpty);

      await pumpSchedule(tester, cached.schedule);

      expect(find.text('Нет расписания на эту неделю'), findsOneWidget);
      expect(find.text('Свободные дни'), findsNothing);
    },
  );

  testWidgets('a cached published all-free week still renders as free days', (
    tester,
  ) async {
    configurePhoneViewport(tester);

    final database = MyDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final provider = ScheduleLocalDataProvider(database);
    final periodStart = DateTime(2026, 9, 14);

    await provider.saveSchedule(
      Schedule(
        week: 3,
        info: info,
        daySchedules: List.generate(
          7,
          (index) => DaySchedule.empty(periodStart.add(Duration(days: index))),
        ),
        academicYearStart: 2026,
        periodStart: periodStart,
        periodEnd: DateTime(2026, 9, 20),
      ),
    );

    final cached = await provider.getSchedule(3, info, 2026);
    expect(cached, isNotNull);
    expect(cached!.schedule.daySchedules, hasLength(7));

    await pumpSchedule(tester, cached.schedule);

    expect(find.text('Нет расписания на эту неделю'), findsNothing);
    expect(find.text('Свободные дни'), findsOneWidget);
  });
}
