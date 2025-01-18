@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

class _ThemeMode {
  const _ThemeMode(this.name, this.data);
  final String name;
  final MThemeData data;
}

final List<_ThemeMode> _themes = <_ThemeMode>[
  _ThemeMode('light', MThemeData.light()),
  _ThemeMode('dark', MThemeData.dark()),
];

class _Case {
  const _Case(this.name, this.open, this.selected);
  final String name;
  final bool open;
  final bool selected;
}

const List<_Case> _cases = <_Case>[
  _Case('closed_unselected', false, false),
  _Case('closed_selected', false, true),
  _Case('open_unselected', true, false),
  _Case('open_selected', true, true),
];

const List<MSelectItem<String>> _fruits = <MSelectItem<String>>[
  MSelectItem<String>(value: 'apple', label: 'Apple'),
  MSelectItem<String>(value: 'banana', label: 'Banana'),
  MSelectItem<String>(value: 'cherry', label: 'Cherry'),
];

Widget _scene(MThemeData theme, _Case c) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 220,
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext _) => Center(
                child: MSelect<String>(
                  items: _fruits,
                  placeholder: 'Pick a fruit',
                  initialValue: c.selected ? 'banana' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('MSelect goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              // Larger viewport so the open-state popover has room.
              viewport: const Size(320, 320),
              modality: MInputModality.mouse,
            );
            await tester.pump();

            if (c.open) {
              await tester.tap(find.byType(MSelect<String>));
              // Three pumps: open frame, focus postFrameCallback, settle.
              await tester.pump();
              await tester.pump();
              await tester.pump();
            }

            await expectLater(
              find.byType(Overlay).first,
              matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
