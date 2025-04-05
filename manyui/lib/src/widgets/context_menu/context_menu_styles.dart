import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'context_menu_style.dart';

/// The resolution table for [MContextMenu].
///
/// Lives on `MThemeData.contextMenu`. The default style mirrors shadcn's
/// context menu: same popover surface as [MMenuBar]'s pulldown popovers so
/// the two widgets read as the same visual family. Touch modality grows
/// item height to a comfortable 40 logical pixels; mouse modality uses 32.
///
/// ```dart
/// final MContextMenuStyle style = theme.contextMenu.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MContextMenuStyles {
  /// Builds a styles table.
  const MContextMenuStyles();

  /// Returns the resolved [MContextMenuStyle] under [modality] and the
  /// supplied theme tokens.
  MContextMenuStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;
    final double itemHeight = touch ? 40 : 32;

    return MContextMenuStyle(
      surfaceBackgroundColor: colors.popover,
      surfaceForegroundColor: colors.popoverForeground,
      surfaceBorderColor: colors.border,
      surfaceBorderWidth: 1,
      surfaceRadius: BorderRadius.circular(radius),
      surfacePadding: const EdgeInsets.all(4),
      surfaceElevation: 12,
      surfaceShadowColor: const Color(0x33000000),
      surfaceMinWidth: 160,
      surfaceMaxWidth: 320,
      viewportPadding: 8,
      itemHeight: itemHeight,
      itemPadding: const EdgeInsets.symmetric(horizontal: 8),
      itemSpacing: 2,
      itemForegroundColor: colors.popoverForeground,
      itemHoveredBackgroundColor: colors.accent,
      itemTextStyle: typography.label,
      itemTrailingForegroundColor: colors.mutedForeground,
      itemRadius: BorderRadius.circular(radius),
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MContextMenuStyles;

  @override
  int get hashCode => (MContextMenuStyles).hashCode;
}
