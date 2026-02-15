import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

/// Wraps [child] in a bounded SizedBox so MTextField (which expands to its
/// parent) gets a deterministic width. Tests pump this via
/// `pumpManyApp(..., installOverlay: true)` so EditableText's
/// interactive-selection magnifier path finds an ambient Overlay.
Widget _hosted(Widget child, {double width = 240}) {
  return Center(child: SizedBox(width: width, child: child));
}

Future<void> _pumpField(
  WidgetTester tester, {
  MController<String>? controller,
  String initialValue = '',
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  String? placeholder,
  bool enabled = true,
  bool readOnly = false,
  bool error = false,
  bool obscureText = false,
  int? maxLength,
  Widget? leading,
  Widget? trailing,
  FocusNode? focusNode,
  bool autofocus = false,
  List<TextInputFormatter>? inputFormatters,
  int? minLines,
  int? maxLines = 1,
  MInputModality modality = MInputModality.mouse,
}) async {
  await pumpManyApp(
    tester,
    _hosted(MTextField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      placeholder: placeholder,
      enabled: enabled,
      readOnly: readOnly,
      error: error,
      obscureText: obscureText,
      maxLength: maxLength,
      leading: leading,
      trailing: trailing,
      focusNode: focusNode,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
    )),
    modality: modality,
    installOverlay: true,
  );
  // Second pump so any focus postFrameCallbacks settle.
  await tester.pump();
}

