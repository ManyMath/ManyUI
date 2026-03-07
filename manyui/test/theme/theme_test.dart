import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

void main() {
  group('MColorScheme', () {
    test('light and dark differ on background', () {
      expect(
        const MColorScheme.light().background ==
            const MColorScheme.dark().background,
        isFalse,
      );
    });

    test('copyWith overrides only the supplied tokens', () {
      const MColorScheme base = MColorScheme.light();
      final MColorScheme tweaked = base.copyWith(
        primary: const Color(0xFF00FF00),
      );
      expect(tweaked.primary, const Color(0xFF00FF00));
      expect(tweaked.foreground, base.foreground);
      expect(tweaked.background, base.background);
    });

    test('equality uses field-wise comparison', () {
      expect(const MColorScheme.light(), const MColorScheme.light());
      expect(const MColorScheme.light() == const MColorScheme.dark(), isFalse);
    });
  });

  group('MTypography', () {
    test('standard slots have no fontFamily on text slots', () {
      const MTypography t = MTypography.standard();
      expect(t.body.fontFamily, isNull);
      expect(t.title.fontFamily, isNull);
      expect(t.label.fontFamily, isNull);
    });

    test('code slot does pin a monospace family', () {
      const MTypography t = MTypography.standard();
      expect(t.code.fontFamily, 'monospace');
    });

    test('standard and workbench typography never tighten letter spacing', () {
      const sets = <MTypography>[
        MTypography.standard(),
        MTypography.workbench(),
      ];
      for (final MTypography typography in sets) {
        expect(typography.displayLarge.letterSpacing, 0);
        expect(typography.displaySmall.letterSpacing, 0);
        expect(typography.headlineLarge.letterSpacing, 0);
        expect(typography.headlineSmall.letterSpacing, 0);
      }
    });

    testWidgets('inheritFromContext merges DefaultTextStyle.style into slots', (
      WidgetTester tester,
    ) async {
      MTypography? captured;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 99, color: Color(0xFF112233)),
            child: Builder(
              builder: (BuildContext context) {
                captured = const MTypography.standard().inheritFromContext(
                  context,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      // The slot's own fontSize wins (body=14), but the ambient color flows in.
      expect(captured!.body.fontSize, 14);
      expect(captured!.body.color, const Color(0xFF112233));
    });
  });

  group('MThemeData', () {
    test('light/dark factories pair the matching color scheme', () {
      expect(
        MThemeData.light().colors.background,
        const MColorScheme.light().background,
      );
      expect(
        MThemeData.dark().colors.background,
        const MColorScheme.dark().background,
      );
    });

    test('copyWith preserves untouched fields', () {
      final MThemeData base = MThemeData.light();
      final MThemeData tweaked = base.copyWith(radius: 12);
      expect(tweaked.radius, 12);
      expect(tweaked.colors, base.colors);
      expect(tweaked.typography, base.typography);
      expect(tweaked.platform, base.platform);
    });

    test('workbench factories create layered, branded surfaces', () {
      final light = MThemeData.workbenchLight(primary: const Color(0xFF176D5B));
      final dark = MThemeData.workbenchDark(primary: const Color(0xFF62D1B3));

      expect(light.colors.card, isNot(light.colors.background));
      expect(dark.colors.card, isNot(dark.colors.background));
      expect(light.colors.primary, const Color(0xFF176D5B));
      expect(dark.colors.primary, const Color(0xFF62D1B3));
      expect(light.typography, const MTypography.workbench());
      expect(dark.radius, 7);
    });

    test('workbench dark destructive text meets normal-text contrast', () {
      final colors = MThemeData.workbenchDark(
        primary: const Color(0xFF62D1B3),
      ).colors;
      final double lighter = colors.destructiveForeground.computeLuminance();
      final double darker = colors.destructive.computeLuminance();
      final double ratio = (lighter + 0.05) / (darker + 0.05);

      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  });

  group('MTheme', () {
    testWidgets('of returns the nearest ancestor data', (
      WidgetTester tester,
    ) async {
      late MThemeData seen;
      final MThemeData themed = MThemeData.dark();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MTheme(
            data: themed,
            child: Builder(
              builder: (BuildContext context) {
                seen = MTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(seen, themed);
    });

    testWidgets('of falls back to light when no ancestor is installed', (
      WidgetTester tester,
    ) async {
      late MThemeData seen;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              seen = MTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.colors.background, const MColorScheme.light().background);
    });

    testWidgets('maybeOf returns null when no ancestor is installed', (
      WidgetTester tester,
    ) async {
      MThemeData? seen;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              seen = MTheme.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen, isNull);
    });

    testWidgets('updateShouldNotify rebuilds dependents when data changes', (
      WidgetTester tester,
    ) async {
      MThemeData? lastSeen;
      int builds = 0;
      Widget app(MThemeData data) => Directionality(
        textDirection: TextDirection.ltr,
        child: MTheme(
          data: data,
          child: Builder(
            builder: (BuildContext context) {
              builds++;
              lastSeen = MTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(app(MThemeData.light()));
      final int after1 = builds;
      expect(
        lastSeen!.colors.background,
        const MColorScheme.light().background,
      );

      await tester.pumpWidget(app(MThemeData.dark()));
      expect(builds, greaterThan(after1));
      expect(lastSeen!.colors.background, const MColorScheme.dark().background);
    });

    testWidgets('context.mTheme sugar matches MTheme.of', (
      WidgetTester tester,
    ) async {
      late MThemeData viaSugar;
      late MThemeData viaOf;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MTheme(
            data: MThemeData.dark(),
            child: Builder(
              builder: (BuildContext context) {
                viaSugar = context.mTheme;
                viaOf = MTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(viaSugar, viaOf);
    });
  });
}
