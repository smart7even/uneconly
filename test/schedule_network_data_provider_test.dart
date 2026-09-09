import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/model/short_professor_info.dart';
import 'package:uneconly/feature/schedule/data/schedule_network_data_provider.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

void main() {
  const groupInfo = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 2602, groupName: 'БИ-2602'),
  );
  const professorInfo = ScheduleInfo.professor(
    shortProfessorInfo: ShortProfessorInfo(
      professorId: 77,
      professorName: 'Иванов И. И.',
    ),
  );

  Map<String, dynamic> lesson({String day = '2026-09-07'}) => {
        'name': 'Линейная алгебра',
        'day': day,
        'day_of_week': 'Понедельник',
        'start': '${day}T09:00:00',
        'end': '${day}T10:30:00',
        'professor': 'Иванов И. И.',
        'location': '3011',
        'lesson_type': null,
        'group': 'БИ-2602',
        'professor_id': 77,
        'room_url': null,
      };

  Map<String, dynamic> payload({
    String periodStart = '2026-09-07',
    String periodEnd = '2026-09-13',
    List<Map<String, dynamic>>? lessons,
    bool? hasScheduleDays,
  }) =>
      {
        'week': 2,
        'academic_year_start': 2026,
        'period_start': periodStart,
        'period_end': periodEnd,
        'has_schedule_days': ?hasScheduleDays,
        'lessons': lessons ?? [lesson()],
      };

  test('uses isolated group and professor API paths with canonical metadata',
      () async {
    final requests = <RequestOptions>[];
    final provider = ScheduleNetworkDataProvider(
      dio: _dioRespondingWith(payload(), requests),
    );

    final group = await provider.fetch(info: groupInfo, week: 2);
    final professor = await provider.fetch(info: professorInfo, week: 2);

    expect(requests[0].path, '/group/2602/schedule');
    expect(requests[1].path, '/professor/77/schedule');
    expect(requests.every((request) => request.queryParameters['week'] == 2),
        isTrue);
    expect(group.periodStart, DateTime(2026, 9, 7));
    expect(group.periodEnd, DateTime(2026, 9, 13));
    expect(group.daySchedules, hasLength(7));
    expect(professor.info, professorInfo);
  });

  test('rejects a period longer than one schedule week', () async {
    final provider = ScheduleNetworkDataProvider(
      dio: _dioRespondingWith(
        payload(periodEnd: '2026-09-14', lessons: []),
        [],
      ),
    );

    await expectLater(
      provider.fetch(info: groupInfo, week: 2),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects lessons outside the declared canonical period', () async {
    final provider = ScheduleNetworkDataProvider(
      dio: _dioRespondingWith(
        payload(lessons: [lesson(day: '2026-09-14')]),
        [],
      ),
    );

    await expectLater(
      provider.fetch(info: groupInfo, week: 2),
      throwsA(isA<FormatException>()),
    );
  });

  test('preserves a published week made entirely of free days', () async {
    final provider = ScheduleNetworkDataProvider(
      dio: _dioRespondingWith(
        payload(lessons: [], hasScheduleDays: true),
        [],
      ),
    );

    final schedule = await provider.fetch(info: groupInfo, week: 2);

    expect(schedule.daySchedules, hasLength(7));
    expect(schedule.daySchedules.every((day) => day.lessons.isEmpty), isTrue);
  });

  test('keeps an old-backend empty response as unpublished', () async {
    final provider = ScheduleNetworkDataProvider(
      dio: _dioRespondingWith(payload(lessons: []), []),
    );

    final schedule = await provider.fetch(info: groupInfo, week: 2);

    expect(schedule.daySchedules, isEmpty);
  });
}

Dio _dioRespondingWith(
  Map<String, dynamic> payload,
  List<RequestOptions> requests,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: payload,
          ),
        );
      },
    ),
  );
  return dio;
}
