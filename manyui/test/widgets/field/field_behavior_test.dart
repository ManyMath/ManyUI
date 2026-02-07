import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders label, child, and description', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const MField(
        label: 'Server',
        description: 'Use host:port for local servers.',
        child: MTextField(semanticLabel: 'Server'),
      ),
    );

    expect(find.text('Server'), findsOneWidget);
    expect(find.byType(MTextField), findsOneWidget);
    expect(find.text('Use host:port for local servers.'), findsOneWidget);
  });

  testWidgets('error text replaces description and uses live region', (
    WidgetTester tester,
  ) async {
    final theme = MThemeData.light();
    await pumpManyApp(
      tester,
      const MField(
        label: 'Port',
        description: 'Usually 9993.',
        errorText: 'Enter a valid TCP port.',
        child: MTextField(error: true, semanticLabel: 'Port'),
      ),
      theme: theme,
    );

    expect(find.text('Usually 9993.'), findsNothing);
    final errorText = tester.widget<Text>(find.text('Enter a valid TCP port.'));
    expect(errorText.style?.color, theme.colors.destructive);

    final semantics = tester.widget<Semantics>(
      find
          .descendant(of: find.byType(MField), matching: find.byType(Semantics))
          .last,
    );
    expect(semantics.properties.liveRegion, isTrue);
  });

  testWidgets('tapping label routes focus when focusNode is shared', (
    WidgetTester tester,
  ) async {
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);

    await pumpManyApp(
      tester,
      MField(
        label: 'Username',
        focusNode: node,
        child: MTextField(focusNode: node, semanticLabel: 'Username'),
      ),
    );

    expect(node.hasFocus, isFalse);
    await tester.tap(find.text('Username'));
    await tester.pump();
    expect(node.hasFocus, isTrue);
  });

  testWidgets('spacing overrides affect label/control gap', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: MField(
          label: 'Name',
          spacing: 20,
          child: SizedBox(
            key: ValueKey<String>('control'),
            width: 20,
            height: 20,
          ),
        ),
      ),
    );

    final double labelBottom = tester.getBottomLeft(find.text('Name')).dy;
    final double controlTop = tester
        .getTopLeft(find.byKey(const ValueKey<String>('control')))
        .dy;
    expect(controlTop - labelBottom, closeTo(20, 0.5));
  });
}
