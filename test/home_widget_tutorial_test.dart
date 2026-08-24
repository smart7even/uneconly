import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:uneconly/feature/tutorials/widget/home_widget_tutorial.dart';
import 'package:uneconly/l10n/app_localizations.dart';

void main() {
  Widget app(Widget home) => MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      );

  testWidgets('shows the text guide and opens the video guide', (tester) async {
    await tester.pumpWidget(
      app(
        const HomeWidgetTutorial(
          videoUrl: 'https://example.invalid/widget-tutorial.gif',
        ),
      ),
    );

    expect(find.text('Нажмите и удерживайте пустое место'), findsOneWidget);
    expect(find.text('Посмотреть видео'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-widget-video-link')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HomeWidgetVideoPage), findsOneWidget);
    expect(find.text('Видеоинструкция'), findsOneWidget);
  });

  testWidgets('keeps the guide useful when the video URL is unavailable',
      (tester) async {
    await tester.pumpWidget(app(const HomeWidgetTutorial(videoUrl: '')));

    await tester.tap(find.byKey(const Key('home-widget-video-link')));
    await tester.pump();

    expect(find.text('Видео сейчас недоступно'), findsOneWidget);
    expect(find.byType(HomeWidgetVideoPage), findsNothing);
  });
}
