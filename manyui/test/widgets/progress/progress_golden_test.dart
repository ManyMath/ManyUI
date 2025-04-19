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
  const _Case(this.name, this.value);
  final String name;
  final double value;
}

const List<_Case> _cases = <_Case>[
  _Case('p000', 0.0),
  _Case('p025', 0.25),
  _Case('p075', 0.75),
  _Case('p100', 1.0),
];

Widget _linearScene(MThemeData theme, _Case c) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 200,
        child: MProgress(initialValue: c.value),
      ),
    ),
  );
}

Widget _circularScene(MThemeData theme, _Case c) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: MCircularProgress(initialValue: c.value),
    ),
  );
}

void main() {
  group('MProgress (linear) goldens — value x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets('linear_${c.name}_${mode.name}',
            (WidgetTester tester) async {
          await pumpManyApp(
            tester,
            _linearScene(mode.data, c),
            theme: mode.data,
            viewport: const Size(280, 80),
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MProgress),
            matchesGoldenFile('goldens/linear_${c.name}_${mode.name}.png'),
          );
        });
      }
    }
  });

  group('MCircularProgress goldens — value x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets('circular_${c.name}_${mode.name}',
            (WidgetTester tester) async {
          await pumpManyApp(
            tester,
            _circularScene(mode.data, c),
            theme: mode.data,
            viewport: const Size(80, 80),
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MCircularProgress),
            matchesGoldenFile('goldens/circular_${c.name}_${mode.name}.png'),
          );
        });
      }
    }
  });
}
