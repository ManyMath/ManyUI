import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MScaffold rendering', () {
    testWidgets('renders body inside a ColoredBox + SafeArea',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MScaffold(body: Text('Body')),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MScaffold),
          matching: find.byType(ColoredBox),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MScaffold),
          matching: find.byType(SafeArea),
        ),
        findsOneWidget,
      );
    });

    testWidgets('paints theme.colors.background on light theme',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const MScaffold(body: Text('Body')),
        theme: theme,
      );

      final ColoredBox box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(MScaffold),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, theme.colors.background);
    });

    testWidgets('paints theme.colors.background on dark theme',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.dark();
      await pumpManyApp(
        tester,
        const MScaffold(body: Text('Body')),
        theme: theme,
      );

      final ColoredBox box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(MScaffold),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, theme.colors.background);
    });

    testWidgets('omits header slot when null', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MScaffold(body: Text('Body')),
      );
      expect(find.text('Header'), findsNothing);
    });

    testWidgets('omits footer slot when null', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MScaffold(body: Text('Body')),
      );
      expect(find.text('Footer'), findsNothing);
    });

    testWidgets('renders header above body, footer below body',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MScaffold(
          header: Text('Header'),
          body: Center(child: Text('Body')),
          footer: Text('Footer'),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);

      final double headerY = tester.getTopLeft(find.text('Header')).dy;
      final double bodyY = tester.getTopLeft(find.text('Body')).dy;
      final double footerY = tester.getTopLeft(find.text('Footer')).dy;
      expect(headerY, lessThan(bodyY));
      expect(bodyY, lessThan(footerY));
    });
  });

  group('MScaffold style delta', () {
    testWidgets('overrides only the supplied fields',
        (WidgetTester tester) async {
      const Color override = Color(0xFF00FF00);
      await pumpManyApp(
        tester,
        const MScaffold(
          style: MScaffoldStyleDelta(backgroundColor: override),
          body: Text('Body'),
        ),
      );

      final ColoredBox box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(MScaffold),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, override);
    });

    testWidgets('null fields in delta keep the theme values',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const MScaffold(
          style: MScaffoldStyleDelta(headerPadding: EdgeInsets.all(4)),
          body: Text('Body'),
        ),
        theme: theme,
      );

      final ColoredBox box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(MScaffold),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, theme.colors.background);
    });
  });

  group('MScaffold text inheritance', () {
    testWidgets('descendant Text inherits foreground color',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const MScaffold(body: Text('Body')),
        theme: theme,
      );

      final Element textElement = tester.element(find.text('Body'));
      final DefaultTextStyle dts = DefaultTextStyle.of(textElement);
      expect(dts.style.color, theme.colors.foreground);
    });
  });

  group('MScaffold theme registration', () {
    test('default theme exposes a non-null scaffold styles table', () {
      final MThemeData light = MThemeData.light();
      final MThemeData dark = MThemeData.dark();
      expect(light.scaffold, isNotNull);
      expect(dark.scaffold, isNotNull);
    });

    test('copyWith round-trips the scaffold field', () {
      final MThemeData base = MThemeData.light();
      final MThemeData copy = base.copyWith();
      expect(copy.scaffold, base.scaffold);
      expect(copy, base);
    });

    test('resolve returns colors.background and colors.foreground', () {
      final MThemeData theme = MThemeData.light();
      final MScaffoldStyle resolved =
          theme.scaffold.resolve(colors: theme.colors);
      expect(resolved.backgroundColor, theme.colors.background);
      expect(resolved.foregroundColor, theme.colors.foreground);
    });
  });

  group('MScaffoldStyle equality', () {
    test('same fields → equal', () {
      const MScaffoldStyle a = MScaffoldStyle(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Color(0xFFFFFFFF),
        bodyPadding: EdgeInsets.zero,
        headerPadding: EdgeInsets.all(8),
        footerPadding: EdgeInsets.all(8),
      );
      const MScaffoldStyle b = MScaffoldStyle(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Color(0xFFFFFFFF),
        bodyPadding: EdgeInsets.zero,
        headerPadding: EdgeInsets.all(8),
        footerPadding: EdgeInsets.all(8),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('applyDelta(null) returns this', () {
      const MScaffoldStyle a = MScaffoldStyle(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Color(0xFFFFFFFF),
        bodyPadding: EdgeInsets.zero,
        headerPadding: EdgeInsets.all(8),
        footerPadding: EdgeInsets.all(8),
      );
      expect(a.applyDelta(null), same(a));
    });

    test('applyDelta overlays non-null fields only', () {
      const MScaffoldStyle base = MScaffoldStyle(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Color(0xFFFFFFFF),
        bodyPadding: EdgeInsets.zero,
        headerPadding: EdgeInsets.all(8),
        footerPadding: EdgeInsets.all(8),
      );
      const MScaffoldStyleDelta delta = MScaffoldStyleDelta(
        backgroundColor: Color(0xFF00FF00),
      );
      final MScaffoldStyle out = base.applyDelta(delta);
      expect(out.backgroundColor, const Color(0xFF00FF00));
      expect(out.foregroundColor, base.foregroundColor);
      expect(out.headerPadding, base.headerPadding);
    });
  });
}
