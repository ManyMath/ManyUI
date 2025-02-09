import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'otp_field_style.dart';

/// The resolution table for [MOTPField].
///
/// Lives on `MThemeData.otpField`. The default table maps shadcn's input
/// tokens to each cell: `colors.background` fill + `colors.input` border in
/// the idle state, swapping the border to `colors.ring` on focus, to
/// `colors.foreground` (subtler) when the cell is filled but not focused,
/// and to `colors.destructive` in error.
///
/// ```dart
/// final MOTPFieldStyle style = theme.otpField.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MOTPFieldStyles {
  /// Builds a styles table.
  const MOTPFieldStyles();

  /// Returns the resolved [MOTPFieldStyle] under [modality] and the supplied
  /// theme tokens.
  MOTPFieldStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;
    // OTP cells are square. Touch modality gets a larger hit target so a
    // 6-digit code stays comfortably tappable on phones.
    final double size = touch ? 48 : 40;

    return MOTPFieldStyle(
      cellSize: size,
      cellGap: 8,
      cellPadding: EdgeInsets.zero,
      cellBackgroundColor: colors.background,
      cellBorderColor: colors.input,
      cellFocusedBorderColor: colors.ring,
      cellFilledBorderColor: colors.foreground,
      cellErrorBorderColor: colors.destructive,
      cellBorderWidth: 1,
      cellRadius: BorderRadius.circular(radius),
      // OTP codes look right at slightly heavier weight than body text — the
      // digits read as a fixed-width sequence rather than running prose.
      textStyle: typography.body.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
      cursorColor: colors.foreground,
      selectionColor: colors.ring.withValues(alpha: 0.25),
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MOTPFieldStyles;

  @override
  int get hashCode => (MOTPFieldStyles).hashCode;
}
