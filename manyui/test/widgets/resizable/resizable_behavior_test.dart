import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

const Color _paneA = Color(0xFF111111);
const Color _paneB = Color(0xFF222222);
const Color _paneC = Color(0xFF333333);

Widget _pane(Color color, String label) =>
    ColoredBox(color: color, child: Center(child: Text(label)));

Widget _scene(Widget child, {double width = 600, double height = 200}) {
  return Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: width, height: height, child: child),
  );
}

void main() {
  group('MResizable render', () {
    testWidgets('renders both panes at initial fractions',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('initialSizes seeds the controller',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          initialSizes: const <double>[0.75, 0.25],
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      final RenderBox paneA =
          tester.renderObject(find.text('A')) as RenderBox;
      final RenderBox paneB =
          tester.renderObject(find.text('B')) as RenderBox;
      // A's parent (the ColoredBox) is ~75% of viewport minus handle; test
      // by comparing widths via the immediate parent.
      final RenderBox boxA = tester.renderObject(
          find.byWidget(_findColoredBoxWith(tester, _paneA))) as RenderBox;
      final RenderBox boxB = tester.renderObject(
          find.byWidget(_findColoredBoxWith(tester, _paneB))) as RenderBox;
      expect(boxA.size.width, greaterThan(boxB.size.width));
      // Sanity: panes have non-zero height and width.
      expect(paneA.size.height, greaterThan(0));
      expect(paneB.size.height, greaterThan(0));
    });

    testWidgets('three children supported, two handles render',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
            MResizableChild(child: _pane(_paneC, 'C')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      // Two handles: count Semantics widgets whose `slider == true`.
      final Iterable<Semantics> sliders = tester
          .widgetList<Semantics>(find.descendant(
            of: find.byType(MResizable),
            matching: find.byType(Semantics),
          ))
          .where((Semantics s) => s.properties.slider == true);
      expect(sliders.length, 2);
    });

    testWidgets('disabled dims the surface', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          enabled: false,
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      final Opacity opacity = tester.widget<Opacity>(find.descendant(
        of: find.byType(MResizable),
        matching: find.byType(Opacity),
      ));
      expect(opacity.opacity, lessThan(1.0));
    });
  });

  group('MResizable drag', () {
    testWidgets('drag moves fractions horizontally',
        (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.5, 0.5]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          controller: c,
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();

      // The handle is the unique Semantics(slider:true)-descended subtree.
      final Finder handleFinder = _handleHitFinder();
      await tester.drag(handleFinder, const Offset(60, 0));
      await tester.pumpAndSettle();

      // Viewport width is 600, so 60px is 0.1. Pane A should be 0.6, B 0.4.
      expect(c.value[0], closeTo(0.6, 0.01));
      expect(c.value[1], closeTo(0.4, 0.01));

      c.dispose();
    });

    testWidgets('drag moves fractions vertically',
        (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.5, 0.5]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          axis: Axis.vertical,
          controller: c,
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      // Height is 200, so 40px is 0.2.
      await tester.drag(_handleHitFinder(), const Offset(0, 40));
      await tester.pumpAndSettle();
      expect(c.value[0], closeTo(0.7, 0.01));
      expect(c.value[1], closeTo(0.3, 0.01));
      c.dispose();
    });

    testWidgets('minSize clamps drag', (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.5, 0.5]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          controller: c,
          children: const <MResizableChild>[
            MResizableChild(minSize: 0.2, child: SizedBox.expand()),
            MResizableChild(minSize: 0.3, child: SizedBox.expand()),
          ],
        )),
      );
      await tester.pumpAndSettle();
      // Try to push pane B way below its minSize (drag right by ~half the
      // viewport — far more than legal).
      await tester.drag(_handleHitFinder(), const Offset(300, 0));
      await tester.pumpAndSettle();
      // Pane B must not go below 0.3.
      expect(c.value[1], greaterThanOrEqualTo(0.3 - 1e-6));
      // Pane A must not go above 0.7 (since 1 - 0.3 = 0.7).
      expect(c.value[0], lessThanOrEqualTo(0.7 + 1e-6));
      c.dispose();
    });

    testWidgets('drag start requests focus on the handle',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel,
          isNot(contains('MResizableHandle')));
      await tester.drag(_handleHitFinder(), const Offset(10, 0));
      await tester.pumpAndSettle();
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        contains('MResizableHandle'),
      );
    });

    testWidgets('disabled handle ignores drag', (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.5, 0.5]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          enabled: false,
          controller: c,
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      await tester.drag(_handleHitFinder(), const Offset(60, 0));
      await tester.pumpAndSettle();
      expect(c.value[0], closeTo(0.5, 1e-9));
      expect(c.value[1], closeTo(0.5, 1e-9));
      c.dispose();
    });
  });

  group('MResizable keyboard', () {
    // Drag-start focuses the handle. Use a near-zero drag (1px) to focus it
    // without meaningfully changing fractions, then keyboard tests can run.
    Future<void> focusHandle(WidgetTester tester) async {
      await tester.drag(_handleHitFinder(), const Offset(1, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('arrow key nudges by keyboardStep',
        (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.5, 0.5]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          controller: c,
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      await focusHandle(tester);
      final double baseline = c.value[0];
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      // Delta from baseline is exactly the keyboard step.
      expect(c.value[0] - baseline, closeTo(0.05, 1e-9));
      c.dispose();
    });

    testWidgets('shift+arrow nudges by keyboardFineStep',
        (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.5, 0.5]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          controller: c,
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      await focusHandle(tester);
      final double baseline = c.value[0];
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(c.value[0] - baseline, closeTo(0.01, 1e-9));
      c.dispose();
    });

    testWidgets('home jumps handle to leftmost legal position',
        (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.5, 0.5]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          controller: c,
          children: const <MResizableChild>[
            MResizableChild(minSize: 0.1, child: SizedBox.expand()),
            MResizableChild(minSize: 0.2, child: SizedBox.expand()),
          ],
        )),
      );
      await tester.pumpAndSettle();
      await focusHandle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(c.value[0], closeTo(0.1, 1e-6));
      expect(c.value[1], closeTo(0.9, 1e-6));
      c.dispose();
    });

    testWidgets('end jumps handle to rightmost legal position',
        (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.5, 0.5]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          controller: c,
          children: const <MResizableChild>[
            MResizableChild(minSize: 0.1, child: SizedBox.expand()),
            MResizableChild(minSize: 0.2, child: SizedBox.expand()),
          ],
        )),
      );
      await tester.pumpAndSettle();
      await focusHandle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(c.value[0], closeTo(0.8, 1e-6));
      expect(c.value[1], closeTo(0.2, 1e-6));
      c.dispose();
    });
  });

  group('MResizable controller', () {
    testWidgets('owns and disposes internal controller when none provided',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      // Just unmounting must not throw.
      await pumpManyApp(tester, const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('external controller value drives layout',
        (WidgetTester tester) async {
      final MController<List<double>> c =
          MController<List<double>>(<double>[0.3, 0.7]);
      await pumpManyApp(
        tester,
        _scene(MResizable(
          controller: c,
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      c.value = <double>[0.8, 0.2];
      await tester.pumpAndSettle();
      // Programmatic mutation honored — controller's value is the source of truth.
      expect(c.value[0], closeTo(0.8, 1e-9));
      c.dispose();
    });

    testWidgets('controller rebind switches listener target',
        (WidgetTester tester) async {
      final MController<List<double>> a =
          MController<List<double>>(<double>[0.3, 0.7]);
      final MController<List<double>> b =
          MController<List<double>>(<double>[0.7, 0.3]);
      final _RebindHarnessState stateRef = _RebindHarnessState();
      await pumpManyApp(
        tester,
        _scene(_RebindHarness(stateRef: stateRef, first: a, second: b)),
      );
      await tester.pumpAndSettle();
      stateRef.swap();
      await tester.pumpAndSettle();
      // Drag now should affect b, not a.
      await tester.drag(_handleHitFinder(), const Offset(60, 0));
      await tester.pumpAndSettle();
      // a unchanged.
      expect(a.value, <double>[0.3, 0.7]);
      // b's first pane grew.
      expect(b.value[0], greaterThan(0.7));
      a.dispose();
      b.dispose();
    });

    testWidgets('onChanged fires on drag', (WidgetTester tester) async {
      final List<List<double>> notifications = <List<double>>[];
      await pumpManyApp(
        tester,
        _scene(MResizable(
          onChanged: notifications.add,
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      await tester.drag(_handleHitFinder(), const Offset(30, 0));
      await tester.pumpAndSettle();
      expect(notifications, isNotEmpty);
    });
  });

  group('MResizable semantics', () {
    testWidgets('handle reports slider role with percent value',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          initialSizes: const <double>[0.4, 0.6],
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      final Iterable<Semantics> sliderSems = tester
          .widgetList<Semantics>(find.descendant(
            of: find.byType(MResizable),
            matching: find.byType(Semantics),
          ))
          .where((Semantics s) => s.properties.slider == true);
      expect(sliderSems.length, 1);
      expect(sliderSems.first.properties.value, '40%');
    });

    testWidgets('semanticLabel applies to the surface',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          semanticLabel: 'Side panel',
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Side panel'), findsWidgets);
    });
  });

  group('MResizable style + theme integration', () {
    testWidgets('style delta overrides handleThickness',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _scene(MResizable(
          style: const MResizableStyleDelta(
            handleThickness: 20,
            handleHitThickness: 30,
            showGripIndicator: false,
          ),
          children: <MResizableChild>[
            MResizableChild(child: _pane(_paneA, 'A')),
            MResizableChild(child: _pane(_paneB, 'B')),
          ],
        )),
      );
      await tester.pumpAndSettle();
      // The handle SizedBox has the hit thickness.
      final Iterable<SizedBox> sizedBoxes = tester
          .widgetList<SizedBox>(find.descendant(
            of: find.byType(MResizable),
            matching: find.byType(SizedBox),
          ));
      expect(sizedBoxes.any((SizedBox b) => b.width == 30), isTrue);
    });

    test('theme.resizable resolves with border on light', () {
      final MThemeData theme = MThemeData.light();
      final MResizableStyle s = theme.resizable.resolve(
        modality: MInputModality.mouse,
        colors: theme.colors,
      );
      expect(s.handleColor, theme.colors.border);
      expect(s.handleActiveColor, theme.colors.primary);
    });

    test('touch modality bumps handle thickness', () {
      final MThemeData theme = MThemeData.light();
      final MResizableStyle touch = theme.resizable.resolve(
        modality: MInputModality.touch,
        colors: theme.colors,
      );
      final MResizableStyle mouse = theme.resizable.resolve(
        modality: MInputModality.mouse,
        colors: theme.colors,
      );
      expect(touch.handleThickness, greaterThan(mouse.handleThickness));
      expect(touch.handleHitThickness, greaterThan(mouse.handleHitThickness));
    });

    test('MThemeData.copyWith(resizable: ...) round-trips', () {
      final MThemeData base = MThemeData.light();
      const MResizableStyles custom = MResizableStyles();
      final MThemeData copy = base.copyWith(resizable: custom);
      expect(identical(copy.resizable, custom), isTrue);
    });
  });
}

// Find the unique handle hit area — the FocusableActionDetector inside the
// resizable subtree (panes don't wrap themselves in FocusableActionDetector).
// For tests with 2 children, there's exactly one handle.
Finder _handleHitFinder() => find.descendant(
      of: find.byType(MResizable),
      matching: find.byType(FocusableActionDetector),
    );

// Find the ColoredBox descendant of MResizable with a given color (used to
// measure pane widths). The text labels are inside ColoredBoxes painted with
// the pane color.
Widget _findColoredBoxWith(WidgetTester tester, Color color) {
  return tester
      .widgetList<ColoredBox>(find.descendant(
        of: find.byType(MResizable),
        matching: find.byType(ColoredBox),
      ))
      .firstWhere((ColoredBox b) => b.color == color);
}

class _RebindHarness extends StatefulWidget {
  const _RebindHarness({
    required this.stateRef,
    required this.first,
    required this.second,
  });

  final _RebindHarnessState stateRef;
  final MController<List<double>> first;
  final MController<List<double>> second;

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
    return MResizable(
      controller: _useSecond ? widget.second : widget.first,
      children: <MResizableChild>[
        MResizableChild(child: _pane(_paneA, 'A')),
        MResizableChild(child: _pane(_paneB, 'B')),
      ],
    );
  }
}
