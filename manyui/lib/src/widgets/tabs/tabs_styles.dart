import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'tabs_style.dart';

/// The resolution table for [MTabs].
///
/// Lives on `MThemeData.tabs`. The default style renders a flat strip with a
/// thin bottom-border indicator under the active tab (shadcn convention).
/// Touch modality bumps the tab height up so the hit target stays a
/// comfortable 48 logical pixels; mouse modality uses a denser 36 pixels.
///
/// ```dart
/// final MTabsStyle style = theme.tabs.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography,
/// );
/// ```
@immutable
class MTabsStyles {
  /// Builds a styles table.
  const MTabsStyles();

  /// Returns the resolved [MTabsStyle] under [modality] and the supplied
  /// theme tokens.
  MTabsStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
  }) {
    final bool touch = modality == MInputModality.touch;
    final double tabHeight = touch ? 48 : 36;

    return MTabsStyle(
      tabHeight: tabHeight,
      tabPadding: const EdgeInsets.symmetric(horizontal: 12),
      tabSpacing: 4,
      activeForegroundColor: colors.foreground,
      inactiveForegroundColor: colors.mutedForeground,
      disabledOpacity: 0.5,
      indicatorColor: colors.primary,
      indicatorThickness: 2,
      stripDividerColor: colors.border,
      stripDividerThickness: 1,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      titleTextStyle: typography.label,
    );
  }

  @override
  bool operator ==(Object other) => other is MTabsStyles;

  @override
  int get hashCode => (MTabsStyles).hashCode;
}
