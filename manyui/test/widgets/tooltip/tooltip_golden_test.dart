@Tags(<String>['golden'])
library;

import 'package:flutter/gestures.dart';
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
  const _Case(this.name, {
    required this.shown,
    this.placement = MTooltipPlacement.above,
    this.message = 'Save',
  });
  final String name;
  final bool shown;
  final MTooltipPlacement placement;
  final String message;
}

const List<_Case> _cases = <_Case>[
  _Case('hidden', shown: false),
  _Case('above', shown: true),
  _Case('below', shown: true, placement: MTooltipPlacement.below),
  _Case(
    'wrapped',
    shown: true,
    message: 'A long tooltip label that wraps onto two lines',
  ),
];

Widget _scene(MThemeData theme, _Case c) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 300,
        height: 200,
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext _) => Center(
                child: MTooltip(
                  message: c.message,
                  placement: c.placement,
                  // Show instantly so we don't need to advance the clock.
                  style: const MTooltipStyleDelta(
                    showDelay: Duration.zero,
                  ),
                  child: const SizedBox(
                    width: 100,
                    height: 36,
                    child: ColoredBox(
                      color: Color(0xFFAAAAAA),
                      child: Center(child: Text('anchor')),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('MTooltip goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              viewport: const Size(320, 240),
              modality: MInputModality.mouse,
            );
            await tester.pump();

            if (c.shown) {
              final TestGesture g = await tester.createGesture(
                kind: PointerDeviceKind.mouse,
              );
              addTearDown(g.removePointer);
              await g.addPointer(
                location: tester.getCenter(find.byType(MTooltip)),
              );
              // showDelay is zero, so a frame after enter is enough.
              await tester.pump();
              await tester.pump();
            }

            await expectLater(
              find.byType(Overlay).first,
              matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
