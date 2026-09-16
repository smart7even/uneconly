import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/widget/lesson_tile.dart';
import 'package:uneconly/l10n/app_localizations.dart';

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  Lesson lesson({
    String name = 'Программно-аппаратные средства информационных систем',
    String? type = 'Лабораторная',
    DateTime? start,
  }) {
    final lessonStart = start ?? DateTime(2026, 9, 15, 12, 50);
    return Lesson(
      name: type == null ? name : '$name ($type)',
      day: DateTime(lessonStart.year, lessonStart.month, lessonStart.day),
      dayOfWeek: 'ВТ',
      start: lessonStart,
      end: lessonStart.add(const Duration(minutes: 90)),
      professor: 'Левоева Инга Валерьевна',
      location: '2005 ауд. Грибоедова 30/32',
      lessonType: type,
      group: null,
      professorId: 112271,
    );
  }

  Future<void> pumpLesson(
    WidgetTester tester,
    Lesson value, {
    required DateTime now,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 393,
            child: LessonTile(
              cluster: LessonCluster([value]),
              currentTime: now,
              scheduleInfo: const ScheduleInfo.group(
                shortGroupInfo: ShortGroupInfo(
                  groupId: 14115,
                  groupName: 'БИ-2601',
                ),
              ),
              choiceRepository: LessonChoiceRepository(preferences),
              onChoiceChanged: () {},
              appConfig: const AppConfig.safeDefaults(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'ordinary lesson type leads metadata and full title is retained',
    (tester) async {
      final value = lesson();
      await pumpLesson(tester, value, now: DateTime(2026, 9, 15, 12));

      expect(
        find.text(
          'Лабораторная · Левоева И. В. · ауд. 2005 · Грибоедова 30/32',
        ),
        findsOneWidget,
      );
      final title = tester.widget<Text>(find.text(lessonDisplayName(value)));
      expect(title.maxLines, isNull);
      expect(title.overflow, isNull);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    },
  );

  testWidgets('exam badge and current marker coexist without repeating type', (
    tester,
  ) async {
    final value = lesson(
      name: 'Линейная алгебра',
      type: 'Экзамен',
      start: DateTime(2026, 9, 15, 10, 45),
    );
    await pumpLesson(tester, value, now: DateTime(2026, 9, 15, 11, 16));

    expect(find.byKey(const ValueKey('lesson-type-ЭКЗАМЕН')), findsOneWidget);
    expect(find.text('СЕЙЧАС'), findsOneWidget);
    expect(
      find.text('Левоева И. В. · ауд. 2005 · Грибоедова 30/32'),
      findsOneWidget,
    );
    expect(find.textContaining('Экзамен · Левоева'), findsNothing);
  });

  testWidgets('past lessons remain fully readable as one semantic row', (
    tester,
  ) async {
    final value = lesson(start: DateTime(2026, 9, 14, 10, 45));
    await pumpLesson(tester, value, now: DateTime(2026, 9, 15, 11, 16));

    expect(find.byType(AnimatedOpacity), findsNothing);
    expect(find.text(lessonDisplayName(value)), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Лабораторная')), findsOneWidget);
  });
}
