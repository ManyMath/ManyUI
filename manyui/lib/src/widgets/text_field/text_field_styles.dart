import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'text_field_style.dart';

/// The resolution table for [MTextField].
///
/// Lives on `MThemeData.textField`. The default table maps shadcn's input
/// tokens to the surface: `colors.background` + `colors.input` border in the
/// idle state, swapping the border to `colors.ring` on focus and to
/// `colors.destructive` in error. The placeholder uses `colors.mutedForeground`
/// and the cursor uses `colors.foreground`.
///
/// ```dart
/// final MTextFieldStyle style = theme.textField.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MTextFieldStyles {
  /// Builds a styles table.
  const MTextFieldStyles();

  /// Returns the resolved [MTextFieldStyle] under [modality] and the supplied
  /// theme tokens.
  MTextFieldStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;
    // Match the MSelect anchor scale so a label-text-field-select row lines up
    // vertically: 36 px on mouse, 44 px on touch.
    final double height = touch ? 44 : 36;

    return MTextFieldStyle(
      minHeight: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      backgroundColor: colors.background,
      borderColor: colors.input,
      focusedBorderColor: colors.ring,
      errorBorderColor: colors.destructive,
      borderWidth: 1,
      radius: BorderRadius.circular(radius),
      textStyle: typography.body,
      placeholderColor: colors.mutedForeground,
      cursorColor: colors.foreground,
      // ~25% opacity over the ring color matches shadcn's selection band.
      selectionColor: colors.ring.withValues(alpha: 0.25),
      iconColor: colors.mutedForeground,
      decorationGap: 8,
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MTextFieldStyles;

  @override
  int get hashCode => (MTextFieldStyles).hashCode;
}
