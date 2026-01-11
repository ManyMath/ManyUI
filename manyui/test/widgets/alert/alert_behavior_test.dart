import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders title, message, leading, and actions', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      MAlert(
        leading: const MIcon(MIconData.check),
        title: 'Saved',
        message: 'Your changes are stored locally.',
        actions: <Widget>[
          MButton(onPressed: () {}, child: const Text('Dismiss')),
        ],
      ),
    );

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Your changes are stored locally.'), findsOneWidget);
    expect(find.byType(MIcon), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('uses neutral theme colors by default', (
    WidgetTester tester,
  ) async {
    final theme = MThemeData.light();
    await pumpManyApp(tester, const MAlert(message: 'Connected'), theme: theme);

    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(MAlert),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = box.decoration as BoxDecoration;
    final text = tester.widget<Text>(find.text('Connected'));

    expect(decoration.color, theme.colors.muted);
    expect(decoration.border, isNotNull);
    expect(text.style?.color, theme.colors.mutedForeground);
  });

  testWidgets('destructive alerts use destructive colors and live region', (
    WidgetTester tester,
  ) async {
    final theme = MThemeData.light();
    await pumpManyApp(
      tester,
      const MAlert(
        variant: MAlertVariant.destructive,
        title: 'Could not save',
        message: 'Disk is full.',
      ),
      theme: theme,
    );

    final title = tester.widget<Text>(find.text('Could not save'));
    final message = tester.widget<Text>(find.text('Disk is full.'));
    final semantics = tester.widget<Semantics>(
      find
          .descendant(of: find.byType(MAlert), matching: find.byType(Semantics))
          .first,
    );

    expect(title.style?.color, theme.colors.destructive);
    expect(message.style?.color, theme.colors.destructive);
    expect(semantics.properties.liveRegion, isTrue);
  });

  testWidgets('wraps actions at compact widths without overflow', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 190,
          child: MAlert(
            message: 'Could not load rooms.',
            actions: <Widget>[
              MButton(onPressed: () {}, child: const Text('Retry')),
              MButton(onPressed: () {}, child: const Text('Settings')),
            ],
          ),
        ),
      ),
      viewport: const Size(220, 260),
    );

    expect(tester.takeException(), isNull);
    final retryTop = tester.getTopLeft(find.text('Retry')).dy;
    final settingsTop = tester.getTopLeft(find.text('Settings')).dy;
    expect(settingsTop, greaterThan(retryTop));
  });
}
