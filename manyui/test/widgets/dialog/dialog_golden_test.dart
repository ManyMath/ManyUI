@Tags(<String>['golden'])
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

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

Widget _page(MThemeData theme) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 140,
        height: 36,
        child: ColoredBox(
          color: theme.colors.muted,
          child: Center(
            child: Text(
              'Anchor',
              style: TextStyle(color: theme.colors.mutedForeground),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _dialogBody(MThemeData theme) {
  return SizedBox(
    width: 240,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Are you sure?',
          style: theme.typography.title.copyWith(
            color: theme.colors.popoverForeground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This action cannot be undone.',
          style: theme.typography.body.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('MDialog goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            tester.view.physicalSize = const Size(360, 260);
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            late BuildContext rootContext;
            await tester.pumpWidget(MWidgetsApp(
              theme: mode.data,
              themeMode: MThemeMode.light,
              darkTheme: mode.data,
              debugShowCheckedModeBanner: false,
              home: Builder(builder: (BuildContext context) {
                rootContext = context;
                return _page(mode.data);
              }),
            ));
            await tester.pumpAndSettle();

            if (c.open) {
              unawaited(showMDialog<void>(
                rootContext,
                builder: (BuildContext _) => _dialogBody(mode.data),
              ));
              await tester.pumpAndSettle();
            }

            await expectLater(
              find.byType(MWidgetsApp),
              matchesGoldenFile('goldens/${c.name}_${mode.name}.png'),
            );
          },
        );
      }
    }
  });
}
