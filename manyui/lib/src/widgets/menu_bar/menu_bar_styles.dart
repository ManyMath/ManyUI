import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'menu_bar_style.dart';

/// The resolution table for [MMenuBar].
///
/// Lives on `MThemeData.menuBar`. The default style mirrors shadcn's menubar:
/// flat menu titles in the strip, accent-tinted background under the open
/// menu's title, popover surface that matches [MPopover]'s look so menus
/// don't visually drift from other floating surfaces. Touch modality grows
/// the title height to a comfortable 44 logical pixels; mouse modality uses
/// 32, plus a tighter item height inside the popover.
///
/// ```dart
/// final MMenuBarStyle style = theme.menuBar.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MMenuBarStyles {
  /// Builds a styles table.
  const MMenuBarStyles();

  /// Returns the resolved [MMenuBarStyle] under [modality] and the supplied
  /// theme tokens.
  MMenuBarStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;
    final double titleHeight = touch ? 44 : 32;
    final double itemHeight = touch ? 40 : 32;

    return MMenuBarStyle(
      titleHeight: titleHeight,
      titlePadding: const EdgeInsets.symmetric(horizontal: 10),
      titleSpacing: 2,
      activeTitleBackgroundColor: colors.accent,
      hoveredTitleBackgroundColor: colors.muted,
      titleForegroundColor: colors.foreground,
      disabledOpacity: 0.5,
      titleTextStyle: typography.label,
      titleRadius: BorderRadius.circular(radius),
      popoverBackgroundColor: colors.popover,
      popoverForegroundColor: colors.popoverForeground,
      popoverBorderColor: colors.border,
      popoverBorderWidth: 1,
      popoverRadius: BorderRadius.circular(radius),
      popoverPadding: const EdgeInsets.all(4),
      popoverElevation: 12,
      popoverShadowColor: const Color(0x33000000),
      popoverGap: 4,
      popoverMinWidth: 160,
      itemHeight: itemHeight,
      itemPadding: const EdgeInsets.symmetric(horizontal: 8),
      itemSpacing: 2,
      itemForegroundColor: colors.popoverForeground,
      itemHoveredBackgroundColor: colors.accent,
      itemTextStyle: typography.label,
      itemTrailingForegroundColor: colors.mutedForeground,
      itemRadius: BorderRadius.circular(radius),
    );
  }

  @override
  bool operator ==(Object other) => other is MMenuBarStyles;

  @override
  int get hashCode => (MMenuBarStyles).hashCode;
}
