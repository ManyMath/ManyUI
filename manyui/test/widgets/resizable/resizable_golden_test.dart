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
  const _Case(this.name, this.sizes);
  final String name;
  final List<double> sizes;
}

final List<_Case> _cases = <_Case>[
  const _Case('initial', <double>[0.5, 0.5]),
  const _Case('dragged', <double>[0.7, 0.3]),
  const _Case('min_clamped', <double>[0.2, 0.8]),
];

const Color _paneAColor = Color(0xFF5B8DEF);
const Color _paneBColor = Color(0xFFEFA85B);

Widget _pane(Color color) => ColoredBox(color: color);

Widget _scene(MThemeData theme, _Case c, Axis axis) {
  final double w = axis == Axis.horizontal ? 388 : 188;
  final double h = axis == Axis.horizontal ? 188 : 388;
  return ColoredBox(
    color: theme.colors.background,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: w,
        height: h,
        child: MResizable(
          axis: axis,
          initialSizes: c.sizes,
          children: <MResizableChild>[
            MResizableChild(minSize: 0.15, child: _pane(_paneAColor)),
            MResizableChild(minSize: 0.15, child: _pane(_paneBColor)),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('MResizable goldens — state x axis x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final Axis axis in <Axis>[Axis.horizontal, Axis.vertical]) {
        final String axisName = axis == Axis.horizontal ? 'h' : 'v';
        for (final _Case c in _cases) {
          testWidgets('${c.name}_${axisName}_${mode.name}',
              (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c, axis),
              theme: mode.data,
              viewport: axis == Axis.horizontal
                  ? const Size(420, 220)
                  : const Size(220, 420),
              modality: MInputModality.mouse,
            );
            await tester.pumpAndSettle();
            await expectLater(
              find.byType(MResizable),
              matchesGoldenFile(
                  'goldens/${c.name}_${axisName}_${mode.name}.png'),
            );
          });
        }
      }
    }
  });
}
