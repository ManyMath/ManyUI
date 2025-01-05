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
  const _Case(this.name, this.value, this.enabled);
  final String name;
  final double value;
  final bool enabled;
}

const List<_Case> _cases = <_Case>[
  _Case('min_enabled', 0.0, true),
  _Case('mid_enabled', 0.5, true),
  _Case('max_enabled', 1.0, true),
  _Case('mid_disabled', 0.5, false),
];

Widget _scene(MThemeData theme, _Case c) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 200,
        child: MSlider(
          initialValue: c.value,
          enabled: c.enabled,
        ),
      ),
    ),
  );
}

void main() {
  group('MSlider goldens — value x enabled x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              viewport: const Size(280, 80),
              modality: MInputModality.mouse,
            );
            await expectLater(
              find.byType(MSlider),
              matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
