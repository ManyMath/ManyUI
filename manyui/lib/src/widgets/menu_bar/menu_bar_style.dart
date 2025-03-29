import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MMenuBar].
///
/// Carries strip chrome, menu-title chrome, popover-surface chrome, and the
/// styling of each menu item inside the open popover. The popover surface
/// fields mirror [MPopoverStyle] field-for-field so menu popovers sit
/// comfortably next to standalone popovers.
@immutable
class MMenuBarStyle {
  /// Builds a menu-bar style with every field specified.
  const MMenuBarStyle({
    required this.titleHeight,
    required this.titlePadding,
    required this.titleSpacing,
    required this.activeTitleBackgroundColor,
    required this.hoveredTitleBackgroundColor,
    required this.titleForegroundColor,
    required this.disabledOpacity,
    required this.titleTextStyle,
    required this.titleRadius,
    required this.popoverBackgroundColor,
    required this.popoverForegroundColor,
    required this.popoverBorderColor,
    required this.popoverBorderWidth,
    required this.popoverRadius,
    required this.popoverPadding,
    required this.popoverElevation,
    required this.popoverShadowColor,
    required this.popoverGap,
    required this.popoverMinWidth,
    required this.itemHeight,
    required this.itemPadding,
    required this.itemSpacing,
    required this.itemForegroundColor,
    required this.itemHoveredBackgroundColor,
    required this.itemTextStyle,
    required this.itemTrailingForegroundColor,
    required this.itemRadius,
  });

  /// Height of each menu title in the strip, in logical pixels.
  final double titleHeight;

  /// Inner padding of each menu title between its edge and its label.
  final EdgeInsetsGeometry titlePadding;

  /// Horizontal spacing between adjacent menu titles.
  final double titleSpacing;

  /// Background color of the menu title whose popover is currently open.
  final Color activeTitleBackgroundColor;

  /// Background color of a menu title under a hovering pointer.
  final Color hoveredTitleBackgroundColor;

  /// Default text color used for each menu title.
  final Color titleForegroundColor;

  /// Opacity multiplier applied to a disabled menu title or menu item.
  final double disabledOpacity;

  /// Text style applied to each menu title label.
  final TextStyle titleTextStyle;

  /// Corner radius of each menu title's background pill.
  final BorderRadiusGeometry titleRadius;

  /// Fill color of the open popover body.
  final Color popoverBackgroundColor;

  /// Default text color used inside the popover.
  final Color popoverForegroundColor;

  /// Border stroke color of the popover, or null for no border.
  final Color? popoverBorderColor;

  /// Border thickness of the popover in logical pixels.
  final double popoverBorderWidth;

  /// Corner radius of the popover surface.
  final BorderRadiusGeometry popoverRadius;

  /// Inner padding between the popover's edge and its item list.
  final EdgeInsetsGeometry popoverPadding;

  /// Drop-shadow blur radius. 0 disables the shadow.
  final double popoverElevation;

  /// Drop-shadow color.
  final Color popoverShadowColor;

  /// Space between the menu title and the popover surface, in logical pixels.
  final double popoverGap;

