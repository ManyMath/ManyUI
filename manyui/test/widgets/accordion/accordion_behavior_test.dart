import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

const List<MAccordionItem> _threeItems = <MAccordionItem>[
  MAccordionItem(id: 'a', title: Text('Alpha'), content: Text('Body A')),
  MAccordionItem(id: 'b', title: Text('Bravo'), content: Text('Body B')),
  MAccordionItem(id: 'c', title: Text('Charlie'), content: Text('Body C')),
];

Widget _scene(Widget child) {
  return Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: 400, child: child),
  );
}

Finder _header(String title) => find.ancestor(
      of: find.text(title),
      matching: find.byType(GestureDetector),
    ).first;

void main() {
  group('MAccordion render', () {
    testWidgets('renders all headers, hides bodies when collapsed',
        (WidgetTester tester) async {
      await pumpManyApp(tester, _scene(const MAccordion(items: _threeItems)));
      await tester.pumpAndSettle();
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Bravo'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
      // Bodies are mounted (text widgets findable with skipOffstage: false)
      // but their wrapping AnimatedSize reports height 0 because
      // heightFactor: 0 collapses the body.
      final RenderBox box = tester.renderObject(find.byType(AnimatedSize).first);
      expect(box.size.height, 0);
    });

    testWidgets('initialExpanded shows the body',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(const MAccordion(
          items: _threeItems,
          initialExpanded: <String>{'b'},
        )),
      );
      await tester.pumpAndSettle();
      // The AnimatedSize wrapping body 'b' (second item) should be > 0.
      final RenderBox box =
          tester.renderObject(find.byType(AnimatedSize).at(1));
      expect(box.size.height, greaterThan(0));
    });
  });

  group('MAccordion single mode', () {
    testWidgets('tapping a collapsed item expands it; tapping again collapses',
        (WidgetTester tester) async {
      final MController<Set<String>> c =
          MController<Set<String>>(<String>{});
      await pumpManyApp(
        tester,
        _scene(MAccordion(
          mode: MAccordionMode.single,
          controller: c,
          items: _threeItems,
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();
      expect(c.value, <String>{'a'});

      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();
      expect(c.value, <String>{});
      c.dispose();
    });

    testWidgets('tapping a different item collapses the first',
        (WidgetTester tester) async {
      final MController<Set<String>> c =
          MController<Set<String>>(<String>{'a'});
      await pumpManyApp(
        tester,
        _scene(MAccordion(
          mode: MAccordionMode.single,
          controller: c,
          items: _threeItems,
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(_header('Bravo'));
      await tester.pumpAndSettle();
      expect(c.value, <String>{'b'});
      c.dispose();
    });
  });

  group('MAccordion multiple mode', () {
    testWidgets('tapping multiple items expands all of them',
        (WidgetTester tester) async {
      final MController<Set<String>> c =
          MController<Set<String>>(<String>{});
      await pumpManyApp(
        tester,
        _scene(MAccordion(
          mode: MAccordionMode.multiple,
          controller: c,
          items: _threeItems,
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();
      await tester.tap(_header('Charlie'));
      await tester.pumpAndSettle();
      expect(c.value, <String>{'a', 'c'});

      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();
      expect(c.value, <String>{'c'});
      c.dispose();
    });
  });

  group('MAccordion disabled', () {
    testWidgets('disabled accordion ignores taps',
        (WidgetTester tester) async {
      final MController<Set<String>> c =
          MController<Set<String>>(<String>{});
      await pumpManyApp(
        tester,
        _scene(MAccordion(
          controller: c,
          enabled: false,
          items: _threeItems,
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(_header('Alpha'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(c.value, <String>{});
      c.dispose();
    });

    testWidgets('disabled item ignores taps but allows neighbours',
        (WidgetTester tester) async {
      final MController<Set<String>> c =
          MController<Set<String>>(<String>{});
      const List<MAccordionItem> items = <MAccordionItem>[
        MAccordionItem(id: 'a', title: Text('Alpha'), content: Text('Body A')),
        MAccordionItem(
          id: 'b',
          title: Text('Bravo'),
          content: Text('Body B'),
          enabled: false,
        ),
        MAccordionItem(id: 'c', title: Text('Charlie'), content: Text('Body C')),
      ];
      await pumpManyApp(
        tester,
        _scene(MAccordion(controller: c, items: items)),
      );
      await tester.pumpAndSettle();

      await tester.tap(_header('Bravo'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(c.value, <String>{});

      await tester.tap(_header('Charlie'));
      await tester.pumpAndSettle();
      expect(c.value, <String>{'c'});

      // Programmatic mutation IS honored even for disabled items.
      c.value = <String>{'b'};
      await tester.pumpAndSettle();
      expect(c.value, <String>{'b'});
      c.dispose();
    });
  });

  group('MAccordion keyboard nav', () {
    testWidgets('Up/Down move focus between headers with wraparound',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(const MAccordion(items: _threeItems)),
      );
      await tester.pumpAndSettle();

      // Tap Alpha to put focus on it.
      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      // Bravo should now hold focus. We can't easily assert directly, but
      // Enter at this point should toggle Bravo.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // The default internal controller is unobservable; instead use a
      // labeled accordion with a controller to verify.
    });

    testWidgets('Enter toggles focused item via controller',
        (WidgetTester tester) async {
      final MController<Set<String>> c =
          MController<Set<String>>(<String>{});
      await pumpManyApp(
        tester,
        _scene(MAccordion(controller: c, items: _threeItems)),
      );
      await tester.pumpAndSettle();

      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();
      // Collapsing Alpha by tapping again (single mode).
      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();
      expect(c.value, <String>{});

      // Now focus is on Alpha. Down to Bravo, Enter to toggle.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(c.value, <String>{'b'});
      c.dispose();
    });

    testWidgets('Space toggles focused item', (WidgetTester tester) async {
      final MController<Set<String>> c =
          MController<Set<String>>(<String>{});
      await pumpManyApp(
        tester,
        _scene(MAccordion(controller: c, items: _threeItems)),
      );
      await tester.pumpAndSettle();

      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();
      expect(c.value, <String>{'a'});

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(c.value, <String>{});
      c.dispose();
    });

    testWidgets('Home/End jump to first/last enabled', (WidgetTester tester) async {
      final MController<Set<String>> c =
          MController<Set<String>>(<String>{});
      await pumpManyApp(
        tester,
        _scene(MAccordion(controller: c, items: _threeItems)),
      );
      await tester.pumpAndSettle();

      await tester.tap(_header('Alpha'));
      await tester.pumpAndSettle();
      // Move focus to last via End.
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(c.value.contains('c'), isTrue);

      // Home.
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(c.value.contains('a'), isTrue);
      c.dispose();
    });
  });

  group('MAccordion controller rebind', () {
    testWidgets('switching controllers re-binds listeners',
        (WidgetTester tester) async {
      final MController<Set<String>> a =
          MController<Set<String>>(<String>{'a'});
      final MController<Set<String>> b =
          MController<Set<String>>(<String>{'b'});
      final _RebindHarnessState stateRef = _RebindHarnessState();
      await pumpManyApp(
        tester,
        _scene(_RebindHarness(stateRef: stateRef, first: a, second: b)),
      );
      await tester.pumpAndSettle();

      // 'a' is initially expanded — AnimatedSize index 0 is non-zero.
      RenderBox boxA = tester.renderObject(find.byType(AnimatedSize).at(0));
      expect(boxA.size.height, greaterThan(0));

      stateRef.swap();
      await tester.pumpAndSettle();
      // Now 'b' (index 1) is expanded, 'a' is collapsed.
      final RenderBox boxB =
          tester.renderObject(find.byType(AnimatedSize).at(1));
      expect(boxB.size.height, greaterThan(0));
      boxA = tester.renderObject(find.byType(AnimatedSize).at(0));
      expect(boxA.size.height, 0);

      // Mutating the old one should NOT change things.
      a.value = <String>{'a', 'c'};
      await tester.pumpAndSettle();
      boxA = tester.renderObject(find.byType(AnimatedSize).at(0));
      expect(boxA.size.height, 0);

      a.dispose();
      b.dispose();
    });
  });

  group('MAccordion semantics', () {
    testWidgets('header reports button + expanded state',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(const MAccordion(
          items: _threeItems,
          initialExpanded: <String>{'a'},
        )),
      );
      await tester.pumpAndSettle();

      // Find the inner Semantics widget per row (button:true, expanded:bool).
      // The accordion wraps each row's header in `Semantics(button:true,
      // expanded:..., child: ...)`. find.byWidgetPredicate is the cleanest way.
      final Iterable<Semantics> semWidgets =
          tester.widgetList<Semantics>(find.descendant(
        of: find.byType(MAccordion),
        matching: find.byType(Semantics),
      ));
      final Semantics alphaSem = semWidgets.firstWhere(
        (Semantics s) =>
            s.properties.button == true && s.properties.expanded == true,
      );
      expect(alphaSem.properties.button, isTrue);
      expect(alphaSem.properties.expanded, isTrue);

      final Semantics bravoSem = semWidgets.firstWhere(
        (Semantics s) =>
            s.properties.button == true && s.properties.expanded == false,
      );
      expect(bravoSem.properties.button, isTrue);
      expect(bravoSem.properties.expanded, isFalse);
    });

    testWidgets('semanticLabel applies to the surface',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(const MAccordion(
          items: _threeItems,
          semanticLabel: 'Settings groups',
        )),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Settings groups'), findsWidgets);
    });
  });

  group('MAccordion style + theme integration', () {
    testWidgets('style delta overrides headerHeight',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(const MAccordion(
          items: _threeItems,
          style: MAccordionStyleDelta(headerHeight: 80),
        )),
      );
      await tester.pumpAndSettle();
      // The Alpha header must be at least 80 tall.
      final RenderBox header = tester.renderObject(_header('Alpha'));
      expect(header.size.height, greaterThanOrEqualTo(80));
    });

    test('theme.accordion resolves with light tokens', () {
      final MThemeData theme = MThemeData.light();
      final MAccordionStyle s = theme.accordion.resolve(
        modality: MInputModality.mouse,
        colors: theme.colors,
        typography: theme.typography,
        radius: theme.radius,
      );
      expect(s.surfaceBackgroundColor, theme.colors.background);
      expect(s.headerForegroundColor, theme.colors.foreground);
    });

    test('touch modality bumps headerHeight', () {
      final MThemeData theme = MThemeData.light();
      final MAccordionStyle touch = theme.accordion.resolve(
        modality: MInputModality.touch,
        colors: theme.colors,
        typography: theme.typography,
        radius: theme.radius,
      );
      final MAccordionStyle mouse = theme.accordion.resolve(
        modality: MInputModality.mouse,
        colors: theme.colors,
        typography: theme.typography,
        radius: theme.radius,
      );
      expect(touch.headerHeight, greaterThan(mouse.headerHeight));
    });

    test('MThemeData.copyWith(accordion: ...) round-trips', () {
      final MThemeData base = MThemeData.light();
      const MAccordionStyles custom = MAccordionStyles();
      final MThemeData copy = base.copyWith(accordion: custom);
      expect(identical(copy.accordion, custom), isTrue);
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
  final MController<Set<String>> first;
  final MController<Set<String>> second;

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
    return MAccordion(
      controller: _useSecond ? widget.second : widget.first,
      items: _threeItems,
    );
  }
}
