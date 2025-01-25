import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('pumpManyApp', () {
    testWidgets('installs MTheme, MInputModalityScope, and a sized MediaQuery',
        (WidgetTester tester) async {
      late MThemeData seenTheme;
      late MInputModality seenModality;
      late Size seenSize;

      await pumpManyApp(
        tester,
        Builder(
          builder: (BuildContext context) {
            seenTheme = MTheme.of(context);
            seenModality = MInputModalityScope.of(context);
            seenSize = MediaQuery.sizeOf(context);
            return const SizedBox.shrink();
          },
        ),
        theme: MThemeData.dark(),
        viewport: const Size(360, 800),
        modality: MInputModality.keyboard,
      );

      expect(seenTheme.colors.background,
          const MColorScheme.dark().background);
      expect(seenModality, MInputModality.keyboard);
      expect(seenSize, const Size(360, 800));
    });

    testWidgets('omitted modality derives from theme platform',
        (WidgetTester tester) async {
      late MInputModality seen;
      await pumpManyApp(
        tester,
        Builder(
          builder: (BuildContext context) {
            seen = MInputModalityScope.of(context);
            return const SizedBox.shrink();
          },
        ),
        theme: MThemeData.light(platform: TargetPlatform.android),
      );
      expect(seen, MInputModality.touch);
    });

    testWidgets('DefaultTextStyle carries the theme body slot',
        (WidgetTester tester) async {
      TextStyle? captured;
      await pumpManyApp(
        tester,
        Builder(
          builder: (BuildContext context) {
            captured = DefaultTextStyle.of(context).style;
            return const SizedBox.shrink();
          },
        ),
      );
      expect(captured!.fontSize, 14);
      expect(captured!.color, const MColorScheme.light().foreground);
    });

    testWidgets('installOverlay defaults to no ambient Overlay',
        (WidgetTester tester) async {
      OverlayState? seen;
      await pumpManyApp(
        tester,
        Builder(
          builder: (BuildContext context) {
            seen = Overlay.maybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(seen, isNull);
    });

    testWidgets('installOverlay: true exposes an ambient Overlay',
        (WidgetTester tester) async {
      OverlayState? seen;
      await pumpManyApp(
        tester,
        Builder(
          builder: (BuildContext context) {
            seen = Overlay.maybeOf(context);
            return const SizedBox.shrink();
          },
        ),
        installOverlay: true,
      );
      expect(seen, isNotNull);
    });
  });
}
