import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MButton tap', () {
    testWidgets('fires onPressed when tapped under mouse modality',
        (WidgetTester tester) async {
      int taps = 0;
      await pumpManyApp(
        tester,
        MButton(onPressed: () => taps++, child: const Text('Save')),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('fires onPressed when tapped under touch modality',
        (WidgetTester tester) async {
      int taps = 0;
      await pumpManyApp(
        tester,
        MButton(onPressed: () => taps++, child: const Text('Save')),
        modality: MInputModality.touch,
      );

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('does not fire onPressed when disabled',
        (WidgetTester tester) async {
      const int taps = 0;
      await pumpManyApp(
        tester,
        const MButton(child: Text('Save')),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(taps, 0);
    });
  });

  group('MButton long-press', () {
    testWidgets('fires onLongPress on long-press gesture',
        (WidgetTester tester) async {
      int presses = 0;
      await pumpManyApp(
        tester,
        MButton(
          onPressed: () {},
          onLongPress: () => presses++,
          child: const Text('Save'),
        ),
        modality: MInputModality.touch,
      );

      await tester.longPress(find.text('Save'));
      await tester.pump();
      expect(presses, 1);
    });
  });

  group('MButton keyboard activation', () {
    Future<void> activate(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }

    testWidgets('Enter triggers onPressed when focused',
        (WidgetTester tester) async {
      int taps = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await pumpManyApp(
        tester,
        MButton(
          onPressed: () => taps++,
          focusNode: node,
          autofocus: true,
          child: const Text('Save'),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();
      expect(node.hasFocus, isTrue);

      await activate(tester, LogicalKeyboardKey.enter);
      expect(taps, 1);
    });

    testWidgets('Space triggers onPressed when focused',
        (WidgetTester tester) async {
      int taps = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await pumpManyApp(
        tester,
        MButton(
          onPressed: () => taps++,
          focusNode: node,
          autofocus: true,
          child: const Text('Save'),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await activate(tester, LogicalKeyboardKey.space);
      expect(taps, 1);
    });

    testWidgets('disabled button is skipped by focus traversal',
        (WidgetTester tester) async {
      final FocusNode firstNode = FocusNode(debugLabel: 'first');
      final FocusNode lastNode = FocusNode(debugLabel: 'last');
      addTearDown(firstNode.dispose);
      addTearDown(lastNode.dispose);

      await pumpManyApp(
        tester,
        FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Row(
            children: <Widget>[
              MButton(
                onPressed: () {},
                focusNode: firstNode,
                autofocus: true,
                child: const Text('A'),
              ),
              const MButton(child: Text('disabled')),
              MButton(
                onPressed: () {},
                focusNode: lastNode,
                child: const Text('C'),
              ),
            ],
          ),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();
      expect(firstNode.hasFocus, isTrue);

      // Programmatically traverse forward — focus should jump past the
      // disabled middle button to land on lastNode. (We invoke the traversal
      // policy directly rather than sending a Tab keystroke because the
      // pumpManyApp harness intentionally omits the WidgetsApp Shortcuts
      // defaults that wire Tab to NextFocusIntent — that responsibility
      // belongs to MWidgetsApp, not the per-widget test.)
      firstNode.nextFocus();
      await tester.pump();
      expect(lastNode.hasFocus, isTrue);
    });
  });

  group('MButton hover', () {
    testWidgets('mouse hover swaps to hoverBackgroundColor and reverts',
        (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic;
      });

      const Key buttonKey = Key('btn');
      await pumpManyApp(
        tester,
        Center(
          child: MButton(
            key: buttonKey,
            onPressed: () {},
            child: const Text('Save'),
          ),
        ),
        modality: MInputModality.mouse,
      );

      final DecoratedBox before = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(buttonKey),
          matching: find.byType(DecoratedBox),
        ),
      );
      final Color beforeColor =
          (before.decoration as BoxDecoration).color!;

      // Move a virtual mouse pointer over the button. Start at a corner of
      // the viewport so the enter event fires when the pointer reaches the
      // button — addPointer that already overlaps the target doesn't.
      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: const Offset(1, 1));
      await gesture.moveTo(tester.getCenter(find.byKey(buttonKey)));
      await tester.pumpAndSettle();

      final DecoratedBox during = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(buttonKey),
          matching: find.byType(DecoratedBox),
        ),
      );
      final Color duringColor =
          (during.decoration as BoxDecoration).color!;
      expect(duringColor, isNot(equals(beforeColor)));

      await gesture.moveTo(const Offset(1, 1));
      await tester.pumpAndSettle();

      final DecoratedBox after = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(buttonKey),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((after.decoration as BoxDecoration).color, beforeColor);
    });

    testWidgets('touch modality does not swap to hoverBackgroundColor',
        (WidgetTester tester) async {
      const Key buttonKey = Key('btn');
      await pumpManyApp(
        tester,
        MButton(
          key: buttonKey,
          onPressed: () {},
          child: const Text('Save'),
        ),
        modality: MInputModality.touch,
      );

      final Color before = ((tester
              .widget<DecoratedBox>(find.descendant(
                of: find.byKey(buttonKey),
                matching: find.byType(DecoratedBox),
              ))
              .decoration) as BoxDecoration)
          .color!;

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.byKey(buttonKey)));
      await tester.pumpAndSettle();

      // Even though a real mouse is hovering, the resolved modality is touch
      // so the hover swap stays off.
      final Color during = ((tester
              .widget<DecoratedBox>(find.descendant(
                of: find.byKey(buttonKey),
                matching: find.byType(DecoratedBox),
              ))
              .decoration) as BoxDecoration)
          .color!;
      expect(during, before);
    });
  });

  group('MButton hit-target size', () {
    testWidgets('touch modality renders a taller md button than mouse',
        (WidgetTester tester) async {
      const Key buttonKey = Key('btn');

      Future<double> measure(MInputModality modality) async {
        await pumpManyApp(
          tester,
          Center(
            child: MButton(
              key: buttonKey,
              onPressed: () {},
              child: const Text('Save'),
            ),
          ),
          modality: modality,
        );
        await tester.pump();
        return tester.getSize(find.byKey(buttonKey)).height;
      }

      final double mouseHeight = await measure(MInputModality.mouse);
      final double touchHeight = await measure(MInputModality.touch);
      expect(touchHeight, greaterThan(mouseHeight));
    });
  });

  group('MButton semantics', () {
    testWidgets('reports isButton + isEnabled when onPressed is wired',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpManyApp(
        tester,
        MButton(
          onPressed: () {},
          semanticLabel: 'Save changes',
          child: const Text('Save'),
        ),
        modality: MInputModality.keyboard,
      );

      expect(
        tester.getSemantics(find.byType(MButton)),
        matchesSemantics(
          label: 'Save changes',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('reports !isEnabled when disabled',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpManyApp(
        tester,
        const MButton(
          semanticLabel: 'Save changes',
          child: Text('Save'),
        ),
        modality: MInputModality.keyboard,
      );

      expect(
        tester.getSemantics(find.byType(MButton)),
        matchesSemantics(
          label: 'Save changes',
          isButton: true,
          hasEnabledState: true,
        ),
      );
      handle.dispose();
    });
  });

  group('MButton style delta', () {
    testWidgets('overrides only the supplied fields of the resolved style',
        (WidgetTester tester) async {
      const Key buttonKey = Key('btn');
      const Color override = Color(0xFF00FF00);

      await pumpManyApp(
        tester,
        MButton(
          key: buttonKey,
          onPressed: () {},
          style: const MButtonStyleDelta(backgroundColor: override),
          child: const Text('Save'),
        ),
        modality: MInputModality.mouse,
      );

      final BoxDecoration deco = tester
          .widget<DecoratedBox>(find.descendant(
            of: find.byKey(buttonKey),
            matching: find.byType(DecoratedBox),
          ))
          .decoration as BoxDecoration;
      expect(deco.color, override);
    });
  });

  group('MButton stylus modality', () {
    testWidgets('stylus is hover-capable like mouse',
        (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic;
      });

      const Key buttonKey = Key('btn');
      await pumpManyApp(
        tester,
        MButton(
          key: buttonKey,
          onPressed: () {},
          child: const Text('Save'),
        ),
        modality: MInputModality.stylus,
      );

      final Color before = ((tester
              .widget<DecoratedBox>(find.descendant(
                of: find.byKey(buttonKey),
                matching: find.byType(DecoratedBox),
              ))
              .decoration) as BoxDecoration)
          .color!;

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.byKey(buttonKey)));
      await tester.pumpAndSettle();

      final Color during = ((tester
              .widget<DecoratedBox>(find.descendant(
                of: find.byKey(buttonKey),
                matching: find.byType(DecoratedBox),
              ))
              .decoration) as BoxDecoration)
          .color!;
      expect(during, isNot(equals(before)));
    });
  });
}
