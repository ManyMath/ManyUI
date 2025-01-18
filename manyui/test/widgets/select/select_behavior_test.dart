import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

/// Wraps [child] in a sized box inside a minimal Overlay so OverlayPortal
/// inside the widget can find an ambient Overlay. pumpManyApp doesn't install
/// one by default.
Widget _overlayed(Widget child) {
  return Overlay(
    initialEntries: <OverlayEntry>[
      OverlayEntry(
        builder: (BuildContext _) => Center(
          child: SizedBox(width: 240, child: child),
        ),
      ),
    ],
  );
}

const List<MSelectItem<String>> _fruits = <MSelectItem<String>>[
  MSelectItem<String>(value: 'apple', label: 'Apple'),
  MSelectItem<String>(value: 'banana', label: 'Banana'),
  MSelectItem<String>(value: 'cherry', label: 'Cherry'),
];

Future<void> _pumpSelect(
  WidgetTester tester, {
  MController<String?>? controller,
  String? initialValue,
  ValueChanged<String?>? onChanged,
  String? placeholder = 'Pick one',
  bool enabled = true,
  FocusNode? focusNode,
  bool autofocus = false,
  List<MSelectItem<String>>? items,
  MInputModality modality = MInputModality.mouse,
}) async {
  await pumpManyApp(
    tester,
    _overlayed(MSelect<String>(
      items: items ?? _fruits,
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      placeholder: placeholder,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
    )),
    modality: modality,
  );
  // First frame mounts the select and the controller's initial value; pump a
  // second frame so postFrameCallbacks (focus requests) settle.
  await tester.pump();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
}

