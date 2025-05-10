import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

/// Wraps [child] in a bounded SizedBox so MDateField (which expands to its
/// parent) gets a deterministic width. Tests pump via
/// `pumpManyApp(..., installOverlay: true)` for OverlayPortal + EditableText.
Widget _hosted(Widget child, {double width = 260}) {
  return Center(child: SizedBox(width: width, child: child));
}

Future<void> _pumpField(
  WidgetTester tester, {
  MController<DateTime?>? controller,
  DateTime? initialValue,
  ValueChanged<DateTime?>? onChanged,
  ValueChanged<DateTime?>? onSubmitted,
  String? placeholder,
  bool enabled = true,
  bool readOnly = false,
  bool error = false,
  FocusNode? focusNode,
  bool autofocus = false,
  DateTime? firstDate,
  DateTime? lastDate,
  MInputModality modality = MInputModality.mouse,
}) async {
  await pumpManyApp(
    tester,
    _hosted(MDateField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      placeholder: placeholder,
      enabled: enabled,
      readOnly: readOnly,
      error: error,
      focusNode: focusNode,
      autofocus: autofocus,
      firstDate: firstDate,
      lastDate: lastDate,
    )),
    modality: modality,
    installOverlay: true,
  );
  // Second pump so any focus postFrameCallbacks settle.
  await tester.pump();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
}

