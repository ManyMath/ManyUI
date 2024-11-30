import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import 'card_style.dart';

/// The resolution table for [MCard].
///
/// Lives on `MThemeData.card` so apps can swap the entire table to re-skin
/// every card in the tree at once. The default table is derived from the
/// [MColorScheme] tokens passed into [resolve].
///
/// ```dart
/// final MCardStyle style = theme.card.resolve(
///   colors: theme.colors,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MCardStyles {
  /// Builds a styles table.
  const MCardStyles();

  /// Returns the resolved [MCardStyle] using the supplied theme tokens.
  MCardStyle resolve({
    required MColorScheme colors,
    required double radius,
  }) {
    return MCardStyle(
      backgroundColor: colors.card,
      foregroundColor: colors.cardForeground,
      borderColor: colors.border,
      borderWidth: 1,
      padding: const EdgeInsets.all(16),
      radius: BorderRadius.circular(radius),
    );
  }

  @override
  bool operator ==(Object other) => other is MCardStyles;

  @override
  int get hashCode => (MCardStyles).hashCode;
}
