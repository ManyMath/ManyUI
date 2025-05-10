import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

Widget _anchor({Key? key, String label = 'Open'}) {
  return SizedBox(
    key: key,
    width: 120,
    height: 36,
    child: Center(child: Text(label)),
  );
}

Widget _content({String text = 'Popover body'}) {
  return SizedBox(
    width: 200,
    height: 80,
    child: Center(child: Text(text)),
  );
}

void main() {
  group('MPopover open/close', () {
    testWidgets('controller.open shows the popover surface',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      expect(find.text('Popover body'), findsNothing);
      c.open();
      await tester.pump();
      expect(find.text('Popover body'), findsOneWidget);
    });

    testWidgets('controller.close hides the popover',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      expect(find.text('Popover body'), findsOneWidget);

      c.close();
      await tester.pump();
      expect(find.text('Popover body'), findsNothing);
    });

    testWidgets('controller.toggle alternates state',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.toggle();
      await tester.pump();
      expect(c.isOpen, isTrue);
      expect(find.text('Popover body'), findsOneWidget);

      c.toggle();
      await tester.pump();
      expect(c.isOpen, isFalse);
      expect(find.text('Popover body'), findsNothing);
    });

    testWidgets('tapping the anchor toggles when controller is internal',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(key: const ValueKey<String>('a')),
          ),
        ),
        installOverlay: true,
      );

      expect(find.text('Popover body'), findsNothing);
      await tester.tap(find.byKey(const ValueKey<String>('a')));
      await tester.pump();
      expect(find.text('Popover body'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('a')));
      await tester.pump();
      expect(find.text('Popover body'), findsNothing);
    });

    testWidgets('content callback close() dismisses the popover',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            popoverBuilder: (BuildContext context, VoidCallback close) {
              return GestureDetector(
                onTap: close,
                child: const SizedBox(
                  width: 100,
                  height: 50,
                  child: Center(child: Text('Done')),
                ),
              );
            },
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(find.text('Done'), findsNothing);
      expect(c.isOpen, isFalse);
    });
  });

  group('MPopover dismiss', () {
    testWidgets('outside tap closes the popover',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      expect(find.text('Popover body'), findsOneWidget);

      // Tap on the modal barrier (top-left corner is well outside any content).
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.text('Popover body'), findsNothing);
      expect(c.isOpen, isFalse);
    });

    testWidgets('Escape closes the popover', (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      expect(find.text('Popover body'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('Popover body'), findsNothing);
      expect(c.isOpen, isFalse);
    });

    testWidgets('onClose fires on outside-tap close',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      int closeCount = 0;

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            onClose: () => closeCount++,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(closeCount, 1);
    });

    testWidgets('onClose fires on programmatic close',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      int closeCount = 0;

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            onClose: () => closeCount++,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      c.close();
      await tester.pump();
      expect(closeCount, 1);
    });
  });

  group('MPopover onKeyEvent', () {
    testWidgets('caller onKeyEvent receives keys before default handling',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      LogicalKeyboardKey? seenKey;

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            onKeyEvent: (FocusNode node, KeyEvent event) {
              if (event is KeyDownEvent) {
                seenKey = event.logicalKey;
              }
              return KeyEventResult.ignored;
            },
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(seenKey, LogicalKeyboardKey.arrowDown);
      // ArrowDown wasn't claimed by caller — popover should still be open.
      expect(c.isOpen, isTrue);
    });

    testWidgets('caller returning handled blocks default Escape close',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            onKeyEvent: (FocusNode node, KeyEvent event) =>
                KeyEventResult.handled,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(c.isOpen, isTrue,
          reason: 'caller-handled key should suppress default Escape close');
    });
  });

  group('MPopover semantics', () {
    testWidgets('expanded reflects open state', (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            semanticLabel: 'Filters',
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      Semantics root = tester.widget(find
          .descendant(
            of: find.byType(MPopover),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(root.properties.expanded, false);
      expect(root.properties.label, 'Filters');

      c.open();
      await tester.pump();

      root = tester.widget(find
          .descendant(
            of: find.byType(MPopover),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(root.properties.expanded, true);
    });
  });

  group('MPopover style', () {
    testWidgets('applyDelta overrides padding on the surface',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            style: const MPopoverStyleDelta(
              padding: EdgeInsets.all(24),
            ),
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();

      // The Padding inside the popover surface — find one whose padding
      // matches the delta to confirm the override threaded through.
      final Iterable<Padding> paddings = tester.widgetList<Padding>(
        find.byType(Padding),
      );
      final bool anyMatch = paddings.any((Padding p) =>
          p.padding == const EdgeInsets.all(24));
      expect(anyMatch, isTrue);
    });
  });

  group('MPopover controller rebind', () {
    testWidgets('swapping the external controller picks up its state',
        (WidgetTester tester) async {
      final MPopoverController initial = MPopoverController();
      addTearDown(initial.dispose);
      final MPopoverController replacement = MPopoverController()..open();
      addTearDown(replacement.dispose);

      final _RebindHarnessState ref = _RebindHarnessState();
      await pumpManyApp(
        tester,
        Center(
          child: _RebindHarness(
            stateRef: ref,
            initial: initial,
            replacement: replacement,
          ),
        ),
        installOverlay: true,
      );

      expect(find.text('Popover body'), findsNothing);
      ref.swap();
      // didUpdateWidget defers the controller-sync to a post-frame callback,
      // so pump once for the swap frame and once more for the deferred open.
      await tester.pump();
      await tester.pump();
      expect(find.text('Popover body'), findsOneWidget,
          reason: 'rebind should pick up replacement controller open state');
    });
  });

  group('MPopover dispose', () {
    testWidgets('disposing while open releases resources without throwing',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: MPopover(
            controller: c,
            popoverBuilder: (BuildContext context, VoidCallback close) =>
                _content(),
            child: _anchor(),
          ),
        ),
        installOverlay: true,
      );

      c.open();
      await tester.pump();
      // Replace the tree entirely so MPopover is disposed mid-open.
      await pumpManyApp(tester, const Center(child: SizedBox.shrink()));
      await tester.pump();
      // No exception = pass.
    });
  });
}

class _RebindHarness extends StatefulWidget {
  const _RebindHarness({
    required this.stateRef,
    required this.initial,
    required this.replacement,
  });

  final _RebindHarnessState stateRef;
  final MPopoverController initial;
  final MPopoverController replacement;

  @override
  State<_RebindHarness> createState() => _RebindHarnessStateProxy();
}

class _RebindHarnessState {
  late VoidCallback _swap;
  void swap() => _swap();
}

class _RebindHarnessStateProxy extends State<_RebindHarness> {
  bool _swapped = false;

  @override
  void initState() {
    super.initState();
    widget.stateRef._swap = () => setState(() => _swapped = true);
  }

  @override
  Widget build(BuildContext context) {
    return MPopover(
      controller: _swapped ? widget.replacement : widget.initial,
      popoverBuilder: (BuildContext context, VoidCallback close) {
        return const SizedBox(
          width: 200,
          height: 80,
          child: Center(child: Text('Popover body')),
        );
      },
      child: const SizedBox(width: 120, height: 36),
    );
  }
}
