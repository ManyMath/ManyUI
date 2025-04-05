import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

List<MMenuItem> _items({
  List<String>? disabled,
  VoidCallback? onCopy,
  VoidCallback? onCut,
  VoidCallback? onPaste,
}) {
  bool dis(String id) => disabled?.contains(id) ?? false;
  return <MMenuItem>[
    MMenuItem(
      id: 'cut',
      title: const Text('Cut'),
      onTap: onCut,
      enabled: !dis('cut'),
      trailing: const Text('⌘X'),
    ),
    MMenuItem(
      id: 'copy',
      title: const Text('Copy'),
      onTap: onCopy,
      enabled: !dis('copy'),
    ),
    MMenuItem(
      id: 'paste',
      title: const Text('Paste'),
      onTap: onPaste,
      enabled: !dis('paste'),
    ),
  ];
}

/// Builds a target inside an Align so the test has a stable hit-test
/// position no matter the viewport. Returns the controller for the wrapping
/// MContextMenu so tests can read isOpen.
Widget _scene({
  required Key targetKey,
  MPopoverController? controller,
  List<MMenuItem>? items,
  bool enabled = true,
  String? semanticLabel,
}) {
  return Align(
    alignment: Alignment.center,
    child: MContextMenu(
      controller: controller,
      enabled: enabled,
      semanticLabel: semanticLabel,
      items: items ?? _items(),
      child: SizedBox(
        key: targetKey,
        width: 200,
        height: 200,
        child: const Center(child: Text('Target')),
      ),
    ),
  );
}

Future<void> _sendRightClick(WidgetTester tester, Offset globalPosition) async {
  // We construct PointerDown/Up events directly with kSecondaryMouseButton
  // because TestPointer's convenience methods don't expose the buttons mask.
  final TestPointer pointer = TestPointer(
    1,
    PointerDeviceKind.mouse,
    null,
    kSecondaryMouseButton,
  );
  await tester.sendEventToBinding(pointer.hover(globalPosition));
  await tester.sendEventToBinding(pointer.down(globalPosition));
  await tester.sendEventToBinding(pointer.up());
}

