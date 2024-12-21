import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import 'checkbox_style.dart';

/// The resolution table for [MCheckbox].
///
/// Lives on `MThemeData.checkbox`. The default table reads `colors.primary`
/// for the checked fill, `colors.primaryForeground` for the checkmark stroke,
/// and `colors.border` for the unchecked border. Touch modality bumps the
/// box size up so the hit target stays a comfortable 44+ logical pixels once
/// the surrounding padding is added by the widget.
///
/// ```dart
/// final MCheckboxStyle style = theme.checkbox.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MCheckboxStyles {
  /// Builds a styles table.
  const MCheckboxStyles();

  /// Returns the resolved [MCheckboxStyle] under [modality] and the supplied
  /// theme tokens.
  MCheckboxStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;
    final double size = touch ? 22 : 18;
    final double checkmarkThickness = touch ? 2.2 : 1.8;

    return MCheckboxStyle(
      size: size,
      borderColor: colors.border,
      borderWidth: 1.5,
      uncheckedBackgroundColor: const Color(0x00000000),
      checkedBackgroundColor: colors.primary,
      checkmarkColor: colors.primaryForeground,
      checkmarkThickness: checkmarkThickness,
      radius: BorderRadius.circular(radius * 0.66),
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MCheckboxStyles;

  @override
  int get hashCode => (MCheckboxStyles).hashCode;
}
