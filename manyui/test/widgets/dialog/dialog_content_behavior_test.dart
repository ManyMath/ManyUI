import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders title, description, content, and actions', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      MDialogContent(
        title: 'Create thing',
        description: 'Choose a name before saving.',
        content: const Text('Form fields'),
        actions: <Widget>[
          MButton(onPressed: () {}, child: const Text('Cancel')),
          MButton(onPressed: () {}, child: const Text('Save')),
        ],
      ),
    );

    expect(find.text('Create thing'), findsOneWidget);
    expect(find.text('Choose a name before saving.'), findsOneWidget);
    expect(find.text('Form fields'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('uses title and muted description typography', (
    WidgetTester tester,
  ) async {
    final MThemeData theme = MThemeData.light();
    await pumpManyApp(
      tester,
      const MDialogContent(
        title: 'Rename group',
        description: 'This is shown in the vault sidebar.',
      ),
      theme: theme,
    );

    final Text title = tester.widget<Text>(find.text('Rename group'));
    final Text description = tester.widget<Text>(
      find.text('This is shown in the vault sidebar.'),
    );

    expect(title.style?.fontSize, theme.typography.title.fontSize);
    expect(title.style?.color, theme.colors.foreground);
    expect(description.style?.fontSize, theme.typography.bodySmall.fontSize);
    expect(description.style?.color, theme.colors.mutedForeground);
  });

  testWidgets('clamps content to maxWidth', (WidgetTester tester) async {
    await pumpManyApp(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: MDialogContent(
          title: 'Wide content',
          maxWidth: 180,
          content: SizedBox(width: 800, height: 20),
        ),
      ),
    );

    final Finder clamp = find.byWidgetPredicate(
      (Widget widget) =>
          widget is ConstrainedBox && widget.constraints.maxWidth == 180,
    );
    final RenderBox box = tester.renderObject(clamp) as RenderBox;
    expect(box.size.width, lessThanOrEqualTo(180));
  });

  testWidgets('actions wrap at compact widths without overflow', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 128,
          child: MDialogContent(
            title: 'Leave?',
            actions: <Widget>[
              MButton(onPressed: () {}, child: const Text('Stay here')),
              MButton(onPressed: () {}, child: const Text('Leave now')),
            ],
          ),
        ),
      ),
      viewport: const Size(180, 240),
    );

    expect(tester.takeException(), isNull);
    final double cancelTop = tester.getTopLeft(find.text('Stay here')).dy;
    final double confirmTop = tester.getTopLeft(find.text('Leave now')).dy;
    expect(confirmTop, greaterThan(cancelTop));
  });
}
