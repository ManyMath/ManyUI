import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

Widget _app({required Widget child, MThemeData? theme}) {
  return MWidgetsApp(
    theme: theme ?? MThemeData.light(),
    themeMode: MThemeMode.light,
    home: child,
  );
}

List<MCommandItem<String>> _commands({
  Set<String> disabled = const <String>{},
  VoidCallback? onOpen,
  VoidCallback? onSave,
  VoidCallback? onClose,
}) {
  bool dis(String id) => disabled.contains(id);
  return <MCommandItem<String>>[
    MCommandItem<String>(
      id: 'open',
      title: const Text('Open File'),
      trailing: const Text('⌘O'),
      searchText: 'open file',
      keywords: const <String>['load'],
      value: 'open',
      onTap: onOpen,
      enabled: !dis('open'),
    ),
    MCommandItem<String>(
      id: 'save',
      title: const Text('Save'),
      trailing: const Text('⌘S'),
      searchText: 'save',
      keywords: const <String>['write', 'persist'],
      value: 'save',
      onTap: onSave,
      enabled: !dis('save'),
    ),
    MCommandItem<String>(
      id: 'close',
      title: const Text('Close Window'),
      searchText: 'close window',
      keywords: const <String>['quit', 'exit'],
      value: 'close',
      onTap: onClose,
      enabled: !dis('close'),
    ),
  ];
}

Future<BuildContext> _pumpRoot(WidgetTester tester, {MThemeData? theme}) async {
  late BuildContext rootContext;
  await tester.pumpWidget(_app(
    theme: theme,
    child: Builder(builder: (BuildContext ctx) {
      rootContext = ctx;
      return const SizedBox.shrink();
    }),
  ));
  return rootContext;
}

