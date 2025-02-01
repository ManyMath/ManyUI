import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'date_field_style.dart';

/// The resolution table for [MDateField].
///
/// Lives on `MThemeData.dateField`. The default table maps shadcn's input
/// tokens to the anchor (mirroring [MTextField]) and the popover tokens to
/// the calendar surface (mirroring [MSelect]'s overlay).
///
/// ```dart
/// final MDateFieldStyle style = theme.dateField.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MDateFieldStyles {
  /// Builds a styles table.
  const MDateFieldStyles();

  /// Returns the resolved [MDateFieldStyle] under [modality] and the supplied
  /// theme tokens.
  MDateFieldStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;
    // Anchor lines up vertically with MTextField and MSelect: 36 px on mouse,
    // 44 px on touch.
    final double anchorHeight = touch ? 44 : 36;
    // The calendar grid stays the same size across modalities — the picker
    // mostly lives on desktop and the touch story is a follow-up.
    final double cellSize = touch ? 40 : 32;

    final BorderRadius cornerRadius = BorderRadius.circular(radius);

    return MDateFieldStyle(
      minHeight: anchorHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      backgroundColor: colors.background,
      borderColor: colors.input,
      focusedBorderColor: colors.ring,
      errorBorderColor: colors.destructive,
      borderWidth: 1,
      radius: cornerRadius,
      textStyle: typography.body,
      placeholderColor: colors.mutedForeground,
      cursorColor: colors.foreground,
      selectionColor: colors.ring.withValues(alpha: 0.25),
      iconColor: colors.mutedForeground,
      decorationGap: 8,
      disabledOpacity: 0.5,
      popoverBackgroundColor: colors.popover,
      popoverBorderColor: colors.border,
      popoverBorderWidth: 1,
      popoverRadius: cornerRadius,
      popoverElevation: 12,
      popoverShadowColor: const Color(0x33000000),
      popoverPadding: const EdgeInsets.all(8),
      popoverGap: 4,
      popoverHeaderTextStyle: typography.body,
      popoverHeaderForegroundColor: colors.popoverForeground,
      popoverWeekdayTextStyle: typography.caption,
      popoverWeekdayColor: colors.mutedForeground,
      cellSize: cellSize,
      cellTextStyle: typography.body,
      cellForegroundColor: colors.popoverForeground,
      cellMutedForegroundColor: colors.mutedForeground,
      cellFocusedBackgroundColor: colors.accent,
      cellSelectedBackgroundColor: colors.primary,
      cellSelectedForegroundColor: colors.primaryForeground,
      cellRadius: BorderRadius.circular(radius - 2 < 0 ? 0 : radius - 2),
    );
  }

  @override
  bool operator ==(Object other) => other is MDateFieldStyles;

  @override
  int get hashCode => (MDateFieldStyles).hashCode;
}
