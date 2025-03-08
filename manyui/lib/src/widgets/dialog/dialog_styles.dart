import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'dialog_style.dart';

/// The resolution table for [MDialog].
///
/// Lives on `MThemeData.dialog`. The default style mirrors the popover surface
/// — `colors.popover` background with `colors.popoverForeground` text — and
/// adds a translucent black scrim and a 425-logical-pixel max width.
///
/// ```dart
/// final MDialogStyle style = theme.dialog.resolve(
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MDialogStyles {
  /// Builds a styles table.
  const MDialogStyles();

  /// Returns the resolved [MDialogStyle] under the supplied theme tokens.
  MDialogStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    return MDialogStyle(
      backgroundColor: colors.popover,
      foregroundColor: colors.popoverForeground,
      borderColor: colors.border,
      borderWidth: 1,
      radius: BorderRadius.circular(radius),
      padding: const EdgeInsets.all(24),
      elevation: 24,
      shadowColor: const Color(0x40000000),
      scrimColor: const Color(0x80000000),
      maxWidth: 425,
    );
  }

  @override
  bool operator ==(Object other) => other is MDialogStyles;

  @override
  int get hashCode => (MDialogStyles).hashCode;
}
