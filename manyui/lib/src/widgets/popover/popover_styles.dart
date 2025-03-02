import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'popover_style.dart';

/// The resolution table for [MPopover].
///
/// Lives on `MThemeData.popover`. The default style mirrors MSelect's popover
/// surface — `colors.popover` background with `colors.popoverForeground`
/// text — so any standalone popover sits comfortably next to a select's
/// dropdown.
///
/// ```dart
/// final MPopoverStyle style = theme.popover.resolve(
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MPopoverStyles {
  /// Builds a styles table.
  const MPopoverStyles();

  /// Returns the resolved [MPopoverStyle] under the supplied theme tokens.
  MPopoverStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    return MPopoverStyle(
      backgroundColor: colors.popover,
      foregroundColor: colors.popoverForeground,
      borderColor: colors.border,
      borderWidth: 1,
      radius: BorderRadius.circular(radius),
      padding: const EdgeInsets.all(8),
      elevation: 12,
      shadowColor: const Color(0x33000000),
      gap: 4,
    );
  }

  @override
  bool operator ==(Object other) => other is MPopoverStyles;

  @override
  int get hashCode => (MPopoverStyles).hashCode;
}