  /// Minimum width of the popover surface, in logical pixels.
  final double popoverMinWidth;

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

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MMenuBarStyle applyDelta(MMenuBarStyleDelta? delta) {
    if (delta == null) return this;
    return MMenuBarStyle(
      titleHeight: delta.titleHeight ?? titleHeight,
      titlePadding: delta.titlePadding ?? titlePadding,
      titleSpacing: delta.titleSpacing ?? titleSpacing,
      activeTitleBackgroundColor:
          delta.activeTitleBackgroundColor ?? activeTitleBackgroundColor,
      hoveredTitleBackgroundColor:
          delta.hoveredTitleBackgroundColor ?? hoveredTitleBackgroundColor,
      titleForegroundColor: delta.titleForegroundColor ?? titleForegroundColor,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
      titleTextStyle: delta.titleTextStyle ?? titleTextStyle,
      titleRadius: delta.titleRadius ?? titleRadius,
      popoverBackgroundColor:
          delta.popoverBackgroundColor ?? popoverBackgroundColor,
      popoverForegroundColor:
          delta.popoverForegroundColor ?? popoverForegroundColor,
      popoverBorderColor: delta.popoverBorderColor ?? popoverBorderColor,
      popoverBorderWidth: delta.popoverBorderWidth ?? popoverBorderWidth,
      popoverRadius: delta.popoverRadius ?? popoverRadius,
      popoverPadding: delta.popoverPadding ?? popoverPadding,
      popoverElevation: delta.popoverElevation ?? popoverElevation,
      popoverShadowColor: delta.popoverShadowColor ?? popoverShadowColor,
      popoverGap: delta.popoverGap ?? popoverGap,
      popoverMinWidth: delta.popoverMinWidth ?? popoverMinWidth,
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MMenuBarStyle &&
        other.titleHeight == titleHeight &&
        other.titlePadding == titlePadding &&
        other.titleSpacing == titleSpacing &&
        other.activeTitleBackgroundColor == activeTitleBackgroundColor &&
        other.hoveredTitleBackgroundColor == hoveredTitleBackgroundColor &&
        other.titleForegroundColor == titleForegroundColor &&
        other.disabledOpacity == disabledOpacity &&
        other.titleTextStyle == titleTextStyle &&
        other.titleRadius == titleRadius &&
        other.popoverBackgroundColor == popoverBackgroundColor &&
        other.popoverForegroundColor == popoverForegroundColor &&
        other.popoverBorderColor == popoverBorderColor &&
        other.popoverBorderWidth == popoverBorderWidth &&
        other.popoverRadius == popoverRadius &&
        other.popoverPadding == popoverPadding &&
        other.popoverElevation == popoverElevation &&
        other.popoverShadowColor == popoverShadowColor &&
        other.popoverGap == popoverGap &&
        other.popoverMinWidth == popoverMinWidth &&
        other.itemHeight == itemHeight &&
        other.itemPadding == itemPadding &&
        other.itemSpacing == itemSpacing &&
        other.itemForegroundColor == itemForegroundColor &&
        other.itemHoveredBackgroundColor == itemHoveredBackgroundColor &&
        other.itemTextStyle == itemTextStyle &&
        other.itemTrailingForegroundColor == itemTrailingForegroundColor &&
        other.itemRadius == itemRadius;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        titleHeight,
        titlePadding,
        titleSpacing,
        activeTitleBackgroundColor,
        hoveredTitleBackgroundColor,
        titleForegroundColor,
        disabledOpacity,
        titleTextStyle,
        titleRadius,
        popoverBackgroundColor,
        popoverForegroundColor,
        popoverBorderColor,
        popoverBorderWidth,
        popoverRadius,
        popoverPadding,
        popoverElevation,
        popoverShadowColor,
        popoverGap,
        popoverMinWidth,
        itemHeight,
        itemPadding,
        itemSpacing,
        itemForegroundColor,
        itemHoveredBackgroundColor,
        itemTextStyle,
        itemTrailingForegroundColor,
        itemRadius,
      ]);
}

