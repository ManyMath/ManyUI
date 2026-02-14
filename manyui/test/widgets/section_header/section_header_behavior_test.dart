import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders title, description, status, leading, and actions', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const MSectionHeader(
        title: 'Status',
        description: 'Node health and identity.',
        leading: SizedBox(key: ValueKey<String>('leading'), width: 24),
        status: MBadge(child: Text('Online')),
        actions: <Widget>[MButton(child: Text('Refresh'))],
      ),
    );

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Node health and identity.'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('leading')), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('wide layout keeps status and actions beside title block', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const SizedBox(
        width: 720,
        child: MSectionHeader(
          title: 'Embedded runtime',
          description: 'Embedded UDP host is listening.',
          compactBreakpoint: 0,
          status: MBadge(
            key: ValueKey<String>('status'),
            child: Text('Running'),
          ),
          actions: <Widget>[
            MButton(
              key: ValueKey<String>('action'),
              size: MButtonSize.sm,
              child: Text('Stop'),
            ),
          ],
        ),
      ),
    );

    final titleRight = tester.getTopRight(find.text('Embedded runtime')).dx;
    final statusLeft = tester
        .getTopLeft(find.byKey(const ValueKey<String>('status')))
        .dx;
    final actionLeft = tester
        .getTopLeft(find.byKey(const ValueKey<String>('action')))
        .dx;

    expect(statusLeft, greaterThan(titleRight));
    expect(actionLeft, greaterThan(statusLeft));
  });

  testWidgets('compact layout stacks status and actions below title block', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const SizedBox(
        width: 260,
        child: MSectionHeader(
          title: 'Embedded runtime',
          description: 'Embedded UDP host is listening.',
          compactBreakpoint: 1000,
          status: MBadge(
            key: ValueKey<String>('status'),
            child: Text('Running'),
          ),
          actions: <Widget>[
            MButton(
              key: ValueKey<String>('action'),
              size: MButtonSize.sm,
              child: Text('Stop'),
            ),
          ],
        ),
      ),
    );

    final descriptionBottom = tester
        .getBottomLeft(find.text('Embedded UDP host is listening.'))
        .dy;
    final statusTop = tester
        .getTopLeft(find.byKey(const ValueKey<String>('status')))
        .dy;
    final actionTop = tester
        .getTopLeft(find.byKey(const ValueKey<String>('action')))
        .dy;

    expect(statusTop, greaterThan(descriptionBottom));
    expect(actionTop, greaterThan(statusTop));
  });

  testWidgets('uses headline title style and muted description by default', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const MSectionHeader(
        title: 'Peers',
        description: 'Peers appear after discovery.',
      ),
    );

    final theme = MTheme.of(tester.element(find.text('Peers')));
    final Text title = tester.widget(find.text('Peers'));
    final Text description = tester.widget(
      find.text('Peers appear after discovery.'),
    );

    expect(title.style?.fontSize, theme.typography.headlineSmall.fontSize);
    expect(description.style?.color, theme.colors.mutedForeground);
  });
}
