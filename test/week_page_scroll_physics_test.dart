import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/feature/schedule/widget/schedule_page.dart';

void main() {
  const pageExtent = 100.0;
  const minPageIndex = 4242;
  const maxPageIndex = 4294;
  const physics = WeekPageScrollPhysics(
    minPageIndex: minPageIndex,
    maxPageIndex: maxPageIndex,
  );

  FixedScrollMetrics metrics(double pixels) => FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: double.infinity,
        pixels: pixels,
        viewportDimension: pageExtent,
        axisDirection: AxisDirection.right,
        devicePixelRatio: 1,
      );

  test('allows returning from week 2 to week 1', () {
    final week2Pixels = (minPageIndex + 1) * pageExtent;
    final week1Pixels = minPageIndex * pageExtent;

    expect(
      physics.applyBoundaryConditions(
        metrics(week2Pixels),
        week1Pixels,
      ),
      0,
    );
  });

  test('blocks pages outside the valid week range', () {
    final minPixels = minPageIndex * pageExtent;
    final maxPixels = maxPageIndex * pageExtent;

    expect(
      physics.applyBoundaryConditions(metrics(minPixels), minPixels - 10),
      -10,
    );
    expect(
      physics.applyBoundaryConditions(metrics(maxPixels), maxPixels + 10),
      10,
    );
  });

  testWidgets('allows a real PageView drag from week 1 to 2 and back',
      (tester) async {
    final controller = PageController(initialPage: minPageIndex);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: pageExtent,
            height: pageExtent,
            child: PageView.builder(
              controller: controller,
              physics: physics,
              itemBuilder: (context, index) => Text('$index'),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-100, 0));
    await tester.pumpAndSettle();
    expect(controller.page, minPageIndex + 1);

    await tester.drag(find.byType(PageView), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(controller.page, minPageIndex);
  });
}
