import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import 'divider_style.dart';

/// The resolution table for [MDivider].
///
/// Lives on `MThemeData.divider`. The default table reads the stroke from
/// `colors.border` and renders a hairline (1 logical pixel).
@immutable
class MDividerStyles {
  /// Builds a styles table.
  const MDividerStyles();

  /// Returns the resolved [MDividerStyle] from theme tokens.
  MDividerStyle resolve({required MColorScheme colors}) {
    return MDividerStyle(color: colors.border, thickness: 1);
  }

  @override
  bool operator ==(Object other) => other is MDividerStyles;

  @override
  int get hashCode => (MDividerStyles).hashCode;
}
