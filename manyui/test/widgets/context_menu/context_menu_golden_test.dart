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
  const _Case(this.name, this.pointer, {this.withTrailing = false});
  final String name;

  /// Where the synthetic right-click lands. Drives where the menu opens
  /// — and exercises the viewport-clamp path for the `bottom_right` case.
  final Offset pointer;

  final bool withTrailing;
}

const Size _viewport = Size(360, 240);

const List<_Case> _cases = <_Case>[
  // Anchor near the top-left — menu opens unmodified.
  _Case('top_left', Offset(40, 40)),
  // Anchor near the bottom-right — viewport clamp pushes the surface
  // back into view.
  _Case('bottom_right', Offset(340, 220), withTrailing: true),
];

List<MMenuItem> _itemsFor(_Case c) {
  return <MMenuItem>[
    MMenuItem(
      id: 'cut',
      title: const Text('Cut'),
      trailing: c.withTrailing ? const Text('⌘X') : null,
    ),
    MMenuItem(
      id: 'copy',
      title: const Text('Copy'),
      trailing: c.withTrailing ? const Text('⌘C') : null,
    ),
    MMenuItem(
      id: 'paste',
      title: const Text('Paste'),
      trailing: c.withTrailing ? const Text('⌘V') : null,
    ),
  ];
}

/// Wraps the menu scene in a fixed-size box matching the documented
/// viewport so the menu's layout delegate sees a small enough surface to
/// trip the bottom-right clamp.
Widget _scene(MThemeData theme, _Case c) {
  return Align(
    alignment: AlignmentDirectional.topStart,
    child: SizedBox(
      width: _viewport.width,
      height: _viewport.height,
      child: RepaintBoundary(
        child: ColoredBox(
          color: theme.colors.background,
          child: Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext _) => MContextMenu(
                  items: _itemsFor(c),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _rightClick(WidgetTester tester, Offset position) async {
  final TestPointer pointer = TestPointer(
    1,
    PointerDeviceKind.mouse,
    null,
    kSecondaryMouseButton,
  );
  await tester.sendEventToBinding(pointer.hover(position));
  await tester.sendEventToBinding(pointer.down(position));
  await tester.sendEventToBinding(pointer.up());
}

void main() {
  group('MContextMenu goldens — position x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              viewport: _viewport,
              modality: MInputModality.mouse,
            );

            await _rightClick(tester, c.pointer);
            // Two pumps so the overlay portal mounts and the focus
            // post-frame settles.
            await tester.pump();
            await tester.pump();

            await expectLater(
              find.byType(RepaintBoundary).first,
              matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
