import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

const Duration _kShowDelay = Duration(milliseconds: 500);
const Duration _kHideDelay = Duration(milliseconds: 0);
const Key _kTooltipSurfaceKey = ValueKey<String>('MTooltip.surface');

/// A keyed anchor child used so tests can find and tap it.
Widget _anchor({Key? key, String label = 'anchor'}) {
  return SizedBox(
    key: key,
    width: 80,
    height: 32,
    child: Center(child: Text(label)),
  );
}

Future<void> _pumpTooltip(
  WidgetTester tester, {
  required String message,
  required Widget child,
  MInputModality modality = MInputModality.mouse,
  MTooltipPlacement placement = MTooltipPlacement.above,
  MTooltipStyleDelta? style,
  bool enabled = true,
}) async {
  await pumpManyApp(
    tester,
    Center(
      child: MTooltip(
        message: message,
        placement: placement,
        modality: modality,
        style: style,
        enabled: enabled,
        child: child,
      ),
    ),
    modality: modality,
    installOverlay: true,
  );
  await tester.pump();
}

Future<TestGesture> _showTooltip(WidgetTester tester, Finder anchor) async {
  final TestGesture gesture = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
  );
  await gesture.addPointer(location: tester.getCenter(anchor));
  await tester.pump();
  return gesture;
}

Future<void> _pumpEdgeTooltip(
  WidgetTester tester, {
  required Alignment alignment,
  required MTooltipPlacement placement,
  required String message,
  Size viewport = const Size(320, 240),
}) async {
  await tester.binding.setSurfaceSize(viewport);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await pumpManyApp(
    tester,
    Align(
      alignment: alignment,
      child: MTooltip(
        message: message,
        placement: placement,
        modality: MInputModality.mouse,
        style: const MTooltipStyleDelta(
          maxWidth: 180,
          showDelay: Duration.zero,
        ),
        child: _anchor(key: const ValueKey<String>('edge-anchor')),
      ),
    ),
    viewport: viewport,
    modality: MInputModality.mouse,
    installOverlay: true,
  );
  final TestGesture gesture = await _showTooltip(
    tester,
    find.byKey(const ValueKey<String>('edge-anchor')),
  );
  addTearDown(gesture.removePointer);
}

