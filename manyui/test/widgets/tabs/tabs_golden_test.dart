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
  const _Case(this.name, this.activeId);
  final String name;
  final String activeId;
}

const List<_Case> _cases = <_Case>[
  _Case('first_active', 'overview'),
  _Case('middle_active', 'usage'),
];

Widget _scene(MThemeData theme, _Case c) {
  // Build a fresh controller per scene so each golden renders deterministically.
  final MTabsController controller = MTabsController(c.activeId);
  return ColoredBox(
    color: theme.colors.background,
    child: SizedBox(
      width: 360,
      height: 140,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MTabs(
          controller: controller,
          tabs: <MTab>[
            MTab(
              id: 'overview',
              title: const Text('Overview'),
              content: Text(
                'Account summary.',
                style: theme.typography.body
                    .copyWith(color: theme.colors.foreground),
              ),
            ),
            MTab(
              id: 'usage',
              title: const Text('Usage'),
              content: Text(
                'Bandwidth this cycle.',
                style: theme.typography.body
                    .copyWith(color: theme.colors.foreground),
              ),
            ),
            MTab(
              id: 'billing',
              title: const Text('Billing'),
              content: Text(
                'Next invoice date.',
                style: theme.typography.body
                    .copyWith(color: theme.colors.foreground),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('MTabs goldens — active x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              viewport: const Size(360, 140),
              modality: MInputModality.mouse,
            );
            await expectLater(
              find.byType(MTabs),
              matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
