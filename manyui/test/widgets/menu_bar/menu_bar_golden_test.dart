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
  const _Case(this.name, this.openId, {this.withTrailing = false});
  final String name;
  final String? openId;
  final bool withTrailing;
}

const List<_Case> _cases = <_Case>[
  _Case('closed', null),
  _Case('open_basic', 'file'),
  _Case('open_with_trailing', 'file', withTrailing: true),
];

List<MMenu> _menusFor(_Case c) {
  return <MMenu>[
    MMenu(
      id: 'file',
      title: const Text('File'),
      items: <MMenuItem>[
        MMenuItem(
          id: 'new',
          title: const Text('New'),
          trailing: c.withTrailing ? const Text('⌘N') : null,
        ),
        MMenuItem(
          id: 'open',
          title: const Text('Open'),
          trailing: c.withTrailing ? const Text('⌘O') : null,
        ),
        MMenuItem(
          id: 'save',
          title: const Text('Save'),
          trailing: c.withTrailing ? const Text('⌘S') : null,
        ),
      ],
    ),
    const MMenu(
      id: 'edit',
      title: Text('Edit'),
      items: <MMenuItem>[
        MMenuItem(id: 'undo', title: Text('Undo')),
        MMenuItem(id: 'redo', title: Text('Redo')),
      ],
    ),
    const MMenu(
      id: 'view',
      title: Text('View'),
      items: <MMenuItem>[
        MMenuItem(id: 'zoom-in', title: Text('Zoom In')),
        MMenuItem(id: 'zoom-out', title: Text('Zoom Out')),
      ],
    ),
  ];
}

Widget _scene(MThemeData theme, _Case c, MMenuBarController controller) {
  return ColoredBox(
    color: theme.colors.background,
    child: Overlay(
      initialEntries: <OverlayEntry>[
        OverlayEntry(
          builder: (BuildContext _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: MMenuBar(
                menus: _menusFor(c),
                controller: controller,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('MMenuBar goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            final MMenuBarController controller =
                MMenuBarController(c.openId);
            addTearDown(controller.dispose);

            await pumpManyApp(
              tester,
              _scene(mode.data, c, controller),
              theme: mode.data,
              viewport: const Size(360, 240),
              modality: MInputModality.mouse,
            );

            if (c.openId != null) {
              // Two extra pumps: the seeded-open path defers the overlay
              // show() to a post-frame callback, then the portal rebuild
              // settles on the next frame.
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
