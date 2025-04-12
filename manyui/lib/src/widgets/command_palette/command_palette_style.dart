import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MCommandPalette].
///
/// Carries the surface chrome, the scrim color, the search-field treatment,
/// per-item rendering, and the empty-state label style. The palette renders
/// the same popover-family surface as [MDialog] / [MContextMenu], differing
/// mainly in that it embeds a search field above a scrollable item list.
@immutable
class MCommandPaletteStyle {
  /// Builds a command-palette style with every field specified.
  const MCommandPaletteStyle({
    required this.surfaceBackgroundColor,
    required this.surfaceForegroundColor,
    required this.surfaceBorderColor,
    required this.surfaceBorderWidth,
    required this.surfaceRadius,
    required this.surfacePadding,
    required this.surfaceElevation,
    required this.surfaceShadowColor,
    required this.scrimColor,
    required this.maxWidth,
    required this.maxHeightFraction,
    required this.topOffset,
    required this.searchPadding,
    required this.searchTextStyle,
    required this.searchPlaceholderColor,
    required this.searchDividerColor,
    required this.listPadding,
    required this.itemHeight,
    required this.itemPadding,
    required this.itemSpacing,
    required this.itemForegroundColor,
    required this.itemSubtitleForegroundColor,
    required this.itemHoveredBackgroundColor,
    required this.itemTitleTextStyle,
    required this.itemSubtitleTextStyle,
    required this.itemTrailingForegroundColor,
    required this.itemRadius,
    required this.itemLeadingTrailingGap,
    required this.disabledOpacity,
    required this.emptyText,
    required this.emptyTextStyle,
  });

  /// Fill color of the palette surface.
  final Color surfaceBackgroundColor;

  /// Default text color used inside the palette.
  final Color surfaceForegroundColor;

  /// Border stroke color, or null for no border.
  final Color? surfaceBorderColor;

  /// Border thickness, in logical pixels.
  final double surfaceBorderWidth;

  /// Corner radius of the surface.
  final BorderRadiusGeometry surfaceRadius;

  /// Inner padding between the surface edge and the search field / list.
  final EdgeInsetsGeometry surfacePadding;

  /// Drop-shadow blur radius. 0 disables the shadow.
  final double surfaceElevation;

  /// Drop-shadow color.
  final Color surfaceShadowColor;

  /// The full-screen scrim color rendered behind the palette.
  final Color scrimColor;

  /// Maximum width of the palette surface, in logical pixels.
  final double maxWidth;

  /// Maximum height of the palette surface as a fraction of the viewport
  /// height (e.g. 0.6 caps the palette at 60% of the screen height).
  final double maxHeightFraction;

  /// Distance from the top of the viewport to the top of the palette.
  final double topOffset;

  /// Inner padding around the search field.
  final EdgeInsetsGeometry searchPadding;

  /// Text style applied to the search field's user-typed query.
  final TextStyle searchTextStyle;

  /// Color of the search field's placeholder text.
  final Color searchPlaceholderColor;

  /// Color of the divider between the search field and the item list.
  final Color searchDividerColor;

  /// Inner padding around the scrollable list of items.
  final EdgeInsetsGeometry listPadding;

  /// Height of each item row, in logical pixels.
  final double itemHeight;

  /// Inner padding of each item row.
  final EdgeInsetsGeometry itemPadding;

  /// Vertical spacing between adjacent items.
  final double itemSpacing;

  /// Default text color used for an item's title.
  final Color itemForegroundColor;

  /// Default text color used for an item's subtitle.
  final Color itemSubtitleForegroundColor;

  /// Background color of a hovered or focused item.
  final Color itemHoveredBackgroundColor;

  /// Text style applied to the item title.
  final TextStyle itemTitleTextStyle;

  /// Text style applied to the item subtitle.
  final TextStyle itemSubtitleTextStyle;

  /// Default text color used for the trailing accessory of an item
  /// (e.g. a keyboard-shortcut hint).
  final Color itemTrailingForegroundColor;

  /// Corner radius of each item's hover background.
  final BorderRadiusGeometry itemRadius;

  /// Horizontal gap between an item's leading / title / trailing slots.
  final double itemLeadingTrailingGap;

  /// Opacity multiplier applied to a disabled item.
  final double disabledOpacity;

  /// The placeholder text rendered when the filter returns no items.
  final String emptyText;

