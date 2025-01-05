import 'package:flutter/services.dart';
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
  group('MSlider tap-to-set', () {
    testWidgets('tap at the right edge writes max',
        (WidgetTester tester) async {
      double? reported;
      await pumpManyApp(
        tester,
        _sized(MSlider(onChanged: (double v) => reported = v)),
        modality: MInputModality.mouse,
      );

      // Tap near the right edge of the slider's row.
      final Offset bottomRight = tester.getBottomRight(find.byType(MSlider));
      final Offset topLeft = tester.getTopLeft(find.byType(MSlider));
      final double y = (topLeft.dy + bottomRight.dy) / 2;
      await tester.tapAt(Offset(bottomRight.dx - 1, y));
      await tester.pump();
      expect(reported, closeTo(1.0, 0.01));
    });

    testWidgets('tap at the left edge writes min',
        (WidgetTester tester) async {
      final MController<double> controller = MController<double>(0.7);
      addTearDown(controller.dispose);
      await pumpManyApp(
        tester,
        _sized(MSlider(controller: controller)),
        modality: MInputModality.mouse,
      );

      final Offset topLeft = tester.getTopLeft(find.byType(MSlider));
      final Offset bottomLeft = tester.getBottomLeft(find.byType(MSlider));
      final double y = (topLeft.dy + bottomLeft.dy) / 2;
      await tester.tapAt(Offset(topLeft.dx + 1, y));
      await tester.pump();
      expect(controller.value, closeTo(0.0, 0.01));
    });

    testWidgets('tap is a no-op when enabled is false',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            enabled: false,
            onChanged: (_) => calls++,
          ),
        ),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MSlider));
      await tester.pump();
      expect(calls, 0);
    });
  });

  group('MSlider drag', () {
    testWidgets('horizontal drag updates value and fires lifecycle callbacks',
        (WidgetTester tester) async {
      int starts = 0;
      int ends = 0;
      double? last;
      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            onChangeStart: (_) => starts++,
            onChangeEnd: (_) => ends++,
            onChanged: (double v) => last = v,
          ),
        ),
        modality: MInputModality.mouse,
      );

      final Offset topLeft = tester.getTopLeft(find.byType(MSlider));
      final Offset bottomRight = tester.getBottomRight(find.byType(MSlider));
      final double centerY = (topLeft.dy + bottomRight.dy) / 2;
      final Offset start = Offset(topLeft.dx + 1, centerY);
      final Offset end = Offset(bottomRight.dx - 1, centerY);

      await tester.dragFrom(start, end - start);
      await tester.pumpAndSettle();

      expect(starts, 1);
      expect(ends, 1);
      expect(last, closeTo(1.0, 0.01));
    });
  });

  group('MSlider keyboard', () {
    Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }

    testWidgets('ArrowRight steps up by 5% of the range when no divisions',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<double> controller = MController<double>(0.5);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            controller: controller,
            focusNode: node,
            autofocus: true,
          ),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(controller.value, closeTo(0.55, 1e-9));
      await press(tester, LogicalKeyboardKey.arrowLeft);
      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(controller.value, closeTo(0.45, 1e-9));
    });

    testWidgets('ArrowUp and ArrowDown step in the same direction as right/left',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<double> controller = MController<double>(0.5);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            controller: controller,
            focusNode: node,
            autofocus: true,
          ),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(controller.value, closeTo(0.55, 1e-9));
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.value, closeTo(0.5, 1e-9));
    });

    testWidgets('PageUp and PageDown step by 10x', (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<double> controller = MController<double>(0.5);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            controller: controller,
            focusNode: node,
            autofocus: true,
          ),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      // Step is 0.05; PageUp moves +0.5 → clamped at 1.0.
      await press(tester, LogicalKeyboardKey.pageUp);
      expect(controller.value, closeTo(1.0, 1e-9));
      await press(tester, LogicalKeyboardKey.pageDown);
      expect(controller.value, closeTo(0.5, 1e-9));
    });

    testWidgets('Home and End jump to min and max',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<double> controller = MController<double>(0.5);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            controller: controller,
            min: -10,
            max: 10,
            focusNode: node,
            autofocus: true,
          ),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await press(tester, LogicalKeyboardKey.home);
      expect(controller.value, -10);
      await press(tester, LogicalKeyboardKey.end);
      expect(controller.value, 10);
    });

    testWidgets('disabled slider ignores keyboard input',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<double> controller = MController<double>(0.5);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            controller: controller,
            enabled: false,
            focusNode: node,
            autofocus: true,
          ),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(controller.value, 0.5);
    });
  });

  group('MSlider divisions', () {
    testWidgets('snaps to the nearest stop on tap',
        (WidgetTester tester) async {
      final MController<double> controller = MController<double>(0);
      addTearDown(controller.dispose);

      // 4 divisions in [0..1] → stops at 0, 0.25, 0.5, 0.75, 1.
      await pumpManyApp(
        tester,
        _sized(MSlider(controller: controller, divisions: 4)),
        modality: MInputModality.mouse,
      );

      // Tap roughly 60% across — should snap to 0.5.
      final Offset topLeft = tester.getTopLeft(find.byType(MSlider));
      final Offset bottomRight = tester.getBottomRight(find.byType(MSlider));
      final double y = (topLeft.dy + bottomRight.dy) / 2;
      final double x = topLeft.dx + (bottomRight.dx - topLeft.dx) * 0.6;
      await tester.tapAt(Offset(x, y));
      await tester.pump();

      expect(controller.value, closeTo(0.5, 1e-9));
    });

    testWidgets('keyboard step is one division wide',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<double> controller = MController<double>(0);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            controller: controller,
            divisions: 4,
            focusNode: node,
            autofocus: true,
          ),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(controller.value, closeTo(0.25, 1e-9));
    });
  });

  group('MSlider clamping', () {
    testWidgets('initialValue is clamped into [min, max]',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(const MSlider(initialValue: 5, min: 0, max: 1)),
        modality: MInputModality.mouse,
      );

      final Semantics s =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(s.properties.value, '1.00');
    });

    testWidgets('keyboard step does not exceed bounds',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<double> controller = MController<double>(0.95);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            controller: controller,
            focusNode: node,
            autofocus: true,
          ),
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(controller.value, 1.0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(controller.value, 1.0);
    });
  });

  group('MSlider controller wiring', () {
    testWidgets('caller-supplied controller is used and not disposed',
        (WidgetTester tester) async {
      final MController<double> controller = MController<double>(0.3);

      await pumpManyApp(
        tester,
        _sized(MSlider(controller: controller)),
        modality: MInputModality.mouse,
      );

      final Offset bottomRight = tester.getBottomRight(find.byType(MSlider));
      final Offset topLeft = tester.getTopLeft(find.byType(MSlider));
      await tester.tapAt(Offset(bottomRight.dx - 1,
          (topLeft.dy + bottomRight.dy) / 2));
      await tester.pump();
      expect(controller.value, closeTo(1.0, 0.01));

      // Remove the widget — controller must still be usable.
      await pumpManyApp(tester, const SizedBox.shrink());
      expect(() => controller.value = 0.5, returnsNormally);

      controller.dispose();
    });

    testWidgets(
        'external controller value mutation updates the rendered semantics '
        'value', (WidgetTester tester) async {
      final MController<double> controller = MController<double>(0.0);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _sized(MSlider(controller: controller)),
        modality: MInputModality.mouse,
      );

      final Semantics initial =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(initial.properties.value, '0.00');

      controller.value = 0.75;
      await tester.pump();
      final Semantics next =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(next.properties.value, '0.75');
    });

    testWidgets('swapping from internal to external controller rebinds',
        (WidgetTester tester) async {
      final MController<double> external = MController<double>(0.9);
      addTearDown(external.dispose);

      await pumpManyApp(
        tester,
        _sized(const MSlider(initialValue: 0.1)),
        modality: MInputModality.mouse,
      );
      await pumpManyApp(
        tester,
        _sized(MSlider(controller: external)),
        modality: MInputModality.mouse,
      );

      final Semantics rendered =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(rendered.properties.value, '0.90',
          reason: 'rebind should pick up the external controllers value');
    });
  });

  group('MSlider semantics', () {
    testWidgets('reports slider, value, increasedValue, decreasedValue, label',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(
          const MSlider(
            initialValue: 0.5,
            semanticLabel: 'Volume',
          ),
        ),
      );

      final Semantics s =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(s.properties.slider, true);
      expect(s.properties.enabled, true);
      expect(s.properties.label, 'Volume');
      expect(s.properties.value, '0.50');
      expect(s.properties.increasedValue, '0.55');
      expect(s.properties.decreasedValue, '0.45');
    });

    testWidgets('semanticFormatterCallback formats reported values',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(
          MSlider(
            initialValue: 0.5,
            semanticFormatterCallback: (double v) =>
                '${(v * 100).round()}%',
          ),
        ),
      );

      final Semantics s =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(s.properties.value, '50%');
      expect(s.properties.increasedValue, '55%');
      expect(s.properties.decreasedValue, '45%');
    });
  });

  group('MSlider modality', () {
    testWidgets('mouse modality renders the compact thumb size',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(const MSlider()),
        modality: MInputModality.mouse,
      );

      final SizedBox box = tester.widget(find
          .descendant(of: find.byType(MSlider), matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.height, 16);
    });

    testWidgets('touch modality bumps the thumb to the WCAG hit target',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(const MSlider()),
        modality: MInputModality.touch,
      );

      final SizedBox box = tester.widget(find
          .descendant(of: find.byType(MSlider), matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.height, 24);
    });
  });

  group('MSlider style', () {
    testWidgets('applyDelta overrides thumbDiameter at the SizedBox level',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _sized(
          const MSlider(
            style: MSliderStyleDelta(thumbDiameter: 40),
          ),
        ),
        modality: MInputModality.mouse,
      );

      final SizedBox box = tester.widget(find
          .descendant(of: find.byType(MSlider), matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.height, 40);
    });
  });
}
