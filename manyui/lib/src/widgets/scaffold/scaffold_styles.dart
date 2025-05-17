import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import 'scaffold_style.dart';

/// The resolution table for [MScaffold].
///
/// Lives on `MThemeData.scaffold` so apps can swap the entire table to
/// re-skin every scaffold in the tree at once. The default table is derived
/// from the [MColorScheme] tokens passed into [resolve].
///
/// ```dart
/// final MScaffoldStyle style = theme.scaffold.resolve(colors: theme.colors);
/// ```
@immutable
class MScaffoldStyles {
  /// Builds a styles table.
  const MScaffoldStyles();

  /// Returns the resolved [MScaffoldStyle] using the supplied theme tokens.
  MScaffoldStyle resolve({required MColorScheme colors}) {
    return MScaffoldStyle(
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
      bodyPadding: EdgeInsets.zero,
      headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      footerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  bool operator ==(Object other) => other is MScaffoldStyles;

  @override
  int get hashCode => (MScaffoldStyles).hashCode;
}
