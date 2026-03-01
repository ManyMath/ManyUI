import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MIcon sizing and color', () {
    testWidgets('defaults to 24 and theme foreground when unset', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(tester, const MIcon(MIconData.chevronDown));

      final SizedBox box = tester.widget(
        find.descendant(
          of: find.byType(MIcon),
          matching: find.byType(SizedBox),
        ),
      );
      expect(box.width, 24);
      expect(box.height, 24);
    });

    testWidgets('explicit size overrides the default', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(tester, const MIcon(MIconData.chevronDown, size: 40));

      final SizedBox box = tester.widget(
        find.descendant(
          of: find.byType(MIcon),
          matching: find.byType(SizedBox),
        ),
      );
      expect(box.width, 40);
      expect(box.height, 40);
    });

    testWidgets('inherits size/color from an ancestor IconTheme', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        const IconTheme(
          data: IconThemeData(size: 32, color: Color(0xFF123456)),
          child: MIcon(MIconData.close),
        ),
      );

      final SizedBox box = tester.widget(
        find.descendant(
          of: find.byType(MIcon),
          matching: find.byType(SizedBox),
        ),
      );
      expect(box.width, 32);
    });
  });

  group('MIcon semantics', () {
    testWidgets('defaults to the glyph label', (WidgetTester tester) async {
      await pumpManyApp(tester, const MIcon(MIconData.chevronDown));

      expect(find.bySemanticsLabel('Expand'), findsOneWidget);
    });

    testWidgets('call-site semanticLabel overrides the default', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        const MIcon(MIconData.chevronDown, semanticLabel: 'Show more results'),
      );

      expect(find.bySemanticsLabel('Show more results'), findsOneWidget);
      expect(find.bySemanticsLabel('Expand'), findsNothing);
    });

    testWidgets('eye and eyeOff default to Show/Hide labels', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(tester, const MIcon(MIconData.eye));
      expect(find.bySemanticsLabel('Show'), findsOneWidget);

      await pumpManyApp(tester, const MIcon(MIconData.eyeOff));
      expect(find.bySemanticsLabel('Hide'), findsOneWidget);
    });
  });
}
