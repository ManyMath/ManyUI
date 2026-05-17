import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

Widget _hosted(Widget child, {double width = 240}) {
  return Center(
    child: SizedBox(width: width, child: child),
  );
}

void main() {
  group('MSecretField', () {
    testWidgets('starts obscured with a Show toggle', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        _hosted(const MSecretField(initialValue: 'hunter2')),
        installOverlay: true,
      );

      final MTextField field =
          tester.widget(find.byType(MTextField)) as MTextField;
      expect(field.obscureText, isTrue);
      expect(find.bySemanticsLabel('Show password'), findsOneWidget);
    });

    testWidgets('forwards password autofill hints', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        _hosted(
          const MSecretField(autofillHints: <String>[AutofillHints.password]),
        ),
        installOverlay: true,
      );

      final field = tester.widget<MTextField>(find.byType(MTextField));
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.autofillHints, <String>[AutofillHints.password]);
      expect(editable.autofillHints, <String>[AutofillHints.password]);
    });

    for (final (modality, expectedHeight, expectedButtonSize)
        in <(MInputModality, double, double)>[
          (MInputModality.mouse, 36, 32),
          (MInputModality.touch, 44, 40),
        ]) {
      testWidgets(
        'matches a plain field height under ${modality.name} modality',
        (WidgetTester tester) async {
          const plainKey = Key('plain');
          const secretKey = Key('secret');
          await pumpManyApp(
            tester,
            _hosted(
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MTextField(key: plainKey),
                  MSecretField(key: secretKey),
                ],
              ),
            ),
            installOverlay: true,
            modality: modality,
          );

          expect(tester.getSize(find.byKey(plainKey)).height, expectedHeight);
          expect(tester.getSize(find.byKey(secretKey)).height, expectedHeight);
          expect(
            tester.getSize(find.byType(MIconButton)),
            Size.square(expectedButtonSize),
          );
        },
      );
    }

    testWidgets('tapping the toggle reveals the text and flips the label', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        _hosted(const MSecretField(initialValue: 'hunter2')),
        installOverlay: true,
      );

      await tester.tap(find.bySemanticsLabel('Show password'));
      await tester.pump();

      final MTextField field =
          tester.widget(find.byType(MTextField)) as MTextField;
      expect(field.obscureText, isFalse);
      expect(find.bySemanticsLabel('Hide password'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Hide password'));
      await tester.pump();

      final MTextField reobscured =
          tester.widget(find.byType(MTextField)) as MTextField;
      expect(reobscured.obscureText, isTrue);
    });

    testWidgets('focus traversal reaches the toggle and Enter activates it', (
      WidgetTester tester,
    ) async {
      final fieldFocus = FocusNode(debugLabel: 'secret field');
      addTearDown(fieldFocus.dispose);
      await pumpManyApp(
        tester,
        _hosted(MSecretField(initialValue: 'hunter2', focusNode: fieldFocus)),
        installOverlay: true,
        modality: MInputModality.keyboard,
      );

      fieldFocus.requestFocus();
      await tester.pump();
      expect(fieldFocus.hasFocus, isTrue);

      fieldFocus.nextFocus();
      await tester.pump();
      expect(fieldFocus.hasFocus, isFalse);
      expect(FocusManager.instance.primaryFocus, isNotNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      final field = tester.widget<MTextField>(find.byType(MTextField));
      expect(field.obscureText, isFalse);
      expect(find.bySemanticsLabel('Hide password'), findsOneWidget);
    });

    testWidgets('onChanged reports edits through to the caller', (
      WidgetTester tester,
    ) async {
      final List<String> reports = <String>[];
      await pumpManyApp(
        tester,
        _hosted(MSecretField(onChanged: reports.add)),
        installOverlay: true,
      );

      await tester.tap(find.byType(MSecretField));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'sekret');
      await tester.pump();

      expect(reports.last, 'sekret');
    });

    testWidgets('disabled toggle does not flip reveal state', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        _hosted(const MSecretField(enabled: false, initialValue: 'x')),
        installOverlay: true,
      );

      await tester.tap(
        find.bySemanticsLabel('Show password'),
        warnIfMissed: false,
      );
      await tester.pump();

      final MTextField field =
          tester.widget(find.byType(MTextField)) as MTextField;
      expect(field.obscureText, isTrue);
    });
  });
}
