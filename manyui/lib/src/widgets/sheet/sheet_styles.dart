import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'sheet_style.dart';

/// The resolution table for [MSheet].
///
/// Lives on `MThemeData.sheet`. The default style mirrors the popover surface
/// — `colors.popover` background with `colors.popoverForeground` text — and
/// adds a translucent black scrim. Unlike [MDialogStyles] there is no
/// max-width clamp; sheets fill their anchored edge.
///
/// ```dart
/// final MSheetStyle style = theme.sheet.resolve(
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MSheetStyles {
  /// Builds a styles table.
  const MSheetStyles();

  /// Returns the resolved [MSheetStyle] under the supplied theme tokens.
  MSheetStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    return MSheetStyle(
      backgroundColor: colors.popover,
      foregroundColor: colors.popoverForeground,
      borderColor: colors.border,
      borderWidth: 1,
      radius: BorderRadius.circular(radius),
      padding: const EdgeInsets.all(24),
      elevation: 24,
      shadowColor: const Color(0x40000000),
      scrimColor: const Color(0x80000000),
      sideWidth: 320,
      maxHeightFraction: 0.8,
      dragHandleColor: colors.mutedForeground,
    );
  }

  @override
  bool operator ==(Object other) => other is MSheetStyles;

  @override
  int get hashCode => (MSheetStyles).hashCode;
}
