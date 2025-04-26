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
  const _Case(this.name, this.expanded, this.mode);
  final String name;
  final Set<String> expanded;
  final MAccordionMode mode;
}

final List<_Case> _cases = <_Case>[
  const _Case('collapsed', <String>{}, MAccordionMode.single),
  const _Case('one_expanded', <String>{'b'}, MAccordionMode.single),
  const _Case('two_expanded', <String>{'a', 'c'}, MAccordionMode.multiple),
];

const List<MAccordionItem> _items = <MAccordionItem>[
  MAccordionItem(id: 'a', title: Text('Alpha'), content: Text('Body of Alpha section.')),
  MAccordionItem(id: 'b', title: Text('Bravo'), content: Text('Body of Bravo section.')),
  MAccordionItem(id: 'c', title: Text('Charlie'), content: Text('Body of Charlie section.')),
];

Widget _scene(MThemeData theme, _Case c) {
  return ColoredBox(
    color: theme.colors.background,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: MAccordion(
        mode: c.mode,
        initialExpanded: c.expanded,
        items: _items,
      ),
    ),
  );
}

void main() {
  group('MAccordion goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets('${c.name}_${mode.name}', (WidgetTester tester) async {
          await pumpManyApp(
            tester,
            _scene(mode.data, c),
            theme: mode.data,
            viewport: const Size(420, 320),
            modality: MInputModality.mouse,
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MAccordion),
            matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
          );
        });
      }
    }
  });
}
