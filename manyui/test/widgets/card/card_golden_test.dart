@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

class _Viewport {
  const _Viewport(this.name, this.size);
  final String name;
  final Size size;
}

const List<_Viewport> _viewports = <_Viewport>[
  _Viewport('phone', Size(360, 800)),
  _Viewport('tablet', Size(1024, 768)),
  _Viewport('desktop', Size(1440, 900)),
];

class _ThemeMode {
  const _ThemeMode(this.name, this.data);
  final String name;
  final MThemeData data;
}

final List<_ThemeMode> _themes = <_ThemeMode>[
  _ThemeMode('light', MThemeData.light()),
  _ThemeMode('dark', MThemeData.dark()),
];

Widget _scene(MThemeData theme, Widget card) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(width: 280, child: card),
    ),
  );
}

Future<void> _pumpAndMatch(
  WidgetTester tester, {
  required MThemeData theme,
  required Size viewport,
  required String goldenPath,
}) async {
  await pumpManyApp(
    tester,
    _scene(
      theme,
      const MCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Card title'),
            SizedBox(height: 6),
            Text('Body text in a card.'),
          ],
        ),
      ),
    ),
    theme: theme,
    viewport: viewport,
  );
  await expectLater(find.byType(MCard), matchesGoldenFile(goldenPath));
}

void main() {
  group('MCard goldens — default surface across viewports', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Viewport vp in _viewports) {
        testWidgets(
          'card ${vp.name} ${mode.name}',
          (WidgetTester tester) async {
            await _pumpAndMatch(
              tester,
              theme: mode.data,
              viewport: vp.size,
              goldenPath: 'goldens/card_${vp.name}_${mode.name}.png',
            );
          },
        );
      }
    }
  });
}
