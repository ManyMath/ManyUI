import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

Widget _sized(Widget child, {double width = 200}) {
  return Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: width, child: child),
  );
}

void main() {
  group('MProgress determinate', () {
    testWidgets('renders at initialValue', (WidgetTester tester) async {
      await pumpManyApp(tester, _sized(const MProgress(initialValue: 0.25)));
      await tester.pumpAndSettle();
      expect(find.byType(MProgress), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('clamps initialValue above max', (WidgetTester tester) async {
      await pumpManyApp(tester, _sized(const MProgress(initialValue: 1.5)));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '100%'),
      );
    });

    testWidgets('clamps below zero', (WidgetTester tester) async {
      await pumpManyApp(tester, _sized(const MProgress(initialValue: -0.5)));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '0%'),
      );
    });

    testWidgets('controller updates rebuild the widget', (WidgetTester tester) async {
      final MController<double> c = MController<double>(0.3);
      await pumpManyApp(tester, _sized(MProgress(controller: c)));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '30%'),
      );

      c.value = 0.7;
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '70%'),
      );
      c.dispose();
    });

    testWidgets('disabled dims surface but keeps semantics value', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(const MProgress(initialValue: 0.4, enabled: false)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Opacity), findsWidgets);
      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '40%'),
      );
    });

    testWidgets('semanticLabel propagates', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(const MProgress(initialValue: 0.5, semanticLabel: 'Upload')),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(label: 'Upload', value: '50%'),
      );
    });

    testWidgets('style delta overrides thickness', (WidgetTester tester) async {
      const MProgressStyleDelta delta = MProgressStyleDelta(thickness: 24);
      await pumpManyApp(
        tester,
        _sized(const MProgress(initialValue: 0.5, style: delta)),
      );
      await tester.pumpAndSettle();
      final RenderBox box = tester.renderObject(find.descendant(
        of: find.byType(MProgress),
        matching: find.byType(CustomPaint),
      ).first);
      expect(box.size.height, 24);
    });

    testWidgets('value tweens between changes (animation runs)', (WidgetTester tester) async {
      final MController<double> c = MController<double>(0.0);
      await pumpManyApp(tester, _sized(MProgress(controller: c)));
      await tester.pumpAndSettle();

      c.value = 1.0;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      c.dispose();
    });
  });

  group('MProgress indeterminate', () {
    testWidgets('mounts and animates', (WidgetTester tester) async {
      await pumpManyApp(tester, _sized(const MProgress.indeterminate()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.hasRunningAnimations, isTrue);
      expect(find.byType(MProgress), findsOneWidget);
      // No semantic value in indeterminate mode.
      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: ''),
      );
    });

    testWidgets('disabled freezes the animation', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(const MProgress.indeterminate(enabled: false)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('custom indeterminateDuration is accepted', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(const MProgress.indeterminate(
          style: MProgressStyleDelta(indeterminateDuration: Duration(seconds: 3)),
        )),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MProgress), findsOneWidget);
    });
  });

  group('MProgress controller rebind', () {
    testWidgets('switching controllers re-binds listeners', (WidgetTester tester) async {
      final MController<double> a = MController<double>(0.2);
      final MController<double> b = MController<double>(0.8);
      final _RebindHarnessState stateRef = _RebindHarnessState();
      await pumpManyApp(
        tester,
        _sized(_RebindHarness(stateRef: stateRef, first: a, second: b)),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '20%'),
      );

      stateRef.swap();
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '80%'),
      );

      // Mutating the old controller should NOT change the widget now.
      a.value = 0.5;
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '80%'),
      );

      // Mutating the new one should.
      b.value = 0.1;
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(MProgress)),
        matchesSemantics(value: '10%'),
      );

      a.dispose();
      b.dispose();
    });
  });

  group('MCircularProgress', () {
    testWidgets('determinate renders at value', (WidgetTester tester) async {
      await pumpManyApp(tester, const MCircularProgress(initialValue: 0.5));
      await tester.pumpAndSettle();
      expect(find.byType(MCircularProgress), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(MCircularProgress)),
        matchesSemantics(value: '50%'),
      );
    });

    testWidgets('controller updates rebuild', (WidgetTester tester) async {
      final MController<double> c = MController<double>(0.1);
      await pumpManyApp(tester, MCircularProgress(controller: c));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(MCircularProgress)),
        matchesSemantics(value: '10%'),
      );

      c.value = 0.9;
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(MCircularProgress)),
        matchesSemantics(value: '90%'),
      );
      c.dispose();
    });

    testWidgets('indeterminate mounts and animates', (WidgetTester tester) async {
      await pumpManyApp(tester, const MCircularProgress.indeterminate());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('disabled freezes indeterminate', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MCircularProgress.indeterminate(enabled: false),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('style delta overrides diameter', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(
          child: MCircularProgress(
            initialValue: 0.5,
            style: MProgressStyleDelta(diameter: 64),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final RenderBox box = tester.renderObject(find.descendant(
        of: find.byType(MCircularProgress),
        matching: find.byType(SizedBox),
      ).first);
      expect(box.size.width, 64);
      expect(box.size.height, 64);
    });
  });

  group('MProgress theme integration', () {
    test('theme.progress resolves with primary on light', () {
      final MThemeData theme = MThemeData.light();
      final MProgressStyle style = theme.progress.resolve(colors: theme.colors);
      expect(style.valueColor, theme.colors.primary);
      expect(style.trackColor, theme.colors.muted);
    });

    test('MThemeData.copyWith(progress: ...) round-trips', () {
      final MThemeData base = MThemeData.light();
      const MProgressStyles custom = MProgressStyles();
      final MThemeData copy = base.copyWith(progress: custom);
      expect(identical(copy.progress, custom), isTrue);
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
  final MController<double> first;
  final MController<double> second;

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
    return MProgress(
      controller: _useSecond ? widget.second : widget.first,
    );
  }
}
