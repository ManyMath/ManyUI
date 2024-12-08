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

Widget _scene(MThemeData theme, MAvatarShape shape) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: MAvatar(
        size: 64,
        shape: shape,
        fallback: const Text('JD'),
      ),
    ),
  );
}

void main() {
  group('MAvatar goldens — fallback x shape x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final MAvatarShape shape in MAvatarShape.values) {
        testWidgets(
          '${shape.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, shape),
              theme: mode.data,
              viewport: const Size(800, 400),
            );
            await expectLater(
              find.byType(MAvatar),
              matchesGoldenFile('goldens/fallback_${shape.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
