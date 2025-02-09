import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

/// Wraps [child] in a bounded SizedBox + Center so MOTPField gets a
/// deterministic layout. Tests pump via
/// `pumpManyApp(..., installOverlay: true)` so EditableText's magnifier
/// has an ambient Overlay.
Widget _hosted(Widget child) {
  return Center(child: SizedBox(width: 360, child: child));
}

Future<void> _pumpField(
  WidgetTester tester, {
  MController<String>? controller,
  String initialValue = '',
  int length = 6,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onCompleted,
  bool enabled = true,
  bool readOnly = false,
  bool error = false,
  bool obscureText = false,
  RegExp? inputFilter,
  bool autofocus = false,
  MInputModality modality = MInputModality.mouse,
}) async {
  await pumpManyApp(
    tester,
    _hosted(MOTPField(
      controller: controller,
      initialValue: initialValue,
      length: length,
      onChanged: onChanged,
      onCompleted: onCompleted,
      enabled: enabled,
      readOnly: readOnly,
      error: error,
      obscureText: obscureText,
      inputFilter: inputFilter,
      autofocus: autofocus,
    )),
    modality: modality,
    installOverlay: true,
  );
  // Second pump so any focus postFrameCallbacks settle.
  await tester.pump();
}

/// Returns the [EditableText] for cell [i] inside the MOTPField subtree.
Finder _cellEditable(int i) => find
    .descendant(
      of: find.byType(MOTPField),
      matching: find.byType(EditableText),
    )
    .at(i);

/// Returns the [FocusNode] currently attached to the [i]th cell.
FocusNode _cellFocus(WidgetTester tester, int i) {
  final EditableText et = tester.widget(_cellEditable(i)) as EditableText;
  return et.focusNode;
}

Future<void> _typeInto(WidgetTester tester, int i, String text) async {
  await tester.tap(_cellEditable(i));
  await tester.pump();
  await tester.enterText(_cellEditable(i), text);
  await tester.pump();
}

