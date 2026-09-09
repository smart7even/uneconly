import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/model/short_professor_info.dart';
import 'package:uneconly/feature/schedule/data/schedule_local_data_provider.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

void main() {
  late MyDatabase database;
  late ScheduleLocalDataProvider provider;

  const info = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 2602, groupName: 'БИ-2602'),
  );

  setUp(() {
    database = MyDatabase.forTesting(NativeDatabase.memory());
    provider = ScheduleLocalDataProvider(database);
  });

  tearDown(() => database.close());

  test('uses the canonical cached period instead of reconstructing its dates',
      () async {
    final periodStart = DateTime(2026, 9, 7);
    final lessonDay = DateTime(2026, 9, 8);
    final schedule = Schedule(
      week: 2,
      info: info,
      academicYearStart: 2026,
      periodStart: periodStart,
      periodEnd: DateTime(2026, 9, 13),
      daySchedules: [
        DaySchedule(
          day: lessonDay,
          lessons: [
            Lesson(
              name: 'Информационные системы и технологии',
              day: lessonDay,
              dayOfWeek: 'Вторник',
              start: DateTime(2026, 9, 8, 9),
              end: DateTime(2026, 9, 8, 10, 30),
              professor: 'Коршунов И. Л.',
              location: '2090',
              lessonType: null,
              group: 'БИ-2602',
              professorId: null,
            ),
          ],
        ),
      ],
    );

    await provider.saveSchedule(schedule);

    final cacheEntry = await provider.getSchedule(2, info, 2026);
    expect(cacheEntry, isNotNull);
    final cached = cacheEntry!.schedule;
    expect(cached.periodStart, DateTime(2026, 9, 7));
    expect(cached.periodEnd, DateTime(2026, 9, 13));
    expect(cached.daySchedules.first.day, DateTime(2026, 9, 7));
    expect(cacheEntry.updatedAt, isNotNull);
  });

  test('rejects a cached week from another academic year', () async {
    final lessonDay = DateTime(2025, 9, 8);
    await provider.saveSchedule(
      Schedule(
        week: 2,
        info: info,
        academicYearStart: 2025,
        periodStart: lessonDay,
        periodEnd: DateTime(2025, 9, 14),
        daySchedules: [
          DaySchedule(
            day: lessonDay,
            lessons: [
              Lesson(
                name: 'Старое расписание',
                day: lessonDay,
                dayOfWeek: 'Понедельник',
                start: DateTime(2025, 9, 8, 9),
                end: DateTime(2025, 9, 8, 10, 30),
                professor: null,
                location: '',
                lessonType: null,
                group: 'БИ-2602',
                professorId: null,
              ),
            ],
          ),
        ],
      ),
    );

    expect(await provider.getSchedule(2, info, 2026), isNull);
  });

  test('finds the closest canonical period for an offline cold start',
      () async {
    Future<void> save(int week, DateTime start, DateTime end) =>
        provider.saveSchedule(
          Schedule(
            week: week,
            info: info,
            academicYearStart: 2026,
            periodStart: start,
            periodEnd: end,
            daySchedules: [
              DaySchedule(
                day: start,
                lessons: [
                  Lesson(
                    name: 'Кэш недели $week',
                    day: start,
                    dayOfWeek: '',
                    start: start.add(const Duration(hours: 9)),
                    end: start.add(const Duration(hours: 10, minutes: 30)),
                    professor: null,
                    location: '',
                    lessonType: null,
                    group: 'БИ-2602',
                    professorId: null,
                  ),
                ],
              ),
            ],
          ),
        );

    await save(1, DateTime(2026, 9, 1), DateTime(2026, 9, 6));
    await save(2, DateTime(2026, 9, 7), DateTime(2026, 9, 13));

    final duringWeek =
        await provider.getClosestSchedule(DateTime(2026, 9, 3), info);
    expect(duringWeek?.schedule.week, 1);

    final dayBeforeFirstWeek =
        await provider.getClosestSchedule(DateTime(2026, 8, 31), info);
    expect(dayBeforeFirstWeek?.schedule.week, 1);

    final duringSecondWeek =
        await provider.getClosestSchedule(DateTime(2026, 9, 9), info);
    expect(duringSecondWeek?.schedule.week, 2);
  });

  test('a late shortened-week save cannot erase the next Monday', () async {
    Lesson lesson(String name, DateTime day) => Lesson(
          name: name,
          day: day,
          dayOfWeek: '',
          start: day.add(const Duration(hours: 9)),
          end: day.add(const Duration(hours: 10, minutes: 30)),
          professor: null,
          location: '',
          lessonType: null,
          group: 'БИ-2602',
          professorId: null,
        );

    final nextMonday = DateTime(2026, 9, 7);
    await provider.saveSchedule(
      Schedule(
        week: 2,
        info: info,
        academicYearStart: 2026,
        periodStart: nextMonday,
        periodEnd: DateTime(2026, 9, 13),
        daySchedules: [
          DaySchedule(
            day: nextMonday,
            lessons: [lesson('Линейная алгебра', nextMonday)],
          ),
          DaySchedule(
            day: DateTime(2026, 9, 8),
            lessons: [
              lesson(
                'Информационные системы',
                DateTime(2026, 9, 8),
              ),
            ],
          ),
        ],
      ),
    );

    // Simulate the slower week-1 request completing after week 2. Week 1 is
    // shortened by the academic-year boundary and ends on September 6.
    await provider.saveSchedule(
      Schedule(
        week: 1,
        info: info,
        academicYearStart: 2026,
        periodStart: DateTime(2026, 9, 1),
        periodEnd: DateTime(2026, 9, 6),
        daySchedules: [
          DaySchedule(
            day: DateTime(2026, 9, 2),
            lessons: [lesson('Экономическая теория', DateTime(2026, 9, 2))],
          ),
        ],
      ),
    );

    final cachedWeek2 = await provider.getSchedule(2, info, 2026);
    expect(cachedWeek2, isNotNull);
    expect(
      cachedWeek2!.schedule.daySchedules.first.lessons
          .map((lesson) => lesson.name),
      contains('Линейная алгебра'),
    );
  });

  test('an explicitly empty server response remains a valid cache entry',
      () async {
    await provider.saveSchedule(
      Schedule(
        week: 3,
        info: info,
        academicYearStart: 2026,
        periodStart: DateTime(2026, 9, 14),
        periodEnd: DateTime(2026, 9, 20),
        daySchedules: const [],
      ),
    );

    final cached = await provider.getSchedule(3, info, 2026);
    expect(cached, isNotNull);
    expect(cached!.schedule.daySchedules, hasLength(7));
    expect(
      cached.schedule.daySchedules.every((day) => day.lessons.isEmpty),
      isTrue,
    );
  });

  test('group and professor cache rows stay isolated in both directions',
      () async {
    const professorInfo = ScheduleInfo.professor(
      shortProfessorInfo: ShortProfessorInfo(
        professorId: 77,
        professorName: 'Иванов И. И.',
      ),
    );
    final day = DateTime(2026, 9, 8);

    Lesson lesson(String name) => Lesson(
          name: name,
          day: day,
          dayOfWeek: '',
          start: day.add(const Duration(hours: 9)),
          end: day.add(const Duration(hours: 10, minutes: 30)),
          professor: 'Иванов И. И.',
          location: '',
          lessonType: null,
          group: 'БИ-2602',
          professorId: 77,
        );

    Schedule schedule(ScheduleInfo scheduleInfo, String lessonName) => Schedule(
          week: 2,
          info: scheduleInfo,
          academicYearStart: 2026,
          periodStart: DateTime(2026, 9, 7),
          periodEnd: DateTime(2026, 9, 13),
          daySchedules: [
            DaySchedule(day: day, lessons: [lesson(lessonName)]),
          ],
        );

    await provider.saveSchedule(schedule(professorInfo, 'Кэш преподавателя'));
    await provider.saveSchedule(schedule(info, 'Кэш группы'));

    final professorAfterGroup =
        await provider.getSchedule(2, professorInfo, 2026);
    expect(
      professorAfterGroup!.schedule.daySchedules
          .expand((day) => day.lessons)
          .map((lesson) => lesson.name),
      ['Кэш преподавателя'],
    );

    await provider.saveSchedule(
      schedule(professorInfo, 'Обновлённый кэш преподавателя'),
    );

    final groupAfterProfessor = await provider.getSchedule(2, info, 2026);
    expect(
      groupAfterProfessor!.schedule.daySchedules
          .expand((day) => day.lessons)
          .map((lesson) => lesson.name),
      ['Кэш группы'],
    );
  });

  test('refresh atomically replaces every lesson inside one period', () async {
    final day = DateTime(2026, 9, 8);
    Lesson lesson(String name) => Lesson(
          name: name,
          day: day,
          dayOfWeek: '',
          start: day.add(const Duration(hours: 9)),
          end: day.add(const Duration(hours: 10, minutes: 30)),
          professor: null,
          location: '',
          lessonType: null,
          group: 'БИ-2602',
          professorId: null,
        );
    Schedule value(String name) => Schedule(
          week: 2,
          info: info,
          academicYearStart: 2026,
          periodStart: DateTime(2026, 9, 7),
          periodEnd: DateTime(2026, 9, 13),
          daySchedules: [
            DaySchedule(day: day, lessons: [lesson(name)]),
          ],
        );

    await provider.saveSchedule(value('Старая версия'));
    await provider.saveSchedule(value('Новая версия'));

    final cached = await provider.getSchedule(2, info, 2026);
    expect(
      cached!.schedule.daySchedules
          .expand((day) => day.lessons)
          .map((lesson) => lesson.name),
      ['Новая версия'],
    );
  });

  test('invalid response cannot partially overwrite a healthy cache', () async {
    final day = DateTime(2026, 9, 8);
    final healthy = Schedule(
      week: 2,
      info: info,
      academicYearStart: 2026,
      periodStart: DateTime(2026, 9, 7),
      periodEnd: DateTime(2026, 9, 13),
      daySchedules: [
        DaySchedule(
          day: day,
          lessons: [
            Lesson(
              name: 'Достоверный кэш',
              day: day,
              dayOfWeek: '',
              start: day.add(const Duration(hours: 9)),
              end: day.add(const Duration(hours: 10, minutes: 30)),
              professor: null,
              location: '',
              lessonType: null,
              group: 'БИ-2602',
              professorId: null,
            ),
          ],
        ),
      ],
    );
    await provider.saveSchedule(healthy);

    final outside = DateTime(2026, 9, 14);
    final invalid = Schedule(
      week: 2,
      info: info,
      academicYearStart: 2026,
      periodStart: DateTime(2026, 9, 7),
      periodEnd: DateTime(2026, 9, 13),
      daySchedules: [DaySchedule.empty(outside)],
    );
    await expectLater(provider.saveSchedule(invalid), throwsArgumentError);

    final cached = await provider.getSchedule(2, info, 2026);
    expect(
      cached!.schedule.daySchedules.expand((day) => day.lessons).single.name,
      'Достоверный кэш',
    );
  });
}