void main() {
  group('MContextMenu initial state', () {
    testWidgets('renders the child and no popover until opened',
        (WidgetTester tester) async {
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target),
        installOverlay: true,
      );
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Copy', skipOffstage: false), findsNothing);
      expect(find.text('Paste', skipOffstage: false), findsNothing);
    });

    testWidgets('external controller already-open seeds the menu open',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController()..open();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
      );
      // Two pumps: one for the post-frame portal show, one for the
      // resulting overlay build.
      await tester.pump();
      await tester.pump();
      expect(find.text('Copy', skipOffstage: false), findsOneWidget);
    });
  });

  group('MContextMenu gesture open', () {
    testWidgets('right-click on mouse opens the popover at the pointer',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );

      final Offset center = tester.getCenter(find.byKey(target));
      await _sendRightClick(tester, center);
      await tester.pump();

      expect(c.isOpen, isTrue);
      expect(find.text('Copy', skipOffstage: false), findsOneWidget);
    });

    testWidgets('left-click does NOT open the popover',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await tester.tap(find.byKey(target));
      await tester.pump();
      expect(c.isOpen, isFalse);
    });

    testWidgets('long-press on touch opens the popover at the pointer',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.touch,
      );

      final Offset center = tester.getCenter(find.byKey(target));
      await tester.longPressAt(center);
      await tester.pump();

      expect(c.isOpen, isTrue);
      expect(find.text('Copy', skipOffstage: false), findsOneWidget);
    });

    testWidgets('long-press is ignored under mouse modality',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await tester.longPressAt(tester.getCenter(find.byKey(target)));
      await tester.pump();
      expect(c.isOpen, isFalse);
    });

    testWidgets('right-click on a disabled MContextMenu is a no-op',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c, enabled: false),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();
      expect(c.isOpen, isFalse);
    });
  });

  group('MContextMenu dismiss', () {
    testWidgets('tap on the barrier outside the popover closes the menu',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();
      expect(c.isOpen, isTrue);

      // Tap a corner of the viewport, well outside the popover surface.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(c.isOpen, isFalse);
      expect(find.text('Copy', skipOffstage: false), findsNothing);
    });

    testWidgets('Escape closes the open menu',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();
      // Pump again — the autofocus into the FocusScope is a post-frame.
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(c.isOpen, isFalse);
    });

    testWidgets('right-click on the barrier re-anchors instead of closing',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();
      expect(c.isOpen, isTrue);

      // Right-click somewhere else on the barrier. The menu should stay
      // open (re-anchor); a follow-up left-tap on the barrier should still
      // close it.
      await _sendRightClick(tester, const Offset(10, 10));
      await tester.pump();
      expect(c.isOpen, isTrue);
    });
  });

  group('MContextMenu item activation', () {
    testWidgets('tapping an item invokes its onTap and closes the menu',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      int copyCount = 0;
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(
          targetKey: target,
          controller: c,
          items: _items(onCopy: () => copyCount++),
        ),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();

      await tester.tap(find.text('Copy'));
      await tester.pump();
      expect(copyCount, 1);
      expect(c.isOpen, isFalse);
    });

    testWidgets('tapping a disabled item is a no-op (menu stays open)',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      int copyCount = 0;
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(
          targetKey: target,
          controller: c,
          items: _items(
            disabled: <String>['copy'],
            onCopy: () => copyCount++,
          ),
        ),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();

      await tester.tap(find.text('Copy'), warnIfMissed: false);
      await tester.pump();
      expect(copyCount, 0);
      expect(c.isOpen, isTrue);
    });

    testWidgets('Enter activates the focused item',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      int copyCount = 0;
      int pasteCount = 0;
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(
          targetKey: target,
          controller: c,
          items: _items(
            onCopy: () => copyCount++,
            onPaste: () => pasteCount++,
          ),
        ),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();
      await tester.pump();
      // First item ('Cut') is focused on open. Down twice → 'Paste'.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pasteCount, 1);
      expect(copyCount, 0);
      expect(c.isOpen, isFalse);
    });

    testWidgets('Down/Up skip disabled items with wraparound',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      int pasteCount = 0;
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(
          targetKey: target,
          controller: c,
          items: _items(
            disabled: <String>['copy'],
            onPaste: () => pasteCount++,
          ),
        ),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();
      await tester.pump();
      // First focused = Cut. Down once should skip Copy and land on Paste.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pasteCount, 1);
    });

    testWidgets('Home/End jump to first/last enabled item',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      int pasteCount = 0;
      int cutCount = 0;
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(
          targetKey: target,
          controller: c,
          items: _items(
            onCut: () => cutCount++,
            onPaste: () => pasteCount++,
          ),
        ),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pasteCount, 1);
      expect(cutCount, 0);
    });
  });

  group('MContextMenu programmatic open/close', () {
    testWidgets('controller.open() opens the menu',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
      );
      c.open();
      await tester.pump();
      await tester.pump();
      expect(find.text('Copy', skipOffstage: false), findsOneWidget);
    });

    testWidgets('controller.close() closes the open menu',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await _sendRightClick(tester, tester.getCenter(find.byKey(target)));
      await tester.pump();
      expect(c.isOpen, isTrue);

      c.close();
      await tester.pump();
      expect(find.text('Copy', skipOffstage: false), findsNothing);
    });

    testWidgets('disabling the menu closes an open one',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final _EnabledHarnessState stateRef = _EnabledHarnessState();
      await pumpManyApp(
        tester,
        _EnabledHarness(stateRef: stateRef, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      c.open();
      await tester.pump();
      await tester.pump();
      expect(c.isOpen, isTrue);

      stateRef.disable();
      await tester.pump();
      // The disable handler is deferred to a post-frame callback.
      await tester.pump();
      expect(c.isOpen, isFalse);
    });
  });

  group('MContextMenu positioning', () {
    testWidgets('clamps to the viewport when right-click is near the bottom-'
        'right corner', (WidgetTester tester) async {
      // Wrap the scene in a fixed-size box that matches the viewport we
      // assert against. The layout delegate's `size` argument is the size
      // of the rendered Overlay surface — which in turn is the size of
      // its parent — so without this SizedBox the surface is the full
      // 800×600 test view and the clamp never fires.
      final MPopoverController c = MPopoverController();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: 400,
            height: 400,
            // A locally-scoped Overlay so the MContextMenu's OverlayPortal
            // attaches to it rather than the test view's default Overlay.
            // The layout delegate reads its `size` argument from this
            // overlay's render box — only then will the bottom-right
            // clamp trip at the 400×400 boundary we're asserting against.
            child: Overlay(
              initialEntries: <OverlayEntry>[
                OverlayEntry(
                  builder: (BuildContext _) => MContextMenu(
                    controller: c,
                    items: _items(),
                    child: SizedBox(
                      key: target,
                      width: 400,
                      height: 400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        modality: MInputModality.mouse,
      );
      // Open in the very bottom-right corner of the viewport.
      await _sendRightClick(tester, const Offset(398, 398));
      await tester.pump();
      await tester.pump();

      // The 'Copy' row should be inside the viewport bounds.
      final Offset topLeft = tester.getTopLeft(find.text('Copy'));
      final Offset bottomRight = tester.getBottomRight(find.text('Copy'));
      expect(topLeft.dx, greaterThanOrEqualTo(0));
      expect(topLeft.dy, greaterThanOrEqualTo(0));
      expect(bottomRight.dx, lessThanOrEqualTo(400));
      expect(bottomRight.dy, lessThanOrEqualTo(400));
    });
  });

  group('MContextMenu style', () {
    testWidgets('mouse modality uses the 32px item height',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController()..open();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await tester.pump();
      await tester.pump();
      final Finder copyRow = find.ancestor(
        of: find.text('Copy'),
        matching: find.byType(GestureDetector),
      );
      expect(tester.getSize(copyRow).height, 32);
    });

    testWidgets('touch modality uses the 40px item height',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController()..open();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c),
        installOverlay: true,
        modality: MInputModality.touch,
      );
      await tester.pump();
      await tester.pump();
      final Finder copyRow = find.ancestor(
        of: find.text('Copy'),
        matching: find.byType(GestureDetector),
      );
      expect(tester.getSize(copyRow).height, 40);
    });

    testWidgets('style delta itemHeight overrides the theme-resolved value',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController()..open();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        Align(
          alignment: Alignment.center,
          child: MContextMenu(
            controller: c,
            items: _items(),
            style: const MContextMenuStyleDelta(itemHeight: 48),
            child: SizedBox(
              key: target,
              width: 200,
              height: 200,
              child: const Center(child: Text('Target')),
            ),
          ),
        ),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await tester.pump();
      await tester.pump();
      final Finder copyRow = find.ancestor(
        of: find.text('Copy'),
        matching: find.byType(GestureDetector),
      );
      expect(tester.getSize(copyRow).height, 48);
    });
  });

  group('MContextMenu semantics', () {
    testWidgets('semanticLabel is applied to the popover surface',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController()..open();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: c, semanticLabel: 'Edit menu'),
        installOverlay: true,
      );
      await tester.pump();
      await tester.pump();
      expect(find.bySemanticsLabel('Edit menu'), findsOneWidget);
    });

    testWidgets('disabled item reports enabled: false',
        (WidgetTester tester) async {
      final MPopoverController c = MPopoverController()..open();
      addTearDown(c.dispose);
      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(
          targetKey: target,
          controller: c,
          items: _items(disabled: <String>['copy']),
        ),
        installOverlay: true,
      );
      await tester.pump();
      await tester.pump();
      // Find the item Semantics whose label is 'Copy' and check enabled.
      final Iterable<Element> ancestors = find
          .ancestor(of: find.text('Copy'), matching: find.byType(Semantics))
          .evaluate();
      Semantics? itemSemantics;
      for (final Element e in ancestors) {
        final Semantics s = e.widget as Semantics;
        if (s.properties.button == true) {
          itemSemantics = s;
          break;
        }
      }
      expect(itemSemantics, isNotNull);
      expect(itemSemantics!.properties.enabled, isFalse);
    });
  });

  group('MContextMenu controller rebind', () {
    testWidgets('swapping the caller-supplied controller rebinds the menu',
        (WidgetTester tester) async {
      final MPopoverController first = MPopoverController();
      final MPopoverController second = MPopoverController()..open();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      final _RebindHarnessState stateRef = _RebindHarnessState();
      await pumpManyApp(
        tester,
        _RebindHarness(
          stateRef: stateRef,
          first: first,
          second: second,
        ),
        installOverlay: true,
      );

      expect(first.isOpen, isFalse);
      expect(find.text('Copy', skipOffstage: false), findsNothing);

      stateRef.swap();
      await tester.pump();
      // didUpdateWidget defers the overlay sync to a post-frame callback.
      await tester.pump();
      expect(find.text('Copy', skipOffstage: false), findsOneWidget);
    });

    testWidgets('disposing the menu with an externally-owned controller '
        'does NOT dispose the controller',
        (WidgetTester tester) async {
      final MPopoverController owned = MPopoverController();
      addTearDown(owned.dispose);

      final Key target = UniqueKey();
      await pumpManyApp(
        tester,
        _scene(targetKey: target, controller: owned),
        installOverlay: true,
      );
      await pumpManyApp(tester, const SizedBox.shrink());

      owned.open();
      expect(owned.isOpen, isTrue);
    });
  });
}

