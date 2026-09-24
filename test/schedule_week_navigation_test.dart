import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/schedule_week_navigation.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  Schedule schedule({
    required int week,
    required DateTime start,
    required DateTime end,
  }) => Schedule(
    week: week,
    info: const ScheduleInfo.group(
      shortGroupInfo: ShortGroupInfo(groupId: 2602, groupName: 'БИ-2602'),
    ),
    daySchedules: const [],
    academicYearStart: 2026,
    periodStart: start,
    periodEnd: end,
  );

  Widget host({
    required int selectedWeek,
    required int currentWeek,
    required Schedule value,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    TextScaler? textScaler,
  }) => MaterialApp(
    theme: AppTheme.light(),
    builder: textScaler == null
        ? null
        : (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
    home: Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: ScheduleWeekNavigation(
            selectedWeek: selectedWeek,
            currentWeek: currentWeek,
            schedule: value,
            onPrevious: onPrevious ?? () {},
            onNext: onNext ?? () {},
          ),
        ),
      ),
    ),
  );

  testWidgets('keeps explicit week controls visible with useful context', (
    tester,
  ) async {
    var previousTaps = 0;
    var nextTaps = 0;
    await tester.pumpWidget(
      host(
        selectedWeek: 4,
        currentWeek: 4,
        value: schedule(
          week: 4,
          start: DateTime(2026, 9, 21),
          end: DateTime(2026, 9, 27),
        ),
        onPrevious: () => previousTaps++,
        onNext: () => nextTaps++,
      ),
    );

    expect(find.text('21–27 сентября'), findsOneWidget);
    expect(find.text('Неделя 4 · чётная · эта неделя'), findsOneWidget);
    expect(find.byTooltip('Предыдущая неделя, 3'), findsOneWidget);
    expect(find.byTooltip('Следующая неделя, 5'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('previous-week-button')));
    await tester.tap(find.byKey(const ValueKey('next-week-button')));
    expect(previousTaps, 1);
    expect(nextTaps, 1);
  });

  testWidgets('disables only the unavailable semester boundary', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        selectedWeek: 1,
        currentWeek: 4,
        value: schedule(
          week: 1,
          start: DateTime(2026, 9),
          end: DateTime(2026, 9, 6),
        ),
      ),
    );

    final previous = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const ValueKey('previous-week-button')),
        matching: find.byType(IconButton),
      ),
    );
    final next = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const ValueKey('next-week-button')),
        matching: find.byType(IconButton),
      ),
    );
    expect(previous.onPressed, isNull);
    expect(next.onPressed, isNotNull);
    expect(find.text('Неделя 1 · нечётная'), findsOneWidget);
  });

  testWidgets('remains usable on a narrow phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      host(
        selectedWeek: 4,
        currentWeek: 4,
        value: schedule(
          week: 4,
          start: DateTime(2026, 9, 21),
          end: DateTime(2026, 9, 27),
        ),
        textScaler: const TextScaler.linear(2),
      ),
    );

    expect(tester.takeException(), isNull);
    final previousSize = tester.getSize(
      find.byKey(const ValueKey('previous-week-button')),
    );
    final nextSize = tester.getSize(
      find.byKey(const ValueKey('next-week-button')),
    );
    expect(previousSize.width, greaterThanOrEqualTo(44));
    expect(previousSize.height, greaterThanOrEqualTo(44));
    expect(nextSize.width, greaterThanOrEqualTo(44));
    expect(nextSize.height, greaterThanOrEqualTo(44));
  });

  test('formats a range across two months without ambiguity', () {
    expect(
      formatSchedulePeriod(DateTime(2026, 9, 28), DateTime(2026, 10, 4)),
      '28 сент. – 4 окт.',
    );
  });
}
