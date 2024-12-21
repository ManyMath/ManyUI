import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MCheckbox tap', () {
    testWidgets('tapping flips internal value and reports through onChanged',
        (WidgetTester tester) async {
      bool? reported;
      await pumpManyApp(
        tester,
        MCheckbox(onChanged: (bool v) => reported = v),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MCheckbox));
      await tester.pump();
      expect(reported, true);

      await tester.tap(find.byType(MCheckbox));
      await tester.pump();
      expect(reported, false);
    });

    testWidgets('tap is a no-op when enabled is false',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        MCheckbox(enabled: false, onChanged: (_) => calls++),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MCheckbox));
      await tester.pump();
      expect(calls, 0);
    });

    testWidgets('tap fires under touch modality too',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        MCheckbox(onChanged: (_) => calls++),
        modality: MInputModality.touch,
      );

      await tester.tap(find.byType(MCheckbox));
      await tester.pump();
      expect(calls, 1);
    });
  });

  group('MCheckbox keyboard activation', () {
    Future<void> activate(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }

    testWidgets('Space toggles when focused', (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      bool? reported;

      await pumpManyApp(
        tester,
        MCheckbox(
          focusNode: node,
          autofocus: true,
          onChanged: (bool v) => reported = v,
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();
      expect(node.hasFocus, isTrue);

      await activate(tester, LogicalKeyboardKey.space);
      expect(reported, true);
    });

    testWidgets('Enter and NumpadEnter both toggle when focused',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      int calls = 0;

      await pumpManyApp(
        tester,
        MCheckbox(
          focusNode: node,
          autofocus: true,
          onChanged: (_) => calls++,
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await activate(tester, LogicalKeyboardKey.enter);
      expect(calls, 1);

      await activate(tester, LogicalKeyboardKey.numpadEnter);
      expect(calls, 2);
    });

    testWidgets('disabled checkbox ignores keyboard activation',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      int calls = 0;

      await pumpManyApp(
        tester,
        MCheckbox(
          enabled: false,
          focusNode: node,
          autofocus: true,
          onChanged: (_) => calls++,
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await activate(tester, LogicalKeyboardKey.space);
      expect(calls, 0);
    });
  });

  group('MCheckbox controller wiring', () {
    testWidgets('caller-supplied controller is used and not disposed',
        (WidgetTester tester) async {
      final MController<bool> controller = MController<bool>(false);

      await pumpManyApp(
        tester,
        MCheckbox(controller: controller),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MCheckbox));
      await tester.pump();
      expect(controller.value, true);

      // Remove the widget — controller must still be usable.
      await pumpManyApp(tester, const SizedBox.shrink());
      expect(() => controller.value = false, returnsNormally);

      controller.dispose();
    });

    testWidgets(
        'external controller value mutation updates the rendered checked '
        'state', (WidgetTester tester) async {
      final MController<bool> controller = MController<bool>(false);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        MCheckbox(controller: controller),
        modality: MInputModality.mouse,
      );

      final Semantics initial =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(initial.properties.checked, false);

      controller.value = true;
      await tester.pump();
      final Semantics next =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(next.properties.checked, true);
    });

    testWidgets('initialValue seeds the internally-owned controller',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MCheckbox(initialValue: true),
        modality: MInputModality.mouse,
      );

      final Semantics rendered =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(rendered.properties.checked, true);
    });

    testWidgets('swapping from internal to external controller rebinds',
        (WidgetTester tester) async {
      final MController<bool> external = MController<bool>(true);
      addTearDown(external.dispose);

      await pumpManyApp(
        tester,
        const MCheckbox(initialValue: false),
        modality: MInputModality.mouse,
      );

      await pumpManyApp(
        tester,
        MCheckbox(controller: external),
        modality: MInputModality.mouse,
      );

      final Semantics rendered =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(rendered.properties.checked, true,
          reason: 'rebind should pick up the external controllers value');
    });
  });

  group('MCheckbox semantics', () {
    testWidgets('reports checked, enabled, and label', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MCheckbox(
          initialValue: true,
          semanticLabel: 'Agree to terms',
        ),
      );

      final Semantics s =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(s.properties.checked, true);
      expect(s.properties.enabled, true);
      expect(s.properties.label, 'Agree to terms');
    });

    testWidgets('disabled checkbox reports enabled=false',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MCheckbox(enabled: false),
      );

      final Semantics s =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(s.properties.enabled, false);
    });
  });

  group('MCheckbox style', () {
    testWidgets('applyDelta overrides size at the SizedBox level',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MCheckbox(
          style: MCheckboxStyleDelta(size: 40),
        ),
        modality: MInputModality.mouse,
      );

      final SizedBox box = tester.widget(find
          .descendant(of: find.byType(MCheckbox), matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.width, 40);
      expect(box.height, 40);
    });
  });
}
