@TestOn('browser')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

void main() {
  testWidgets('defers descendant focus until the first layout completes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MWidgetsApp(
        home: Focus(autofocus: true, child: Text('Focusable content')),
      ),
    );

    expect(
      tester
          .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
          .any((ExcludeFocus widget) => widget.excluding),
      isTrue,
    );

    await tester.pump();

    expect(
      tester
          .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
          .any((ExcludeFocus widget) => widget.excluding),
      isFalse,
    );
  });
}
