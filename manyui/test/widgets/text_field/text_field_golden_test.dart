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

enum _Variant { idle, focused, error, disabled }

class _Case {
  const _Case(this.name, this.variant);
  final String name;
  final _Variant variant;
}

const List<_Case> _cases = <_Case>[
  _Case('idle', _Variant.idle),
  _Case('focused', _Variant.focused),
  _Case('error', _Variant.error),
  _Case('disabled', _Variant.disabled),
];

Widget _scene(MThemeData theme, _Case c) {
  // Seed text so the idle/focused/error variants render the text style, not
  // the placeholder; disabled is intentionally rendered with placeholder
  // text to show the dimmed state across both surfaces.
  final bool showsPlaceholder = c.variant == _Variant.disabled;
  // MTextField, like its underlying EditableText, expands to fill its
  // parent's height bound (the same gotcha MSlider has). Hard-cap the host
  // SizedBox to the field's natural height so the captured PNG shows the
  // field at its rendered size rather than stretched.
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 220,
        height: 60,
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext _) => Center(
                child: MTextField(
                  initialValue: showsPlaceholder ? '' : 'manyui',
                  placeholder: 'name@example.com',
                  enabled: c.variant != _Variant.disabled,
                  error: c.variant == _Variant.error,
                  autofocus: c.variant == _Variant.focused,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _multilineScene(MThemeData theme) {
  // A growing textarea (minLines/maxLines) seeded with several lines, so the
  // golden captures the multiline layout: top-aligned content sized to the
  // line count rather than collapsed to one row.
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 220,
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext _) => const Center(
                child: MTextField(
                  initialValue: 'first line\nsecond line\nthird line',
                  placeholder: 'notes',
                  minLines: 1,
                  maxLines: 5,
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
  group('MTextField multiline goldens', () {
    for (final _ThemeMode mode in _themes) {
      testWidgets(
        'multiline ${mode.name}',
        (WidgetTester tester) async {
          await pumpManyApp(
            tester,
            _multilineScene(mode.data),
            theme: mode.data,
            viewport: const Size(320, 220),
            modality: MInputModality.mouse,
          );
          await tester.pump();

          await expectLater(
            find.byType(Overlay).first,
            matchesGoldenFile('goldens/multiline_${mode.name}.png'),
          );
        },
      );
    }
  });

  group('MTextField goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            await pumpManyApp(
              tester,
              _scene(mode.data, c),
              theme: mode.data,
              viewport: const Size(320, 160),
              modality: MInputModality.mouse,
            );
            // Two pumps so the autofocus post-frame callback settles before
            // capturing the focused-state golden.
            await tester.pump();
            await tester.pump();

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
