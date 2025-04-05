import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MContextMenu].
///
/// Mirrors [MMenuBarStyle]'s popover-surface and item fields so a context
/// menu sits comfortably next to a pulldown menu — same surface, same item
/// chrome, same hover/focus treatment. Differs from [MPopoverStyle] in
/// that it also carries the per-item styling, since context menus always
/// render a list of [MMenuItem]s rather than caller-supplied content.
@immutable
class MContextMenuStyle {
  /// Builds a context-menu style with every field specified.
  const MContextMenuStyle({
    required this.surfaceBackgroundColor,
    required this.surfaceForegroundColor,
    required this.surfaceBorderColor,
    required this.surfaceBorderWidth,
    required this.surfaceRadius,
    required this.surfacePadding,
    required this.surfaceElevation,
    required this.surfaceShadowColor,
    required this.surfaceMinWidth,
    required this.surfaceMaxWidth,
    required this.viewportPadding,
    required this.itemHeight,
    required this.itemPadding,
    required this.itemSpacing,
    required this.itemForegroundColor,
    required this.itemHoveredBackgroundColor,
    required this.itemTextStyle,
    required this.itemTrailingForegroundColor,
    required this.itemRadius,
    required this.disabledOpacity,
  });

  /// Fill color of the popover body.
  final Color surfaceBackgroundColor;

  /// Default text color used inside the popover.
  final Color surfaceForegroundColor;

  /// Border stroke color of the popover, or null for no border.
  final Color? surfaceBorderColor;

  /// Border thickness of the popover in logical pixels.
  final double surfaceBorderWidth;

  /// Corner radius of the popover surface.
  final BorderRadiusGeometry surfaceRadius;

  /// Inner padding between the popover's edge and its item list.
  final EdgeInsetsGeometry surfacePadding;

  /// Drop-shadow blur radius. 0 disables the shadow.
  final double surfaceElevation;

  /// Drop-shadow color.
  final Color surfaceShadowColor;

  /// Minimum width of the popover surface, in logical pixels.
  final double surfaceMinWidth;

  /// Maximum width of the popover surface, in logical pixels.
  final double surfaceMaxWidth;

  /// Minimum spacing kept between the popover and the viewport edges when
  /// the menu would otherwise be clipped.
  final double viewportPadding;

  /// Height of each menu item inside the popover, in logical pixels.
  final double itemHeight;

  /// Inner padding of each menu item between its edge and its content.
  final EdgeInsetsGeometry itemPadding;

  /// Vertical spacing between adjacent menu items.
  final double itemSpacing;

  /// Default text color used for each menu item label.
  final Color itemForegroundColor;

  /// Background color of a hovered or focused menu item.
  final Color itemHoveredBackgroundColor;

  /// Text style applied to each menu item label.
  final TextStyle itemTextStyle;

  /// Default text color used for the trailing accessory of a menu item
  /// (e.g. a keyboard shortcut hint).
  final Color itemTrailingForegroundColor;

  /// Corner radius of each menu item's hover background.
  final BorderRadiusGeometry itemRadius;

  /// Opacity multiplier applied to a disabled menu item.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MContextMenuStyle applyDelta(MContextMenuStyleDelta? delta) {
    if (delta == null) return this;
    return MContextMenuStyle(
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
      surfaceMinWidth: delta.surfaceMinWidth ?? surfaceMinWidth,
      surfaceMaxWidth: delta.surfaceMaxWidth ?? surfaceMaxWidth,
      viewportPadding: delta.viewportPadding ?? viewportPadding,
      itemHeight: delta.itemHeight ?? itemHeight,
      itemPadding: delta.itemPadding ?? itemPadding,
      itemSpacing: delta.itemSpacing ?? itemSpacing,
      itemForegroundColor: delta.itemForegroundColor ?? itemForegroundColor,
      itemHoveredBackgroundColor:
          delta.itemHoveredBackgroundColor ?? itemHoveredBackgroundColor,
      itemTextStyle: delta.itemTextStyle ?? itemTextStyle,
      itemTrailingForegroundColor:
          delta.itemTrailingForegroundColor ?? itemTrailingForegroundColor,
      itemRadius: delta.itemRadius ?? itemRadius,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MContextMenuStyle &&
        other.surfaceBackgroundColor == surfaceBackgroundColor &&
        other.surfaceForegroundColor == surfaceForegroundColor &&
        other.surfaceBorderColor == surfaceBorderColor &&
        other.surfaceBorderWidth == surfaceBorderWidth &&
        other.surfaceRadius == surfaceRadius &&
        other.surfacePadding == surfacePadding &&
        other.surfaceElevation == surfaceElevation &&
        other.surfaceShadowColor == surfaceShadowColor &&
        other.surfaceMinWidth == surfaceMinWidth &&
        other.surfaceMaxWidth == surfaceMaxWidth &&
        other.viewportPadding == viewportPadding &&
        other.itemHeight == itemHeight &&
        other.itemPadding == itemPadding &&
        other.itemSpacing == itemSpacing &&
        other.itemForegroundColor == itemForegroundColor &&
        other.itemHoveredBackgroundColor == itemHoveredBackgroundColor &&
        other.itemTextStyle == itemTextStyle &&
        other.itemTrailingForegroundColor == itemTrailingForegroundColor &&
        other.itemRadius == itemRadius &&
        other.disabledOpacity == disabledOpacity;
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
        surfaceMinWidth,
        surfaceMaxWidth,
        viewportPadding,
        itemHeight,
        itemPadding,
        itemSpacing,
        itemForegroundColor,
        itemHoveredBackgroundColor,
        itemTextStyle,
        itemTrailingForegroundColor,
        itemRadius,
        disabledOpacity,
      ]);
}

