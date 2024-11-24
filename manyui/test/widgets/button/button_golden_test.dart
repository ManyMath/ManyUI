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

String _variantName(MButtonVariant variant) => variant.name;
String _sizeName(MButtonSize size) => size.name;

Widget _scene(MThemeData theme, Widget button) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(child: button),
  );
}

Future<void> _pumpAndMatch(
  WidgetTester tester, {
  required MThemeData theme,
  required Size viewport,
  required MButtonVariant variant,
  required MButtonSize size,
  required String goldenPath,
}) async {
  await pumpManyApp(
    tester,
    _scene(
      theme,
      MButton(
        onPressed: () {},
        variant: variant,
        size: size,
        child: const Text('Button'),
      ),
    ),
    theme: theme,
    viewport: viewport,
  );
  await expectLater(find.byType(MButton), matchesGoldenFile(goldenPath));
}

void main() {
  group('MButton goldens — all variants at md across viewports', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Viewport vp in _viewports) {
        for (final MButtonVariant variant in MButtonVariant.values) {
          testWidgets(
            '${_variantName(variant)} md ${vp.name} ${mode.name}',
            (WidgetTester tester) async {
              await _pumpAndMatch(
                tester,
                theme: mode.data,
                viewport: vp.size,
                variant: variant,
                size: MButtonSize.md,
                goldenPath:
                    'goldens/${_variantName(variant)}_md_${vp.name}_${mode.name}.png',
              );
            },
          );
        }
      }
    }
  });

  group('MButton goldens — all sizes at primary on desktop', () {
    for (final _ThemeMode mode in _themes) {
      for (final MButtonSize size in MButtonSize.values) {
        testWidgets(
          'primary ${_sizeName(size)} desktop ${mode.name}',
          (WidgetTester tester) async {
            await _pumpAndMatch(
              tester,
              theme: mode.data,
              viewport: const Size(1440, 900),
              variant: MButtonVariant.primary,
              size: size,
              goldenPath:
                  'goldens/primary_${_sizeName(size)}_desktop_${mode.name}.png',
            );
          },
        );
      }
    }
  });
}
