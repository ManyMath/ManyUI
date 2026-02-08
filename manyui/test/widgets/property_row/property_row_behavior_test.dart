import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders label, value, description, and trailing', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const MPropertyRow(
        label: 'Server',
        value: Text('https://example.org'),
        description: 'Used for sync.',
        trailing: Text('Edit'),
      ),
    );

    expect(find.text('Server'), findsOneWidget);
    expect(find.text('https://example.org'), findsOneWidget);
    expect(find.text('Used for sync.'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('wide stacked layout keeps trailing beside content', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const SizedBox(
        width: 640,
        child: MPropertyRow(
          label: 'Theme',
          compactBreakpoint: 0,
          description: 'Controls app color mode.',
          trailing: SizedBox(
            key: ValueKey<String>('control'),
            width: 80,
            height: 24,
          ),
        ),
      ),
    );

    final contentRight = tester.getTopRight(find.text('Theme')).dx;
    final controlLeft = tester
        .getTopLeft(find.byKey(const ValueKey<String>('control')))
        .dx;
    expect(controlLeft, greaterThan(contentRight));
  });

  testWidgets('compact stacked layout moves trailing below content', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const SizedBox(
        width: 240,
        child: MPropertyRow(
          label: 'Theme',
          compactBreakpoint: 1000,
          description: 'Controls app color mode.',
          trailing: SizedBox(
            key: ValueKey<String>('control'),
            width: 80,
            height: 24,
          ),
        ),
      ),
    );

    final labelBottom = tester.getBottomLeft(find.text('Theme')).dy;
    final controlTop = tester
        .getTopLeft(find.byKey(const ValueKey<String>('control')))
        .dy;
    expect(controlTop, greaterThan(labelBottom));
  });

  testWidgets('inline layout places label and value on the same row', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const SizedBox(
        width: 640,
        child: MPropertyRow(
          label: 'Version',
          value: Text('1.2.3'),
          layout: MPropertyRowLayout.inline,
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('Version')).dy,
      closeTo(tester.getTopLeft(find.text('1.2.3')).dy, 1),
    );
    expect(
      tester.getTopRight(find.text('Version')).dx,
      lessThanOrEqualTo(tester.getTopLeft(find.text('1.2.3')).dx),
    );
  });

  testWidgets('padding expands the row bounds', (WidgetTester tester) async {
    await pumpManyApp(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: MPropertyRow(
          padding: EdgeInsets.all(16),
          label: 'Name',
          value: SizedBox(
            key: ValueKey<String>('value'),
            width: 20,
            height: 20,
          ),
        ),
      ),
    );

    expect(tester.getTopLeft(find.text('Name')).dx, closeTo(16, 0.5));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('value'))).dx,
      closeTo(16, 0.5),
    );
  });
}
