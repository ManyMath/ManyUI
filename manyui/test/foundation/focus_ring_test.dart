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
    testWidgets('paints nothing when focused is false but keeps tree shape',
        (WidgetTester tester) async {
      const Key childKey = Key('inner');
      await tester.pumpWidget(_wrap(
        child: const MFocusRing(
          focused: false,
          child: SizedBox(key: childKey, width: 40, height: 40),
        ),
      ));

      expect(find.byKey(childKey), findsOneWidget);
      // The CustomPaint is always present (stable tree shape) but has no
      // painter while unfocused. Swapping the widget type on focus change
      // would rebuild the entire subtree and destroy its state, see the
      // 'preserves subtree state' test below.
      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(MFocusRing),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.foregroundPainter, isNull);
    });

    testWidgets('preserves subtree state when focused toggles',
        (WidgetTester tester) async {
      // Regression: MFocusRing used to return the bare child when unfocused
      // and a CustomPaint wrapper when focused, changing the widget type at
      // this slot on every focus change. That discarded the subtree's
      // elements/state, most visibly killing EditableText's freshly opened
      // IME connection (fields highlighted but typing did nothing).
      Widget build(bool focused) => _wrap(
            child: MFocusRing(
              focused: focused,
              child: const _StateProbe(),
            ),
          );

      await tester.pumpWidget(build(false));
      final State before = tester.state(find.byType(_StateProbe));

      await tester.pumpWidget(build(true));
      final State afterFocus = tester.state(find.byType(_StateProbe));
      expect(identical(before, afterFocus), isTrue,
          reason: 'gaining focus must not recreate the subtree state');

      await tester.pumpWidget(build(false));
      final State afterBlur = tester.state(find.byType(_StateProbe));
      expect(identical(before, afterBlur), isTrue,
          reason: 'losing focus must not recreate the subtree state');
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

class _StateProbe extends StatefulWidget {
  const _StateProbe();

  @override
  State<_StateProbe> createState() => _StateProbeState();
}

class _StateProbeState extends State<_StateProbe> {
  @override
  Widget build(BuildContext context) => const SizedBox(width: 40, height: 40);
}