void main() {
  group('MTextField typing', () {
    testWidgets('entering text propagates to controller and onChanged',
        (WidgetTester tester) async {
      final List<String> reports = <String>[];
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        onChanged: reports.add,
      );

      await tester.tap(find.byType(MTextField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'hello');
      await tester.pump();

      expect(controller.value, 'hello');
      // enterText fires one onChanged with the whole final string.
      expect(reports.last, 'hello');
    });

    testWidgets('tapping opens the input connection and accepts text',
        (WidgetTester tester) async {
      // Uses the real tap path, not enterText(), which calls requestKeyboard()
      // directly and so hides a broken onTap. Regression test for tapping
      // focusing the field but never opening the input connection.
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller);
      expect(tester.testTextInput.hasAnyClients, isFalse);

      await tester.tap(find.byType(MTextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.testTextInput.hasAnyClients, isTrue);

      tester.testTextInput.enterText('hello');
      await tester.pump();
      expect(controller.value, 'hello');
    });

    testWidgets('external controller mutation updates the displayed text',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('start');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller);
      expect(find.text('start'), findsOneWidget);

      controller.value = 'changed';
      await tester.pump();
      expect(find.text('changed'), findsOneWidget);
    });

    testWidgets('initialValue seeds the internally-owned controller',
        (WidgetTester tester) async {
      await _pumpField(tester, initialValue: 'seed');
      expect(find.text('seed'), findsOneWidget);
    });

    testWidgets('placeholder shows only when the field is empty',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        placeholder: 'enter something',
      );
      expect(find.text('enter something'), findsOneWidget);

      controller.value = 'x';
      await tester.pump();
      expect(find.text('enter something'), findsNothing);

      controller.value = '';
      await tester.pump();
      expect(find.text('enter something'), findsOneWidget);
    });

    testWidgets('maxLength caps the entered text',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, maxLength: 4);

      await tester.tap(find.byType(MTextField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'abcdefg');
      await tester.pump();

      expect(controller.value, 'abcd');
    });
  });

  group('MTextField multiline', () {
    testWidgets('maxLines: null lets a newline reach inputFormatters',
        (WidgetTester tester) async {
      // The motivating case: a formatter must see the raw '\n' so it can act
      // on a multi-line paste before anything strips it.
      final List<String> seen = <String>[];
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        maxLines: null,
        inputFormatters: <TextInputFormatter>[
          TextInputFormatter.withFunction((TextEditingValue _, TextEditingValue next) {
            seen.add(next.text);
            return next;
          }),
        ],
      );

      await tester.tap(find.byType(MTextField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'a\nb');
      await tester.pump();

      expect(seen, contains('a\nb'),
          reason: 'multiline must forward the raw newline to formatters');
      expect(controller.value, 'a\nb');
    });

    testWidgets('maxLines: 1 strips the newline before inputFormatters',
        (WidgetTester tester) async {
      final List<String> seen = <String>[];
      final MController<String> controller = MController<String>('');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        maxLines: 1,
        inputFormatters: <TextInputFormatter>[
          TextInputFormatter.withFunction((TextEditingValue _, TextEditingValue next) {
            seen.add(next.text);
            return next;
          }),
        ],
      );

      await tester.tap(find.byType(MTextField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'a\nb');
      await tester.pump();

      // Single-line EditableText strips '\n' before formatters run, so neither
      // the formatter nor the controller ever sees it.
      expect(seen.every((String s) => !s.contains('\n')), isTrue,
          reason: 'single-line must strip the newline before formatters');
      expect(controller.value, isNot(contains('\n')));
      expect(controller.value, 'ab');
    });

    testWidgets('grows taller as lines are added when minLines/maxLines allow',
        (WidgetTester tester) async {
      // minLines anchors the floor so the field sizes to content (between
      // minLines and maxLines) rather than greedily filling its parent. This
      // is the textarea-that-grows config.
      final MController<String> controller = MController<String>('one');
      addTearDown(controller.dispose);

      await _pumpField(tester, controller: controller, minLines: 1, maxLines: 5);
      final double oneLine =
          tester.getSize(find.byType(MTextField)).height;

      controller.value = 'one\ntwo\nthree';
      await tester.pump();
      final double threeLines =
          tester.getSize(find.byType(MTextField)).height;

      expect(threeLines, greaterThan(oneLine),
          reason: 'a growing multiline field should size to its content');
    });

    testWidgets('single-line field does not grow with newlines',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('one');
      addTearDown(controller.dispose);

      // Default maxLines: 1.
      await _pumpField(tester, controller: controller);
      final double before =
          tester.getSize(find.byType(MTextField)).height;

      controller.value = 'one\ntwo\nthree';
      await tester.pump();
      final double after = tester.getSize(find.byType(MTextField)).height;

      expect(after, before,
          reason: 'single-line height must not change with newlines');
    });

    testWidgets('single-line defaults keyboardType to text',
        (WidgetTester tester) async {
      await _pumpField(tester, maxLines: 1);
      final EditableText editable =
          tester.widget(find.byType(EditableText)) as EditableText;
      expect(editable.keyboardType, TextInputType.text);
    });

    testWidgets('multiline defaults keyboardType to multiline',
        (WidgetTester tester) async {
      await _pumpField(tester, maxLines: null);
      final EditableText editable =
          tester.widget(find.byType(EditableText)) as EditableText;
      expect(editable.keyboardType, TextInputType.multiline);
    });

    testWidgets('an explicit keyboardType is not overridden by multiline',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _hosted(const MTextField(
          maxLines: null,
          keyboardType: TextInputType.number,
        )),
      );
      await tester.pump();
      final EditableText editable =
          tester.widget(find.byType(EditableText)) as EditableText;
      expect(editable.keyboardType, TextInputType.number);
    });
  });

  group('MTextField focus + enable', () {
    testWidgets('tapping the surface routes focus into the editor',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await _pumpField(tester, focusNode: node);
      expect(node.hasFocus, isFalse);

      await tester.tap(find.byType(MTextField));
      await tester.pump();

      expect(node.hasFocus, isTrue);
    });

    testWidgets('disabled field refuses focus and edits',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<String> controller = MController<String>('seed');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        enabled: false,
        focusNode: node,
      );

      await tester.tap(find.byType(MTextField), warnIfMissed: false);
      await tester.pump();
      expect(node.hasFocus, isFalse);

      // The editor is read-only when disabled — enterText still types via the
      // engine's TextInput hookup, but EditableText drops the input when
      // readOnly is set. We assert the value didn't change.
      await tester.enterText(find.byType(EditableText), 'nope');
      await tester.pump();
      expect(controller.value, 'seed');
    });

    testWidgets('readOnly accepts focus but refuses edits',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      final MController<String> controller = MController<String>('seed');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        controller: controller,
        readOnly: true,
        focusNode: node,
      );

      await tester.tap(find.byType(MTextField));
      await tester.pump();
      expect(node.hasFocus, isTrue);

      await tester.enterText(find.byType(EditableText), 'nope');
      await tester.pump();
      expect(controller.value, 'seed');
    });

    testWidgets('autofocus requests focus on mount',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await _pumpField(tester, focusNode: node, autofocus: true);
      // Autofocus runs in the post-frame; pumpField already pumps twice.
      expect(node.hasFocus, isTrue);
    });
  });

  group('MTextField undo/redo', () {
    testWidgets(
        'EditableText receives an UndoHistoryController so Cmd-Z wiring is live',
        (WidgetTester tester) async {
      await _pumpField(tester, initialValue: 'hello');

      final EditableText editable =
          tester.widget(find.byType(EditableText)) as EditableText;
      expect(editable.undoController, isNotNull,
          reason: 'MTextField must hand EditableText an UndoHistoryController '
              'so the platform Cmd/Ctrl-Z shortcuts route through it');
    });
  });

  group('MTextField onSubmitted', () {
    testWidgets('Enter while focused fires onSubmitted with the current text',
        (WidgetTester tester) async {
      String? submitted;
      await _pumpField(
        tester,
        onSubmitted: (String v) => submitted = v,
      );

      // Tap to establish focus and the IME connection — autofocus alone
      // doesn't wire the test text-input channel to this EditableText.
      await tester.tap(find.byType(MTextField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'final');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, 'final');
    });
  });

  group('MTextField controller rebinding', () {
    testWidgets(
        'swapping from internal to external controller picks up the new value',
        (WidgetTester tester) async {
      final MController<String> external = MController<String>('external');
      addTearDown(external.dispose);

      final _RebindHarnessState ref = _RebindHarnessState();
      await pumpManyApp(
        tester,
        _hosted(_RebindHarness(
          stateRef: ref,
          external: external,
          initialInternal: 'internal',
        )),
        installOverlay: true,
      );
      expect(find.text('internal'), findsOneWidget);

      ref.swapToExternal();
      await tester.pump();

      expect(find.text('external'), findsOneWidget,
          reason: 'rebind should pick up the external controller value');
    });

    testWidgets('caller-supplied controller is not disposed when the field unmounts',
        (WidgetTester tester) async {
      final MController<String> controller = MController<String>('x');

      await _pumpField(tester, controller: controller);
      await pumpManyApp(tester, const SizedBox.shrink());

      // Should be alive after the widget unmounts.
      expect(() => controller.value = 'still-here', returnsNormally);
      controller.dispose();
    });
  });

  group('MTextField error state', () {
    testWidgets('error=true swaps the border to colors.destructive',
        (WidgetTester tester) async {
      await _pumpField(tester, error: true);

      // The first DecoratedBox inside the field carries the visible border.
      final DecoratedBox box = tester.widget(find
          .descendant(
            of: find.byType(MTextField),
            matching: find.byType(DecoratedBox),
          )
          .first) as DecoratedBox;
      final BoxDecoration deco = box.decoration as BoxDecoration;
      final BorderSide side = (deco.border! as Border).top;
      expect(side.color, MThemeData.light().colors.destructive);
    });

    testWidgets('error=false focused-border swaps to colors.ring',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await _pumpField(tester, focusNode: node, autofocus: true);

      final DecoratedBox box = tester.widget(find
          .descendant(
            of: find.byType(MTextField),
            matching: find.byType(DecoratedBox),
          )
          .first) as DecoratedBox;
      final BoxDecoration deco = box.decoration as BoxDecoration;
      final BorderSide side = (deco.border! as Border).top;
      expect(side.color, MThemeData.light().colors.ring);
    });
  });

  group('MTextField modality', () {
    testWidgets('mouse modality renders the compact field height',
        (WidgetTester tester) async {
      await _pumpField(tester, modality: MInputModality.mouse);
      final ConstrainedBox box = tester.widget(find
          .descendant(
            of: find.byType(MTextField),
            matching: find.byType(ConstrainedBox),
          )
          .first) as ConstrainedBox;
      expect(box.constraints.minHeight, 36);
    });

    testWidgets('touch modality bumps to the larger hit target',
        (WidgetTester tester) async {
      await _pumpField(tester, modality: MInputModality.touch);
      final ConstrainedBox box = tester.widget(find
          .descendant(
            of: find.byType(MTextField),
            matching: find.byType(ConstrainedBox),
          )
          .first) as ConstrainedBox;
      expect(box.constraints.minHeight, 44);
    });
  });

  group('MTextField semantics', () {
    testWidgets('reports textField, enabled, label, and value',
        (WidgetTester tester) async {
      await _pumpField(
        tester,
        initialValue: 'visible',
        placeholder: 'unused-here',
      );

      final Semantics s = tester.widget(find
          .descendant(
            of: find.byType(MTextField),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(s.properties.textField, true);
      expect(s.properties.enabled, true);
      expect(s.properties.value, 'visible');
    });

    testWidgets('disabled field reports enabled=false',
        (WidgetTester tester) async {
      await _pumpField(tester, enabled: false);

      final Semantics s = tester.widget(find
          .descendant(
            of: find.byType(MTextField),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(s.properties.enabled, false);
    });

    testWidgets('obscureText is reflected in semantics',
        (WidgetTester tester) async {
      await _pumpField(tester, obscureText: true);

      final Semantics s = tester.widget(find
          .descendant(
            of: find.byType(MTextField),
            matching: find.byType(Semantics),
          )
          .first) as Semantics;
      expect(s.properties.obscured, true);
    });
  });

  group('MTextField style', () {
    testWidgets('applyDelta overrides minHeight',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _hosted(const MTextField(
          style: MTextFieldStyleDelta(minHeight: 60),
        )),
        modality: MInputModality.mouse,
        installOverlay: true,
      );

      final ConstrainedBox box = tester.widget(find
          .descendant(
            of: find.byType(MTextField),
            matching: find.byType(ConstrainedBox),
          )
          .first) as ConstrainedBox;
      expect(box.constraints.minHeight, 60);
    });
  });
}

/// Toggles between an internally-owned controller and a caller-supplied
/// external one, exercising MTextField.didUpdateWidget's rebind path without
/// re-mounting the whole subtree (mirrors the MSelect rebind harness).
class _RebindHarness extends StatefulWidget {
  const _RebindHarness({
    required this.stateRef,
    required this.external,
    required this.initialInternal,
  });

  final _RebindHarnessState stateRef;
  final MController<String> external;
  final String initialInternal;

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
    return MTextField(
      controller: _useExternal ? widget.external : null,
      initialValue: widget.initialInternal,
    );
  }
}
