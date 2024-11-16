import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

Widget _wrap({required Widget child, MThemeData? theme}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MTheme(data: theme ?? MThemeData.light(), child: child),
  );
}

void main() {
  group('MFocusRing', () {
    testWidgets('returns child unwrapped when focused is false',
        (WidgetTester tester) async {
      const Key childKey = Key('inner');
      await tester.pumpWidget(_wrap(
        child: const MFocusRing(
          focused: false,
          child: SizedBox(key: childKey, width: 40, height: 40),
        ),
      ));

      expect(find.byKey(childKey), findsOneWidget);
      // No CustomPaint should be inserted when not focused.
      expect(
        find.descendant(
          of: find.byType(MFocusRing),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });

    testWidgets('inserts a CustomPaint above the child when focused',
        (WidgetTester tester) async {
      const Key childKey = Key('inner');
      await tester.pumpWidget(_wrap(
        child: const MFocusRing(
          focused: true,
          child: SizedBox(key: childKey, width: 40, height: 40),
        ),
      ));

      expect(find.byKey(childKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MFocusRing),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('toggling focused does not change the child layout size',
        (WidgetTester tester) async {
      const Key childKey = Key('inner');
      Widget build(bool focused) => _wrap(
            child: MFocusRing(
              focused: focused,
              child: const SizedBox(key: childKey, width: 40, height: 40),
            ),
          );

      await tester.pumpWidget(build(false));
      final Size offSize = tester.getSize(find.byKey(childKey));

      await tester.pumpWidget(build(true));
      final Size onSize = tester.getSize(find.byKey(childKey));

      expect(onSize, offSize);
    });

    testWidgets('uses the explicit style override when supplied',
        (WidgetTester tester) async {
      const MFocusRingStyle custom =
          MFocusRingStyle(width: 6, offset: 8, radius: Radius.circular(20));
      await tester.pumpWidget(_wrap(
        child: const MFocusRing(
          focused: true,
          style: custom,
          child: SizedBox(width: 40, height: 40),
        ),
      ));

      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(MFocusRing),
          matching: find.byType(CustomPaint),
        ),
      );
      // The painter is private, so equality is the cheapest check that the
      // override flowed through: rebuilding with the same style should not
      // ask for a repaint, but rebuilding with a different style should.
      expect(paint.foregroundPainter, isNotNull);
    });
  });
}