void main() {
  group('MTooltip mouse modality', () {
    testWidgets('hovering shows the tooltip after showDelay', (
      WidgetTester tester,
    ) async {
      await _pumpTooltip(
        tester,
        message: 'Hello',
        child: _anchor(key: const ValueKey<String>('a')),
      );

      // Not shown before hover.
      expect(find.text('Hello'), findsNothing);

      final TestGesture g = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(g.removePointer);
      await g.addPointer(
        location: tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      await tester.pump();

      // Still not shown until the delay has elapsed.
      await tester.pump(_kShowDelay - const Duration(milliseconds: 50));
      expect(find.text('Hello'), findsNothing);

      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('pointer exit hides the tooltip', (WidgetTester tester) async {
      await _pumpTooltip(
        tester,
        message: 'Hello',
        child: _anchor(key: const ValueKey<String>('a')),
      );

      final TestGesture g = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(g.removePointer);
      await g.addPointer(
        location: tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      await tester.pump();
      await tester.pump(_kShowDelay + const Duration(milliseconds: 50));
      expect(find.text('Hello'), findsOneWidget);

      // Move pointer far away.
      await g.moveTo(const Offset(2000, 2000));
      await tester.pump(_kHideDelay + const Duration(milliseconds: 50));
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('hideDelay defers the hide', (WidgetTester tester) async {
      await _pumpTooltip(
        tester,
        message: 'Delayed',
        child: _anchor(key: const ValueKey<String>('a')),
        style: const MTooltipStyleDelta(hideDelay: Duration(milliseconds: 200)),
      );

      final TestGesture g = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(g.removePointer);
      await g.addPointer(
        location: tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      await tester.pump();
      await tester.pump(_kShowDelay + const Duration(milliseconds: 50));
      expect(find.text('Delayed'), findsOneWidget);

      // Move pointer away — hideDelay must elapse before hide.
      await g.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.text('Delayed'),
        findsOneWidget,
        reason: 'hideDelay (200 ms) not yet elapsed',
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Delayed'), findsNothing);
    });
  });

  group('MTooltip touch modality', () {
    testWidgets('long-press shows the tooltip', (WidgetTester tester) async {
      await _pumpTooltip(
        tester,
        message: 'Touched',
        child: _anchor(key: const ValueKey<String>('a')),
        modality: MInputModality.touch,
      );

      expect(find.text('Touched'), findsNothing);

      final TestGesture g = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      // Long-press threshold is 500 ms; pump a hair past it.
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Touched'), findsOneWidget);

      await g.up();
      await tester.pump();
      expect(find.text('Touched'), findsNothing);
    });
  });

  group('MTooltip dismiss-and-pass-through', () {
    testWidgets('tap outside hides the tooltip', (WidgetTester tester) async {
      await _pumpTooltip(
        tester,
        message: 'Dismiss me',
        child: _anchor(key: const ValueKey<String>('a')),
      );

      final TestGesture g = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(g.removePointer);
      await g.addPointer(
        location: tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      await tester.pump();
      await tester.pump(_kShowDelay + const Duration(milliseconds: 50));
      expect(find.text('Dismiss me'), findsOneWidget);

      // Tap somewhere far from the anchor.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.text('Dismiss me'), findsNothing);
    });
  });

  group('MTooltip enabled flag', () {
    testWidgets('disabled tooltip never shows on hover', (
      WidgetTester tester,
    ) async {
      await _pumpTooltip(
        tester,
        message: 'Nope',
        child: _anchor(key: const ValueKey<String>('a')),
        enabled: false,
      );

      final TestGesture g = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(g.removePointer);
      await g.addPointer(
        location: tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      await tester.pump(_kShowDelay + const Duration(milliseconds: 100));
      expect(find.text('Nope'), findsNothing);
    });
  });

  group('MTooltip placement', () {
    testWidgets('top collision flips preferred-above tooltip below', (
      WidgetTester tester,
    ) async {
      await _pumpEdgeTooltip(
        tester,
        alignment: Alignment.topCenter,
        placement: MTooltipPlacement.above,
        message: 'Header action',
      );

      final Rect anchor = tester.getRect(
        find.byKey(const ValueKey<String>('edge-anchor')),
      );
      final Rect surface = tester.getRect(find.byKey(_kTooltipSurfaceKey));
      expect(surface.top, greaterThanOrEqualTo(anchor.bottom));
      expect(surface.top, greaterThanOrEqualTo(8));
    });

    testWidgets('bottom collision flips preferred-below tooltip above', (
      WidgetTester tester,
    ) async {
      await _pumpEdgeTooltip(
        tester,
        alignment: Alignment.bottomCenter,
        placement: MTooltipPlacement.below,
        message: 'Footer action',
      );

      final Rect anchor = tester.getRect(
        find.byKey(const ValueKey<String>('edge-anchor')),
      );
      final Rect surface = tester.getRect(find.byKey(_kTooltipSurfaceKey));
      expect(surface.bottom, lessThanOrEqualTo(anchor.top));
      expect(surface.bottom, lessThanOrEqualTo(232));
    });

    testWidgets('left collision shifts tooltip inside viewport', (
      WidgetTester tester,
    ) async {
      await _pumpEdgeTooltip(
        tester,
        alignment: Alignment.centerLeft,
        placement: MTooltipPlacement.above,
        message: 'A wider tooltip at the leading edge',
      );

      final Rect surface = tester.getRect(find.byKey(_kTooltipSurfaceKey));
      expect(surface.left, closeTo(8, 0.01));
      expect(surface.right, lessThanOrEqualTo(312));
    });

    testWidgets('right collision shifts tooltip inside viewport', (
      WidgetTester tester,
    ) async {
      await _pumpEdgeTooltip(
        tester,
        alignment: Alignment.centerRight,
        placement: MTooltipPlacement.above,
        message: 'A wider tooltip at the trailing edge',
      );

      final Rect surface = tester.getRect(find.byKey(_kTooltipSurfaceKey));
      expect(surface.left, greaterThanOrEqualTo(8));
      expect(surface.right, closeTo(312, 0.01));
    });

    testWidgets('constrains a large tooltip to all viewport bounds', (
      WidgetTester tester,
    ) async {
      await _pumpEdgeTooltip(
        tester,
        alignment: Alignment.topLeft,
        placement: MTooltipPlacement.above,
        message: List<String>.filled(20, 'viewport-aware').join(' '),
        viewport: const Size(160, 120),
      );

      final Rect surface = tester.getRect(find.byKey(_kTooltipSurfaceKey));
      expect(surface.left, greaterThanOrEqualTo(8));
      expect(surface.top, greaterThanOrEqualTo(8));
      expect(surface.right, lessThanOrEqualTo(152));
      expect(surface.bottom, lessThanOrEqualTo(112));
    });

    testWidgets('below places tooltip beneath the anchor', (
      WidgetTester tester,
    ) async {
      await _pumpTooltip(
        tester,
        message: 'Below',
        placement: MTooltipPlacement.below,
        child: _anchor(key: const ValueKey<String>('a')),
      );

      final TestGesture g = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(g.removePointer);
      await g.addPointer(
        location: tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      await tester.pump();
      await tester.pump(_kShowDelay + const Duration(milliseconds: 50));

      final Offset anchorBottomLeft = tester.getBottomLeft(
        find.byKey(const ValueKey<String>('a')),
      );
      final Offset surfaceTopLeft = tester.getTopLeft(find.text('Below'));
      expect(
        surfaceTopLeft.dy,
        greaterThan(anchorBottomLeft.dy),
        reason: 'Below placement should sit beneath the anchor',
      );
    });

    testWidgets('above places tooltip over the anchor', (
      WidgetTester tester,
    ) async {
      await _pumpTooltip(
        tester,
        message: 'Above',
        child: _anchor(key: const ValueKey<String>('a')),
      );

      final TestGesture g = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(g.removePointer);
      await g.addPointer(
        location: tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      await tester.pump();
      await tester.pump(_kShowDelay + const Duration(milliseconds: 50));

      final Offset anchorTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey<String>('a')),
      );
      final Offset surfaceTopLeft = tester.getTopLeft(find.text('Above'));
      expect(
        surfaceTopLeft.dy,
        lessThan(anchorTopLeft.dy),
        reason: 'Above placement should sit over the anchor',
      );
    });
  });

  group('MTooltip dispose', () {
    testWidgets('disposing while show timer is pending does not throw', (
      WidgetTester tester,
    ) async {
      await _pumpTooltip(
        tester,
        message: 'Pending',
        child: _anchor(key: const ValueKey<String>('a')),
      );

      final TestGesture g = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(g.removePointer);
      await g.addPointer(
        location: tester.getCenter(find.byKey(const ValueKey<String>('a'))),
      );
      await tester.pump();
      // Replace the tree before the show timer fires.
      await pumpManyApp(tester, const Center(child: SizedBox.shrink()));
      await tester.pump(_kShowDelay + const Duration(milliseconds: 200));
      // No exception = pass.
    });
  });

  group('MTooltip semantics', () {
    testWidgets('exposes one anchor tooltip while excluding visual duplicate', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpTooltip(
        tester,
        message: 'Click me',
        child: _anchor(key: const ValueKey<String>('a')),
        style: const MTooltipStyleDelta(showDelay: Duration.zero),
      );

      expect(
        tester.getSemantics(find.byKey(const ValueKey<String>('a'))),
        matchesSemantics(label: 'anchor', tooltip: 'Click me'),
      );

      final TestGesture gesture = await _showTooltip(
        tester,
        find.byKey(const ValueKey<String>('a')),
      );
      addTearDown(gesture.removePointer);
      expect(
        find.semantics.byPredicate(
          (SemanticsNode node) => node.tooltip == 'Click me',
        ),
        findsOne,
      );
      expect(
        find.ancestor(
          of: find.text('Click me'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
