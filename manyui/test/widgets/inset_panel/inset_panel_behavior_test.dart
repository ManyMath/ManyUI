import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('uses muted background without card border by default', (
    WidgetTester tester,
  ) async {
    final theme = MThemeData.light();
    await pumpManyApp(
      tester,
      const MInsetPanel(child: Text('Recovery phrase')),
      theme: theme,
    );

    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(MInsetPanel),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = box.decoration as BoxDecoration;

    expect(decoration.color, theme.colors.muted);
    expect(decoration.border, isNull);
    expect(decoration.borderRadius, BorderRadius.circular(theme.radius));
  });

  testWidgets('inherits foreground color for text and icons', (
    WidgetTester tester,
  ) async {
    const foreground = Color(0xFF123456);
    await pumpManyApp(
      tester,
      const MInsetPanel(
        foregroundColor: foreground,
        child: Row(children: <Widget>[MIcon(MIconData.check), Text('Ready')]),
      ),
    );

    final textElement = tester.element(find.text('Ready'));
    final DefaultTextStyle textStyle = DefaultTextStyle.of(textElement);
    final iconElement = tester.element(find.byType(CustomPaint));

    expect(textStyle.style.color, foreground);
    expect(IconTheme.of(iconElement).color, foreground);
  });

  testWidgets('allows explicit padding, color, radius, and border', (
    WidgetTester tester,
  ) async {
    const background = Color(0xFFABCDEF);
    const border = Color(0xFF111111);
    const padding = EdgeInsets.all(7);
    const radius = BorderRadius.all(Radius.circular(5));

    await pumpManyApp(
      tester,
      const MInsetPanel(
        padding: padding,
        backgroundColor: background,
        borderColor: border,
        borderWidth: 2,
        radius: radius,
        child: Text('Preview'),
      ),
    );

    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(MInsetPanel),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = box.decoration as BoxDecoration;
    final panelPadding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(MInsetPanel),
        matching: find.byType(Padding),
      ),
    );

    expect(decoration.color, background);
    expect(decoration.borderRadius, radius);
    expect(decoration.border, isNotNull);
    expect((decoration.border! as Border).top.color, border);
    expect((decoration.border! as Border).top.width, 2);
    expect(panelPadding.padding, padding);
  });
}
