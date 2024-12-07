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

Widget _scene(MThemeData theme, MBadgeVariant variant) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: MBadge(variant: variant, child: const Text('Badge')),
    ),
  );
}

void main() {
  group('MBadge goldens — variant x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final MBadgeVariant variant in MBadgeVariant.values) {
        testWidgets(
          '${variant.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, variant),
              theme: mode.data,
              viewport: const Size(800, 400),
            );
            await expectLater(
              find.byType(MBadge),
              matchesGoldenFile('goldens/${variant.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
