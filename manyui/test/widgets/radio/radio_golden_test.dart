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
  const _Case(this.name, this.selected, this.enabled);
  final String name;
  final bool selected;
  final bool enabled;
}

const List<_Case> _cases = <_Case>[
  _Case('off_enabled', false, true),
  _Case('on_enabled', true, true),
  _Case('off_disabled', false, false),
  _Case('on_disabled', true, false),
];

Widget _scene(MThemeData theme, _Case c) {
  // Group seeded with 'a' iff the case is "selected", otherwise null. The
  // captured MRadio has value 'a' — so its checked state mirrors `c.selected`.
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: MRadioGroup<String>(
        initialValue: c.selected ? 'a' : null,
        enabled: c.enabled,
        child: const MRadio<String>(value: 'a'),
      ),
    ),
  );
}

void main() {
  group('MRadio goldens — state x theme', () {
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
              find.byType(MRadio<String>),
              matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
