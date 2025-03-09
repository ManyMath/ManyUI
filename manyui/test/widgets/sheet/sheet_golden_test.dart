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
  const _Case(this.name, this.anchor);
  final String name;
  final MSheetAnchor anchor;
}

const List<_Case> _cases = <_Case>[
  _Case('bottom', MSheetAnchor.bottom),
  _Case('start', MSheetAnchor.start),
];

Widget _page(MThemeData theme) {
  return ColoredBox(
    color: theme.colors.background,
    child: Center(
      child: SizedBox(
        width: 200,
        height: 60,
        child: ColoredBox(
          color: theme.colors.muted,
          child: Center(
            child: Text(
              'Behind',
              style: TextStyle(color: theme.colors.mutedForeground),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _sheetBody(MThemeData theme) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'Quick actions',
        style: theme.typography.title.copyWith(
          color: theme.colors.popoverForeground,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Pick one of the options below.',
        style: theme.typography.body.copyWith(
          color: theme.colors.mutedForeground,
        ),
      ),
    ],
  );
}

void main() {
  group('MSheet goldens — anchor x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            tester.view.physicalSize = const Size(420, 320);
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

            unawaited(showMSheet<void>(
              rootContext,
              anchor: c.anchor,
              builder: (BuildContext _) => _sheetBody(mode.data),
            ));
            await tester.pumpAndSettle();

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
