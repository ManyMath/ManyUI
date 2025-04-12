import 'package:flutter/widgets.dart';

import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'command_palette_style.dart';

/// The resolution table for [MCommandPalette].
///
/// Lives on `MThemeData.commandPalette`. The default style mirrors shadcn's
/// command palette ("cmdk"): a popover-surface centered near the top of the
/// viewport, ~520 logical-pixel max width, ~60% viewport-height max, with a
/// search-field header above a scrollable item list.
///
/// ```dart
/// final MCommandPaletteStyle style = theme.commandPalette.resolve(
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MCommandPaletteStyles {
  /// Builds a styles table.
  const MCommandPaletteStyles();

  /// Returns the resolved [MCommandPaletteStyle] under the supplied theme
  /// tokens.
  MCommandPaletteStyle resolve({
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    return MCommandPaletteStyle(
      surfaceBackgroundColor: colors.popover,
      surfaceForegroundColor: colors.popoverForeground,
      surfaceBorderColor: colors.border,
      surfaceBorderWidth: 1,
      surfaceRadius: BorderRadius.circular(radius),
      surfacePadding: EdgeInsets.zero,
      surfaceElevation: 24,
      surfaceShadowColor: const Color(0x40000000),
      scrimColor: const Color(0x80000000),
      maxWidth: 520,
      maxHeightFraction: 0.6,
      topOffset: 96,
      searchPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      searchTextStyle: typography.body.copyWith(color: colors.foreground),
      searchPlaceholderColor: colors.mutedForeground,
      searchDividerColor: colors.border,
      listPadding: const EdgeInsets.all(6),
      itemHeight: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 10),
      itemSpacing: 2,
      itemForegroundColor: colors.popoverForeground,
      itemSubtitleForegroundColor: colors.mutedForeground,
      itemHoveredBackgroundColor: colors.accent,
      itemTitleTextStyle: typography.label,
      itemSubtitleTextStyle: typography.caption,
      itemTrailingForegroundColor: colors.mutedForeground,
      itemRadius: BorderRadius.circular(radius),
      itemLeadingTrailingGap: 8,
      disabledOpacity: 0.5,
      emptyText: 'No results.',
      emptyTextStyle:
          typography.label.copyWith(color: colors.mutedForeground),
    );
  }

  @override
  bool operator ==(Object other) => other is MCommandPaletteStyles;

  @override
  int get hashCode => (MCommandPaletteStyles).hashCode;
}
