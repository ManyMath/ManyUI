import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'list_tile_style.dart';

/// The resolution table for [MListTile].
///
/// Lives on `MThemeData.listTile` so apps can swap the entire table to
/// re-skin every row at once. The default table is derived from the
/// [MColorScheme] and [MTypography] tokens passed into [resolve].
///
/// ```dart
/// final MListTileStyle style = theme.listTile.resolve(
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MListTileStyles {
  /// Builds a styles table.
  const MListTileStyles();

  /// Returns the resolved [MListTileStyle] using the supplied theme tokens.
  MListTileStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    return MListTileStyle(
      backgroundColor: const Color(0x00000000),
      selectedBackgroundColor: colors.accent,
      foregroundColor: colors.foreground,
      selectedForegroundColor: colors.accentForeground,
      subtitleColor: colors.mutedForeground,
      titleStyle: typography.body,
      subtitleStyle: typography.bodySmall,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      horizontalGap: 12,
      radius: BorderRadius.circular(radius),
    );
  }

  @override
  bool operator ==(Object other) => other is MListTileStyles;

  @override
  int get hashCode => (MListTileStyles).hashCode;
}
