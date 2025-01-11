import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'label_style.dart';

/// The resolution table for [MLabel].
///
/// Lives on `MThemeData.label`. The default table reads the text style from
/// `typography.label`, the disabled color from `colors.mutedForeground`, and
/// uses an 8-logical-pixel gap between the label and its associated child.
@immutable
class MLabelStyles {
  /// Builds a styles table.
  const MLabelStyles();

  /// Returns the resolved [MLabelStyle] from theme tokens.
  MLabelStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
  }) {
    return MLabelStyle(
      textStyle: typography.label.copyWith(color: colors.foreground),
      disabledColor: colors.mutedForeground,
      gap: 8,
    );
  }

  @override
  bool operator ==(Object other) => other is MLabelStyles;

  @override
  int get hashCode => (MLabelStyles).hashCode;
}
