import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'tooltip_style.dart';

/// The resolution table for [MTooltip].
///
/// Lives on `MThemeData.tooltip`. The default style is a small dark surface
/// with light text — shadcn's `popover` tokens get loud against backgrounds,
/// so tooltips invert: `foreground` background with `background` text.
///
/// ```dart
/// final MTooltipStyle style = theme.tooltip.resolve(
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MTooltipStyles {
  /// Builds a styles table.
  const MTooltipStyles();

  /// Returns the resolved [MTooltipStyle] under the supplied theme tokens.
  MTooltipStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    return MTooltipStyle(
      backgroundColor: colors.foreground,
      foregroundColor: colors.background,
      borderColor: null,
      borderWidth: 0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      textStyle: typography.caption,
      radius: BorderRadius.circular(radius),
      elevation: 6,
      shadowColor: const Color(0x33000000),
      gap: 6,
      maxWidth: 240,
      showDelay: const Duration(milliseconds: 500),
      hideDelay: const Duration(milliseconds: 0),
    );
  }

  @override
  bool operator ==(Object other) => other is MTooltipStyles;

  @override
  int get hashCode => (MTooltipStyles).hashCode;
}
