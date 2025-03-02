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
  const _Case(this.name, {required this.open});
  final String name;
  final bool open;
}

const List<_Case> _cases = <_Case>[
  _Case('closed', open: false),
  _Case('open', open: true),
];

Widget _scene(MThemeData theme, _Case c, MPopoverController controller) {
  final Color anchorBg = theme.colors.muted;
  final Color anchorFg = theme.colors.mutedForeground;
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 320,
        height: 220,
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext _) => Center(
                child: MPopover(
                  controller: controller,
                  matchAnchorWidth: true,
                  popoverBuilder: (BuildContext context, VoidCallback close) {
                    return SizedBox(
                      width: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Item one',
                              style: TextStyle(color: anchorFg)),
                          const SizedBox(height: 4),
                          Text('Item two',
                              style: TextStyle(color: anchorFg)),
                        ],
                      ),
                    );
                  },
                  child: ColoredBox(
                    color: anchorBg,
                    child: SizedBox(
                      width: 140,
                      height: 36,
                      child: Center(
                        child: Text(
                          'Open',
                          style: TextStyle(color: anchorFg),
                        ),
                      ),
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
  group('MPopover goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            final MPopoverController controller = MPopoverController();
            addTearDown(controller.dispose);

            await pumpManyApp(
              tester,
              _scene(mode.data, c, controller),
              theme: mode.data,
              viewport: const Size(360, 260),
              modality: MInputModality.mouse,
            );
            await tester.pump();

            if (c.open) {
              controller.open();
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
