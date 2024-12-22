import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MSwitch tap', () {
    testWidgets('tapping flips internal value and reports through onChanged',
        (WidgetTester tester) async {
      bool? reported;
      await pumpManyApp(
        tester,
        MSwitch(onChanged: (bool v) => reported = v),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MSwitch));
      await tester.pump();
      expect(reported, true);

      await tester.tap(find.byType(MSwitch));
      await tester.pump();
      expect(reported, false);
    });

    testWidgets('tap is a no-op when enabled is false',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        MSwitch(enabled: false, onChanged: (_) => calls++),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MSwitch));
      await tester.pump();
      expect(calls, 0);
    });

    testWidgets('tap fires under touch modality too',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        MSwitch(onChanged: (_) => calls++),
        modality: MInputModality.touch,
      );

      await tester.tap(find.byType(MSwitch));
      await tester.pump();
      expect(calls, 1);
    });
  });

  group('MSwitch keyboard activation', () {
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
        MSwitch(
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
        MSwitch(
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

    testWidgets('disabled switch ignores keyboard activation',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      int calls = 0;

      await pumpManyApp(
        tester,
        MSwitch(
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

  group('MSwitch controller wiring', () {
    testWidgets('caller-supplied controller is used and not disposed',
        (WidgetTester tester) async {
      final MController<bool> controller = MController<bool>(false);

      await pumpManyApp(
        tester,
        MSwitch(controller: controller),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MSwitch));
      await tester.pump();
      expect(controller.value, true);

      // Remove the widget — controller must still be usable.
      await pumpManyApp(tester, const SizedBox.shrink());
      expect(() => controller.value = false, returnsNormally);

      controller.dispose();
    });

    testWidgets(
        'external controller value mutation updates the rendered toggled '
        'state', (WidgetTester tester) async {
      final MController<bool> controller = MController<bool>(false);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        MSwitch(controller: controller),
        modality: MInputModality.mouse,
      );

      final Semantics initial =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(initial.properties.toggled, false);

      controller.value = true;
      await tester.pump();
      final Semantics next =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(next.properties.toggled, true);
    });

    testWidgets('initialValue seeds the internally-owned controller',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MSwitch(initialValue: true),
        modality: MInputModality.mouse,
      );

      final Semantics rendered =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(rendered.properties.toggled, true);
    });

    testWidgets('swapping from internal to external controller rebinds',
        (WidgetTester tester) async {
      final MController<bool> external = MController<bool>(true);
      addTearDown(external.dispose);

      await pumpManyApp(
        tester,
        const MSwitch(initialValue: false),
        modality: MInputModality.mouse,
      );

      await pumpManyApp(
        tester,
        MSwitch(controller: external),
        modality: MInputModality.mouse,
      );

      final Semantics rendered =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(rendered.properties.toggled, true,
          reason: 'rebind should pick up the external controllers value');
    });
  });

  group('MSwitch semantics', () {
    testWidgets('reports toggled, enabled, and label',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MSwitch(
          initialValue: true,
          semanticLabel: 'Enable wifi',
        ),
      );

      final Semantics s =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(s.properties.toggled, true);
      expect(s.properties.enabled, true);
      expect(s.properties.label, 'Enable wifi');
    });

    testWidgets('disabled switch reports enabled=false',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MSwitch(enabled: false),
      );

      final Semantics s =
          tester.widget(find.byType(Semantics).first) as Semantics;
      expect(s.properties.enabled, false);
    });
  });

  group('MSwitch modality', () {
    testWidgets('mouse modality renders the compact track size',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MSwitch(),
        modality: MInputModality.mouse,
      );

      final SizedBox box = tester.widget(find
          .descendant(of: find.byType(MSwitch), matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.width, 32);
      expect(box.height, 18);
    });

    testWidgets('touch modality bumps the track to the larger hit target',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MSwitch(),
        modality: MInputModality.touch,
      );

      final SizedBox box = tester.widget(find
          .descendant(of: find.byType(MSwitch), matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.width, 44);
      expect(box.height, 24);
    });
  });

  group('MSwitch style', () {
    testWidgets('applyDelta overrides trackWidth at the SizedBox level',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MSwitch(
          style: MSwitchStyleDelta(trackWidth: 80, trackHeight: 40),
        ),
        modality: MInputModality.mouse,
      );

      final SizedBox box = tester.widget(find
          .descendant(of: find.byType(MSwitch), matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.width, 80);
      expect(box.height, 40);
    });
  });
}