/// A nullable overlay of [MContextMenuStyle] fields.
///
/// Pass an instance into `MContextMenu(style: ...)` to override individual
/// fields of the theme-resolved style. Any field left null keeps the theme
/// value.
@immutable
class MContextMenuStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MContextMenuStyleDelta({
    this.surfaceBackgroundColor,
    this.surfaceForegroundColor,
    this.surfaceBorderColor,
    this.surfaceBorderWidth,
    this.surfaceRadius,
    this.surfacePadding,
    this.surfaceElevation,
    this.surfaceShadowColor,
    this.surfaceMinWidth,
    this.surfaceMaxWidth,
    this.viewportPadding,
    this.itemHeight,
    this.itemPadding,
    this.itemSpacing,
    this.itemForegroundColor,
    this.itemHoveredBackgroundColor,
    this.itemTextStyle,
    this.itemTrailingForegroundColor,
    this.itemRadius,
    this.disabledOpacity,
  });

  /// Override for [MContextMenuStyle.surfaceBackgroundColor].
  final Color? surfaceBackgroundColor;

  /// Override for [MContextMenuStyle.surfaceForegroundColor].
  final Color? surfaceForegroundColor;

  /// Override for [MContextMenuStyle.surfaceBorderColor].
  final Color? surfaceBorderColor;

  /// Override for [MContextMenuStyle.surfaceBorderWidth].
  final double? surfaceBorderWidth;

  /// Override for [MContextMenuStyle.surfaceRadius].
  final BorderRadiusGeometry? surfaceRadius;

  /// Override for [MContextMenuStyle.surfacePadding].
  final EdgeInsetsGeometry? surfacePadding;

  /// Override for [MContextMenuStyle.surfaceElevation].
  final double? surfaceElevation;

  /// Override for [MContextMenuStyle.surfaceShadowColor].
  final Color? surfaceShadowColor;

  /// Override for [MContextMenuStyle.surfaceMinWidth].
  final double? surfaceMinWidth;

  /// Override for [MContextMenuStyle.surfaceMaxWidth].
  final double? surfaceMaxWidth;

  /// Override for [MContextMenuStyle.viewportPadding].
  final double? viewportPadding;

  /// Override for [MContextMenuStyle.itemHeight].
  final double? itemHeight;

  /// Override for [MContextMenuStyle.itemPadding].
  final EdgeInsetsGeometry? itemPadding;

  /// Override for [MContextMenuStyle.itemSpacing].
  final double? itemSpacing;

  /// Override for [MContextMenuStyle.itemForegroundColor].
  final Color? itemForegroundColor;

  /// Override for [MContextMenuStyle.itemHoveredBackgroundColor].
  final Color? itemHoveredBackgroundColor;

  /// Override for [MContextMenuStyle.itemTextStyle].
  final TextStyle? itemTextStyle;

  /// Override for [MContextMenuStyle.itemTrailingForegroundColor].
  final Color? itemTrailingForegroundColor;

  /// Override for [MContextMenuStyle.itemRadius].
  final BorderRadiusGeometry? itemRadius;

  /// Override for [MContextMenuStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MContextMenuStyleDelta &&
        other.surfaceBackgroundColor == surfaceBackgroundColor &&
        other.surfaceForegroundColor == surfaceForegroundColor &&
        other.surfaceBorderColor == surfaceBorderColor &&
        other.surfaceBorderWidth == surfaceBorderWidth &&
        other.surfaceRadius == surfaceRadius &&
        other.surfacePadding == surfacePadding &&
        other.surfaceElevation == surfaceElevation &&
        other.surfaceShadowColor == surfaceShadowColor &&
        other.surfaceMinWidth == surfaceMinWidth &&
        other.surfaceMaxWidth == surfaceMaxWidth &&
        other.viewportPadding == viewportPadding &&
        other.itemHeight == itemHeight &&
        other.itemPadding == itemPadding &&
        other.itemSpacing == itemSpacing &&
        other.itemForegroundColor == itemForegroundColor &&
        other.itemHoveredBackgroundColor == itemHoveredBackgroundColor &&
        other.itemTextStyle == itemTextStyle &&
        other.itemTrailingForegroundColor == itemTrailingForegroundColor &&
        other.itemRadius == itemRadius &&
        other.disabledOpacity == disabledOpacity;
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
        surfaceMinWidth,
        surfaceMaxWidth,
        viewportPadding,
        itemHeight,
        itemPadding,
        itemSpacing,
        itemForegroundColor,
        itemHoveredBackgroundColor,
        itemTextStyle,
        itemTrailingForegroundColor,
        itemRadius,
        disabledOpacity,
      ]);
}