void main() {
  group('MSelect open/close', () {
    testWidgets('tapping the anchor opens the popover',
        (WidgetTester tester) async {
      await _pumpSelect(tester);

      // Popover not in the tree yet.
      expect(find.text('Apple'), findsNothing);

      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('tapping the anchor again closes the popover',
        (WidgetTester tester) async {
      await _pumpSelect(tester);

      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();
      expect(find.text('Apple'), findsOneWidget);

      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('Escape closes the popover without committing',
        (WidgetTester tester) async {
      String? reported;
      await _pumpSelect(
        tester,
        onChanged: (String? v) => reported = v,
        modality: MInputModality.keyboard,
      );

      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();
      expect(find.text('Apple'), findsOneWidget);

      await _press(tester, LogicalKeyboardKey.escape);
      expect(find.text('Apple'), findsNothing);
      expect(reported, isNull);
    });

    testWidgets('tapping outside the popover dismisses without committing',
        (WidgetTester tester) async {
      String? reported;
      await _pumpSelect(
        tester,
        onChanged: (String? v) => reported = v,
      );

      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();
      expect(find.text('Apple'), findsOneWidget);

      // Top-left of the screen is well outside the centered 240-wide anchor
      // and its popover beneath it.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();

      expect(find.text('Apple'), findsNothing);
      expect(reported, isNull);
    });

    testWidgets('disabled select ignores taps', (WidgetTester tester) async {
      await _pumpSelect(tester, enabled: false);

      await tester.tap(find.byType(MSelect<String>), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Apple'), findsNothing);
    });
  });

  group('MSelect item activation', () {
    testWidgets('tapping an item commits its value and closes the popover',
        (WidgetTester tester) async {
      String? reported;
      final MController<String?> controller = MController<String?>(null);
      addTearDown(controller.dispose);

      await _pumpSelect(
        tester,
        controller: controller,
        onChanged: (String? v) => reported = v,
      );

      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();

      await tester.tap(find.text('Banana'));
      await tester.pump();

      expect(reported, 'banana');
      expect(controller.value, 'banana');
      expect(find.text('Apple'), findsNothing, reason: 'popover closed');
      // Anchor now shows the selected label.
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('tapping a disabled item is a no-op',
        (WidgetTester tester) async {
      int calls = 0;
      const List<MSelectItem<String>> withDisabled = <MSelectItem<String>>[
        MSelectItem<String>(value: 'a', label: 'A'),
        MSelectItem<String>(value: 'b', label: 'B', enabled: false),
        MSelectItem<String>(value: 'c', label: 'C'),
      ];

      await _pumpSelect(
        tester,
        items: withDisabled,
        onChanged: (_) => calls++,
      );

      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();

      await tester.tap(find.text('B'), warnIfMissed: false);
      await tester.pump();

      expect(calls, 0);
      // Popover is still open since the tap was ignored.
      expect(find.text('A'), findsOneWidget);
    });
  });

  group('MSelect keyboard navigation', () {
    testWidgets('Arrow-Down on a focused anchor opens the popover',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await _pumpSelect(
        tester,
        focusNode: node,
        autofocus: true,
        modality: MInputModality.keyboard,
      );
      expect(node.hasFocus, isTrue);

      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('Enter commits the focused item',
        (WidgetTester tester) async {
      String? reported;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await _pumpSelect(
        tester,
        focusNode: node,
        autofocus: true,
        onChanged: (String? v) => reported = v,
        modality: MInputModality.keyboard,
      );

      await _press(tester, LogicalKeyboardKey.enter); // opens
      expect(find.text('Apple'), findsOneWidget);

      // Initial focused item with no selection is the first enabled item.
      await _press(tester, LogicalKeyboardKey.arrowDown); // → Banana
      await _press(tester, LogicalKeyboardKey.enter);

      expect(reported, 'banana');
      expect(find.text('Apple'), findsNothing,
          reason: 'popover closed on commit');
    });

    testWidgets('Arrow-Down wraps from the last item to the first',
        (WidgetTester tester) async {
      String? reported;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await _pumpSelect(
        tester,
        focusNode: node,
        autofocus: true,
        onChanged: (String? v) => reported = v,
        modality: MInputModality.keyboard,
      );

      await _press(tester, LogicalKeyboardKey.enter); // open, focus on Apple
      await _press(tester, LogicalKeyboardKey.arrowDown); // Banana
      await _press(tester, LogicalKeyboardKey.arrowDown); // Cherry
      await _press(tester, LogicalKeyboardKey.arrowDown); // wraps → Apple
      await _press(tester, LogicalKeyboardKey.enter);

      expect(reported, 'apple');
    });

    testWidgets('Arrow-Down skips a disabled item',
        (WidgetTester tester) async {
      String? reported;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      const List<MSelectItem<String>> items = <MSelectItem<String>>[
        MSelectItem<String>(value: 'a', label: 'A'),
        MSelectItem<String>(value: 'b', label: 'B', enabled: false),
        MSelectItem<String>(value: 'c', label: 'C'),
      ];

      await _pumpSelect(
        tester,
        items: items,
        focusNode: node,
        autofocus: true,
        onChanged: (String? v) => reported = v,
        modality: MInputModality.keyboard,
      );

      await _press(tester, LogicalKeyboardKey.enter); // open, focus on A
      await _press(tester, LogicalKeyboardKey.arrowDown); // jumps past B → C
      await _press(tester, LogicalKeyboardKey.enter);

      expect(reported, 'c');
    });

    testWidgets('Home and End jump to the first / last enabled item',
        (WidgetTester tester) async {
      String? reported;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await _pumpSelect(
        tester,
        focusNode: node,
        autofocus: true,
        onChanged: (String? v) => reported = v,
        modality: MInputModality.keyboard,
      );

      await _press(tester, LogicalKeyboardKey.enter); // open
      await _press(tester, LogicalKeyboardKey.end);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(reported, 'cherry');

      await _press(tester, LogicalKeyboardKey.enter); // re-open
      await _press(tester, LogicalKeyboardKey.home);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(reported, 'apple');
    });

    testWidgets('type-to-search jumps focus to a matching item',
        (WidgetTester tester) async {
      String? reported;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await _pumpSelect(
        tester,
        focusNode: node,
        autofocus: true,
        onChanged: (String? v) => reported = v,
        modality: MInputModality.keyboard,
      );

      await _press(tester, LogicalKeyboardKey.enter); // open

      // 'c' should advance focus to Cherry.
      await _press(tester, LogicalKeyboardKey.keyC);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(reported, 'cherry');
    });
  });

  group('MSelect controller wiring', () {
    testWidgets('caller-supplied controller is used and not disposed',
        (WidgetTester tester) async {
      final MController<String?> controller = MController<String?>(null);

      await _pumpSelect(tester, controller: controller);

      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();
      await tester.tap(find.text('Banana'));
      await tester.pump();

      expect(controller.value, 'banana');

      await pumpManyApp(tester, const SizedBox.shrink());
      expect(() => controller.value = 'apple', returnsNormally);
      controller.dispose();
    });

    testWidgets('initialValue seeds the internally-owned controller',
        (WidgetTester tester) async {
      await _pumpSelect(tester, initialValue: 'cherry');
      // The anchor shows the selected label.
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets(
        'external controller value mutation updates the anchor label',
        (WidgetTester tester) async {
      final MController<String?> controller = MController<String?>(null);
      addTearDown(controller.dispose);

      await _pumpSelect(tester, controller: controller);
      // No selection — placeholder is visible, no fruit name.
      expect(find.text('Apple'), findsNothing);

      controller.value = 'apple';
      await tester.pump();
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('swapping from internal to external controller rebinds',
        (WidgetTester tester) async {
      final MController<String?> external = MController<String?>('cherry');
      addTearDown(external.dispose);

      final _RebindHarnessState harnessState = _RebindHarnessState();
      await pumpManyApp(
        tester,
        _overlayed(_RebindHarness(
          stateRef: harnessState,
          external: external,
        )),
      );
      expect(find.text('Apple'), findsOneWidget);

      harnessState.swapToExternal();
      await tester.pump();

      expect(find.text('Cherry'), findsOneWidget,
          reason: 'rebind should pick up the external controller value');
    });
  });

  group('MSelect semantics', () {
    testWidgets('the anchor reports button, enabled, and label semantics',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _overlayed(const MSelect<String>(
          items: _fruits,
          semanticLabel: 'Fruit',
        )),
      );

      final Semantics root = tester.widget(find
          .descendant(
            of: find.byType(MSelect<String>),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(root.properties.button, true);
      expect(root.properties.enabled, true);
      expect(root.properties.label, 'Fruit');
    });

    testWidgets('item rows report selected and label semantics',
        (WidgetTester tester) async {
      await _pumpSelect(tester, initialValue: 'banana');
      await tester.tap(find.byType(MSelect<String>));
      await tester.pump();

      // Find each item row's Semantics by its text and walk up.
      final Iterable<Semantics> rows = tester.widgetList<Semantics>(
        find.byWidgetPredicate((Widget w) {
          return w is Semantics &&
              w.properties.label != null &&
              <String>['Apple', 'Banana', 'Cherry']
                  .contains(w.properties.label);
        }),
      );

      final Map<String, Semantics> byLabel = <String, Semantics>{
        for (final Semantics s in rows) s.properties.label!: s,
      };
      expect(byLabel['Apple']!.properties.selected, false);
      expect(byLabel['Banana']!.properties.selected, true);
      expect(byLabel['Cherry']!.properties.selected, false);
    });

    testWidgets('disabled select reports enabled=false on the anchor',
        (WidgetTester tester) async {
      await _pumpSelect(tester, enabled: false);

      final Semantics root = tester.widget(find
          .descendant(
            of: find.byType(MSelect<String>),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(root.properties.enabled, false);
    });
  });

  group('MSelect modality', () {
    testWidgets('mouse modality renders the compact anchor height',
        (WidgetTester tester) async {
      await _pumpSelect(tester, modality: MInputModality.mouse);

      // The first ConstrainedBox inside the select carries the anchor's
      // minHeight.
      final ConstrainedBox box = tester.widget(find
          .descendant(
            of: find.byType(MSelect<String>),
            matching: find.byType(ConstrainedBox),
          )
          .first) as ConstrainedBox;
      expect(box.constraints.minHeight, 36);
    });

    testWidgets('touch modality bumps the anchor to the larger hit target',
        (WidgetTester tester) async {
      await _pumpSelect(tester, modality: MInputModality.touch);

      final ConstrainedBox box = tester.widget(find
          .descendant(
            of: find.byType(MSelect<String>),
            matching: find.byType(ConstrainedBox),
          )
          .first) as ConstrainedBox;
      expect(box.constraints.minHeight, 44);
    });
  });

  group('MSelect style', () {
    testWidgets('applyDelta overrides minHeight on the anchor',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _overlayed(const MSelect<String>(
          items: _fruits,
          style: MSelectStyleDelta(minHeight: 64),
        )),
        modality: MInputModality.mouse,
      );

      final ConstrainedBox box = tester.widget(find
          .descendant(
            of: find.byType(MSelect<String>),
            matching: find.byType(ConstrainedBox),
          )
          .first) as ConstrainedBox;
      expect(box.constraints.minHeight, 64);
    });
  });
}

/// Test-only harness that toggles between an internally-owned controller
/// (initialValue: 'apple') and a caller-supplied external controller — used
/// to exercise [MSelect.didUpdateWidget]'s rebind path without re-mounting
/// the whole subtree.
class _RebindHarness extends StatefulWidget {
  const _RebindHarness({
    required this.stateRef,
    required this.external,
  });

  final _RebindHarnessState stateRef;
  final MController<String?> external;

  @override
  State<_RebindHarness> createState() => _RebindHarnessStateProxy();
}

class _RebindHarnessState {
  late VoidCallback _swap;
  void swapToExternal() => _swap();
}

class _RebindHarnessStateProxy extends State<_RebindHarness> {
  bool _useExternal = false;

  @override
  void initState() {
    super.initState();
    widget.stateRef._swap = () => setState(() => _useExternal = true);
  }

  @override
  Widget build(BuildContext context) {
    return MSelect<String>(
      items: _fruits,
      controller: _useExternal ? widget.external : null,
      initialValue: 'apple',
    );
  }
}
