import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'toast_style.dart';

/// The resolution table for [MToast].
///
/// Lives on `MThemeData.toast`. The default style mirrors the popover surface
/// — `colors.popover` background with `colors.popoverForeground` text — adds
/// a 24-blur shadow, a 360-logical-pixel max width, a 16-pixel inset from the
/// anchored viewport edge, and an 8-pixel gap between stacked toasts.
///
/// ```dart
/// final MToastStyle style = theme.toast.resolve(
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MToastStyles {
  /// Builds a styles table.
  const MToastStyles();

  /// Returns the resolved [MToastStyle] under the supplied theme tokens.
  MToastStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    return MToastStyle(
      backgroundColor: colors.popover,
      foregroundColor: colors.popoverForeground,
      borderColor: colors.border,
      borderWidth: 1,
      radius: BorderRadius.circular(radius),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 24,
      shadowColor: const Color(0x40000000),
      maxWidth: 360,
      edgeInset: 16,
      gap: 8,
    );
  }

  @override
  bool operator ==(Object other) => other is MToastStyles;

  @override
  int get hashCode => (MToastStyles).hashCode;
}
