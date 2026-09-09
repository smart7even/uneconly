import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/feature/initialization/data/initialization.dart';
import 'package:uneconly/feature/initialization/widget/inherited_dependencies.dart';
import 'package:uneconly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'cached adjacent week remains complete across a real app restart',
    (tester) async {
      final testErrorHandler = FlutterError.onError;
      final testPlatformErrorHandler = PlatformDispatcher.instance.onError;
      late final Dependencies dependencies;
      await $initializeApp(
        onSuccess: (initializedDependencies) {
          dependencies = initializedDependencies;
          runApp(
            InheritedDependencies(
              dependencies: dependencies,
              child: const app.MyApp(),
            ),
          );
        },
      );
      FlutterError.onError = testErrorHandler;
      PlatformDispatcher.instance.onError = testPlatformErrorHandler;

      await _pumpUntil(
        tester,
        () =>
            find.text('Выберите группу').evaluate().isNotEmpty ||
            find.textContaining('1–6 сентября').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 30),
      );
      if (find.text('Выберите группу').evaluate().isNotEmpty) {
        await _pumpUntil(
          tester,
          () => find.text('БИ-2602').evaluate().isNotEmpty,
          timeout: const Duration(seconds: 30),
        );
        await tester.tap(find.text('БИ-2602'));
      }
      await _pumpUntil(
        tester,
        () => find.textContaining('1–6 сентября').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 30),
      );

      final groupTitle = find.text('БИ-2602');
      expect(groupTitle, findsOneWidget);

      await _tapNextWeek(tester);

      await _pumpUntil(
        tester,
        () => find.textContaining('7–13 сентября').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 30),
      );

      expect(find.textContaining('7–13 сентября'), findsOneWidget);
      expect(
        find.textContaining('Понедельник · 7 сентября'),
        findsOneWidget,
      );
      _expectMondayHasLessons();

      await _pumpUntil(
        tester,
        () => find
            .byKey(const ValueKey('schedule-refresh-card'))
            .evaluate()
            .isEmpty,
        timeout: const Duration(seconds: 30),
      );

      _openSchedule(
        tester,
        arguments: const {
          'groupId': '13872',
          'groupName': 'БИ-2501',
          'isViewMode': 'true',
        },
      );
      await _pumpUntil(
        tester,
        () =>
            find.text('БИ-2501').evaluate().isNotEmpty &&
            find.textContaining('1–6 сентября').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 30),
      );
      await _tapNextWeek(tester);
      await _pumpUntil(
        tester,
        () => find.textContaining('7–13 сентября').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 30),
      );
      _expectMondayHasLessons();
      await _waitForRefreshToFinish(tester);

      _openSchedule(
        tester,
        arguments: const {
          'professorId': '978',
          'professorName': 'Ермаченко Юлия Германовна',
          'isViewMode': 'true',
        },
      );
      await _pumpUntil(
        tester,
        () =>
            find.text('Ермаченко Юлия Германовна').evaluate().isNotEmpty &&
            find
                .textContaining('Преподаватель · 1–6 сентября')
                .evaluate()
                .isNotEmpty,
        timeout: const Duration(seconds: 30),
      );
      expect(
        find.textContaining('Преподаватель · 1–6 сентября'),
        findsOneWidget,
      );
      await _tapNextWeek(tester);
      await _pumpUntil(
        tester,
        () => find
            .textContaining('Преподаватель · 7–13 сентября')
            .evaluate()
            .isNotEmpty,
        timeout: const Duration(seconds: 30),
      );
      _expectMondayHasLessons();
      await _waitForRefreshToFinish(tester);

      // Recreate the full app widget tree and make every new request hang. The
      // next assertions can therefore only pass from the persisted cache.
      dependencies.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Intentionally never continue or reject this request.
          },
        ),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(
        InheritedDependencies(
          dependencies: dependencies,
          child: const app.MyApp(),
        ),
      );

      await _pumpUntil(
        tester,
        () => find.textContaining('1–6 сентября').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 5),
      );
      expect(find.text('БИ-2602'), findsOneWidget);

      await _tapNextWeek(tester);
      await _pumpUntil(
        tester,
        () => find.textContaining('7–13 сентября').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 3),
      );
      expect(
        find.textContaining('Понедельник · 7 сентября'),
        findsOneWidget,
      );
      _expectMondayHasLessons();
      await _pumpUntil(
        tester,
        () => find
            .byKey(const ValueKey('schedule-refresh-card'))
            .evaluate()
            .isNotEmpty,
        timeout: const Duration(seconds: 3),
      );

      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, -10000),
        3000,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('week-navigation')), findsOneWidget);

      final overlay = find.byKey(const ValueKey('schedule-refresh-card'));
      final navigation = find.byKey(const ValueKey('week-navigation'));
      final overlayTop = tester.getTopLeft(overlay).dy;
      final navigationBottom = tester.getBottomLeft(navigation).dy;
      expect(navigationBottom, lessThanOrEqualTo(overlayTop));
    },
  );
}

void _openSchedule(
  WidgetTester tester, {
  required Map<String, String> arguments,
}) {
  final context = tester.element(find.byType(Scaffold).first);
  Octopus.of(context).setState(
    (state) => state..add(Routes.schedule.node(arguments: arguments)),
  );
}

Future<void> _waitForRefreshToFinish(WidgetTester tester) => _pumpUntil(
      tester,
      () => find
          .byKey(const ValueKey('schedule-refresh-card'))
          .evaluate()
          .isEmpty,
      timeout: const Duration(seconds: 30),
    );

Future<void> _tapNextWeek(WidgetTester tester) async {
  final navigation = find.byKey(const ValueKey('week-navigation'));
  await tester.dragUntilVisible(
    navigation,
    find.byType(CustomScrollView).first,
    const Offset(0, -600),
  );
  final nextButton = find.descendant(
    of: navigation,
    matching: find.byIcon(Icons.arrow_forward),
  );
  expect(nextButton, findsOneWidget);
  await tester.tap(nextButton);
  await tester.pump(const Duration(milliseconds: 500));
}

void _expectMondayHasLessons() {
  final mondayHeader = find.textContaining('Понедельник · 7 сентября');
  final mondayHeaderRow = find.ancestor(
    of: mondayHeader,
    matching: find.byType(Row),
  );
  expect(
    find.descendant(
      of: mondayHeaderRow,
      matching: find.textContaining('пары ·'),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: mondayHeaderRow,
      matching: find.text('нет пар'),
    ),
    findsNothing,
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required Duration timeout,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Timed out waiting for the expected app state.');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
}
