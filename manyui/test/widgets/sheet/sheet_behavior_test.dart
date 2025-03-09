import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

Widget _app({
  required Widget child,
  MThemeData? theme,
  MInputModality? modality,
}) {
  // MWidgetsApp installs an MInputModalityScope above its Navigator using the
  // theme's platform default. A scope wrapped around `home` would sit BELOW
  // the Navigator and be invisible to pushed routes, so we route modality
  // through the theme's platform instead.
  final TargetPlatform? platform = switch (modality) {
    MInputModality.touch => TargetPlatform.android,
    MInputModality.mouse => TargetPlatform.macOS,
    MInputModality.keyboard => TargetPlatform.linux,
    MInputModality.stylus => TargetPlatform.fuchsia,
    null => null,
  };
  return MWidgetsApp(
    theme: (theme ?? MThemeData.light()).copyWith(platform: platform),
    themeMode: MThemeMode.light,
    home: child,
  );
}

void main() {
  group('showMSheet open/close', () {
    testWidgets('mounts the sheet body when shown',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      expect(find.text('Hello'), findsNothing);

      unawaited(showMSheet<void>(
        rootContext,
        builder: (BuildContext _) => const Text('Hello'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(MSheet), findsOneWidget);
    });

    testWidgets('Navigator.pop returns the result to the awaiter',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      final Future<String?> result = showMSheet<String>(
        rootContext,
        builder: (BuildContext ctx) => GestureDetector(
          onTap: () => Navigator.of(ctx).pop('save'),
          child: const Text('Tap to pop'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap to pop'));
      await tester.pumpAndSettle();

      expect(await result, 'save');
      expect(find.text('Tap to pop'), findsNothing);
    });
  });

  group('showMSheet dismiss', () {
    testWidgets('Escape closes the sheet when dismissible',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        builder: (BuildContext _) => const Text('Body'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('Escape does NOT close when dismissible: false',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        dismissible: false,
        builder: (BuildContext _) => const Text('Sticky'),
      ));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Sticky'), findsOneWidget);
    });

    testWidgets('scrim tap closes the sheet when dismissible',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      // Side anchor keeps a wide scrim area in the test's default 800x600
      // viewport, away from the sheet body.
      unawaited(showMSheet<void>(
        rootContext,
        anchor: MSheetAnchor.start,
        builder: (BuildContext _) => const SizedBox(
          width: 100,
          height: 100,
          child: Center(child: Text('Body')),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);

      // Tap a far-right point outside the start-aligned sheet.
      await tester.tapAt(const Offset(780, 300));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('scrim tap does NOT close when dismissible: false',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        anchor: MSheetAnchor.start,
        dismissible: false,
        builder: (BuildContext _) => const SizedBox(
          width: 100,
          height: 100,
          child: Center(child: Text('Sticky')),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(780, 300));
      await tester.pumpAndSettle();
      expect(find.text('Sticky'), findsOneWidget);
    });

    testWidgets('programmatic Navigator.pop closes the sheet',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      late BuildContext sheetContext;
      unawaited(showMSheet<void>(
        rootContext,
        dismissible: false,
        builder: (BuildContext ctx) {
          sheetContext = ctx;
          return const Text('Body');
        },
      ));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);

      Navigator.of(sheetContext).pop();
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });
  });

  group('MSheet anchor placement', () {
    testWidgets('bottom anchor aligns the sheet to bottomCenter',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        builder: (BuildContext _) => const SizedBox(width: 200, height: 120),
      ));
      await tester.pumpAndSettle();

      final Size view = tester.view.physicalSize / tester.view.devicePixelRatio;
      final Rect sheetRect = tester.getRect(find.byType(MSheet));
      // Bottom sheet hugs the bottom edge.
      expect(sheetRect.bottom, closeTo(view.height, 1));
      // And spans the full width.
      expect(sheetRect.width, closeTo(view.width, 1));
    });

    testWidgets('start anchor aligns to the start edge with sideWidth',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        anchor: MSheetAnchor.start,
        builder: (BuildContext _) => const SizedBox.expand(),
      ));
      await tester.pumpAndSettle();

      final Rect sheetRect = tester.getRect(find.byType(MSheet));
      // Default sideWidth is 320.
      expect(sheetRect.left, closeTo(0, 1));
      expect(sheetRect.width, closeTo(320, 1));
    });

    testWidgets('end anchor aligns to the end edge with sideWidth',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        anchor: MSheetAnchor.end,
        builder: (BuildContext _) => const SizedBox.expand(),
      ));
      await tester.pumpAndSettle();

      final Size view = tester.view.physicalSize / tester.view.devicePixelRatio;
      final Rect sheetRect = tester.getRect(find.byType(MSheet));
      expect(sheetRect.right, closeTo(view.width, 1));
      expect(sheetRect.width, closeTo(320, 1));
    });
  });

  group('MSheet drag-to-dismiss', () {
    testWidgets('vertical fling-down dismisses a bottom sheet on touch',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        modality: MInputModality.touch,
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        builder: (BuildContext _) => const SizedBox(width: 400, height: 240),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(MSheet), findsOneWidget);

      // Fling downward from inside the sheet body — well past the
      // 700 px/s velocity threshold.
      await tester.fling(
        find.byType(MSheet),
        const Offset(0, 400),
        2000,
      );
      await tester.pumpAndSettle();
      expect(find.byType(MSheet), findsNothing);
    });

    testWidgets('vertical fling-down does NOT dismiss when mouse modality',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        modality: MInputModality.mouse,
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        builder: (BuildContext _) => const SizedBox(width: 400, height: 240),
      ));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(MSheet),
        const Offset(0, 400),
        2000,
      );
      await tester.pumpAndSettle();
      // Sheet stays — no drag-to-dismiss under mouse modality.
      expect(find.byType(MSheet), findsOneWidget);
    });

    testWidgets('drag handle is painted on bottom + touch and absent otherwise',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        modality: MInputModality.touch,
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        builder: (BuildContext _) => const Text('Body'),
      ));
      await tester.pumpAndSettle();

      final MSheet sheet = tester.widget(find.byType(MSheet)) as MSheet;
      expect(sheet.showDragHandle, isTrue);
    });

    testWidgets('no drag handle on side anchors even under touch',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        modality: MInputModality.touch,
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        anchor: MSheetAnchor.start,
        builder: (BuildContext _) => const Text('Body'),
      ));
      await tester.pumpAndSettle();

      final MSheet sheet = tester.widget(find.byType(MSheet)) as MSheet;
      expect(sheet.showDragHandle, isFalse);
    });
  });

  group('MSheet style', () {
    testWidgets('applyDelta overrides padding on the surface',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        style: const MSheetStyleDelta(padding: EdgeInsets.all(40)),
        builder: (BuildContext _) => const SizedBox(
          key: ValueKey<String>('body'),
          width: 80,
          height: 30,
        ),
      ));
      await tester.pumpAndSettle();

      // Under touch modality the drag handle's own Padding sits above the
      // body Padding in the surface tree. Find the Padding whose child is
      // the DefaultTextStyle wrapping caller content.
      final Padding pad = tester.widget(find.ancestor(
        of: find.byType(DefaultTextStyle).last,
        matching: find.byType(Padding),
      ).first) as Padding;
      expect(pad.padding, const EdgeInsets.all(40));
    });

    testWidgets('default sheet uses the resolved theme background',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      final MThemeData theme = MThemeData.light();
      await tester.pumpWidget(_app(
        theme: theme,
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        builder: (BuildContext _) => const SizedBox(width: 80, height: 30),
      ));
      await tester.pumpAndSettle();

      final DecoratedBox decorated = tester.widget(find.descendant(
        of: find.byType(MSheet),
        matching: find.byType(DecoratedBox),
      ).first) as DecoratedBox;
      final BoxDecoration deco = decorated.decoration as BoxDecoration;
      expect(deco.color, theme.colors.popover);
    });

    testWidgets('caller theme is re-installed inside the route',
        (WidgetTester tester) async {
      // Custom theme with a distinctive popover color — proves the route
      // re-installs MTheme inside buildPage instead of falling back to the
      // MWidgetsApp default.
      final MThemeData theme = MThemeData.light().copyWith(
        colors: MThemeData.light().colors.copyWith(
              popover: const Color(0xFF112233),
            ),
      );
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        theme: theme,
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        builder: (BuildContext _) => const SizedBox(width: 80, height: 30),
      ));
      await tester.pumpAndSettle();

      final DecoratedBox decorated = tester.widget(find.descendant(
        of: find.byType(MSheet),
        matching: find.byType(DecoratedBox),
      ).first) as DecoratedBox;
      final BoxDecoration deco = decorated.decoration as BoxDecoration;
      expect(deco.color, const Color(0xFF112233));
    });
  });

  group('MSheet semantics', () {
    testWidgets('semanticLabel is applied to the sheet surface',
        (WidgetTester tester) async {
      late BuildContext rootContext;
      await tester.pumpWidget(_app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      unawaited(showMSheet<void>(
        rootContext,
        semanticLabel: 'Compose actions',
        builder: (BuildContext _) => const Text('Body'),
      ));
      await tester.pumpAndSettle();

      final Semantics semantics = tester.widget(find.descendant(
        of: find.byType(MSheet),
        matching: find.byType(Semantics),
      ).first) as Semantics;
      expect(semantics.properties.label, 'Compose actions');
    });
  });
}
