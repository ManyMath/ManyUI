import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

/// A minimal builder that paints a fixed-size box and records the latest
/// [MPressableStates] it was handed, so tests can assert on the state stream.
Widget _box(MPressableStates states) {
  return const SizedBox(width: 80, height: 40);
}

void main() {
  group('MPressable tap', () {
    testWidgets('tap fires onPressed', (WidgetTester tester) async {
      int taps = 0;
      await pumpManyApp(
        tester,
        MPressable(
          onPressed: () => taps++,
          builder: (BuildContext context, MPressableStates states) =>
              _box(states),
        ),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MPressable));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('long-press fires onLongPress', (WidgetTester tester) async {
      int presses = 0;
      await pumpManyApp(
        tester,
        MPressable(
          onLongPress: () => presses++,
          builder: (BuildContext context, MPressableStates states) =>
              _box(states),
        ),
        modality: MInputModality.touch,
      );

      await tester.longPress(find.byType(MPressable));
      await tester.pump();
      expect(presses, 1);
    });
  });

  group('MPressable disabled', () {
    testWidgets('no callbacks ⇒ disabled, taps are no-ops, cursor is basic',
        (WidgetTester tester) async {
      MPressableStates? seen;
      await pumpManyApp(
        tester,
        MPressable(
          builder: (BuildContext context, MPressableStates states) {
            seen = states;
            return _box(states);
          },
        ),
        modality: MInputModality.mouse,
      );

      expect(seen!.disabled, isTrue);
      expect(seen!.hovered, isFalse);
      expect(seen!.focused, isFalse);
      expect(seen!.pressed, isFalse);

      // Taps are no-ops (nothing to fire); the gesture still misses cleanly.
      await tester.tap(find.byType(MPressable), warnIfMissed: false);
      await tester.pump();

      final MouseRegion region = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.byType(MPressable),
              matching: find.byType(MouseRegion),
            )
            .first,
      );
      expect(region.cursor, SystemMouseCursors.basic);
    });

    testWidgets('enabled pressable shows the click cursor',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MPressable(
          onPressed: () {},
          builder: (BuildContext context, MPressableStates states) =>
              _box(states),
        ),
        modality: MInputModality.mouse,
      );

      final MouseRegion region = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.byType(MPressable),
              matching: find.byType(MouseRegion),
            )
            .first,
      );
      expect(region.cursor, SystemMouseCursors.click);
    });
  });

  group('MPressable keyboard', () {
    Future<void> pumpFocused(
      WidgetTester tester,
      FocusNode node,
      VoidCallback onPressed,
    ) async {
      await pumpManyApp(
        tester,
        MPressable(
          onPressed: onPressed,
          focusNode: node,
          autofocus: true,
          builder: (BuildContext context, MPressableStates states) =>
              _box(states),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();
      expect(node.hasFocus, isTrue);
    }

    testWidgets('Enter fires onPressed', (WidgetTester tester) async {
      int taps = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await pumpFocused(tester, node, () => taps++);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('NumpadEnter fires onPressed', (WidgetTester tester) async {
      int taps = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await pumpFocused(tester, node, () => taps++);

      await tester.sendKeyEvent(LogicalKeyboardKey.numpadEnter);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('Space fires onPressed', (WidgetTester tester) async {
      int taps = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await pumpFocused(tester, node, () => taps++);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('MPressable hover gating', () {
    testWidgets('mouse modality sets states.hovered on hover',
        (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic;
      });

      MPressableStates? seen;
      const Key key = Key('p');
      await pumpManyApp(
        tester,
        Center(
          child: MPressable(
            key: key,
            onPressed: () {},
            builder: (BuildContext context, MPressableStates states) {
              seen = states;
              return _box(states);
            },
          ),
        ),
        modality: MInputModality.mouse,
      );
      expect(seen!.hovered, isFalse);

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: const Offset(1, 1));
      await gesture.moveTo(tester.getCenter(find.byKey(key)));
      await tester.pumpAndSettle();

      expect(seen!.hovered, isTrue);
    });

    testWidgets('touch modality leaves states.hovered false',
        (WidgetTester tester) async {
      MPressableStates? seen;
      const Key key = Key('p');
      await pumpManyApp(
        tester,
        Center(
          child: MPressable(
            key: key,
            onPressed: () {},
            builder: (BuildContext context, MPressableStates states) {
              seen = states;
              return _box(states);
            },
          ),
        ),
        modality: MInputModality.touch,
      );

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.byKey(key)));
      await tester.pumpAndSettle();

      // A real mouse is hovering, but the resolved modality is touch so the
      // hover flag stays off.
      expect(seen!.hovered, isFalse);
    });
  });

  group('MPressable pressed', () {
    testWidgets('pressed toggles true on tap-down and false on tap-up',
        (WidgetTester tester) async {
      final List<bool> pressedLog = <bool>[];
      const Key key = Key('p');
      await pumpManyApp(
        tester,
        Center(
          child: MPressable(
            key: key,
            onPressed: () {},
            builder: (BuildContext context, MPressableStates states) {
              pressedLog.add(states.pressed);
              return _box(states);
            },
          ),
        ),
        modality: MInputModality.mouse,
      );

      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.byKey(key)));
      await tester.pump();
      expect(pressedLog.last, isTrue);

      await gesture.up();
      await tester.pump();
      expect(pressedLog.last, isFalse);
    });

    testWidgets('pressed resets to false on tap-cancel',
        (WidgetTester tester) async {
      final List<bool> pressedLog = <bool>[];
      const Key key = Key('p');
      await pumpManyApp(
        tester,
        Center(
          child: MPressable(
            key: key,
            onPressed: () {},
            builder: (BuildContext context, MPressableStates states) {
              pressedLog.add(states.pressed);
              return _box(states);
            },
          ),
        ),
        modality: MInputModality.mouse,
      );

      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.byKey(key)));
      await tester.pump();
      expect(pressedLog.last, isTrue);

      // Drag far off the surface so the tap is cancelled rather than completed.
      await gesture.moveBy(const Offset(400, 400));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(pressedLog.last, isFalse);
    });
  });

  group('MPressable focus ring', () {
    testWidgets('present when focused and includeFocusRing is true',
        (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic;
      });

      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await pumpManyApp(
        tester,
        MPressable(
          onPressed: () {},
          focusNode: node,
          autofocus: true,
          builder: (BuildContext context, MPressableStates states) =>
              _box(states),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      final MFocusRing ring = tester.widget<MFocusRing>(
        find.descendant(
          of: find.byType(MPressable),
          matching: find.byType(MFocusRing),
        ),
      );
      expect(ring.focused, isTrue);
    });

    testWidgets('absent when includeFocusRing is false',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await pumpManyApp(
        tester,
        MPressable(
          onPressed: () {},
          focusNode: node,
          autofocus: true,
          includeFocusRing: false,
          builder: (BuildContext context, MPressableStates states) =>
              _box(states),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(MPressable),
          matching: find.byType(MFocusRing),
        ),
        findsNothing,
      );
    });
  });
}
