import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

Widget _app({required Widget child}) {
  return MWidgetsApp(
    home: Center(child: SizedBox(width: 300, child: child)),
  );
}

void main() {
  group('MTextField IME connection', () {
    testWidgets('tap focuses the field and opens the text input connection',
        (WidgetTester tester) async {
      // Regression for the MFocusRing tree-shape bug: gaining focus rebuilt
      // the subtree, destroying EditableText's state right after it opened
      // its IME connection: fields highlighted but typing did nothing.
      final List<String> changes = <String>[];
      await tester.pumpWidget(_app(
        child: MTextField(onChanged: changes.add),
      ));

      await tester.tap(find.byType(MTextField));
      await tester.pump();

      expect(tester.testTextInput.hasAnyClients, isTrue,
          reason: 'focused field must hold an open text input connection');

      // enterText without an explicit showKeyboard must reach the field.
      await tester.enterText(find.byType(MTextField), 'hello');
      await tester.pump();

      expect(changes, contains('hello'));
    });
  });
}
