import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
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

    testWidgets('deeper rows get more left padding', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        const Column(
          children: <Widget>[
            MTreeListTile(title: Text('Root'), depth: 0),
            MTreeListTile(title: Text('Child'), depth: 1),
          ],
        ),
      );

      final Container rootContainer = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(MTreeListTile).first,
              matching: find.byType(Container),
            ),
          )
          .first;
      final Container childContainer = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(MTreeListTile).last,
              matching: find.byType(Container),
            ),
          )
          .first;

      final EdgeInsetsDirectional rootPadding =
          rootContainer.padding! as EdgeInsetsDirectional;
      final EdgeInsetsDirectional childPadding =
          childContainer.padding! as EdgeInsetsDirectional;
      expect(childPadding.start, greaterThan(rootPadding.start));
    });

    testWidgets('preserves logical padding and indentation in RTL', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        const Directionality(
          textDirection: TextDirection.rtl,
          child: MTreeListTile(
            title: Text('Child'),
            depth: 1,
            style: MListTileStyleDelta(
              padding: EdgeInsetsDirectional.only(
                start: 20,
                top: 3,
                end: 4,
                bottom: 5,
              ),
            ),
          ),
        ),
      );

      final Container container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(MTreeListTile),
              matching: find.byType(Container),
            ),
          )
          .first;
      final EdgeInsetsDirectional padding =
          container.padding! as EdgeInsetsDirectional;

      expect(padding.start, 36);
      expect(padding.end, 4);
      expect(padding.top, 3);
      expect(padding.bottom, 5);
      expect(
        padding.resolve(TextDirection.rtl),
        const EdgeInsets.fromLTRB(4, 3, 36, 5),
      );
    });

    testWidgets('hides chevron tap target when onToggle is null', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        const MTreeListTile(title: Text('Leaf'), depth: 0),
      );

      expect(find.byType(MIcon), findsNothing);
    });

    testWidgets('shows a chevron when onToggle is set', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        MTreeListTile(title: const Text('Branch'), depth: 0, onToggle: () {}),
      );

      expect(find.byType(MIcon), findsOneWidget);
      expect(find.bySemanticsLabel('Expand Branch'), findsOneWidget);
    });

    testWidgets('uses the visible title as its default accessible name', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        MTreeListTile(
          title: const Text('Projects'),
          depth: 0,
          selected: true,
          onTap: () {},
        ),
      );

      expect(find.bySemanticsLabel('Projects'), findsOneWidget);
    });

    testWidgets('non-interactive selected rows expose selected state', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        const MTreeListTile(
          title: Text('Current group'),
          depth: 0,
          selected: true,
        ),
      );

      final Semantics semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(MTreeListTile),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.selected, isTrue);
      expect(find.bySemanticsLabel('Current group'), findsOneWidget);
    });

    testWidgets('tree toggle meets the touch target minimum', (
      WidgetTester tester,
    ) async {
      await pumpManyApp(
        tester,
        MTreeListTile(
          title: const Text('Touch branch'),
          depth: 0,
          onToggle: () {},
        ),
        modality: MInputModality.touch,
      );

      final Size size = tester.getSize(find.byType(MIconButton));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });
  });

  group('MTreeListTile interaction', () {
    testWidgets('onTap and onToggle fire independently', (
      WidgetTester tester,
    ) async {
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

    testWidgets('expanded flips the chevron glyph', (
      WidgetTester tester,
    ) async {
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
        MTreeListTile(title: const Text('Branch'), depth: 0, onToggle: () {}),
      );

      final MIcon icon = tester.widget<MIcon>(find.byType(MIcon));
      expect(icon.icon, MIconData.chevronRight);
    });

    testWidgets('row action is keyboard operable', (WidgetTester tester) async {
      int taps = 0;
      await pumpManyApp(
        tester,
        MTreeListTile(
          title: const Text('Keyboard branch'),
          depth: 0,
          autofocus: true,
          onTap: () => taps += 1,
        ),
        modality: MInputModality.keyboard,
      );

      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(taps, 1);
    });
  });
}