  /// The text style used for [emptyText].
  final TextStyle emptyTextStyle;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MCommandPaletteStyle applyDelta(MCommandPaletteStyleDelta? delta) {
    if (delta == null) return this;
    return MCommandPaletteStyle(
      surfaceBackgroundColor:
          delta.surfaceBackgroundColor ?? surfaceBackgroundColor,
      surfaceForegroundColor:
          delta.surfaceForegroundColor ?? surfaceForegroundColor,
      surfaceBorderColor: delta.surfaceBorderColor ?? surfaceBorderColor,
      surfaceBorderWidth: delta.surfaceBorderWidth ?? surfaceBorderWidth,
      surfaceRadius: delta.surfaceRadius ?? surfaceRadius,
      surfacePadding: delta.surfacePadding ?? surfacePadding,
      surfaceElevation: delta.surfaceElevation ?? surfaceElevation,
      surfaceShadowColor: delta.surfaceShadowColor ?? surfaceShadowColor,
      scrimColor: delta.scrimColor ?? scrimColor,
      maxWidth: delta.maxWidth ?? maxWidth,
      maxHeightFraction: delta.maxHeightFraction ?? maxHeightFraction,
      topOffset: delta.topOffset ?? topOffset,
      searchPadding: delta.searchPadding ?? searchPadding,
      searchTextStyle: delta.searchTextStyle ?? searchTextStyle,
      searchPlaceholderColor:
          delta.searchPlaceholderColor ?? searchPlaceholderColor,
      searchDividerColor: delta.searchDividerColor ?? searchDividerColor,
      listPadding: delta.listPadding ?? listPadding,
      itemHeight: delta.itemHeight ?? itemHeight,
      itemPadding: delta.itemPadding ?? itemPadding,
      itemSpacing: delta.itemSpacing ?? itemSpacing,
      itemForegroundColor: delta.itemForegroundColor ?? itemForegroundColor,
      itemSubtitleForegroundColor:
          delta.itemSubtitleForegroundColor ?? itemSubtitleForegroundColor,
      itemHoveredBackgroundColor:
          delta.itemHoveredBackgroundColor ?? itemHoveredBackgroundColor,
      itemTitleTextStyle: delta.itemTitleTextStyle ?? itemTitleTextStyle,
      itemSubtitleTextStyle:
          delta.itemSubtitleTextStyle ?? itemSubtitleTextStyle,
      itemTrailingForegroundColor:
          delta.itemTrailingForegroundColor ?? itemTrailingForegroundColor,
      itemRadius: delta.itemRadius ?? itemRadius,
      itemLeadingTrailingGap:
          delta.itemLeadingTrailingGap ?? itemLeadingTrailingGap,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
      emptyText: delta.emptyText ?? emptyText,
      emptyTextStyle: delta.emptyTextStyle ?? emptyTextStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCommandPaletteStyle &&
        other.surfaceBackgroundColor == surfaceBackgroundColor &&
        other.surfaceForegroundColor == surfaceForegroundColor &&
        other.surfaceBorderColor == surfaceBorderColor &&
        other.surfaceBorderWidth == surfaceBorderWidth &&
        other.surfaceRadius == surfaceRadius &&
        other.surfacePadding == surfacePadding &&
        other.surfaceElevation == surfaceElevation &&
        other.surfaceShadowColor == surfaceShadowColor &&
        other.scrimColor == scrimColor &&
        other.maxWidth == maxWidth &&
        other.maxHeightFraction == maxHeightFraction &&
        other.topOffset == topOffset &&
        other.searchPadding == searchPadding &&
        other.searchTextStyle == searchTextStyle &&
        other.searchPlaceholderColor == searchPlaceholderColor &&
        other.searchDividerColor == searchDividerColor &&
        other.listPadding == listPadding &&
        other.itemHeight == itemHeight &&
        other.itemPadding == itemPadding &&
        other.itemSpacing == itemSpacing &&
        other.itemForegroundColor == itemForegroundColor &&
        other.itemSubtitleForegroundColor == itemSubtitleForegroundColor &&
        other.itemHoveredBackgroundColor == itemHoveredBackgroundColor &&
        other.itemTitleTextStyle == itemTitleTextStyle &&
        other.itemSubtitleTextStyle == itemSubtitleTextStyle &&
        other.itemTrailingForegroundColor == itemTrailingForegroundColor &&
        other.itemRadius == itemRadius &&
        other.itemLeadingTrailingGap == itemLeadingTrailingGap &&
        other.disabledOpacity == disabledOpacity &&
        other.emptyText == emptyText &&
        other.emptyTextStyle == emptyTextStyle;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        surfaceBackgroundColor,
        surfaceForegroundColor,
        surfaceBorderColor,
        surfaceBorderWidth,
        surfaceRadius,
        surfacePadding,
        surfaceElevation,
        surfaceShadowColor,
        scrimColor,
        maxWidth,
        maxHeightFraction,
        topOffset,
        searchPadding,
        searchTextStyle,
        searchPlaceholderColor,
        searchDividerColor,
        listPadding,
        itemHeight,
        itemPadding,
        itemSpacing,
        itemForegroundColor,
        itemSubtitleForegroundColor,
        itemHoveredBackgroundColor,
        itemTitleTextStyle,
        itemSubtitleTextStyle,
        itemTrailingForegroundColor,
        itemRadius,
        itemLeadingTrailingGap,
        disabledOpacity,
        emptyText,
        emptyTextStyle,
      ]);
}

