import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

Widget _hosted(Widget child, {double width = 240}) {
  return Center(child: SizedBox(width: width, child: child));
}

void main() {
  group('MSecretField', () {
    testWidgets('starts obscured with a Show toggle',
        (WidgetTester tester) async {
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

    testWidgets('tapping the toggle reveals the text and flips the label',
        (WidgetTester tester) async {
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

    testWidgets('onChanged reports edits through to the caller',
        (WidgetTester tester) async {
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

    testWidgets('disabled toggle does not flip reveal state',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        _hosted(const MSecretField(enabled: false, initialValue: 'x')),
        installOverlay: true,
      );

      await tester.tap(find.bySemanticsLabel('Show password'),
          warnIfMissed: false);
      await tester.pump();

      final MTextField field =
          tester.widget(find.byType(MTextField)) as MTextField;
      expect(field.obscureText, isTrue);
    });
  });
}
