import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'badge_style.dart';

/// The resolution table for [MBadge].
///
/// Lives on `MThemeData.badge`. The default table maps each [MBadgeVariant]
/// to a pair of theme tokens (background + foreground), uses the caption
/// type slot, and renders a pill (a radius high enough that all corners
/// fully round).
@immutable
class MBadgeStyles {
  /// Builds a styles table.
  const MBadgeStyles();

  /// Returns the resolved [MBadgeStyle] for [variant] from theme tokens.
  MBadgeStyle resolve({
    required MBadgeVariant variant,
    required MColorScheme colors,
    required MTypography typography,
  }) {
    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 8, vertical: 2);
    final TextStyle textStyle = typography.caption.copyWith(
      fontWeight: FontWeight.w600,
    );
    final BorderRadius radius = BorderRadius.circular(999);

    switch (variant) {
      case MBadgeVariant.primary:
        return MBadgeStyle(
          backgroundColor: colors.primary,
          foregroundColor: colors.primaryForeground,
          borderColor: null,
          borderWidth: 0,
          padding: padding,
          textStyle: textStyle,
          radius: radius,
        );
      case MBadgeVariant.secondary:
        return MBadgeStyle(
          backgroundColor: colors.secondary,
          foregroundColor: colors.secondaryForeground,
          borderColor: null,
          borderWidth: 0,
          padding: padding,
          textStyle: textStyle,
          radius: radius,
        );
      case MBadgeVariant.destructive:
        return MBadgeStyle(
          backgroundColor: colors.destructive,
          foregroundColor: colors.destructiveForeground,
          borderColor: null,
          borderWidth: 0,
          padding: padding,
          textStyle: textStyle,
          radius: radius,
        );
      case MBadgeVariant.outline:
        return MBadgeStyle(
          backgroundColor: const Color(0x00000000),
          foregroundColor: colors.foreground,
          borderColor: colors.border,
          borderWidth: 1,
          padding: padding,
          textStyle: textStyle,
          radius: radius,
        );
    }
  }

  @override
  bool operator ==(Object other) => other is MBadgeStyles;

  @override
  int get hashCode => (MBadgeStyles).hashCode;
}