/// A nullable overlay of [MCommandPaletteStyle] fields.
///
/// Pass an instance into [showMCommandPalette] to override individual fields
/// of the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MCommandPaletteStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MCommandPaletteStyleDelta({
    this.surfaceBackgroundColor,
    this.surfaceForegroundColor,
    this.surfaceBorderColor,
    this.surfaceBorderWidth,
    this.surfaceRadius,
    this.surfacePadding,
    this.surfaceElevation,
    this.surfaceShadowColor,
    this.scrimColor,
    this.maxWidth,
    this.maxHeightFraction,
    this.topOffset,
    this.searchPadding,
    this.searchTextStyle,
    this.searchPlaceholderColor,
    this.searchDividerColor,
    this.listPadding,
    this.itemHeight,
    this.itemPadding,
    this.itemSpacing,
    this.itemForegroundColor,
    this.itemSubtitleForegroundColor,
    this.itemHoveredBackgroundColor,
    this.itemTitleTextStyle,
    this.itemSubtitleTextStyle,
    this.itemTrailingForegroundColor,
    this.itemRadius,
    this.itemLeadingTrailingGap,
    this.disabledOpacity,
    this.emptyText,
    this.emptyTextStyle,
  });

  /// Override for [MCommandPaletteStyle.surfaceBackgroundColor].
  final Color? surfaceBackgroundColor;

  /// Override for [MCommandPaletteStyle.surfaceForegroundColor].
  final Color? surfaceForegroundColor;

  /// Override for [MCommandPaletteStyle.surfaceBorderColor].
  final Color? surfaceBorderColor;

  /// Override for [MCommandPaletteStyle.surfaceBorderWidth].
  final double? surfaceBorderWidth;

  /// Override for [MCommandPaletteStyle.surfaceRadius].
  final BorderRadiusGeometry? surfaceRadius;

  /// Override for [MCommandPaletteStyle.surfacePadding].
  final EdgeInsetsGeometry? surfacePadding;

  /// Override for [MCommandPaletteStyle.surfaceElevation].
  final double? surfaceElevation;

  /// Override for [MCommandPaletteStyle.surfaceShadowColor].
  final Color? surfaceShadowColor;

  /// Override for [MCommandPaletteStyle.scrimColor].
  final Color? scrimColor;

  /// Override for [MCommandPaletteStyle.maxWidth].
  final double? maxWidth;

  /// Override for [MCommandPaletteStyle.maxHeightFraction].
  final double? maxHeightFraction;

  /// Override for [MCommandPaletteStyle.topOffset].
  final double? topOffset;

  /// Override for [MCommandPaletteStyle.searchPadding].
  final EdgeInsetsGeometry? searchPadding;

  /// Override for [MCommandPaletteStyle.searchTextStyle].
  final TextStyle? searchTextStyle;

  /// Override for [MCommandPaletteStyle.searchPlaceholderColor].
  final Color? searchPlaceholderColor;

  /// Override for [MCommandPaletteStyle.searchDividerColor].
  final Color? searchDividerColor;

  /// Override for [MCommandPaletteStyle.listPadding].
  final EdgeInsetsGeometry? listPadding;

  /// Override for [MCommandPaletteStyle.itemHeight].
  final double? itemHeight;

  /// Override for [MCommandPaletteStyle.itemPadding].
  final EdgeInsetsGeometry? itemPadding;

  /// Override for [MCommandPaletteStyle.itemSpacing].
  final double? itemSpacing;

  /// Override for [MCommandPaletteStyle.itemForegroundColor].
  final Color? itemForegroundColor;

  /// Override for [MCommandPaletteStyle.itemSubtitleForegroundColor].
  final Color? itemSubtitleForegroundColor;

  /// Override for [MCommandPaletteStyle.itemHoveredBackgroundColor].
  final Color? itemHoveredBackgroundColor;

  /// Override for [MCommandPaletteStyle.itemTitleTextStyle].
  final TextStyle? itemTitleTextStyle;

  /// Override for [MCommandPaletteStyle.itemSubtitleTextStyle].
  final TextStyle? itemSubtitleTextStyle;

  /// Override for [MCommandPaletteStyle.itemTrailingForegroundColor].
  final Color? itemTrailingForegroundColor;

  /// Override for [MCommandPaletteStyle.itemRadius].
  final BorderRadiusGeometry? itemRadius;

  /// Override for [MCommandPaletteStyle.itemLeadingTrailingGap].
  final double? itemLeadingTrailingGap;

  /// Override for [MCommandPaletteStyle.disabledOpacity].
  final double? disabledOpacity;

  /// Override for [MCommandPaletteStyle.emptyText].
  final String? emptyText;

  /// Override for [MCommandPaletteStyle.emptyTextStyle].
  final TextStyle? emptyTextStyle;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCommandPaletteStyleDelta &&
        other.surfaceBackgroundColor == surfaceBackgroundColor &&
        other.surfaceForegroundColor == surfaceForegroundColor &&
        other.surfaceBorderColor == surfaceBorderColor &&
        other.surfaceBorderWidth == surfaceBorderWidth &&
        other.surfaceRadius == surfaceRadius &&
        other.surfacePadding == surfacePadding &&
        other.surfaceElevation == surfaceElevation &&
        other.surfaceShadowColor == surfaceShadowColor &&
        other.scrimColor == scrimColor &&
        other.maxWidth == maxWidth &&
        other.maxHeightFraction == maxHeightFraction &&
        other.topOffset == topOffset &&
        other.searchPadding == searchPadding &&
        other.searchTextStyle == searchTextStyle &&
        other.searchPlaceholderColor == searchPlaceholderColor &&
        other.searchDividerColor == searchDividerColor &&
        other.listPadding == listPadding &&
        other.itemHeight == itemHeight &&
        other.itemPadding == itemPadding &&
        other.itemSpacing == itemSpacing &&
        other.itemForegroundColor == itemForegroundColor &&
        other.itemSubtitleForegroundColor == itemSubtitleForegroundColor &&
        other.itemHoveredBackgroundColor == itemHoveredBackgroundColor &&
        other.itemTitleTextStyle == itemTitleTextStyle &&
        other.itemSubtitleTextStyle == itemSubtitleTextStyle &&
        other.itemTrailingForegroundColor == itemTrailingForegroundColor &&
        other.itemRadius == itemRadius &&
        other.itemLeadingTrailingGap == itemLeadingTrailingGap &&
        other.disabledOpacity == disabledOpacity &&
        other.emptyText == emptyText &&
        other.emptyTextStyle == emptyTextStyle;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        surfaceBackgroundColor,
        surfaceForegroundColor,
        surfaceBorderColor,
        surfaceBorderWidth,
        surfaceRadius,
        surfacePadding,
        surfaceElevation,
        surfaceShadowColor,
        scrimColor,
        maxWidth,
        maxHeightFraction,
        topOffset,
        searchPadding,
        searchTextStyle,
        searchPlaceholderColor,
        searchDividerColor,
        listPadding,
        itemHeight,
        itemPadding,
        itemSpacing,
        itemForegroundColor,
        itemSubtitleForegroundColor,
        itemHoveredBackgroundColor,
        itemTitleTextStyle,
        itemSubtitleTextStyle,
        itemTrailingForegroundColor,
        itemRadius,
        itemLeadingTrailingGap,
        disabledOpacity,
        emptyText,
        emptyTextStyle,
      ]);
}
