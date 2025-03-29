import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

List<MMenu> _menus({
  List<String>? disabled,
  VoidCallback? onFileNew,
  VoidCallback? onFileOpen,
  VoidCallback? onEditUndo,
}) {
  bool dis(String id) => disabled?.contains(id) ?? false;
  return <MMenu>[
    MMenu(
      id: 'file',
      title: const Text('File'),
      enabled: !dis('file'),
      items: <MMenuItem>[
        MMenuItem(
          id: 'new',
          title: const Text('New'),
          onTap: onFileNew,
          enabled: !dis('file.new'),
        ),
        MMenuItem(
          id: 'open',
          title: const Text('Open'),
          onTap: onFileOpen,
          enabled: !dis('file.open'),
          trailing: const Text('⌘O'),
        ),
        MMenuItem(
          id: 'save',
          title: const Text('Save'),
          enabled: !dis('file.save'),
        ),
      ],
    ),
    MMenu(
      id: 'edit',
      title: const Text('Edit'),
      enabled: !dis('edit'),
      items: <MMenuItem>[
        MMenuItem(
          id: 'undo',
          title: const Text('Undo'),
          onTap: onEditUndo,
          enabled: !dis('edit.undo'),
        ),
        MMenuItem(
          id: 'redo',
          title: const Text('Redo'),
          enabled: !dis('edit.redo'),
        ),
      ],
    ),
    MMenu(
      id: 'view',
      title: const Text('View'),
      enabled: !dis('view'),
      items: const <MMenuItem>[
        MMenuItem(id: 'zoom-in', title: Text('Zoom In')),
        MMenuItem(id: 'zoom-out', title: Text('Zoom Out')),
      ],
    ),
  ];
}

Finder _titleFinder(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(GestureDetector),
    );

