import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import 'radio_style.dart';

/// The resolution table for [MRadio].
///
/// Lives on `MThemeData.radio`. The default table reads `colors.primary` for
/// the selected fill, `colors.primaryForeground` for the inner dot, and
/// `colors.border` for the ring in both states. Touch modality bumps the
/// circle size up so the hit target stays a comfortable 44+ logical pixels
/// once the surrounding padding is added by the widget.
///
/// ```dart
/// final MRadioStyle style = theme.radio.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
/// );
/// ```
@immutable
class MRadioStyles {
  /// Builds a styles table.
  const MRadioStyles();

  /// Returns the resolved [MRadioStyle] under [modality] and the supplied
  /// theme tokens.
  MRadioStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
  }) {
    final bool touch = modality == MInputModality.touch;
    // Mouse: 18 px circle, 8 px inner dot. Touch: 22 px circle, 10 px dot.
    final double size = touch ? 22 : 18;
    final double dotDiameter = touch ? 10 : 8;

    return MRadioStyle(
      size: size,
      borderColor: colors.border,
      borderWidth: 1.5,
      uncheckedBackgroundColor: const Color(0x00000000),
      checkedBackgroundColor: colors.primary,
      dotColor: colors.primaryForeground,
      dotDiameter: dotDiameter,
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MRadioStyles;

  @override
  int get hashCode => (MRadioStyles).hashCode;
}
