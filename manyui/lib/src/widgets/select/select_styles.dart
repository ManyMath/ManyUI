import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'select_style.dart';

/// The resolution table for [MSelect].
///
/// Lives on `MThemeData.select`. The default table maps shadcn's popover
/// tokens to the anchor and overlay surfaces: `colors.background` /
/// `colors.input` for the anchor, `colors.popover` / `colors.border` for the
/// overlay, and `colors.accent` for the focused-item background.
///
/// ```dart
/// final MSelectStyle style = theme.select.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MSelectStyles {
  /// Builds a styles table.
  const MSelectStyles();

  /// Returns the resolved [MSelectStyle] under [modality] and the supplied
  /// theme tokens.
  MSelectStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;
    // Mouse: 36 px tall anchor / 32 px tall row. Touch: 44 px / 40 px so the
    // row stays an Apple-style 40+ logical pixels.
    final double anchorHeight = touch ? 44 : 36;
    final double rowHeight = touch ? 40 : 32;

    final BorderRadius cornerRadius = BorderRadius.circular(radius);

    return MSelectStyle(
      minHeight: anchorHeight,
      anchorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      anchorBackgroundColor: colors.background,
      anchorForegroundColor: colors.foreground,
      anchorBorderColor: colors.input,
      anchorBorderWidth: 1,
      anchorRadius: cornerRadius,
      placeholderColor: colors.mutedForeground,
      textStyle: typography.body,
      iconColor: colors.mutedForeground,
      popoverBackgroundColor: colors.popover,
      popoverBorderColor: colors.border,
      popoverBorderWidth: 1,
      popoverRadius: cornerRadius,
      popoverElevation: 12,
      popoverShadowColor: const Color(0x33000000),
      popoverPadding: const EdgeInsets.all(4),
      popoverGap: 4,
      popoverMaxHeight: 280,
      itemMinHeight: rowHeight,
      itemPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemForegroundColor: colors.popoverForeground,
      itemFocusedBackgroundColor: colors.accent,
      itemSelectedBackgroundColor: colors.accent,
      itemSelectedForegroundColor: colors.accentForeground,
      itemRadius: BorderRadius.circular(radius - 2 < 0 ? 0 : radius - 2),
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MSelectStyles;

  @override
  int get hashCode => (MSelectStyles).hashCode;
}