void main() {
  group('MMenuBar initial state', () {
    testWidgets('defaults to closed (no menu open)',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus()),
        installOverlay: true,
      );
      expect(find.text('File'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      // No popover items visible until a menu opens.
      expect(find.text('New', skipOffstage: false), findsNothing);
      expect(find.text('Undo', skipOffstage: false), findsNothing);
    });

    testWidgets('external controller seeded with an id opens that menu',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('edit');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      await tester.pump();
      expect(find.text('Undo', skipOffstage: false), findsOneWidget);
      expect(find.text('Redo', skipOffstage: false), findsOneWidget);
      expect(find.text('New', skipOffstage: false), findsNothing);
    });
  });

  group('MMenuBar UI open/close', () {
    testWidgets('tapping a title opens that menu and reports onChanged',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      String? reported = 'initial-sentinel';
      await pumpManyApp(
        tester,
        MMenuBar(
          menus: _menus(),
          controller: c,
          onChanged: (String? v) => reported = v,
        ),
        installOverlay: true,
      );

      await tester.tap(_titleFinder('File'));
      await tester.pump();
      expect(c.value, 'file');
      expect(reported, 'file');
      expect(find.text('New', skipOffstage: false), findsOneWidget);
    });

    testWidgets('tapping the open title again closes it',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      await tester.pump();

      await tester.tap(_titleFinder('File'));
      await tester.pump();
      expect(c.value, isNull);
      expect(find.text('New', skipOffstage: false), findsNothing);
    });

    testWidgets('tap on a different title swaps which menu is open',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      await tester.pump();
      expect(find.text('New', skipOffstage: false), findsOneWidget);

      await tester.tap(_titleFinder('Edit'));
      await tester.pump();
      expect(c.value, 'edit');
      expect(find.text('Undo', skipOffstage: false), findsOneWidget);
      expect(find.text('New', skipOffstage: false), findsNothing);
    });

    testWidgets('hover over a sibling title swaps which menu is open',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      await tester.pump();

      final TestPointer pointer =
          TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(_titleFinder('Edit'))),
      );
      await tester.pump();
      expect(c.value, 'edit');
    });

    testWidgets('hover does NOT open a closed menu bar',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      final TestPointer pointer =
          TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(_titleFinder('Edit'))),
      );
      await tester.pump();
      expect(c.value, isNull);
    });

    testWidgets('tap on disabled title is a no-op',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      int calls = 0;
      await pumpManyApp(
        tester,
        MMenuBar(
          menus: _menus(disabled: <String>['edit']),
          controller: c,
          onChanged: (_) => calls++,
        ),
        installOverlay: true,
      );
      await tester.tap(_titleFinder('Edit'), warnIfMissed: false);
      await tester.pump();
      expect(c.value, isNull);
      expect(calls, 0);
    });

    testWidgets('disabling the bar closes the open menu',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      final _EnabledHarnessState stateRef = _EnabledHarnessState();
      await pumpManyApp(
        tester,
        _EnabledHarness(stateRef: stateRef, controller: c),
        installOverlay: true,
      );
      await tester.pump();
      expect(c.value, 'file');

      stateRef.disable();
      await tester.pump();
      // The disable handler is deferred to a post-frame callback (so it can
      // hide the overlay portal outside the build phase). Pump again to
      // observe the resulting controller change.
      await tester.pump();
      expect(c.value, isNull);
    });
  });

  group('MMenuBar programmatic open/close', () {
    testWidgets('controller.value = id opens that menu',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      c.value = 'view';
      await tester.pump();
      expect(find.text('Zoom In', skipOffstage: false), findsOneWidget);
    });

    testWidgets('controller.value = null closes any open menu',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      await tester.pump();
      expect(find.text('New', skipOffstage: false), findsOneWidget);

      c.value = null;
      await tester.pump();
      expect(find.text('New', skipOffstage: false), findsNothing);
    });
  });

  group('MMenuBar item activation', () {
    testWidgets('tapping an item invokes its onTap and closes the menu',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      int newCount = 0;
      await pumpManyApp(
        tester,
        MMenuBar(
          menus: _menus(onFileNew: () => newCount++),
          controller: c,
        ),
        installOverlay: true,
      );
      await tester.pump();

      await tester.tap(find.text('New'));
      await tester.pump();
      expect(newCount, 1);
      expect(c.value, isNull);
    });

    testWidgets('tapping a disabled item is a no-op (menu stays open)',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      int newCount = 0;
      await pumpManyApp(
        tester,
        MMenuBar(
          menus: _menus(
            disabled: <String>['file.new'],
            onFileNew: () => newCount++,
          ),
          controller: c,
        ),
        installOverlay: true,
      );
      await tester.pump();

      await tester.tap(find.text('New'), warnIfMissed: false);
      await tester.pump();
      expect(newCount, 0);
      expect(c.value, 'file');
    });
  });

  group('MMenuBar keyboard nav (title strip)', () {
    testWidgets('Right arrow with no menu open cycles title focus through '
        'enabled menus', (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      // Tab into the strip.
      await tester.tap(_titleFinder('File'));
      await tester.pump();
      // Tap also toggled-open File. Close it so we test pure strip nav.
      await tester.tap(_titleFinder('File'));
      await tester.pump();
      expect(c.value, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      // Focus is now on Edit. Strip is still closed (no menu open).
      expect(c.value, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // Down opens the focused menu.
      expect(c.value, 'edit');
    });

    testWidgets('with a menu open, Right/Left arrows swap the open menu',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      await tester.tap(_titleFinder('File'));
      await tester.pump();
      expect(c.value, 'file');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(c.value, 'edit');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(c.value, 'view');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      // Wrap.
      expect(c.value, 'file');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(c.value, 'view');
    });

    testWidgets('Left/Right skip disabled menus',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(
          menus: _menus(disabled: <String>['edit']),
          controller: c,
        ),
        installOverlay: true,
      );
      await tester.tap(_titleFinder('File'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(c.value, 'view');
    });

    testWidgets('Down arrow on a focused (closed) menu title opens it',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      // Focus File via tap-then-toggle-closed.
      await tester.tap(_titleFinder('File'));
      await tester.pump();
      await tester.tap(_titleFinder('File'));
      await tester.pump();
      expect(c.value, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(c.value, 'file');
    });

    testWidgets('Enter on a focused title opens the menu',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController();
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      // Use tab/click trick: tap to focus, tap to close.
      await tester.tap(_titleFinder('File'));
      await tester.pump();
      await tester.tap(_titleFinder('File'));
      await tester.pump();
      expect(c.value, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(c.value, 'file');
    });
  });

  group('MMenuBar keyboard nav (inside open popover)', () {
    testWidgets('Escape closes the open menu and returns focus to its title',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      await tester.pump();
      // The overlay autofocus is disabled — Escape needs to dispatch through
      // the popover's FocusScope. The Tab-into-popover flow seeds focus
      // there; without that, Escape can't reach the popover's onKeyEvent.
      // We simulate the post-Down state by triggering Down on the focused
      // title.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // Now focus is on the popover scope (the title got focus on tap).
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(c.value, isNull);
    });

    testWidgets('Down/Up inside an open menu navigate enabled items',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      int newCount = 0;
      int openCount = 0;
      await pumpManyApp(
        tester,
        MMenuBar(
          menus: _menus(
            onFileNew: () => newCount++,
            onFileOpen: () => openCount++,
          ),
          controller: c,
        ),
        installOverlay: true,
      );
      await tester.pump();

      // Press Down once on the title — focus the first item.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Down again — focus the second item.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Enter activates the second item ('Open').
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(openCount, 1);
      expect(newCount, 0);
      expect(c.value, isNull);
    });

    testWidgets('Down skips disabled items inside the open menu',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('file');
      addTearDown(c.dispose);
      int saveCount = 0;
      await pumpManyApp(
        tester,
        MMenuBar(
          menus: <MMenu>[
            MMenu(
              id: 'file',
              title: const Text('File'),
              items: <MMenuItem>[
                const MMenuItem(id: 'new', title: Text('New')),
                const MMenuItem(
                  id: 'open',
                  title: Text('Open'),
                  enabled: false,
                ),
                MMenuItem(
                  id: 'save',
                  title: const Text('Save'),
                  onTap: () => saveCount++,
                ),
              ],
            ),
          ],
          controller: c,
        ),
        installOverlay: true,
      );
      await tester.pump();

      // Open and focus first ('New'): one Down.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // Skip 'Open' (disabled) and land on 'Save': one Down.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(saveCount, 1);
    });
  });

  group('MMenuBar style', () {
    testWidgets('mouse modality uses the 32px title height',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus()),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      final Size size = tester.getSize(_titleFinder('File'));
      expect(size.height, 32);
    });

    testWidgets('touch modality uses the 44px title height',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus()),
        installOverlay: true,
        modality: MInputModality.touch,
      );
      final Size size = tester.getSize(_titleFinder('File'));
      expect(size.height, 44);
    });

    testWidgets('style delta titleHeight overrides the theme-resolved height',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MMenuBar(
          menus: _menus(),
          style: const MMenuBarStyleDelta(titleHeight: 50),
        ),
        installOverlay: true,
        modality: MInputModality.mouse,
      );
      expect(tester.getSize(_titleFinder('File')).height, 50);
    });
  });

  group('MMenuBar semantics', () {
    Semantics titleSemantics(WidgetTester tester, String label) {
      final Iterable<Element> ancestors = find
          .ancestor(of: _titleFinder(label), matching: find.byType(Semantics))
          .evaluate();
      for (final Element e in ancestors) {
        final Semantics s = e.widget as Semantics;
        if (s.properties.expanded != null) return s;
      }
      throw StateError('No menu-title Semantics with `expanded` set found.');
    }

    testWidgets('open title reports expanded: true; closed ones false',
        (WidgetTester tester) async {
      final MMenuBarController c = MMenuBarController('edit');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: c),
        installOverlay: true,
      );
      await tester.pump();
      expect(titleSemantics(tester, 'File').properties.expanded, isFalse);
      expect(titleSemantics(tester, 'Edit').properties.expanded, isTrue);
    });

    testWidgets('semanticLabel is applied to the bar container',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), semanticLabel: 'Main menu'),
        installOverlay: true,
      );
      expect(find.bySemanticsLabel('Main menu'), findsOneWidget);
    });

    testWidgets('disabled title reports enabled: false',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(disabled: <String>['edit'])),
        installOverlay: true,
      );
      expect(titleSemantics(tester, 'Edit').properties.enabled, isFalse);
    });
  });

  group('MMenuBar controller rebind', () {
    testWidgets('swapping the caller-supplied controller rebinds the bar',
        (WidgetTester tester) async {
      final MMenuBarController first = MMenuBarController();
      final MMenuBarController second = MMenuBarController('edit');
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

      await tester.tap(_titleFinder('File'));
      await tester.pump();
      expect(first.value, 'file');
      expect(second.value, 'edit');

      stateRef.swap();
      await tester.pump();
      // Deferred-sync needs a second pump for the overlay portal show/hide.
      await tester.pump();
      // After swap, the bar reflects `second` (open menu = edit).
      expect(find.text('Undo', skipOffstage: false), findsOneWidget);

      // Tapping View now writes into second; first is untouched.
      await tester.tap(_titleFinder('View'));
      await tester.pump();
      expect(first.value, 'file');
      expect(second.value, 'view');
    });

    testWidgets('disposing the bar with an externally-owned controller '
        'does NOT dispose the controller',
        (WidgetTester tester) async {
      final MMenuBarController owned = MMenuBarController('file');
      addTearDown(owned.dispose);

      await pumpManyApp(
        tester,
        MMenuBar(menus: _menus(), controller: owned),
        installOverlay: true,
      );
      await pumpManyApp(tester, const SizedBox.shrink());

      owned.value = 'edit';
      expect(owned.value, 'edit');
    });
  });
}

