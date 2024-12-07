import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

BoxDecoration _decoOf(WidgetTester tester) =>
    tester
        .widget<DecoratedBox>(find.descendant(
          of: find.byType(MBadge),
          matching: find.byType(DecoratedBox),
        ))
        .decoration as BoxDecoration;

void main() {
  group('MBadge rendering', () {
    testWidgets('renders child Text', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(child: MBadge(child: Text('Beta'))),
      );
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('primary variant paints colors.primary',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const Center(child: MBadge(child: Text('Beta'))),
        theme: theme,
      );
      expect(_decoOf(tester).color, theme.colors.primary);
    });

    testWidgets('secondary variant paints colors.secondary',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const Center(
          child: MBadge(
            variant: MBadgeVariant.secondary,
            child: Text('Beta'),
          ),
        ),
        theme: theme,
      );
      expect(_decoOf(tester).color, theme.colors.secondary);
    });

    testWidgets('destructive variant paints colors.destructive',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const Center(
          child: MBadge(
            variant: MBadgeVariant.destructive,
            child: Text('Beta'),
          ),
        ),
        theme: theme,
      );
      expect(_decoOf(tester).color, theme.colors.destructive);
    });

    testWidgets('outline variant has transparent fill and a border',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const Center(
          child: MBadge(
            variant: MBadgeVariant.outline,
            child: Text('Beta'),
          ),
        ),
        theme: theme,
      );
      final BoxDecoration deco = _decoOf(tester);
      expect(deco.color, const Color(0x00000000));
      expect(deco.border, isNotNull);
    });
  });

  group('MBadge sizing', () {
    testWidgets('sizes itself to its content, not the parent',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(child: MBadge(child: Text('Beta'))),
        viewport: const Size(400, 400),
      );

      final Size size = tester.getSize(find.byType(MBadge));
      // Anything below 200 means it's not stretching to the viewport.
      expect(size.width, lessThan(200));
      expect(size.height, lessThan(80));
    });
  });

  group('MBadge style delta', () {
    testWidgets('overrides only the supplied fields',
        (WidgetTester tester) async {
      const Color override = Color(0xFF00FF00);
      await pumpManyApp(
        tester,
        const Center(
          child: MBadge(
            style: MBadgeStyleDelta(backgroundColor: override),
            child: Text('Beta'),
          ),
        ),
      );
      expect(_decoOf(tester).color, override);
    });
  });
}
