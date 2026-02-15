import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders action children', (WidgetTester tester) async {
    await pumpManyApp(
      tester,
      MActionRow(
        children: <Widget>[
          MButton(onPressed: () {}, child: const Text('Cancel')),
          MButton(onPressed: () {}, child: const Text('Save')),
        ],
      ),
    );

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('aligns actions to the trailing edge by default', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 240,
          child: MActionRow(
            children: <Widget>[
              SizedBox(key: ValueKey<String>('action'), width: 40, height: 20),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('action'))).dx,
      greaterThan(190),
    );
  });

  testWidgets('wraps at compact widths without overflow', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 128,
          child: MActionRow(
            children: <Widget>[
              MButton(onPressed: () {}, child: const Text('Stay here')),
              MButton(onPressed: () {}, child: const Text('Leave now')),
            ],
          ),
        ),
      ),
      viewport: const Size(180, 240),
    );

    expect(tester.takeException(), isNull);
    final double cancelTop = tester.getTopLeft(find.text('Stay here')).dy;
    final double confirmTop = tester.getTopLeft(find.text('Leave now')).dy;
    expect(confirmTop, greaterThan(cancelTop));
  });
}