class _EnabledHarness extends StatefulWidget {
  const _EnabledHarness({required this.stateRef, required this.controller});
  final _EnabledHarnessState stateRef;
  final MMenuBarController controller;

  @override
  State<_EnabledHarness> createState() => _EnabledHarnessStateImpl();
}

class _EnabledHarnessState {
  VoidCallback? _disable;
  void disable() => _disable?.call();
}

class _EnabledHarnessStateImpl extends State<_EnabledHarness> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    widget.stateRef._disable = () => setState(() => _enabled = false);
  }

  @override
  Widget build(BuildContext context) {
    return MMenuBar(
      menus: _menus(),
      controller: widget.controller,
      enabled: _enabled,
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
  final MMenuBarController first;
  final MMenuBarController second;

  @override
  State<_RebindHarness> createState() => _RebindHarnessStateImpl();
}

class _RebindHarnessState {
  VoidCallback? _swap;
  void swap() => _swap?.call();
}

class _RebindHarnessStateImpl extends State<_RebindHarness> {
  bool _useSecond = false;

  @override
  void initState() {
    super.initState();
    widget.stateRef._swap = () => setState(() => _useSecond = true);
  }

  @override
  Widget build(BuildContext context) {
    return MMenuBar(
      controller: _useSecond ? widget.second : widget.first,
      menus: _menus(),
    );
  }
}