/// A nullable overlay of [MMenuBarStyle] fields.
///
/// Pass an instance into `MMenuBar(style: ...)` to override individual fields
/// of the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MMenuBarStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MMenuBarStyleDelta({
    this.titleHeight,
    this.titlePadding,
    this.titleSpacing,
    this.activeTitleBackgroundColor,
    this.hoveredTitleBackgroundColor,
    this.titleForegroundColor,
    this.disabledOpacity,
    this.titleTextStyle,
    this.titleRadius,
    this.popoverBackgroundColor,
    this.popoverForegroundColor,
    this.popoverBorderColor,
    this.popoverBorderWidth,
    this.popoverRadius,
    this.popoverPadding,
    this.popoverElevation,
    this.popoverShadowColor,
    this.popoverGap,
    this.popoverMinWidth,
    this.itemHeight,
    this.itemPadding,
    this.itemSpacing,
    this.itemForegroundColor,
    this.itemHoveredBackgroundColor,
    this.itemTextStyle,
    this.itemTrailingForegroundColor,
    this.itemRadius,
  });

  /// Override for [MMenuBarStyle.titleHeight].
  final double? titleHeight;

  /// Override for [MMenuBarStyle.titlePadding].
  final EdgeInsetsGeometry? titlePadding;

  /// Override for [MMenuBarStyle.titleSpacing].
  final double? titleSpacing;

  /// Override for [MMenuBarStyle.activeTitleBackgroundColor].
  final Color? activeTitleBackgroundColor;

  /// Override for [MMenuBarStyle.hoveredTitleBackgroundColor].
  final Color? hoveredTitleBackgroundColor;

  /// Override for [MMenuBarStyle.titleForegroundColor].
  final Color? titleForegroundColor;

  /// Override for [MMenuBarStyle.disabledOpacity].
  final double? disabledOpacity;

  /// Override for [MMenuBarStyle.titleTextStyle].
  final TextStyle? titleTextStyle;

  /// Override for [MMenuBarStyle.titleRadius].
  final BorderRadiusGeometry? titleRadius;

  /// Override for [MMenuBarStyle.popoverBackgroundColor].
  final Color? popoverBackgroundColor;

  /// Override for [MMenuBarStyle.popoverForegroundColor].
  final Color? popoverForegroundColor;

  /// Override for [MMenuBarStyle.popoverBorderColor].
  final Color? popoverBorderColor;

  /// Override for [MMenuBarStyle.popoverBorderWidth].
  final double? popoverBorderWidth;

  /// Override for [MMenuBarStyle.popoverRadius].
  final BorderRadiusGeometry? popoverRadius;

  /// Override for [MMenuBarStyle.popoverPadding].
  final EdgeInsetsGeometry? popoverPadding;

  /// Override for [MMenuBarStyle.popoverElevation].
  final double? popoverElevation;

  /// Override for [MMenuBarStyle.popoverShadowColor].
  final Color? popoverShadowColor;

  /// Override for [MMenuBarStyle.popoverGap].
  final double? popoverGap;

  /// Override for [MMenuBarStyle.popoverMinWidth].
  final double? popoverMinWidth;

  /// Override for [MMenuBarStyle.itemHeight].
  final double? itemHeight;

  /// Override for [MMenuBarStyle.itemPadding].
  final EdgeInsetsGeometry? itemPadding;

  /// Override for [MMenuBarStyle.itemSpacing].
  final double? itemSpacing;

  /// Override for [MMenuBarStyle.itemForegroundColor].
  final Color? itemForegroundColor;

  /// Override for [MMenuBarStyle.itemHoveredBackgroundColor].
  final Color? itemHoveredBackgroundColor;

  /// Override for [MMenuBarStyle.itemTextStyle].
  final TextStyle? itemTextStyle;

  /// Override for [MMenuBarStyle.itemTrailingForegroundColor].
  final Color? itemTrailingForegroundColor;

  /// Override for [MMenuBarStyle.itemRadius].
  final BorderRadiusGeometry? itemRadius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MMenuBarStyleDelta &&
        other.titleHeight == titleHeight &&
        other.titlePadding == titlePadding &&
        other.titleSpacing == titleSpacing &&
        other.activeTitleBackgroundColor == activeTitleBackgroundColor &&
        other.hoveredTitleBackgroundColor == hoveredTitleBackgroundColor &&
        other.titleForegroundColor == titleForegroundColor &&
        other.disabledOpacity == disabledOpacity &&
        other.titleTextStyle == titleTextStyle &&
        other.titleRadius == titleRadius &&
        other.popoverBackgroundColor == popoverBackgroundColor &&
        other.popoverForegroundColor == popoverForegroundColor &&
        other.popoverBorderColor == popoverBorderColor &&
        other.popoverBorderWidth == popoverBorderWidth &&
        other.popoverRadius == popoverRadius &&
        other.popoverPadding == popoverPadding &&
        other.popoverElevation == popoverElevation &&
        other.popoverShadowColor == popoverShadowColor &&
        other.popoverGap == popoverGap &&
        other.popoverMinWidth == popoverMinWidth &&
        other.itemHeight == itemHeight &&
        other.itemPadding == itemPadding &&
        other.itemSpacing == itemSpacing &&
        other.itemForegroundColor == itemForegroundColor &&
        other.itemHoveredBackgroundColor == itemHoveredBackgroundColor &&
        other.itemTextStyle == itemTextStyle &&
        other.itemTrailingForegroundColor == itemTrailingForegroundColor &&
        other.itemRadius == itemRadius;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        titleHeight,
        titlePadding,
        titleSpacing,
        activeTitleBackgroundColor,
        hoveredTitleBackgroundColor,
        titleForegroundColor,
        disabledOpacity,
        titleTextStyle,
        titleRadius,
        popoverBackgroundColor,
        popoverForegroundColor,
        popoverBorderColor,
        popoverBorderWidth,
        popoverRadius,
        popoverPadding,
        popoverElevation,
        popoverShadowColor,
        popoverGap,
        popoverMinWidth,
        itemHeight,
        itemPadding,
        itemSpacing,
        itemForegroundColor,
        itemHoveredBackgroundColor,
        itemTextStyle,
        itemTrailingForegroundColor,
        itemRadius,
      ]);
}
