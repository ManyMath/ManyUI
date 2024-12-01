import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MDivider sizing', () {
    testWidgets('horizontal divider expands to fill width and is 1px tall',
        (WidgetTester tester) async {
      // In real use a horizontal MDivider drops into a Column or unbounded-
      // height parent, which constrains the cross axis loosely. Mirror that
      // by giving the divider a fixed width but no height constraint.
      await pumpManyApp(
        tester,
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: 200, child: MDivider()),
            ],
          ),
        ),
        viewport: const Size(400, 100),
      );

      final Size size = tester.getSize(find.byType(MDivider));
      expect(size.width, 200);
      expect(size.height, 1);
    });

    testWidgets('vertical divider expands to fill height and is 1px wide',
        (WidgetTester tester) async {
      // Symmetric to the horizontal case — give the vertical divider a fixed
      // height (the main axis) but a loose cross axis via a Row.
      await pumpManyApp(
        tester,
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 200,
                child: MDivider(orientation: MDividerOrientation.vertical),
              ),
            ],
          ),
        ),
        viewport: const Size(400, 400),
      );

      final Size size = tester.getSize(find.byType(MDivider));
      expect(size.width, 1);
      expect(size.height, 200);
    });
  });

  group('MDivider color', () {
    testWidgets('uses colors.border on light theme',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const Center(child: SizedBox(width: 200, child: MDivider())),
        theme: theme,
      );

      final ColoredBox box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(MDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, theme.colors.border);
    });

    testWidgets('uses colors.border on dark theme',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.dark();
      await pumpManyApp(
        tester,
        const Center(child: SizedBox(width: 200, child: MDivider())),
        theme: theme,
      );

      final ColoredBox box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(MDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, theme.colors.border);
    });
  });

  group('MDivider style delta', () {
    testWidgets('overrides color and thickness fields',
        (WidgetTester tester) async {
      const Color override = Color(0xFF00FF00);
      await pumpManyApp(
        tester,
        const Center(
          child: SizedBox(
            width: 200,
            child: MDivider(
              style: MDividerStyleDelta(color: override, thickness: 4),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(MDivider)).height, 4);
      final ColoredBox box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(MDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, override);
    });
  });
}
