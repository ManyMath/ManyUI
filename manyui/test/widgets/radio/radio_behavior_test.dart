import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

Widget _twoRadios({
  MController<String?>? controller,
  String? initialValue,
  ValueChanged<String?>? onChanged,
  bool groupEnabled = true,
  FocusNode? aFocus,
  FocusNode? bFocus,
  bool aAutofocus = false,
  bool bAutofocus = false,
  bool aEnabled = true,
  bool bEnabled = true,
}) {
  return MRadioGroup<String>(
    controller: controller,
    initialValue: initialValue,
    onChanged: onChanged,
    enabled: groupEnabled,
    child: Row(
      children: <Widget>[
        MRadio<String>(
          value: 'a',
          focusNode: aFocus,
          autofocus: aAutofocus,
          enabled: aEnabled,
        ),
        const SizedBox(width: 12),
        MRadio<String>(
          value: 'b',
          focusNode: bFocus,
          autofocus: bAutofocus,
          enabled: bEnabled,
        ),
      ],
    ),
  );
}

void main() {
  group('MRadio tap', () {
    testWidgets('tapping a radio writes its value into the group',
        (WidgetTester tester) async {
      String? reported;
      await pumpManyApp(
        tester,
        _twoRadios(onChanged: (String? v) => reported = v),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MRadio<String>).at(1));
      await tester.pump();
      expect(reported, 'b');

      await tester.tap(find.byType(MRadio<String>).at(0));
      await tester.pump();
      expect(reported, 'a');
    });

    testWidgets('tapping the already-selected radio is a no-op',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        _twoRadios(initialValue: 'a', onChanged: (_) => calls++),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MRadio<String>).at(0));
      await tester.pump();
      expect(calls, 0);
    });

    testWidgets('tap is a no-op when the group is disabled',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        _twoRadios(groupEnabled: false, onChanged: (_) => calls++),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MRadio<String>).at(0), warnIfMissed: false);
      await tester.pump();
      expect(calls, 0);
    });

    testWidgets('tap is a no-op when the individual radio is disabled',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        _twoRadios(aEnabled: false, onChanged: (_) => calls++),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MRadio<String>).at(0), warnIfMissed: false);
      await tester.pump();
      expect(calls, 0);

      // The other radio is still enabled.
      await tester.tap(find.byType(MRadio<String>).at(1));
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('tap fires under touch modality too',
        (WidgetTester tester) async {
      int calls = 0;
      await pumpManyApp(
        tester,
        _twoRadios(onChanged: (_) => calls++),
        modality: MInputModality.touch,
      );

      await tester.tap(find.byType(MRadio<String>).at(0));
      await tester.pump();
      expect(calls, 1);
    });
  });

  group('MRadio keyboard activation', () {
    Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }

    testWidgets('Space selects the focused radio', (WidgetTester tester) async {
      final FocusNode aNode = FocusNode();
      addTearDown(aNode.dispose);
      String? reported;

      await pumpManyApp(
        tester,
        _twoRadios(
          aFocus: aNode,
          aAutofocus: true,
          onChanged: (String? v) => reported = v,
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();
      expect(aNode.hasFocus, isTrue);

      await press(tester, LogicalKeyboardKey.space);
      expect(reported, 'a');
    });

    testWidgets('Enter and NumpadEnter both select the focused radio',
        (WidgetTester tester) async {
      final FocusNode aNode = FocusNode();
      addTearDown(aNode.dispose);
      int calls = 0;

      await pumpManyApp(
        tester,
        _twoRadios(
          aFocus: aNode,
          aAutofocus: true,
          onChanged: (_) => calls++,
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await press(tester, LogicalKeyboardKey.enter);
      expect(calls, 1);

      // NumpadEnter on the same already-selected radio is a no-op.
      await press(tester, LogicalKeyboardKey.numpadEnter);
      expect(calls, 1);
    });

    testWidgets('disabled radio ignores keyboard activation',
        (WidgetTester tester) async {
      final FocusNode aNode = FocusNode();
      addTearDown(aNode.dispose);
      int calls = 0;

      await pumpManyApp(
        tester,
        _twoRadios(
          aFocus: aNode,
          aAutofocus: true,
          aEnabled: false,
          onChanged: (_) => calls++,
        ),
        modality: MInputModality.keyboard,
      );
      await tester.pump();

      await press(tester, LogicalKeyboardKey.space);
      expect(calls, 0);
    });
  });

  group('MRadioGroup focus traversal', () {
    Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }

    testWidgets('arrow right moves focus from the first radio to the second',
        (WidgetTester tester) async {
      final FocusNode aNode = FocusNode();
      final FocusNode bNode = FocusNode();
      addTearDown(aNode.dispose);
      addTearDown(bNode.dispose);

      await pumpManyApp(
        tester,
        _twoRadios(aFocus: aNode, bFocus: bNode, aAutofocus: true),
        modality: MInputModality.keyboard,
      );
      await tester.pump();
      expect(aNode.hasFocus, isTrue);

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(bNode.hasFocus, isTrue);
      expect(aNode.hasFocus, isFalse);
    });

    testWidgets('arrow left moves focus from the second radio back to the first',
        (WidgetTester tester) async {
      final FocusNode aNode = FocusNode();
      final FocusNode bNode = FocusNode();
      addTearDown(aNode.dispose);
      addTearDown(bNode.dispose);

      await pumpManyApp(
        tester,
        _twoRadios(aFocus: aNode, bFocus: bNode, bAutofocus: true),
        modality: MInputModality.keyboard,
      );
      await tester.pump();
      expect(bNode.hasFocus, isTrue);

      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(aNode.hasFocus, isTrue);
    });
  });

  group('MRadioGroup controller wiring', () {
    testWidgets('caller-supplied controller is used and not disposed',
        (WidgetTester tester) async {
      final MController<String?> controller = MController<String?>(null);

      await pumpManyApp(
        tester,
        _twoRadios(controller: controller),
        modality: MInputModality.mouse,
      );

      await tester.tap(find.byType(MRadio<String>).at(0));
      await tester.pump();
      expect(controller.value, 'a');

      // Remove the widget — controller must still be usable.
      await pumpManyApp(tester, const SizedBox.shrink());
      expect(() => controller.value = 'b', returnsNormally);

      controller.dispose();
    });

    testWidgets(
        'external controller value mutation updates the rendered checked state',
        (WidgetTester tester) async {
      final MController<String?> controller = MController<String?>(null);
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _twoRadios(controller: controller),
        modality: MInputModality.mouse,
      );

      // No radio is selected initially.
      final Finder aSemantics = find
          .descendant(
            of: find.byType(MRadio<String>).at(0),
            matching: find.byType(Semantics),
          )
          .first;
      Semantics a = tester.widget(aSemantics) as Semantics;
      expect(a.properties.checked, false);

      controller.value = 'a';
      await tester.pump();
      a = tester.widget(aSemantics) as Semantics;
      expect(a.properties.checked, true);
    });

    testWidgets('initialValue seeds the internally-owned controller',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _twoRadios(initialValue: 'b'),
        modality: MInputModality.mouse,
      );

      final Semantics b = tester.widget(find
          .descendant(
            of: find.byType(MRadio<String>).at(1),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(b.properties.checked, true);
    });

    testWidgets('swapping from internal to external controller rebinds',
        (WidgetTester tester) async {
      final MController<String?> external = MController<String?>('b');
      addTearDown(external.dispose);

      await pumpManyApp(
        tester,
        _twoRadios(initialValue: 'a'),
        modality: MInputModality.mouse,
      );

      await pumpManyApp(
        tester,
        _twoRadios(controller: external),
        modality: MInputModality.mouse,
      );

      final Semantics b = tester.widget(find
          .descendant(
            of: find.byType(MRadio<String>).at(1),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(b.properties.checked, true,
          reason: 'rebind should pick up the external controllers value');
    });
  });

  group('MRadio semantics', () {
    testWidgets('reports checked, inMutuallyExclusiveGroup, enabled, label',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MRadioGroup<String>(
          initialValue: 'a',
          child: Row(
            children: const <Widget>[
              MRadio<String>(value: 'a', semanticLabel: 'Option A'),
              MRadio<String>(value: 'b'),
            ],
          ),
        ),
      );

      final Semantics a = tester.widget(find
          .descendant(
            of: find.byType(MRadio<String>).at(0),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(a.properties.checked, true);
      expect(a.properties.inMutuallyExclusiveGroup, true);
      expect(a.properties.enabled, true);
      expect(a.properties.label, 'Option A');

      final Semantics b = tester.widget(find
          .descendant(
            of: find.byType(MRadio<String>).at(1),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(b.properties.checked, false);
      expect(b.properties.inMutuallyExclusiveGroup, true);
    });

    testWidgets('disabled radio reports enabled=false',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _twoRadios(aEnabled: false),
      );

      final Semantics a = tester.widget(find
          .descendant(
            of: find.byType(MRadio<String>).at(0),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(a.properties.enabled, false);
    });

    testWidgets('group-level enabled=false disables every radio',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _twoRadios(groupEnabled: false),
      );

      final Semantics a = tester.widget(find
          .descendant(
            of: find.byType(MRadio<String>).at(0),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      final Semantics b = tester.widget(find
          .descendant(
            of: find.byType(MRadio<String>).at(1),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(a.properties.enabled, false);
      expect(b.properties.enabled, false);
    });
  });

  group('MRadio modality', () {
    testWidgets('mouse modality renders the compact circle size',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _twoRadios(),
        modality: MInputModality.mouse,
      );

      final SizedBox box = tester.widget(find
          .descendant(
              of: find.byType(MRadio<String>).at(0),
              matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.width, 18);
      expect(box.height, 18);
    });

    testWidgets('touch modality bumps the circle to the larger hit target',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _twoRadios(),
        modality: MInputModality.touch,
      );

      final SizedBox box = tester.widget(find
          .descendant(
              of: find.byType(MRadio<String>).at(0),
              matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.width, 22);
      expect(box.height, 22);
    });
  });

  group('MRadio style', () {
    testWidgets('applyDelta overrides size at the SizedBox level',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MRadioGroup<String>(
          initialValue: 'a',
          child: const MRadio<String>(
            value: 'a',
            style: MRadioStyleDelta(size: 40),
          ),
        ),
        modality: MInputModality.mouse,
      );

      final SizedBox box = tester.widget(find
          .descendant(
              of: find.byType(MRadio<String>),
              matching: find.byType(SizedBox))
          .first) as SizedBox;
      expect(box.width, 40);
      expect(box.height, 40);
    });
  });
}
