import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MListTile rendering', () {
    testWidgets('renders title, subtitle, leading, and trailing', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        const MListTile(
          leading: Text('L'),
          title: Text('Title'),
          subtitle: Text('Subtitle'),
          trailing: Text('T'),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('omits subtitle/leading/trailing when null', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(tester, const MListTile(title: Text('Title only')));

      expect(find.text('Title only'), findsOneWidget);
    });
  });

  group('MListTile interaction', () {
    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      int taps = 0;
      await pumpManyApp(
        tester,
        MListTile(title: const Text('Row'), onTap: () => taps++),
      );

      await tester.tap(find.byType(MListTile));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('has no gesture detector when onTap is null', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(tester, const MListTile(title: Text('Row')));

      expect(
        find.descendant(
          of: find.byType(MListTile),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('exposes button+selected semantics when interactive', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        MListTile(title: const Text('Row'), selected: true, onTap: () {}),
      );

      expect(
        tester.getSemantics(find.byType(MListTile)),
        matchesSemantics(
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
    });
  });

  group('MListTile selected styling', () {
    testWidgets(
      'paints accent background and accentForeground text when selected',
      (WidgetTester tester) async {
        final MThemeData theme = MThemeData.light();
        await pumpManyApp(
          tester,
          const MListTile(title: Text('Row'), selected: true),
          theme: theme,
        );

        final Container container = tester.widget<Container>(
          find.descendant(
            of: find.byType(MListTile),
            matching: find.byType(Container),
          ),
        );
        final BoxDecoration deco = container.decoration! as BoxDecoration;
        expect(deco.color, theme.colors.accent);

        final Element textElement = tester.element(find.text('Row'));
        final DefaultTextStyle dts = DefaultTextStyle.of(textElement);
        expect(dts.style.color, theme.colors.accentForeground);
      },
    );

    testWidgets('unselected row has no accent background', (
      WidgetTester tester,
    ) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const MListTile(title: Text('Row')),
        theme: theme,
      );

      final Container container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MListTile),
          matching: find.byType(Container),
        ),
      );
      final BoxDecoration deco = container.decoration! as BoxDecoration;
      expect(deco.color, isNot(theme.colors.accent));
    });
  });

  group('MListTile style delta', () {
    testWidgets('overrides only the supplied fields', (
      WidgetTester tester,
    ) async {
      const Color override = Color(0xFF00FF00);
      await pumpManyApp(
        tester,
        const MListTile(
          title: Text('Row'),
          selected: true,
          style: MListTileStyleDelta(selectedBackgroundColor: override),
        ),
      );

      final Container container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MListTile),
          matching: find.byType(Container),
        ),
      );
      final BoxDecoration deco = container.decoration! as BoxDecoration;
      expect(deco.color, override);
    });
  });
}
