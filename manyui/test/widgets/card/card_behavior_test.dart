import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MCard rendering', () {
    testWidgets('renders child inside a DecoratedBox + Padding',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MCard(child: Text('Body')),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MCard),
          matching: find.byType(DecoratedBox),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MCard),
          matching: find.byType(Padding),
        ),
        findsOneWidget,
      );
    });

    testWidgets('paints theme.colors.card on light theme',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const MCard(child: Text('Body')),
        theme: theme,
      );

      final BoxDecoration deco = tester
          .widget<DecoratedBox>(find.descendant(
            of: find.byType(MCard),
            matching: find.byType(DecoratedBox),
          ))
          .decoration as BoxDecoration;
      expect(deco.color, theme.colors.card);
      expect(deco.border, isNotNull);
    });

    testWidgets('paints theme.colors.card on dark theme',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.dark();
      await pumpManyApp(
        tester,
        const MCard(child: Text('Body')),
        theme: theme,
      );

      final BoxDecoration deco = tester
          .widget<DecoratedBox>(find.descendant(
            of: find.byType(MCard),
            matching: find.byType(DecoratedBox),
          ))
          .decoration as BoxDecoration;
      expect(deco.color, theme.colors.card);
    });
  });

  group('MCard style delta', () {
    testWidgets('overrides only the supplied fields',
        (WidgetTester tester) async {
      const Color override = Color(0xFF00FF00);
      await pumpManyApp(
        tester,
        const MCard(
          style: MCardStyleDelta(backgroundColor: override),
          child: Text('Body'),
        ),
      );

      final BoxDecoration deco = tester
          .widget<DecoratedBox>(find.descendant(
            of: find.byType(MCard),
            matching: find.byType(DecoratedBox),
          ))
          .decoration as BoxDecoration;
      expect(deco.color, override);
      // Border still comes from the theme — only backgroundColor was overridden.
      expect(deco.border, isNotNull);
    });

    testWidgets('null borderColor in delta keeps the theme border',
        (WidgetTester tester) async {
      // Sanity-check the "null means inherit" contract: the delta below sets
      // only padding, so the border should remain from the resolved style.
      await pumpManyApp(
        tester,
        const MCard(
          style: MCardStyleDelta(padding: EdgeInsets.all(4)),
          child: Text('Body'),
        ),
      );

      final BoxDecoration deco = tester
          .widget<DecoratedBox>(find.descendant(
            of: find.byType(MCard),
            matching: find.byType(DecoratedBox),
          ))
          .decoration as BoxDecoration;
      expect(deco.border, isNotNull);
    });
  });

  group('MCard text inheritance', () {
    testWidgets('descendant Text inherits cardForeground color',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const MCard(child: Text('Body')),
        theme: theme,
      );

      // Look up the closest DefaultTextStyle to the Text — it should carry
      // the cardForeground color the card merged on top.
      final Element textElement = tester.element(find.text('Body'));
      final DefaultTextStyle dts = DefaultTextStyle.of(textElement);
      expect(dts.style.color, theme.colors.cardForeground);
    });
  });
}
