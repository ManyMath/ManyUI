import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('selects an enabled segment', (tester) async {
    final handle = tester.ensureSemantics();
    String selected = 'text';
    await pumpManyApp(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          return MSegmentedControl<String>(
            value: selected,
            onChanged: (value) => setState(() => selected = value),
            items: const <MSegmentedItem<String>>[
              MSegmentedItem(value: 'text', label: 'Text'),
              MSegmentedItem(value: 'notice', label: 'Notice'),
              MSegmentedItem(value: 'emote', label: 'Emote'),
            ],
          );
        },
      ),
    );

    await tester.tap(find.text('Notice'));
    await tester.pump();

    expect(selected, 'notice');
    expect(
      tester.getSemantics(find.bySemanticsLabel('Notice')),
      matchesSemantics(
        label: 'Notice',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('does not select a disabled segment', (tester) async {
    String selected = 'text';
    await pumpManyApp(
      tester,
      MSegmentedControl<String>(
        value: selected,
        onChanged: (value) => selected = value,
        items: const <MSegmentedItem<String>>[
          MSegmentedItem(value: 'text', label: 'Text'),
          MSegmentedItem(value: 'notice', label: 'Notice', enabled: false),
        ],
      ),
    );

    await tester.tap(find.text('Notice'));
    await tester.pump();

    expect(selected, 'text');
  });

  testWidgets('expands segments evenly when fullWidth is true', (tester) async {
    await pumpManyApp(
      tester,
      const SizedBox(
        width: 300,
        child: MSegmentedControl<String>(
          value: 'text',
          fullWidth: true,
          onChanged: _noop,
          items: <MSegmentedItem<String>>[
            MSegmentedItem(value: 'text', label: 'Text'),
            MSegmentedItem(value: 'notice', label: 'Notice'),
          ],
        ),
      ),
    );

    final textWidth = tester
        .getSize(find.widgetWithText(MButton, 'Text'))
        .width;
    final noticeWidth = tester
        .getSize(find.widgetWithText(MButton, 'Notice'))
        .width;

    expect(textWidth, closeTo(noticeWidth, 1));
  });
}

void _noop(String value) {}
