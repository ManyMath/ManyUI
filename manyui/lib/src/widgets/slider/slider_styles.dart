import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import 'slider_style.dart';

/// The resolution table for [MSlider].
///
/// Lives on `MThemeData.slider`. The default table reads `colors.primary` for
/// the active track segment, `colors.input` for the inactive segment, and
/// `colors.background` for the thumb (with a `colors.border` hairline). Touch
/// modality bumps the thumb to a comfortable WCAG hit target.
///
/// ```dart
/// final MSliderStyle style = theme.slider.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
/// );
/// ```
@immutable
class MSliderStyles {
  /// Builds a styles table.
  const MSliderStyles();

  /// Returns the resolved [MSliderStyle] under [modality] and the supplied
  /// theme tokens.
  MSliderStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
  }) {
    final bool touch = modality == MInputModality.touch;
    // Mouse: 4 px track, 16 px thumb. Touch: 6 px track, 24 px thumb (WCAG).
    final double trackHeight = touch ? 6 : 4;
    final double thumbDiameter = touch ? 24 : 16;

    return MSliderStyle(
      trackHeight: trackHeight,
      thumbDiameter: thumbDiameter,
      minTrackWidth: 120,
      activeTrackColor: colors.primary,
      inactiveTrackColor: colors.input,
      thumbColor: colors.background,
      thumbBorderColor: colors.primary,
      thumbBorderWidth: 2,
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MSliderStyles;

  @override
  int get hashCode => (MSliderStyles).hashCode;
}
