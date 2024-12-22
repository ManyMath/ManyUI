import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import 'switch_style.dart';

/// The resolution table for [MSwitch].
///
/// Lives on `MThemeData.switch_`. The default table reads `colors.primary`
/// for the on-track fill, `colors.input` for the off-track fill, and a
/// single light-leaning [MSwitchStyle.thumbColor] for both states (matching
/// shadcn's switch which uses one thumb color regardless of theme mode).
/// Touch modality bumps the track up so the hit target stays a comfortable
/// 44+ logical pixels once the surrounding padding is added by the widget.
///
/// ```dart
/// final MSwitchStyle style = theme.switch_.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
/// );
/// ```
@immutable
class MSwitchStyles {
  /// Builds a styles table.
  const MSwitchStyles();

  /// Returns the resolved [MSwitchStyle] under [modality] and the supplied
  /// theme tokens.
  MSwitchStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
  }) {
    final bool touch = modality == MInputModality.touch;
    // Mouse: 32x18 track, 14 thumb (shadcn-default sizing).
    // Touch: 44x24 track, 20 thumb (lifts hit target to ~44 px).
    final double trackWidth = touch ? 44 : 32;
    final double trackHeight = touch ? 24 : 18;
    final double thumbDiameter = touch ? 20 : 14;

    return MSwitchStyle(
      trackWidth: trackWidth,
      trackHeight: trackHeight,
      thumbDiameter: thumbDiameter,
      thumbPadding: 2,
      offTrackColor: colors.input,
      onTrackColor: colors.primary,
      thumbColor: const Color(0xFFFFFFFF),
      borderColor: const Color(0x00000000),
      borderWidth: 0,
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MSwitchStyles;

  @override
  int get hashCode => (MSwitchStyles).hashCode;
}
