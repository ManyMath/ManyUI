@Tags(<String>['golden'])
library;

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
  const _Case(this.name, this.count);
  final String name;
  final int count;
}

const List<_Case> _cases = <_Case>[
  _Case('single', 1),
  _Case('stacked', 2),
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

Widget _toastBody(MThemeData theme, String title, String detail) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        title,
        style: theme.typography.title.copyWith(
          color: theme.colors.popoverForeground,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        detail,
        style: theme.typography.body.copyWith(
          color: theme.colors.mutedForeground,
        ),
      ),
    ],
  );
}

void main() {
  group('MToast goldens — count x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            tester.view.physicalSize = const Size(480, 360);
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

            const List<List<String>> bodies = <List<String>>[
              <String>['Saved', 'Changes synced just now.'],
              <String>['Uploading', '2 files remaining.'],
            ];

            for (int i = 0; i < c.count; i++) {
              showMToast(
                rootContext,
                builder: (BuildContext _) =>
                    _toastBody(mode.data, bodies[i][0], bodies[i][1]),
                duration: const Duration(seconds: 60),
              );
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
