import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders title, description, leading, and actions', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      MEmptyState(
        leading: const MIcon(MIconData.check),
        title: 'No rooms yet',
        description: 'Create or join a room to start chatting.',
        actions: <Widget>[
          MButton(onPressed: () {}, child: const Text('Create room')),
          MButton(
            variant: MButtonVariant.ghost,
            onPressed: () {},
            child: const Text('Join room'),
          ),
        ],
      ),
    );

    expect(find.text('No rooms yet'), findsOneWidget);
    expect(
      find.text('Create or join a room to start chatting.'),
      findsOneWidget,
    );
    expect(find.byType(MIcon), findsOneWidget);
    expect(find.text('Create room'), findsOneWidget);
    expect(find.text('Join room'), findsOneWidget);
  });

  testWidgets('omits optional regions when only a title is supplied', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(tester, const MEmptyState(title: 'Select an entry'));

    expect(find.text('Select an entry'), findsOneWidget);
    expect(find.byType(MIcon), findsNothing);
    expect(find.byType(MButton), findsNothing);
  });

  testWidgets('uses muted typography for title and description', (
    WidgetTester tester,
  ) async {
    final theme = MThemeData.light();
    await pumpManyApp(
      tester,
      const MEmptyState(
        title: 'Nothing selected',
        description: 'Choose an item from the list.',
      ),
      theme: theme,
    );

    final title = tester.widget<Text>(find.text('Nothing selected'));
    final description = tester.widget<Text>(
      find.text('Choose an item from the list.'),
    );
    expect(title.style?.fontSize, theme.typography.body.fontSize);
    expect(title.style?.color, theme.colors.mutedForeground);
    expect(description.style?.fontSize, theme.typography.bodySmall.fontSize);
    expect(description.style?.color, theme.colors.mutedForeground);
  });

  testWidgets('wraps actions at compact widths without overflow', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 180,
          child: MEmptyState(
            title: 'No rooms yet',
            actions: <Widget>[
              MButton(onPressed: () {}, child: const Text('Create room')),
              MButton(onPressed: () {}, child: const Text('Join room')),
            ],
          ),
        ),
      ),
      viewport: const Size(220, 240),
    );

    expect(tester.takeException(), isNull);
    final createTop = tester.getTopLeft(find.text('Create room')).dy;
    final joinTop = tester.getTopLeft(find.text('Join room')).dy;
    expect(joinTop, greaterThan(createTop));
  });

  testWidgets('can align content to the start edge', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 320,
          child: MEmptyState(
            title: 'No matches',
            description: 'Adjust the search query.',
            alignment: MEmptyStateAlignment.start,
          ),
        ),
      ),
    );

    final titleLeft = tester.getTopLeft(find.text('No matches')).dx;
    final descriptionLeft = tester
        .getTopLeft(find.text('Adjust the search query.'))
        .dx;
    expect((descriptionLeft - titleLeft).abs(), lessThan(1));
  });
}
