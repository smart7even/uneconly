import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/feature/initialization/data/initialization.dart';
import 'package:uneconly/feature/initialization/widget/inherited_dependencies.dart';
import 'package:uneconly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('core release journey survives navigation and offline restart', (
    tester,
  ) async {
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

    await _selectPrimaryGroupIfNeeded(tester);
    await _waitForSchedule(tester, groupName: 'БИ-2604');

    final initialWeek = _weekSubtitle(tester, groupName: 'БИ-2604');
    await tester.drag(
      find.byKey(const ValueKey('schedule-week-page-view')),
      const Offset(-800, 0),
    );
    await _pumpUntil(
      tester,
      () => _weekSubtitle(tester, groupName: 'БИ-2604') != initialWeek,
    );
    await tester.drag(
      find.byKey(const ValueKey('schedule-week-page-view')),
      const Offset(800, 0),
    );
    await _pumpUntil(
      tester,
      () => _weekSubtitle(tester, groupName: 'БИ-2604') == initialWeek,
    );

    // Exercise the real drawer/settings route, the university default, and
    // persistence through the settings repository before restoring the
    // release default for the remainder of the smoke test.
    await _openDrawer(tester);
    await _pumpUntil(
      tester,
      () => find.text('Настройки').evaluate().isNotEmpty,
    );
    await _tapVisible(tester, find.text('Настройки'));
    await _pumpUntil(
      tester,
      () => find.text('Как в системе · Бирюза').evaluate().isNotEmpty,
    );
    await _selectAccent(tester, 'Индиго');
    await _pumpUntil(
      tester,
      () => find.text('Как в системе · Индиго').evaluate().isNotEmpty,
    );
    await _selectAccent(tester, 'Бирюза');
    await _pumpUntil(
      tester,
      () => find.text('Как в системе · Бирюза').evaluate().isNotEmpty,
    );

    await _goBack(tester);
    await _waitForSchedule(tester, groupName: 'БИ-2604');

    // View another real group and return without replacing the user's group.
    await _openDrawer(tester);
    await _pumpUntil(
      tester,
      () => find
          .text('Посмотреть расписание другой группы')
          .evaluate()
          .isNotEmpty,
    );
    await _tapVisible(tester, find.text('Посмотреть расписание другой группы'));
    await _searchAndOpenGroup(tester, 'БИ-2602');
    await _waitForSchedule(tester, groupName: 'БИ-2602');
    await _goBack(tester);
    await _waitForSchedule(tester, groupName: 'БИ-2604');

    // Recreate the whole app while every new request remains pending. The
    // schedule must still become useful from the persisted cache promptly.
    dependencies.dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Deliberately leave the request pending.
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

    await _waitForSchedule(
      tester,
      groupName: 'БИ-2604',
      timeout: const Duration(seconds: 5),
    );
  });
}

Future<void> _selectPrimaryGroupIfNeeded(WidgetTester tester) async {
  await _pumpUntil(
    tester,
    () =>
        find.text('Выберите группу').evaluate().isNotEmpty ||
        find.text('БИ-2604').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
  );
  if (find.text('Выберите группу').evaluate().isEmpty) return;
  await _searchAndOpenGroup(tester, 'БИ-2604');
}

Future<void> _searchAndOpenGroup(WidgetTester tester, String groupName) async {
  await _pumpUntil(
    tester,
    () => find.byType(TextField).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
  );
  await tester.enterText(find.byType(TextField), groupName);
  await _pumpUntil(
    tester,
    () => find.byType(ListTile).hitTestable().evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
  );
  await _tapVisible(tester, find.byType(ListTile));
}

Future<void> _waitForSchedule(
  WidgetTester tester, {
  required String groupName,
  Duration timeout = const Duration(seconds: 30),
}) async {
  await _pumpUntil(
    tester,
    () =>
        find.text(groupName).evaluate().isNotEmpty &&
        (find.byKey(const ValueKey('schedule-content')).evaluate().isNotEmpty ||
            find
                .byKey(const ValueKey('schedule-unpublished'))
                .evaluate()
                .isNotEmpty),
    timeout: timeout,
  );
  expect(find.byKey(const ValueKey('schedule-week-page-view')), findsOneWidget);
}

String _weekSubtitle(WidgetTester tester, {required String groupName}) {
  final appBarTexts = tester.widgetList<Text>(
    find.descendant(of: find.byType(AppBar), matching: find.byType(Text)),
  );
  return appBarTexts
      .map((text) => text.data)
      .whereType<String>()
      .firstWhere((text) => text.isNotEmpty && text != groupName);
}

Future<void> _selectAccent(WidgetTester tester, String accent) async {
  await _tapVisible(tester, find.text('Тема'));
  await _pumpUntil(tester, () => find.text(accent).evaluate().isNotEmpty);
  await _tapVisible(tester, find.text(accent));
  await _tapVisible(tester, find.text('Готово'));
}

Future<void> _goBack(WidgetTester tester) async {
  await _tapVisible(tester, find.byType(BackButton));
}

Future<void> _openDrawer(WidgetTester tester) async {
  final otherGroup = find.text('Посмотреть расписание другой группы');
  if (otherGroup.hitTestable().evaluate().isNotEmpty) return;
  await _tapVisible(tester, find.byIcon(Icons.menu));
  await _pumpUntil(
    tester,
    () => otherGroup.hitTestable().evaluate().isNotEmpty,
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _pumpUntil(tester, () => finder.hitTestable().evaluate().isNotEmpty);
  await tester.tap(finder.hitTestable().first);
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      final visibleTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .where((text) => text.isNotEmpty)
          .toSet()
          .join(' | ');
      debugPrint('Core smoke timeout. Visible text: $visibleTexts');
      throw TestFailure('Timed out waiting for the expected core app state.');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
}
