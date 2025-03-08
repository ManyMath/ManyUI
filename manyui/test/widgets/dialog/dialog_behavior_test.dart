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

void main() {
  group('showMDialog open/close', () {
    testWidgets('mounts the dialog body when shown',
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

      unawaited(showMDialog<void>(
        rootContext,
        builder: (BuildContext _) => const Text('Hello'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(MDialog), findsOneWidget);
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

      final Future<int?> result = showMDialog<int>(
        rootContext,
        builder: (BuildContext ctx) => GestureDetector(
          onTap: () => Navigator.of(ctx).pop(42),
          child: const Text('Tap to pop'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap to pop'));
      await tester.pumpAndSettle();

      expect(await result, 42);
      expect(find.text('Tap to pop'), findsNothing);
    });
  });

  group('showMDialog dismiss', () {
    testWidgets('Escape closes the dialog when dismissible',
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

      unawaited(showMDialog<void>(
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

      unawaited(showMDialog<void>(
        rootContext,
        dismissible: false,
        builder: (BuildContext _) => const Text('Sticky'),
      ));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Sticky'), findsOneWidget);
    });

    testWidgets('scrim tap closes the dialog when dismissible',
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

      unawaited(showMDialog<void>(
        rootContext,
        builder: (BuildContext _) => const SizedBox(
          width: 100,
          height: 100,
          child: Center(child: Text('Body')),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);

      // Tap a screen corner well outside the centered dialog body.
      await tester.tapAt(const Offset(5, 5));
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

      unawaited(showMDialog<void>(
        rootContext,
        dismissible: false,
        builder: (BuildContext _) => const SizedBox(
          width: 100,
          height: 100,
          child: Center(child: Text('Sticky')),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Sticky'), findsOneWidget);
    });

    testWidgets('programmatic Navigator.pop closes the dialog',
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

      late BuildContext dialogContext;
      unawaited(showMDialog<void>(
        rootContext,
        dismissible: false,
        builder: (BuildContext ctx) {
          dialogContext = ctx;
          return const Text('Body');
        },
      ));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);

      Navigator.of(dialogContext).pop();
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });
  });

  group('MDialog style', () {
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

      unawaited(showMDialog<void>(
        rootContext,
        style: const MDialogStyleDelta(padding: EdgeInsets.all(40)),
        builder: (BuildContext _) => const SizedBox(
          key: ValueKey<String>('body'),
          width: 80,
          height: 30,
        ),
      ));
      await tester.pumpAndSettle();

      final Padding pad = tester.widget(find.descendant(
        of: find.byType(MDialog),
        matching: find.byType(Padding),
      ).first) as Padding;
      expect(pad.padding, const EdgeInsets.all(40));
    });

    testWidgets('default dialog uses the resolved theme background',
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

      unawaited(showMDialog<void>(
        rootContext,
        builder: (BuildContext _) => const SizedBox(width: 80, height: 30),
      ));
      await tester.pumpAndSettle();

      final DecoratedBox decorated = tester.widget(find.descendant(
        of: find.byType(MDialog),
        matching: find.byType(DecoratedBox),
      ).first) as DecoratedBox;
      final BoxDecoration deco = decorated.decoration as BoxDecoration;
      expect(deco.color, theme.colors.popover);
    });
  });

  group('MDialog semantics', () {
    testWidgets('semanticLabel is applied to the dialog surface',
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

      unawaited(showMDialog<void>(
        rootContext,
        semanticLabel: 'Confirm delete',
        builder: (BuildContext _) => const Text('Body'),
      ));
      await tester.pumpAndSettle();

      final Semantics semantics = tester.widget(find.descendant(
        of: find.byType(MDialog),
        matching: find.byType(Semantics),
      ).first) as Semantics;
      expect(semantics.properties.label, 'Confirm delete');
    });
  });

  group('MDialog max-width', () {
    testWidgets('clamps wide content to the resolved maxWidth',
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

      unawaited(showMDialog<void>(
        rootContext,
        // Very wide intrinsic content, plus a small padding override so the
        // assertion measures the clamp rather than padding inflation.
        style: const MDialogStyleDelta(padding: EdgeInsets.zero),
        builder: (BuildContext _) => const SizedBox(width: 4000, height: 30),
      ));
      await tester.pumpAndSettle();

      final RenderBox dialogBox =
          tester.renderObject(find.byType(MDialog)) as RenderBox;
      // Default maxWidth is 425 — content tries 4000, ConstrainedBox clamps.
      expect(dialogBox.size.width, lessThanOrEqualTo(425));
    });
  });
}
