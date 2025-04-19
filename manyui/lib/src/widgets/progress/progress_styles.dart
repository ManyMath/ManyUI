import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import 'progress_style.dart';

/// The resolution table for [MProgress] and [MCircularProgress].
///
/// Lives on `MThemeData.progress`. The default table reads `colors.muted` for
/// the unfilled track segment and `colors.primary` for the value indicator.
///
/// ```dart
/// final MProgressStyle style = theme.progress.resolve(
///   colors: theme.colors,
/// );
/// ```
@immutable
class MProgressStyles {
  /// Builds a styles table.
  const MProgressStyles();

  /// Returns the resolved [MProgressStyle] under the supplied theme tokens.
  MProgressStyle resolve({
    required MColorScheme colors,
  }) {
    return MProgressStyle(
      thickness: 8,
      minWidth: 120,
      diameter: 36,
      trackColor: colors.muted,
      valueColor: colors.primary,
      trackRadius: const Radius.circular(999),
      valueRadius: const Radius.circular(999),
      disabledOpacity: 0.5,
      indeterminateDuration: const Duration(milliseconds: 1500),
    );
  }

  @override
  bool operator ==(Object other) => other is MProgressStyles;

  @override
  int get hashCode => (MProgressStyles).hashCode;
}
