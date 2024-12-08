import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'avatar_style.dart';

/// The resolution table for [MAvatar].
///
/// Lives on `MThemeData.avatar`. The default table renders a muted-token
/// fallback surface with the foreground color on top, and uses the label
/// type slot at semibold weight for fallback initials.
@immutable
class MAvatarStyles {
  /// Builds a styles table.
  const MAvatarStyles();

  /// Returns the resolved [MAvatarStyle] from theme tokens.
  MAvatarStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    return MAvatarStyle(
      backgroundColor: colors.muted,
      foregroundColor: colors.mutedForeground,
      borderColor: null,
      borderWidth: 0,
      textStyle: typography.label.copyWith(fontWeight: FontWeight.w600),
      squareRadius: BorderRadius.circular(radius),
    );
  }

  @override
  bool operator ==(Object other) => other is MAvatarStyles;

  @override
  int get hashCode => (MAvatarStyles).hashCode;
}