class _EnabledHarness extends StatefulWidget {
  const _EnabledHarness({required this.stateRef, required this.controller});
  final _EnabledHarnessState stateRef;
  final MPopoverController controller;

  @override
  State<_EnabledHarness> createState() => _EnabledHarnessStateImpl();
}

class _EnabledHarnessState {
  VoidCallback? _disable;
  void disable() => _disable?.call();
}

class _EnabledHarnessStateImpl extends State<_EnabledHarness> {
  bool _enabled = true;
  final Key _target = UniqueKey();

  @override
  void initState() {
    super.initState();
    widget.stateRef._disable = () => setState(() => _enabled = false);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: MContextMenu(
        controller: widget.controller,
        enabled: _enabled,
        items: _items(),
        child: SizedBox(
          key: _target,
          width: 200,
          height: 200,
          child: const Center(child: Text('Target')),
        ),
      ),
    );
  }
}

class _RebindHarness extends StatefulWidget {
  const _RebindHarness({
    required this.stateRef,
    required this.first,
    required this.second,
  });

  final _RebindHarnessState stateRef;
  final MPopoverController first;
  final MPopoverController second;

  @override
  State<_RebindHarness> createState() => _RebindHarnessStateImpl();
}

class _RebindHarnessState {
  VoidCallback? _swap;
  void swap() => _swap?.call();
}

class _RebindHarnessStateImpl extends State<_RebindHarness> {
  bool _useSecond = false;
  final Key _target = UniqueKey();

  @override
  void initState() {
    super.initState();
    widget.stateRef._swap = () => setState(() => _useSecond = true);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: MContextMenu(
        controller: _useSecond ? widget.second : widget.first,
        items: _items(),
        child: SizedBox(
          key: _target,
          width: 200,
          height: 200,
          child: const Center(child: Text('Target')),
        ),
      ),
    );
  }
}
