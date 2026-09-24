import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_details.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/schedule_refresh_overlay.dart';
import 'package:uneconly/l10n/app_localizations.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  final details = ScheduleDetails(
    schedule: Schedule(
      week: 2,
      info: const ScheduleInfo.group(
        shortGroupInfo: ShortGroupInfo(groupId: 2602, groupName: 'БИ-2602'),
      ),
      daySchedules: const [],
      academicYearStart: 2026,
      periodStart: DateTime(2026, 9, 7),
      periodEnd: DateTime(2026, 9, 13),
    ),
    isLocal: true,
    updatedAt: DateTime(2026, 8, 31, 2, 39),
  );

  Widget host({required bool isVisible}) => MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('ru'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(
              key: ValueKey('schedule-content'),
              color: Colors.white,
            ),
          ),
          ScheduleRefreshOverlay(isVisible: isVisible, details: details),
        ],
      ),
    ),
  );

  testWidgets('appears at the bottom without changing content geometry', (
    tester,
  ) async {
    await tester.pumpWidget(host(isVisible: false));
    final contentBefore = tester.getRect(
      find.byKey(const ValueKey('schedule-content')),
    );

    await tester.pumpWidget(host(isVisible: true));
    await tester.pump(const Duration(milliseconds: 200));
    final contentAfter = tester.getRect(
      find.byKey(const ValueKey('schedule-content')),
    );
    final cardRect = tester.getRect(
      find.byKey(const ValueKey('schedule-refresh-card')),
    );

    expect(contentAfter, contentBefore);
    expect(cardRect.bottom, lessThanOrEqualTo(contentAfter.bottom - 16));
    expect(cardRect.center.dy, greaterThan(contentAfter.center.dy));
    expect(find.text('Обновляем расписание…'), findsOneWidget);
    expect(
      find.text('Показана сохранённая копия · от 31 авг., 02:39'),
      findsOneWidget,
    );

    await tester.pumpWidget(host(isVisible: false));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.getRect(find.byKey(const ValueKey('schedule-content'))),
      contentBefore,
    );
    expect(find.text('Обновляем расписание…'), findsNothing);
  });
}
