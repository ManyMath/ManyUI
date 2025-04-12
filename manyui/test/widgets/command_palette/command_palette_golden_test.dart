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
  const _Case(this.name, {required this.query});
  final String name;

  /// What text to type into the palette's search field before the golden
  /// is captured. An empty string means the field stays empty and the
  /// full list (plus placeholder) is shown.
  final String query;
}

const List<_Case> _cases = <_Case>[
  _Case('empty', query: ''),
  _Case('results', query: 'op'),
  _Case('no_matches', query: 'xyzzy'),
];

const Size _viewport = Size(560, 360);

List<MCommandItem<String>> _items() {
  return <MCommandItem<String>>[
    const MCommandItem<String>(
      id: 'open',
      title: Text('Open File'),
      subtitle: Text('Open an existing document'),
      trailing: Text('O'),
      searchText: 'open file',
      keywords: <String>['load'],
      value: 'open',
    ),
    const MCommandItem<String>(
      id: 'save',
      title: Text('Save'),
      subtitle: Text('Save the current document'),
      trailing: Text('S'),
      searchText: 'save',
      keywords: <String>['write'],
      value: 'save',
    ),
    const MCommandItem<String>(
      id: 'close',
      title: Text('Close Window'),
      trailing: Text('W'),
      searchText: 'close',
      keywords: <String>['quit', 'exit'],
      value: 'close',
    ),
  ];
}

void main() {
  group('MCommandPalette goldens — state x theme', () {
    for (final _ThemeMode mode in _themes) {
      for (final _Case c in _cases) {
        testWidgets(
          '${c.name} ${mode.name}',
          (WidgetTester tester) async {
            tester.view.physicalSize = _viewport;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            late BuildContext rootContext;
            await tester.pumpWidget(MWidgetsApp(
              theme: mode.data,
              themeMode: MThemeMode.light,
              darkTheme: mode.data,
              debugShowCheckedModeBanner: false,
              home: Builder(builder: (BuildContext ctx) {
                rootContext = ctx;
                return ColoredBox(color: mode.data.colors.background);
              }),
            ));
            await tester.pumpAndSettle();

            unawaited(showMCommandPalette<String>(
              rootContext,
              placeholder: 'Type a command…',
              items: _items(),
            ));
            await tester.pumpAndSettle();

            if (c.query.isNotEmpty) {
              await tester.enterText(find.byType(EditableText), c.query);
              await tester.pump();
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
