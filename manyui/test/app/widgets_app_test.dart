import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

void main() {
  group('MWidgetsApp', () {
    testWidgets('mounts without a MaterialApp or CupertinoApp ancestor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MWidgetsApp(
          home: Center(child: Text('home')),
        ),
      );
      expect(find.text('home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('installs MTheme so descendants see MThemeData',
        (WidgetTester tester) async {
      late MThemeData seen;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              seen = MTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.colors.background, const MColorScheme.light().background);
    });

    testWidgets('installs MInputModalityScope with a platform-derived default',
        (WidgetTester tester) async {
      late MInputModality seen;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (BuildContext context) {
              seen = MInputModalityScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // iOS → touch.
      expect(seen, MInputModality.touch);
    });

    testWidgets('themeMode.light forces the light theme', (tester) async {
      late MThemeData seen;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(),
          darkTheme: MThemeData.dark(),
          themeMode: MThemeMode.light,
          home: Builder(
            builder: (BuildContext context) {
              seen = MTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.colors.background, const MColorScheme.light().background);
    });

    testWidgets('themeMode.dark forces the dark theme', (tester) async {
      late MThemeData seen;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(),
          darkTheme: MThemeData.dark(),
          themeMode: MThemeMode.dark,
          home: Builder(
            builder: (BuildContext context) {
              seen = MTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.colors.background, const MColorScheme.dark().background);
    });

    testWidgets('themeMode.system tracks platformBrightness', (tester) async {
      late MThemeData seen;
      Widget app() => MediaQuery(
            data: const MediaQueryData(platformBrightness: Brightness.dark),
            child: MWidgetsApp(
              theme: MThemeData.light(),
              darkTheme: MThemeData.dark(),
              builder: (BuildContext context, Widget? child) {
                seen = MTheme.of(context);
                return child ?? const SizedBox.shrink();
              },
              home: const SizedBox.shrink(),
            ),
          );
      await tester.pumpWidget(app());
      expect(seen.colors.background, const MColorScheme.dark().background);
    });

    testWidgets('DefaultTextStyle inherits the theme body typography',
        (tester) async {
      TextStyle? captured;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              captured = DefaultTextStyle.of(context).style;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // body slot fontSize is 14 per MTypography.standard.
      expect(captured!.fontSize, 14);
      expect(captured!.color, const MColorScheme.light().foreground);
    });

    testWidgets(
        'does not depend on Material — the Material widget is absent in-tree',
        (tester) async {
      await tester.pumpWidget(
        const MWidgetsApp(home: Center(child: Text('home'))),
      );
      // package:flutter/material.dart's Material widget would be in the tree
      // if MaterialApp were used. We can't import it here without dragging it
      // in, but we can confirm the runtimeType chain doesn't include
      // 'Material' or 'CupertinoApp' as ancestors.
      bool foundMaterial = false;
      bool foundCupertinoApp = false;
      for (final Widget w in tester.allWidgets) {
        final String name = w.runtimeType.toString();
        if (name == 'Material' || name == 'MaterialApp') foundMaterial = true;
        if (name == 'CupertinoApp') foundCupertinoApp = true;
      }
      expect(foundMaterial, isFalse);
      expect(foundCupertinoApp, isFalse);
    });
  });
}