void main() {
  group('showMCommandPalette open/close', () {
    testWidgets('mounts the palette body when shown',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);

      expect(find.text('Open File'), findsNothing);

      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(MCommandPalette<String>), findsOneWidget);
      expect(find.text('Open File'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Close Window'), findsOneWidget);
    });

    testWidgets('placeholder renders before any text is typed',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        placeholder: 'Type a command…',
        items: _commands(),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Type a command…'), findsOneWidget);
    });
  });

  group('showMCommandPalette dismiss', () {
    testWidgets('Escape dismisses with a null result',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      final Future<MCommandItem<String>?> result = showMCommandPalette<String>(
        root,
        items: _commands(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MCommandPalette<String>), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(await result, isNull);
      expect(find.byType(MCommandPalette<String>), findsNothing);
    });

    testWidgets('Escape does NOT dismiss when dismissible: false',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        dismissible: false,
        items: _commands(),
      ));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(MCommandPalette<String>), findsOneWidget);
    });

    testWidgets('scrim tap dismisses with a null result',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      final Future<MCommandItem<String>?> result = showMCommandPalette<String>(
        root,
        items: _commands(),
      );
      await tester.pumpAndSettle();

      // Tap far below the palette (which is anchored near the top of the
      // 800x600 viewport).
      await tester.tapAt(const Offset(400, 580));
      await tester.pumpAndSettle();
      expect(await result, isNull);
      expect(find.byType(MCommandPalette<String>), findsNothing);
    });
  });

  group('typeahead filter', () {
    testWidgets('substring on searchText filters the visible items',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Open File'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Close Window'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'save');
      await tester.pump();

      expect(find.text('Open File'), findsNothing);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Close Window'), findsNothing);
    });

    testWidgets('keywords also match the typeahead query',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(),
      ));
      await tester.pumpAndSettle();

      // 'load' is a keyword only on the Open File item.
      await tester.enterText(find.byType(EditableText), 'load');
      await tester.pump();

      expect(find.text('Open File'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('no-match state renders the configured empty text',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'xyzzy');
      await tester.pump();

      expect(find.text('No results.'), findsOneWidget);
      expect(find.text('Open File'), findsNothing);
    });

    testWidgets('clearing the query restores the full list',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'save');
      await tester.pump();
      expect(find.text('Open File'), findsNothing);

      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(find.text('Open File'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Close Window'), findsOneWidget);
    });
  });

  group('item activation', () {
    testWidgets('tapping an item invokes onTap, pops the route with the item',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      int saves = 0;
      final Future<MCommandItem<String>?> result = showMCommandPalette<String>(
        root,
        items: _commands(onSave: () => saves++),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saves, 1);
      final MCommandItem<String>? picked = await result;
      expect(picked, isNotNull);
      expect(picked!.id, 'save');
      expect(picked.value, 'save');
      expect(find.byType(MCommandPalette<String>), findsNothing);
    });

    testWidgets('tapping a disabled item is a no-op (palette stays open)',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      int saves = 0;
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(
          disabled: const <String>{'save'},
          onSave: () => saves++,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(saves, 0);
      expect(find.byType(MCommandPalette<String>), findsOneWidget);
    });

    testWidgets('Enter activates the focused item',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      int opens = 0;
      int saves = 0;
      final Future<MCommandItem<String>?> result = showMCommandPalette<String>(
        root,
        items: _commands(
          onOpen: () => opens++,
          onSave: () => saves++,
        ),
      );
      await tester.pumpAndSettle();
      // First item ('Open File') is focused on open. Down once → 'Save'.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(saves, 1);
      expect(opens, 0);
      expect((await result)!.id, 'save');
    });

    testWidgets('Down/Up skip disabled items with wraparound',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      int closes = 0;
      final Future<MCommandItem<String>?> result = showMCommandPalette<String>(
        root,
        items: _commands(
          disabled: const <String>{'save'},
          onClose: () => closes++,
        ),
      );
      await tester.pumpAndSettle();
      // First focused = Open. Down once skips disabled Save and lands on Close.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(closes, 1);
      expect((await result)!.id, 'close');
    });

    testWidgets('Home/End jump to first/last enabled filtered item',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      int closes = 0;
      final Future<MCommandItem<String>?> result = showMCommandPalette<String>(
        root,
        items: _commands(onClose: () => closes++),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(closes, 1);
      expect((await result)!.id, 'close');
    });
  });

  group('focus state across typeahead', () {
    testWidgets('filter that hides the focused item moves focus to the new '
        'first item', (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      final Future<MCommandItem<String>?> result = showMCommandPalette<String>(
        root,
        items: _commands(),
      );
      await tester.pumpAndSettle();
      // Type 'close' — only Close Window matches.
      await tester.enterText(find.byType(EditableText), 'close');
      await tester.pump();
      // Enter activates the now-focused Close Window.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect((await result)!.id, 'close');
    });

    testWidgets('Enter on an empty filtered list is a no-op',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'xyzzy');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      // Palette is still open; the empty state is still showing.
      expect(find.text('No results.'), findsOneWidget);
      expect(find.byType(MCommandPalette<String>), findsOneWidget);
    });
  });

  group('style', () {
    testWidgets('applyDelta overrides the rendered item height',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        style: const MCommandPaletteStyleDelta(itemHeight: 56),
        items: _commands(),
      ));
      await tester.pumpAndSettle();
      final Finder openRow = find
          .ancestor(
            of: find.text('Open File'),
            matching: find.byType(GestureDetector),
          )
          .first;
      expect(tester.getSize(openRow).height, 56);
    });

    testWidgets('applyDelta overrides the empty text',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        style: const MCommandPaletteStyleDelta(emptyText: 'Nothing here yet.'),
        items: _commands(),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'xyzzy');
      await tester.pump();
      expect(find.text('Nothing here yet.'), findsOneWidget);
    });

    testWidgets('default palette uses the theme popover background',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      final BuildContext root = await _pumpRoot(tester, theme: theme);
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(),
      ));
      await tester.pumpAndSettle();
      final DecoratedBox decorated = tester.widget(find.descendant(
        of: find.byType(MCommandPalette<String>),
        matching: find.byType(DecoratedBox),
      ).first) as DecoratedBox;
      final BoxDecoration deco = decorated.decoration as BoxDecoration;
      expect(deco.color, theme.colors.popover);
    });

    testWidgets('clamps wide content to the resolved maxWidth',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(),
      ));
      await tester.pumpAndSettle();
      final RenderBox box = tester
          .renderObject(find.byType(MCommandPalette<String>)) as RenderBox;
      expect(box.size.width, lessThanOrEqualTo(520));
    });
  });

  group('semantics', () {
    testWidgets('semanticLabel is applied to the palette surface',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        semanticLabel: 'Command palette',
        items: _commands(),
      ));
      await tester.pumpAndSettle();
      // The route also adds a barrierLabel-driven Semantics outside the
      // palette body, so two matches exist; assert the inner one is present
      // on the palette surface itself.
      expect(
        find.descendant(
          of: find.byType(MCommandPalette<String>),
          matching: find.bySemanticsLabel('Command palette'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('disabled item reports enabled: false',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      unawaited(showMCommandPalette<String>(
        root,
        items: _commands(disabled: const <String>{'save'}),
      ));
      await tester.pumpAndSettle();

      final Iterable<Element> ancestors = find
          .ancestor(of: find.text('Save'), matching: find.byType(Semantics))
          .evaluate();
      Semantics? itemSemantics;
      for (final Element e in ancestors) {
        final Semantics s = e.widget as Semantics;
        if (s.properties.button == true) {
          itemSemantics = s;
          break;
        }
      }
      expect(itemSemantics, isNotNull);
      expect(itemSemantics!.properties.enabled, isFalse);
    });
  });

  group('programmatic dismiss', () {
    testWidgets('Navigator.pop closes the palette with a null result',
        (WidgetTester tester) async {
      final BuildContext root = await _pumpRoot(tester);
      late BuildContext paletteContext;
      final Future<MCommandItem<String>?> result = showMCommandPalette<String>(
        root,
        items: <MCommandItem<String>>[
          MCommandItem<String>(
            id: 'inspect',
            title: Builder(builder: (BuildContext ctx) {
              paletteContext = ctx;
              return const Text('Inspect');
            }),
            searchText: 'inspect',
            value: 'inspect',
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Inspect'), findsOneWidget);

      Navigator.of(paletteContext).pop();
      await tester.pumpAndSettle();
      expect(await result, isNull);
      expect(find.text('Inspect'), findsNothing);
    });
  });
}
