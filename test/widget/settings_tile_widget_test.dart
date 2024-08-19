import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/feature/settings/widget/settings_tile.dart';

void main() {
  group('SettingsTile widget', () {
    testWidgets(
      'should show settings tile with title and description',
      (widgetTester) async {
        await widgetTester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SettingsTile(
                title: 'Hello',
                description: 'World',
              ),
            ),
          ),
        );

        final titleText = find.text('Hello');
        final descriptionText = find.text('World');

        expect(titleText, findsOne);
        expect(descriptionText, findsOne);
      },
    );
  });
}
