import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('is square and exposes its tooltip label to semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pumpManyApp(
      tester,
      Center(
        child: MIconButton(
          icon: MIconData.settings,
          label: 'Settings',
          onPressed: () {},
        ),
      ),
      modality: MInputModality.mouse,
    );

    final Size size = tester.getSize(find.byType(MButton));
    expect(size.width, closeTo(size.height, 0.01));
    expect(size.width, closeTo(36, 0.01));
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('activates from the keyboard when focused', (
    WidgetTester tester,
  ) async {
    int activations = 0;
    await pumpManyApp(
      tester,
      MIconButton(
        icon: MIconData.refresh,
        label: 'Refresh',
        autofocus: true,
        onPressed: () => activations += 1,
      ),
      modality: MInputModality.keyboard,
    );

    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(activations, 1);
  });
}
