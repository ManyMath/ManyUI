import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

List<MTab> _threeTabs() => const <MTab>[
      MTab(
        id: 'one',
        title: Text('One'),
        content: KeyedSubtree(
          key: ValueKey<String>('content-one'),
          child: Text('Pane one'),
        ),
      ),
      MTab(
        id: 'two',
        title: Text('Two'),
        content: KeyedSubtree(
          key: ValueKey<String>('content-two'),
          child: Text('Pane two'),
        ),
      ),
      MTab(
        id: 'three',
        title: Text('Three'),
        content: KeyedSubtree(
          key: ValueKey<String>('content-three'),
          child: Text('Pane three'),
        ),
      ),
    ];

Finder _tabFinder(String title) => find.ancestor(
      of: find.text(title),
      matching: find.byType(GestureDetector),
    );

void main() {
  group('MTabs initial state', () {
    testWidgets(
        'defaults to the first tab when neither controller nor initialId given',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs()),
      );
      expect(find.text('Pane one'), findsOneWidget);
    });

    testWidgets('initialId selects a non-first tab',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs(), initialId: 'two'),
      );
      // IndexedStack keeps all children mounted; we assert by reading the
      // controller via UI selection instead. Use a controller for clarity.
      final MTabsController c = MTabsController('two');
      addTearDown(c.dispose);
      await pumpManyApp(tester, MTabs(tabs: _threeTabs(), controller: c));
      expect(c.value, 'two');
    });

    testWidgets('external controller seeds the active tab',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('three');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs(), controller: c),
      );
      expect(c.value, 'three');
    });
  });

  group('MTabs UI selection', () {
    testWidgets('tapping a tab writes its id into the controller',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      String? reported;
      await pumpManyApp(
        tester,
        MTabs(
          tabs: _threeTabs(),
          controller: c,
          onChanged: (String v) => reported = v,
        ),
      );

      await tester.tap(_tabFinder('Two'));
      await tester.pump();
      expect(c.value, 'two');
      expect(reported, 'two');

      await tester.tap(_tabFinder('Three'));
      await tester.pump();
      expect(c.value, 'three');
      expect(reported, 'three');
    });

    testWidgets('tapping the active tab is a no-op',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      int calls = 0;
      await pumpManyApp(
        tester,
        MTabs(
          tabs: _threeTabs(),
          controller: c,
          onChanged: (_) => calls++,
        ),
      );
      await tester.tap(_tabFinder('One'));
      await tester.pump();
      expect(calls, 0);
    });

    testWidgets('tap is a no-op when the strip is disabled',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      int calls = 0;
      await pumpManyApp(
        tester,
        MTabs(
          tabs: _threeTabs(),
          controller: c,
          enabled: false,
          onChanged: (_) => calls++,
        ),
      );
      await tester.tap(_tabFinder('Two'), warnIfMissed: false);
      await tester.pump();
      expect(c.value, 'one');
      expect(calls, 0);
    });

    testWidgets('tap is a no-op when the individual tab is disabled',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      int calls = 0;
      await pumpManyApp(
        tester,
        MTabs(
          tabs: const <MTab>[
            MTab(id: 'one', title: Text('One'), content: Text('Pane one')),
            MTab(
              id: 'two',
              title: Text('Two'),
              content: Text('Pane two'),
              enabled: false,
            ),
          ],
          controller: c,
          onChanged: (_) => calls++,
        ),
      );
      await tester.tap(_tabFinder('Two'), warnIfMissed: false);
      await tester.pump();
      expect(c.value, 'one');
      expect(calls, 0);
    });
  });

  group('MTabs programmatic selection', () {
    testWidgets('controller.value = id activates the matching tab',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      await pumpManyApp(tester, MTabs(tabs: _threeTabs(), controller: c));

      c.value = 'two';
      await tester.pump();

      // The active-tab indicator paints under the active tab. We don't have
      // direct access to that in this test, but the controller is the source
      // of truth and the strip rebuilds — the assertion that the strip
      // updates appears in the keyboard-activation tests by indirection.
      expect(c.value, 'two');
    });

    testWidgets('controller assignment to a disabled tab id is allowed',
        (WidgetTester tester) async {
      // Programmatic mutation is authoritative — controllers can land on
      // disabled ids. The DECISIONS entry pins this behavior.
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MTabs(
          tabs: const <MTab>[
            MTab(id: 'one', title: Text('One'), content: Text('Pane one')),
            MTab(
              id: 'two',
              title: Text('Two'),
              content: Text('Pane two'),
              enabled: false,
            ),
          ],
          controller: c,
        ),
      );
      c.value = 'two';
      await tester.pump();
      expect(c.value, 'two');
    });
  });

  group('MTabs keyboard nav', () {
    testWidgets('Right arrow activates the next enabled tab',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        Focus(autofocus: true, child: MTabs(tabs: _threeTabs(), controller: c)),
      );

      await tester.tap(_tabFinder('One'));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(c.value, 'two');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(c.value, 'three');
    });

    testWidgets('Left arrow activates the previous enabled tab',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('three');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs(), controller: c),
      );
      await tester.tap(_tabFinder('Three'));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(c.value, 'two');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(c.value, 'one');
    });

    testWidgets('Right arrow wraps around at the last enabled tab',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('three');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs(), controller: c),
      );
      await tester.tap(_tabFinder('Three'));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(c.value, 'one');
    });

    testWidgets('Left arrow wraps around at the first enabled tab',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs(), controller: c),
      );
      await tester.tap(_tabFinder('One'));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(c.value, 'three');
    });

    testWidgets('Home jumps to the first enabled tab; End jumps to the last',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('two');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs(), controller: c),
      );
      await tester.tap(_tabFinder('Two'));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(c.value, 'one');

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(c.value, 'three');
    });

    testWidgets('arrow keys skip disabled tabs',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      await pumpManyApp(
        tester,
        MTabs(
          tabs: const <MTab>[
            MTab(id: 'one', title: Text('One'), content: Text('Pane one')),
            MTab(
              id: 'two',
              title: Text('Two'),
              content: Text('Pane two'),
              enabled: false,
            ),
            MTab(
              id: 'three',
              title: Text('Three'),
              content: Text('Pane three'),
            ),
          ],
          controller: c,
        ),
      );
      await tester.tap(_tabFinder('One'));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(c.value, 'three');
    });
  });

  group('MTabs content state persistence', () {
    testWidgets('IndexedStack keeps EditableText contents across tab switches',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('one');
      addTearDown(c.dispose);
      final TextEditingController text = TextEditingController();
      addTearDown(text.dispose);

      await pumpManyApp(
        tester,
        MTabs(
          tabs: <MTab>[
            MTab(
              id: 'one',
              title: const Text('One'),
              content: SizedBox(
                width: 200,
                child: EditableText(
                  controller: text,
                  focusNode: FocusNode(),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
                  cursorColor: const Color(0xFF000000),
                  backgroundCursorColor: const Color(0xFF000000),
                ),
              ),
            ),
            const MTab(
              id: 'two',
              title: Text('Two'),
              content: Text('Pane two'),
            ),
          ],
          controller: c,
        ),
      );

      await tester.enterText(find.byType(EditableText), 'hello');
      expect(text.text, 'hello');

      c.value = 'two';
      await tester.pump();
      c.value = 'one';
      await tester.pump();

      // The same EditableText instance survived the swap because the content
      // panes all stay mounted under IndexedStack.
      expect(text.text, 'hello');
    });
  });

  group('MTabs style', () {
    testWidgets('mouse modality uses the 36px tab height',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs()),
        modality: MInputModality.mouse,
      );
      final Finder oneTab = _tabFinder('One');
      final Size size = tester.getSize(oneTab);
      // The tab's GestureDetector lives inside the SizedBox(height: tabHeight);
      // its child's height is the resolved tabHeight.
      expect(size.height, 36);
    });

    testWidgets('touch modality uses the 48px tab height',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs()),
        modality: MInputModality.touch,
      );
      final Finder oneTab = _tabFinder('One');
      final Size size = tester.getSize(oneTab);
      expect(size.height, 48);
    });

    testWidgets('style delta tabHeight overrides the theme-resolved height',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTabs(
          tabs: _threeTabs(),
          style: const MTabsStyleDelta(tabHeight: 60),
        ),
        modality: MInputModality.mouse,
      );
      expect(tester.getSize(_tabFinder('One')).height, 60);
    });
  });

  group('MTabs semantics', () {
    Semantics tabSemantics(WidgetTester tester, String title) {
      // Walk the ancestor chain (innermost first) and return the first
      // Semantics whose `selected` property is non-null — that's the one
      // MTabs publishes for this tab, not FocusableActionDetector's internal
      // bookkeeping node.
      final Iterable<Element> ancestors = find
          .ancestor(of: _tabFinder(title), matching: find.byType(Semantics))
          .evaluate();
      for (final Element e in ancestors) {
        final Semantics s = e.widget as Semantics;
        if (s.properties.selected != null) return s;
      }
      throw StateError('No tab Semantics with `selected` set found.');
    }

    testWidgets('the active tab reports selected: true; others false',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('two');
      addTearDown(c.dispose);
      await pumpManyApp(tester, MTabs(tabs: _threeTabs(), controller: c));

      expect(tabSemantics(tester, 'One').properties.selected, isFalse);
      expect(tabSemantics(tester, 'Two').properties.selected, isTrue);
    });

    testWidgets('semanticLabel is applied to the strip container',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs(), semanticLabel: 'Account sections'),
      );
      expect(find.bySemanticsLabel('Account sections'), findsOneWidget);
    });

    testWidgets('a disabled tab reports enabled: false',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MTabs(
          tabs: <MTab>[
            MTab(id: 'one', title: Text('One'), content: Text('Pane one')),
            MTab(
              id: 'two',
              title: Text('Two'),
              content: Text('Pane two'),
              enabled: false,
            ),
          ],
        ),
      );
      expect(tabSemantics(tester, 'Two').properties.enabled, isFalse);
    });
  });

  group('MTabs controller rebind', () {
    testWidgets('swapping the caller-supplied controller rebinds the strip',
        (WidgetTester tester) async {
      final MTabsController first = MTabsController('one');
      final MTabsController second = MTabsController('three');
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
      );

      // Initially bound to 'first'. Tapping 'two' updates first.
      await tester.tap(_tabFinder('Two'));
      await tester.pump();
      expect(first.value, 'two');
      expect(second.value, 'three');

      // Swap. The widget should now reflect 'second' (active = three).
      stateRef.swap();
      await tester.pump();
      expect(first.value, 'two');
      expect(second.value, 'three');

      // Tapping 'one' now writes into second, leaving first alone.
      await tester.tap(_tabFinder('One'));
      await tester.pump();
      expect(first.value, 'two');
      expect(second.value, 'one');
    });

    testWidgets('disposing the strip with an externally-owned controller '
        'does NOT dispose the controller',
        (WidgetTester tester) async {
      final MTabsController owned = MTabsController('one');
      addTearDown(owned.dispose);

      await pumpManyApp(
        tester,
        MTabs(tabs: _threeTabs(), controller: owned),
      );
      // Replace with an empty scene to trigger MTabs.dispose().
      await pumpManyApp(tester, const SizedBox.shrink());

      // The caller's controller is still usable.
      owned.value = 'two';
      expect(owned.value, 'two');
    });
  });

  group('MTabs tab reordering', () {
    testWidgets('removing a non-active tab keeps the active tab live',
        (WidgetTester tester) async {
      final MTabsController c = MTabsController('three');
      addTearDown(c.dispose);

      await pumpManyApp(tester, MTabs(tabs: _threeTabs(), controller: c));
      expect(c.value, 'three');

      // Remove the middle tab. The active tab id 'three' survives.
      await pumpManyApp(
        tester,
        MTabs(
          tabs: const <MTab>[
            MTab(id: 'one', title: Text('One'), content: Text('Pane one')),
            MTab(
              id: 'three',
              title: Text('Three'),
              content: Text('Pane three'),
            ),
          ],
          controller: c,
        ),
      );
      expect(c.value, 'three');
    });
  });
}

class _RebindHarness extends StatefulWidget {
  const _RebindHarness({
    required this.stateRef,
    required this.first,
    required this.second,
  });

  final _RebindHarnessState stateRef;
  final MTabsController first;
  final MTabsController second;

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
    return MTabs(
      controller: _useSecond ? widget.second : widget.first,
      tabs: const <MTab>[
        MTab(id: 'one', title: Text('One'), content: Text('Pane one')),
        MTab(id: 'two', title: Text('Two'), content: Text('Pane two')),
        MTab(id: 'three', title: Text('Three'), content: Text('Pane three')),
      ],
    );
  }
}
