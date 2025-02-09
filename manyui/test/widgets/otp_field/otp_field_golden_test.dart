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
  const _Case(this.name, this.length, this.value, {this.enabled = true});
  final String name;
  final int length;
  final String value;
  final bool enabled;
}

const List<_Case> _cases = <_Case>[
  // Idle: no input, full-length row.
  _Case('empty', 6, ''),
  // Partial fill: two cells filled, the rest still showing the idle border.
  _Case('partial', 6, '42'),
  // Completed: every cell holds a digit; "filled" borders kick in.
  _Case('filled', 6, '123456'),
  // Disabled: shorter row, dimmed via disabledOpacity.
  _Case('disabled_short', 4, '12', enabled: false),
];

Widget _scene(MThemeData theme, _Case c) {
  return ColoredBox(
    color: theme.colors.background,
    // MOTPField uses MainAxisSize.min so it sizes to its content. Wrap in
    // a tall enough surface to keep the cell border + focus ring entirely
    // inside the captured PNG.
    child: Center(
      child: SizedBox(
        width: 360,
        height: 80,
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext _) => Center(
                child: MOTPField(
                  length: c.length,
                  initialValue: c.value,
                  enabled: c.enabled,
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
  group('MOTPField goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              viewport: const Size(400, 120),
              modality: MInputModality.mouse,
            );
            await tester.pump();

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
