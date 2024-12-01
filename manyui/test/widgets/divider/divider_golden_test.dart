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

Widget _horizontalScene(MThemeData theme) {
  return ColoredBox(
    color: theme.colors.background,
    child: const Center(
      child: SizedBox(
        width: 240,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Above'),
            SizedBox(height: 12),
            MDivider(),
            SizedBox(height: 12),
            Text('Below'),
          ],
        ),
      ),
    ),
  );
}

Widget _verticalScene(MThemeData theme) {
  return ColoredBox(
    color: theme.colors.background,
    child: const Center(
      child: SizedBox(
        height: 120,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: Text('Left')),
            SizedBox(width: 12),
            MDivider(orientation: MDividerOrientation.vertical),
            SizedBox(width: 12),
            Center(child: Text('Right')),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('MDivider goldens — orientation x theme', () {
    for (final _ThemeMode mode in _themes) {
      testWidgets(
        'horizontal ${mode.name}',
        (WidgetTester tester) async {
          await pumpManyApp(
            tester,
            _horizontalScene(mode.data),
            theme: mode.data,
            viewport: const Size(800, 400),
          );
          await expectLater(
            find.byType(MDivider),
            matchesGoldenFile('goldens/horizontal_${mode.name}.png'),
          );
        },
      );

      testWidgets(
        'vertical ${mode.name}',
        (WidgetTester tester) async {
          await pumpManyApp(
            tester,
            _verticalScene(mode.data),
            theme: mode.data,
            viewport: const Size(800, 400),
          );
          await expectLater(
            find.byType(MDivider),
            matchesGoldenFile('goldens/vertical_${mode.name}.png'),
          );
        },
      );
    }
  });
}