void main() {
  group('MDateField typing → parse → controller', () {
    testWidgets('typing a valid ISO date updates the controller',
        (WidgetTester tester) async {
      DateTime? reported;
      final MController<DateTime?> controller = MController<DateTime?>(null);
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        onChanged: (DateTime? v) => reported = v,
      );

      await tester.tap(find.byType(MDateField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '2026-05-13');
      await tester.pump();

      expect(controller.value, DateTime.utc(2026, 5, 13));
      expect(reported, DateTime.utc(2026, 5, 13));
    });

    testWidgets('typing an unparseable string leaves controller null',
        (WidgetTester tester) async {
      final MController<DateTime?> controller = MController<DateTime?>(null);
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller);

      await tester.tap(find.byType(MDateField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'tomorrow');
      await tester.pump();

      expect(controller.value, isNull);
    });

    testWidgets('external controller mutation reformats displayed text',
        (WidgetTester tester) async {
      final MController<DateTime?> controller = MController<DateTime?>(null);
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller);
      expect(find.text('2026-05-13'), findsNothing);

      controller.value = DateTime.utc(2026, 5, 13);
      await tester.pump();

      expect(find.text('2026-05-13'), findsOneWidget);
    });

    testWidgets('clearing the controller blanks the display',
        (WidgetTester tester) async {
      final MController<DateTime?> controller =
          MController<DateTime?>(DateTime.utc(2026, 5, 13));
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller);
      expect(find.text('2026-05-13'), findsOneWidget);

      controller.value = null;
      await tester.pump();

      // The editable text should now be empty.
      final EditableText et = tester.widget(find.byType(EditableText));
      expect(et.controller.text, '');
    });

    testWidgets('onSubmitted normalizes typed text to canonical ISO',
        (WidgetTester tester) async {
      final List<DateTime?> reports = <DateTime?>[];
      final MController<DateTime?> controller = MController<DateTime?>(null);
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        onSubmitted: reports.add,
      );

      await tester.tap(find.byType(MDateField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '5/13/2026');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(controller.value, DateTime.utc(2026, 5, 13));
      expect(reports.last, DateTime.utc(2026, 5, 13));
      // Displayed text was normalized.
      final EditableText et = tester.widget(find.byType(EditableText));
      expect(et.controller.text, '2026-05-13');
    });
  });

  group('MDateField calendar popover open/close', () {
    testWidgets('tapping the calendar icon opens the popover',
        (WidgetTester tester) async {
      final MController<DateTime?> controller =
          MController<DateTime?>(DateTime.utc(2026, 5, 13));
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller);

      // Header isn't in the tree until the popover opens.
      expect(find.text('May 2026'), findsNothing);

      // The calendar toggle is the only GestureDetector outside the field's
      // root tap layer. Tap by finding the widget through its painter.
      await tester.tap(find.byType(CustomPaint).first);
      await tester.pump();
      // pump once for the show, again for the postFrame focus request.
      await tester.pump();

      expect(find.text('May 2026'), findsOneWidget);
    });

    testWidgets('Escape closes the popover without committing',
        (WidgetTester tester) async {
      DateTime? reported;
      final MController<DateTime?> controller = MController<DateTime?>(null);
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        onChanged: (DateTime? v) => reported = v,
        modality: MInputModality.keyboard,
      );

      await tester.tap(find.byType(CustomPaint).first);
      await tester.pump();
      await tester.pump();
      expect(find.text(_currentMonthLabel()), findsOneWidget);

      await _press(tester, LogicalKeyboardKey.escape);
      expect(find.text(_currentMonthLabel()), findsNothing);
      expect(reported, isNull);
      expect(controller.value, isNull);
    });

    testWidgets('PageDown shifts the calendar one month forward',
        (WidgetTester tester) async {
      final MController<DateTime?> controller =
          MController<DateTime?>(DateTime.utc(2026, 5, 13));
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        modality: MInputModality.keyboard,
      );

      await tester.tap(find.byType(CustomPaint).first);
      await tester.pump();
      await tester.pump();
      expect(find.text('May 2026'), findsOneWidget);

      await _press(tester, LogicalKeyboardKey.pageDown);
      expect(find.text('June 2026'), findsOneWidget);
      expect(find.text('May 2026'), findsNothing);
    });
  });

  group('MDateField calendar pick', () {
    testWidgets('Enter on a focused day commits and closes',
        (WidgetTester tester) async {
      DateTime? reported;
      final MController<DateTime?> controller =
          MController<DateTime?>(DateTime.utc(2026, 5, 13));
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        onChanged: (DateTime? v) => reported = v,
        modality: MInputModality.keyboard,
      );

      await tester.tap(find.byType(CustomPaint).first);
      await tester.pump();
      await tester.pump();

      // Move one day forward, then commit. 13 → 14 May.
      await _press(tester, LogicalKeyboardKey.arrowRight);
      await _press(tester, LogicalKeyboardKey.enter);

      expect(controller.value, DateTime.utc(2026, 5, 14));
      expect(reported, DateTime.utc(2026, 5, 14));
      // Popover dismissed.
      expect(find.text('May 2026'), findsNothing);
    });

    testWidgets('firstDate blocks selection of a too-early day',
        (WidgetTester tester) async {
      final MController<DateTime?> controller =
          MController<DateTime?>(DateTime.utc(2026, 5, 13));
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        firstDate: DateTime.utc(2026, 5, 13),
        modality: MInputModality.keyboard,
      );

      await tester.tap(find.byType(CustomPaint).first);
      await tester.pump();
      await tester.pump();

      // Move one day back (focus to May 12, which is out of bounds).
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      await _press(tester, LogicalKeyboardKey.enter);

      // Selection should not have changed.
      expect(controller.value, DateTime.utc(2026, 5, 13));
    });
  });

  group('MDateField focus + error', () {
    testWidgets('error=true does not crash and surface still receives taps',
        (WidgetTester tester) async {
      await _pumpField(tester, error: true);
      await tester.tap(find.byType(MDateField));
      await tester.pump();
      // No expect — the test is that the build path doesn't throw.
    });

    testWidgets('disabled rejects pointer events into the editor',
        (WidgetTester tester) async {
      final MController<DateTime?> controller = MController<DateTime?>(null);
      addTearDown(controller.dispose);
      await _pumpField(tester, controller: controller, enabled: false);

      await tester.tap(find.byType(MDateField));
      await tester.pump();

      // Try to type — IgnorePointer should swallow it. Use the IME path so
      // we don't depend on focus actually landing.
      final Finder editable = find.byType(EditableText);
      // EditableText is still in the tree but should be unfocused.
      final EditableText et = tester.widget(editable);
      expect(et.focusNode.hasFocus, isFalse);
    });
  });

  group('MDateField semantics', () {
    testWidgets('reports textField, label, and value (canonical text)',
        (WidgetTester tester) async {
      final MController<DateTime?> controller =
          MController<DateTime?>(DateTime.utc(2026, 5, 13));
      addTearDown(controller.dispose);

      await pumpManyApp(
        tester,
        _hosted(MDateField(
          controller: controller,
          semanticLabel: 'Start date',
        )),
        installOverlay: true,
      );

      final Semantics root = tester.widget(find
          .descendant(
            of: find.byType(MDateField),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(root.properties.textField, true);
      expect(root.properties.enabled, true);
      expect(root.properties.label, 'Start date');
      expect(root.properties.value, '2026-05-13');
    });
  });

  group('MDateField controller swap', () {
    testWidgets('swapping from internal to external controller rebinds',
        (WidgetTester tester) async {
      final MController<DateTime?> external =
          MController<DateTime?>(DateTime.utc(2030, 1, 1));
      addTearDown(external.dispose);

      final _RebindHarnessState ref = _RebindHarnessState();
      await pumpManyApp(
        tester,
        _hosted(_RebindHarness(
          stateRef: ref,
          external: external,
          initialInternal: DateTime.utc(2026, 5, 13),
        )),
        installOverlay: true,
      );
      expect(find.text('2026-05-13'), findsOneWidget);

      ref.swapToExternal();
      await tester.pump();

      expect(find.text('2030-01-01'), findsOneWidget,
          reason: 'rebind should pick up the external controller value');
    });
  });

  group('MDateField style', () {
    testWidgets('applyDelta overrides minHeight on the anchor',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _hosted(const MDateField(
          style: MDateFieldStyleDelta(minHeight: 60),
        )),
        modality: MInputModality.mouse,
        installOverlay: true,
      );

      final ConstrainedBox box = tester.widget(find
          .descendant(
            of: find.byType(MDateField),
            matching: find.byType(ConstrainedBox),
          )
          .first) as ConstrainedBox;
      expect(box.constraints.minHeight, 60);
    });
  });
}

/// Returns the month-year label for "today" so a test that doesn't pin a
/// controller value can still assert the popover header.
String _currentMonthLabel() {
  const List<String> names = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final DateTime n = DateTime.now();
  return '${names[n.month - 1]} ${n.year}';
}

/// Mirrors the rebind harness pattern from MSelect/MTextField — toggles
/// between an internally-owned controller and a caller-supplied external one
/// to exercise MDateField.didUpdateWidget's rebind path.
class _RebindHarness extends StatefulWidget {
  const _RebindHarness({
    required this.stateRef,
    required this.external,
    required this.initialInternal,
  });

  final _RebindHarnessState stateRef;
  final MController<DateTime?> external;
  final DateTime initialInternal;

  @override
  State<_RebindHarness> createState() => _RebindHarnessStateImpl();
}

class _RebindHarnessState {
  VoidCallback? _swap;
  void swapToExternal() => _swap?.call();
}

class _RebindHarnessStateImpl extends State<_RebindHarness> {
  bool _useExternal = false;

  @override
  void initState() {
    super.initState();
    widget.stateRef._swap = () => setState(() => _useExternal = true);
  }

  @override
  Widget build(BuildContext context) {
    return MDateField(
      controller: _useExternal ? widget.external : null,
      initialValue: widget.initialInternal,
    );
  }
}
