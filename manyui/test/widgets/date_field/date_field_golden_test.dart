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
  const _Case(this.name, this.filled, this.open);
  final String name;
  final bool filled;
  final bool open;
}

const List<_Case> _cases = <_Case>[
  _Case('empty', false, false),
  _Case('filled', true, false),
  _Case('open', true, true),
];

// A fixed seed date so the calendar popover always renders the same month
// regardless of when the goldens are generated.
final DateTime _seed = DateTime.utc(2026, 5, 13);

Widget _scene(MThemeData theme, _Case c) {
  // MDateField, like MTextField, expands to its parent. Bound width and let
  // the anchor row breathe vertically; the open case needs more height for
  // the popover.
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 260,
        height: c.open ? 400 : 60,
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext _) => Align(
                alignment: c.open
                    ? Alignment.topCenter
                    : Alignment.center,
                child: SizedBox(
                  width: 260,
                  child: MDateField(
                    initialValue: c.filled ? _seed : null,
                    placeholder: 'YYYY-MM-DD',
                  ),
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
  group('MDateField goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              viewport: Size(320, c.open ? 420 : 160),
              modality: MInputModality.mouse,
            );
            await tester.pump();

            if (c.open) {
              // Tap the calendar icon to open the popover. The icon's hit
              // surface is the rightmost GestureDetector inside the anchor.
              await tester.tap(
                find
                    .descendant(
                      of: find.byType(MDateField),
                      matching: find.byType(GestureDetector),
                    )
                    .last,
              );
              // Pumps: open frame, post-frame focus request, settle.
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
