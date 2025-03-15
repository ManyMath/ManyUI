import 'package:flutter/gestures.dart';
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
  // the Navigator and be invisible to the root Overlay, so we route modality
  // through the theme's platform instead. Same trick as sheet_behavior_test.
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

Future<BuildContext> _pumpAppContext(
  WidgetTester tester, {
  MThemeData? theme,
  MInputModality? modality,
}) async {
  late BuildContext rootContext;
  await tester.pumpWidget(_app(
    theme: theme,
    modality: modality,
    child: Builder(
      builder: (BuildContext context) {
        rootContext = context;
        return const SizedBox.shrink();
      },
    ),
  ));
  return rootContext;
}

void main() {
  group('showMToast open/close', () {
    testWidgets('mounts the toast body when shown',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      expect(find.text('Saved'), findsNothing);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Saved'), findsOneWidget);
      expect(find.byType(MToast), findsOneWidget);

      // Drain the auto-dismiss timer before the test ends.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('auto-dismisses after the configured duration',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        duration: const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MToast), findsOneWidget);

      // Just before the timer fires.
      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.byType(MToast), findsOneWidget);

      // After the timer fires the exit animation plays out.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.byType(MToast), findsNothing);
    });

    testWidgets('controller.dismiss() removes the toast early',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      final MToastController controller = showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();
      expect(controller.isDismissed, isFalse);
      expect(find.byType(MToast), findsOneWidget);

      controller.dismiss();
      await tester.pumpAndSettle();

      expect(controller.isDismissed, isTrue);
      expect(find.byType(MToast), findsNothing);
    });

    testWidgets('dismiss() after auto-dismiss is a no-op',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      final MToastController controller = showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        duration: const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(controller.isDismissed, isTrue);

      // Should not throw.
      controller.dismiss();
      await tester.pumpAndSettle();
      expect(find.byType(MToast), findsNothing);
    });
  });

  group('stacking', () {
    testWidgets('multiple toasts stack vertically',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('First'),
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();
      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Second'),
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MToast), findsNWidgets(2));

      // For a bottom-end stack, the newest (Second) sits at the bottom and
      // the older (First) is pushed above it.
      final double firstTop = tester.getTopLeft(find.text('First')).dy;
      final double secondTop = tester.getTopLeft(find.text('Second')).dy;
      expect(firstTop < secondTop, isTrue,
          reason: 'older toast (First) should sit ABOVE newest (Second)');

      // Cleanup
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });

    testWidgets('top-anchored toasts stack downward',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('First'),
        anchor: MToastAnchor.topEnd,
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();
      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Second'),
        anchor: MToastAnchor.topEnd,
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      final double firstTop = tester.getTopLeft(find.text('First')).dy;
      final double secondTop = tester.getTopLeft(find.text('Second')).dy;
      expect(firstTop > secondTop, isTrue,
          reason: 'top anchor: older toast pushed DOWN by newer one');

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });
  });

  group('anchor placement', () {
    testWidgets('bottomEnd default hugs the bottom-right corner',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      final Rect toast = tester.getRect(find.byType(MToast));
      final Size viewport = tester.view.physicalSize / tester.view.devicePixelRatio;
      // edgeInset = 16 in the default style.
      expect(viewport.height - toast.bottom, closeTo(16, 0.5));
      expect(viewport.width - toast.right, closeTo(16, 0.5));

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });

    testWidgets('topStart hugs the top-left corner',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        anchor: MToastAnchor.topStart,
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      final Rect toast = tester.getRect(find.byType(MToast));
      expect(toast.top, closeTo(16, 0.5));
      expect(toast.left, closeTo(16, 0.5));

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });
  });

  group('style', () {
    testWidgets('style delta overrides padding',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        style: const MToastStyleDelta(padding: EdgeInsets.all(40)),
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      // Anchor the Padding finder to the DefaultTextStyle wrapper inside the
      // toast body — the toast surface has no other Padding rings, but be
      // defensive (see MSheet style-delta test commentary).
      final Finder padding = find.ancestor(
        of: find.byType(DefaultTextStyle).last,
        matching: find.byType(Padding),
      );
      final Padding widget = tester.widget<Padding>(padding.first);
      expect(widget.padding, const EdgeInsets.all(40));

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });

    testWidgets('default theme background is colors.popover',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      final Finder surface = find.descendant(
        of: find.byType(MToast),
        matching: find.byType(DecoratedBox),
      );
      final DecoratedBox box = tester.widget<DecoratedBox>(surface.first);
      final BoxDecoration decoration = box.decoration as BoxDecoration;
      expect(decoration.color, const MColorScheme.light().popover);

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });

    testWidgets('caller theme is re-installed inside the overlay',
        (WidgetTester tester) async {
      const Color distinctive = Color(0xFFAB12CD);
      final MThemeData themed = MThemeData.light().copyWith(
        colors: const MColorScheme.light().copyWith(popover: distinctive),
      );
      final BuildContext rootContext =
          await _pumpAppContext(tester, theme: themed);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      final Finder surface = find.descendant(
        of: find.byType(MToast),
        matching: find.byType(DecoratedBox),
      );
      final DecoratedBox box = tester.widget<DecoratedBox>(surface.first);
      final BoxDecoration decoration = box.decoration as BoxDecoration;
      expect(decoration.color, distinctive);

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });
  });

  group('semantics', () {
    testWidgets('semanticLabel reaches the Semantics on the surface',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(tester);

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        semanticLabel: 'Notification',
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      final Finder semantics = find.descendant(
        of: find.byType(MToast),
        matching: find.byType(Semantics),
      );
      // The first Semantics node descendant of MToast is the surface label.
      final Semantics widget = tester.widget<Semantics>(semantics.first);
      expect(widget.properties.label, 'Notification');
      expect(widget.properties.liveRegion, isTrue);

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });
  });

  group('hover-to-pause', () {
    testWidgets('mouse hover pauses the auto-dismiss timer',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(
        tester,
        modality: MInputModality.mouse,
      );

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        duration: const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MToast), findsOneWidget);

      // Move a synthetic mouse pointer over the toast and hold it there
      // past the 2s auto-dismiss window. The MouseRegion's onEnter should
      // pause the timer, so the toast stays mounted.
      final Offset center = tester.getCenter(find.byType(MToast));
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(center);
      await tester.pump();

      // 3 seconds elapse with pointer parked on the toast.
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(MToast), findsOneWidget,
          reason: 'timer should be paused while hovering');

      // Move the pointer off — timer resumes from where it paused, finishes,
      // exit animation plays out.
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(MToast), findsNothing);
    });

    testWidgets('touch modality does not install MouseRegion',
        (WidgetTester tester) async {
      final BuildContext rootContext = await _pumpAppContext(
        tester,
        modality: MInputModality.touch,
      );

      showMToast(
        rootContext,
        builder: (BuildContext _) => const Text('Saved'),
        duration: const Duration(seconds: 60),
      );
      await tester.pumpAndSettle();

      // No MouseRegion inside the toast subtree under touch.
      expect(
        find.descendant(
          of: find.byType(MToast),
          matching: find.byType(MouseRegion),
        ),
        findsNothing,
      );

      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
    });
  });
}