void main() {
  group('MOTPField typing → assembled value', () {
    testWidgets('typing one character per cell assembles the full value',
        (WidgetTester tester) async {
      final List<String> reported = <String>[];
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        length: 4,
        onChanged: reported.add,
      );

      await _typeInto(tester, 0, '1');
      await _typeInto(tester, 1, '2');
      await _typeInto(tester, 2, '3');
      await _typeInto(tester, 3, '4');

      expect(controller.value, '1234');
      expect(reported.last, '1234');
    });

    testWidgets('typing into a cell auto-advances focus to the next cell',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 4);

      await _typeInto(tester, 0, '7');

      expect(_cellFocus(tester, 1).hasFocus, isTrue,
          reason: 'focus should move to cell 1 after typing into cell 0');
    });

    testWidgets('typing into the last cell does not crash and keeps focus',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 3);

      await _typeInto(tester, 0, '1');
      await _typeInto(tester, 1, '2');
      await _typeInto(tester, 2, '3');

      // No cell to advance to; focus should stay on cell 2.
      expect(_cellFocus(tester, 2).hasFocus, isTrue);
    });

    testWidgets('inputFilter rejects characters outside the class',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 4);

      // Default filter is digits-only.
      await _typeInto(tester, 0, 'a');
      final EditableText et = tester.widget(_cellEditable(0)) as EditableText;
      expect(et.controller.text, '',
          reason: 'letter should be rejected by the digit-only filter');
    });

    testWidgets('alphanumeric inputFilter accepts letters',
        (WidgetTester tester) async {
      await _pumpField(
        tester,
        length: 4,
        inputFilter: RegExp(r'[A-Za-z0-9]'),
      );

      await _typeInto(tester, 0, 'A');
      final EditableText et = tester.widget(_cellEditable(0)) as EditableText;
      expect(et.controller.text, 'A');
    });
  });

  group('MOTPField backspace nav', () {
    testWidgets('backspace on empty cell jumps to previous and clears it',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, length: 4);

      await _typeInto(tester, 0, '1');
      await _typeInto(tester, 1, '2');
      // After typing into cell 1, focus is on cell 2 (auto-advance).
      expect(_cellFocus(tester, 2).hasFocus, isTrue);

      // Cell 2 is empty. Backspace should move to cell 1 and clear it.
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(_cellFocus(tester, 1).hasFocus, isTrue);
      final EditableText et1 = tester.widget(_cellEditable(1)) as EditableText;
      expect(et1.controller.text, '');
      expect(controller.value, '1');
    });

    testWidgets('backspace on first empty cell does nothing destructive',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 4);

      // Focus first cell, then send backspace on empty cell 0.
      await tester.tap(_cellEditable(0));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      // Focus should still be on cell 0.
      expect(_cellFocus(tester, 0).hasFocus, isTrue);
    });
  });

  group('MOTPField arrow + Home/End nav', () {
    testWidgets('arrow right and left move focus between cells',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 4);

      await tester.tap(_cellEditable(0));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_cellFocus(tester, 1).hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_cellFocus(tester, 2).hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_cellFocus(tester, 1).hasFocus, isTrue);
    });

    testWidgets('Home and End jump to first and last cells',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 6);

      await tester.tap(_cellEditable(2));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(_cellFocus(tester, 5).hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(_cellFocus(tester, 0).hasFocus, isTrue);
    });
  });

  group('MOTPField paste distribution', () {
    testWidgets('multi-char paste fills cells left-to-right from the focused cell',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, length: 6);

      // Simulate a paste landing in cell 0 by writing a long string to its
      // EditableText. The widget's editing listener detects the multi-char
      // value and distributes characters across cells.
      await tester.tap(_cellEditable(0));
      await tester.pump();
      await tester.enterText(_cellEditable(0), '123456');
      await tester.pump();

      expect(controller.value, '123456');
      for (int i = 0; i < 6; i++) {
        final EditableText et = tester.widget(_cellEditable(i)) as EditableText;
        expect(et.controller.text, '${i + 1}',
            reason: 'cell $i should hold ${i + 1}');
      }
    });

    testWidgets('paste longer than length is truncated to fit',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, length: 4);

      await tester.tap(_cellEditable(0));
      await tester.pump();
      await tester.enterText(_cellEditable(0), '123456789');
      await tester.pump();

      expect(controller.value, '1234');
    });

    testWidgets('paste filters out characters outside inputFilter',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, length: 6);

      await tester.tap(_cellEditable(0));
      await tester.pump();
      // The space and dashes are filtered out by the digit-only default.
      await tester.enterText(_cellEditable(0), '12 34-56');
      await tester.pump();

      expect(controller.value, '123456');
    });

    testWidgets('paste into a middle cell distributes from that cell forward',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, length: 6);

      // Pre-fill the first two cells.
      await _typeInto(tester, 0, '9');
      await _typeInto(tester, 1, '8');
      // Focus jumps to cell 2; paste starting there.
      await tester.enterText(_cellEditable(2), '1234');
      await tester.pump();

      expect(controller.value, '981234');
    });
  });

  group('MOTPField onCompleted', () {
    testWidgets('fires once when the final cell is filled by typing',
        (WidgetTester tester) async {
      int fires = 0;
      String? lastValue;
      await _pumpField(
        tester,
        length: 3,
        onCompleted: (String v) {
          fires++;
          lastValue = v;
        },
      );

      await _typeInto(tester, 0, '1');
      await _typeInto(tester, 1, '2');
      expect(fires, 0);
      await _typeInto(tester, 2, '3');
      expect(fires, 1);
      expect(lastValue, '123');
    });

    testWidgets('fires once when paste fills every cell',
        (WidgetTester tester) async {
      int fires = 0;
      await _pumpField(
        tester,
        length: 4,
        onCompleted: (String _) => fires++,
      );

      await tester.tap(_cellEditable(0));
      await tester.pump();
      await tester.enterText(_cellEditable(0), '1234');
      await tester.pump();

      expect(fires, 1);
    });

    testWidgets('re-fires after re-completing post-backspace',
        (WidgetTester tester) async {
      int fires = 0;
      await _pumpField(
        tester,
        length: 3,
        onCompleted: (String _) => fires++,
      );

      await _typeInto(tester, 0, '1');
      await _typeInto(tester, 1, '2');
      await _typeInto(tester, 2, '3');
      expect(fires, 1);

      // Backspace on cell 2 (filled) clears it via EditableText.
      await tester.tap(_cellEditable(2));
      await tester.pump();
      // Select-all then delete clears the cell.
      final EditableText et2 = tester.widget(_cellEditable(2)) as EditableText;
      et2.controller.text = '';
      await tester.pump();

      // Re-fill the last cell — should fire a second onCompleted.
      await _typeInto(tester, 2, '9');
      expect(fires, 2);
    });
  });

  group('MOTPField semantics', () {
    testWidgets('row exposes textField:true with the assembled value',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 4, initialValue: '12');

      final Semantics row = tester.widget(
        find.descendant(of: find.byType(MOTPField), matching: find.byType(Semantics)).first,
      ) as Semantics;
      expect(row.properties.textField, isTrue);
      expect(row.properties.value, '12');
    });

    testWidgets('each cell carries its own "OTP digit N of M" label',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 4);

      expect(find.bySemanticsLabel('OTP digit 1 of 4'), findsOneWidget);
      expect(find.bySemanticsLabel('OTP digit 2 of 4'), findsOneWidget);
      expect(find.bySemanticsLabel('OTP digit 3 of 4'), findsOneWidget);
      expect(find.bySemanticsLabel('OTP digit 4 of 4'), findsOneWidget);
    });

    testWidgets('obscureText blanks the row value to avoid leaking secrets',
        (WidgetTester tester) async {
      await _pumpField(
        tester,
        length: 4,
        initialValue: '9876',
        obscureText: true,
      );

      final Semantics row = tester.widget(
        find.descendant(of: find.byType(MOTPField), matching: find.byType(Semantics)).first,
      ) as Semantics;
      expect(row.properties.value, '',
          reason: 'obscureText should mask the assembled value in semantics');
    });
  });

  group('MOTPField controller bridge', () {
    testWidgets('external mutation pushes text into the cells',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, length: 4);

      controller.value = '42';
      await tester.pump();

      final EditableText et0 = tester.widget(_cellEditable(0)) as EditableText;
      final EditableText et1 = tester.widget(_cellEditable(1)) as EditableText;
      final EditableText et2 = tester.widget(_cellEditable(2)) as EditableText;
      expect(et0.controller.text, '4');
      expect(et1.controller.text, '2');
      expect(et2.controller.text, '');
    });

    testWidgets('swapping from internal to external controller rebinds',
        (WidgetTester tester) async {
      final MController<String> external = MController<String>('999');
      addTearDown(external.dispose);

      final _RebindHarnessState ref = _RebindHarnessState();
      await pumpManyApp(
        tester,
        _hosted(_RebindHarness(stateRef: ref, external: external)),
        installOverlay: true,
      );

      // Internal seed is '111'.
      EditableText et0 = tester.widget(_cellEditable(0)) as EditableText;
      expect(et0.controller.text, '1');

      ref.swapToExternal();
      await tester.pump();

      et0 = tester.widget(_cellEditable(0)) as EditableText;
      final EditableText et1 = tester.widget(_cellEditable(1)) as EditableText;
      final EditableText et2 = tester.widget(_cellEditable(2)) as EditableText;
      expect(et0.controller.text, '9');
      expect(et1.controller.text, '9');
      expect(et2.controller.text, '9');
    });
  });

  group('MOTPField modality sizing', () {
    testWidgets('touch modality renders larger cells than mouse',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 4, modality: MInputModality.mouse);
      final Size mouseSize = tester.getSize(
        find.descendant(of: find.byType(MOTPField), matching: find.byType(DecoratedBox)).first,
      );

      await _pumpField(tester, length: 4, modality: MInputModality.touch);
      final Size touchSize = tester.getSize(
        find.descendant(of: find.byType(MOTPField), matching: find.byType(DecoratedBox)).first,
      );

      expect(touchSize.width, greaterThan(mouseSize.width));
      expect(touchSize.height, greaterThan(mouseSize.height));
    });
  });

  group('MOTPField enabled / readOnly', () {
    testWidgets('disabled field rejects pointer events on cells',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, length: 4, enabled: false);

      await tester.tap(_cellEditable(0), warnIfMissed: false);
      await tester.pump();
      expect(_cellFocus(tester, 0).hasFocus, isFalse);

      // Even if we forced focus and tried typing, EditableText is
      // readOnly:true when enabled is false.
      final EditableText et0 = tester.widget(_cellEditable(0)) as EditableText;
      expect(et0.readOnly, isTrue);
    });

    testWidgets('readOnly accepts focus but rejects edits',
        (WidgetTester tester) async {
      await _pumpField(tester, length: 4, readOnly: true);

      final EditableText et0 = tester.widget(_cellEditable(0)) as EditableText;
      expect(et0.readOnly, isTrue);
    });
  });

  group('MOTPField style', () {
    testWidgets('applyDelta overrides cellSize', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _hosted(const MOTPField(
          length: 4,
          style: MOTPFieldStyleDelta(cellSize: 60),
        )),
        modality: MInputModality.mouse,
        installOverlay: true,
      );

      final Size first = tester.getSize(
        find.descendant(of: find.byType(MOTPField), matching: find.byType(SizedBox)).first,
      );
      // The first SizedBox in the cell subtree is the cell wrapper.
      expect(first.width, 60);
      expect(first.height, 60);
    });
  });
}

/// Mirrors the rebind harness pattern from MTextField/MDateField — toggles
/// between an internally-owned controller (seeded '111') and a caller-
/// supplied external one to exercise didUpdateWidget's rebind path.
class _RebindHarness extends StatefulWidget {
  const _RebindHarness({required this.stateRef, required this.external});

  final _RebindHarnessState stateRef;
  final MController<String> external;

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
    return MOTPField(
      controller: _useExternal ? widget.external : null,
      length: 3,
      initialValue: '111',
    );
  }
}
