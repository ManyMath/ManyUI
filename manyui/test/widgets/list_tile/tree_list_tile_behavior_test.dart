import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MTreeListTile rendering', () {
    testWidgets('renders title', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MTreeListTile(title: Text('Group'), depth: 0),
      );

      expect(find.text('Group'), findsOneWidget);
    });

    testWidgets('deeper rows get more left padding', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Column(
          children: <Widget>[
            MTreeListTile(title: Text('Root'), depth: 0),
            MTreeListTile(title: Text('Child'), depth: 1),
          ],
        ),
      );

      final Container rootContainer = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(MTreeListTile).first,
          matching: find.byType(Container),
        ),
      ).first;
      final Container childContainer = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(MTreeListTile).last,
          matching: find.byType(Container),
        ),
      ).first;

      final EdgeInsetsDirectional rootPadding =
          rootContainer.padding! as EdgeInsetsDirectional;
      final EdgeInsetsDirectional childPadding =
          childContainer.padding! as EdgeInsetsDirectional;
      expect(childPadding.start, greaterThan(rootPadding.start));
    });

    testWidgets('hides chevron tap target when onToggle is null',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const MTreeListTile(title: Text('Leaf'), depth: 0),
      );

      expect(find.byType(MIcon), findsNothing);
    });

    testWidgets('shows a chevron when onToggle is set',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTreeListTile(title: const Text('Branch'), depth: 0, onToggle: () {}),
      );

      expect(find.byType(MIcon), findsOneWidget);
    });
  });

  group('MTreeListTile interaction', () {
    testWidgets('onTap and onToggle fire independently',
        (WidgetTester tester) async {
      int taps = 0;
      int toggles = 0;
      await pumpManyApp(
        tester,
        MTreeListTile(
          title: const Text('Branch'),
          depth: 0,
          onTap: () => taps++,
          onToggle: () => toggles++,
        ),
      );

      await tester.tap(find.byType(MIcon));
      await tester.pump();
      expect(toggles, 1);
      expect(taps, 0);

      await tester.tap(find.text('Branch'));
      await tester.pump();
      expect(taps, 1);
      expect(toggles, 1);
    });

    testWidgets('expanded flips the chevron glyph', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTreeListTile(
          title: const Text('Branch'),
          depth: 0,
          expanded: true,
          onToggle: () {},
        ),
      );

      final MIcon icon = tester.widget<MIcon>(find.byType(MIcon));
      expect(icon.icon, MIconData.chevronDown);
    });

    testWidgets('collapsed shows chevronRight', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        MTreeListTile(
          title: const Text('Branch'),
          depth: 0,
          onToggle: () {},
        ),
      );

      final MIcon icon = tester.widget<MIcon>(find.byType(MIcon));
      expect(icon.icon, MIconData.chevronRight);
    });
  });
}
