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
  const _Case(this.name, this.checked, this.enabled);
  final String name;
  final bool checked;
  final bool enabled;
}

const List<_Case> _cases = <_Case>[
  _Case('unchecked_enabled', false, true),
  _Case('checked_enabled', true, true),
  _Case('unchecked_disabled', false, false),
  _Case('checked_disabled', true, false),
];

Widget _scene(MThemeData theme, _Case c) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: MCheckbox(
        initialValue: c.checked,
        enabled: c.enabled,
      ),
    ),
  );
}

void main() {
  group('MCheckbox goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              viewport: const Size(200, 200),
              modality: MInputModality.mouse,
            );
            await expectLater(
              find.byType(MCheckbox),
              matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
