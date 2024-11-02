import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

/// Pumps [child] inside a minimal [MWidgetsApp]-equivalent test wrapper.
///
/// Unlike [WidgetTester.pumpWidget] alone, `pumpManyApp` installs the
/// [MTheme], [MInputModalityScope], and [MediaQuery] a typical M-widget
/// expects to find above it, without requiring the test to construct an
/// [MWidgetsApp] (which would pull in [Navigator] and routing machinery
/// usually unneeded for widget-level tests).
///
/// Pass [viewport] to size the test surface — defaults to 800×600. Pass
/// [modality] to force a specific input modality. Pass [theme] for non-
/// default theming; omitted [theme] uses `MThemeData.light()`.
///
/// ```dart
/// testWidgets('MButton renders', (tester) async {
///   await pumpManyApp(
///     tester,
///     MButton(onPressed: () {}, child: const Text('Save')),
///     modality: MInputModality.keyboard,
///   );
///   expect(find.text('Save'), findsOneWidget);
/// });
/// ```
Future<void> pumpManyApp(
  WidgetTester tester,
  Widget child, {
  MThemeData? theme,
  Size? viewport,
  MInputModality? modality,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  final MThemeData resolvedTheme = theme ?? MThemeData.light();
  final Size resolvedViewport = viewport ?? const Size(800, 600);
  final MInputModality resolvedModality = modality ??
      MInputModality.defaultForPlatform(resolvedTheme.platform);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: resolvedViewport),
      child: Directionality(
        textDirection: textDirection,
        child: MTheme(
          data: resolvedTheme,
          child: MInputModalityScope(
            modality: resolvedModality,
            child: DefaultTextStyle(
              style: resolvedTheme.typography.body.copyWith(
                color: resolvedTheme.colors.foreground,
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
