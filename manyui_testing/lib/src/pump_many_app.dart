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
/// default theming; omitted [theme] uses `MThemeData.light()`. Pass
/// [installOverlay] to wrap [child] in a minimal [Overlay] — required for
/// widgets that use [OverlayPortal] (`MSelect`, `MDateField`) or whose
/// internals reach for an ambient overlay (`EditableText`'s magnifier in
/// `MTextField`). Defaults to false so the bulk of widgets that don't need
/// one don't pay for an extra layer.
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
  bool installOverlay = false,
}) async {
  final MThemeData resolvedTheme = theme ?? MThemeData.light();
  final Size resolvedViewport = viewport ?? const Size(800, 600);
  final MInputModality resolvedModality = modality ??
      MInputModality.defaultForPlatform(resolvedTheme.platform);

  final Widget hosted = installOverlay
      ? Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(builder: (BuildContext _) => child),
          ],
        )
      : child;

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
              child: hosted,
            ),
          ),
        ),
      ),
    ),
  );
}
