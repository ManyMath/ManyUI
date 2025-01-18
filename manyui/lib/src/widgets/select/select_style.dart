import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MSelect].
///
/// Carries the anchor visual (the closed-state button surface) and the
/// popover visual (open-state listbox), plus the shared item visual used for
/// each row. Build by hand for advanced theming, or let the theme resolve
/// one via `theme.select.resolve(...)` and tweak through an
/// [MSelectStyleDelta].
@immutable
class MSelectStyle {
  /// Builds a select style with every field specified.
  const MSelectStyle({
    required this.minHeight,
    required this.anchorPadding,
    required this.anchorBackgroundColor,
    required this.anchorForegroundColor,
    required this.anchorBorderColor,
    required this.anchorBorderWidth,
    required this.anchorRadius,
    required this.placeholderColor,
    required this.textStyle,
    required this.iconColor,
    required this.popoverBackgroundColor,
    required this.popoverBorderColor,
    required this.popoverBorderWidth,
    required this.popoverRadius,
    required this.popoverElevation,
    required this.popoverShadowColor,
    required this.popoverPadding,
    required this.popoverGap,
    required this.popoverMaxHeight,
    required this.itemMinHeight,
    required this.itemPadding,
    required this.itemForegroundColor,
    required this.itemFocusedBackgroundColor,
    required this.itemSelectedBackgroundColor,
    required this.itemSelectedForegroundColor,
    required this.itemRadius,
    required this.disabledOpacity,
  });

  /// Minimum height of the anchor surface, in logical pixels. Touch modality
  /// resolves to a larger height than mouse modality.
  final double minHeight;

  /// Inner padding of the anchor between its border and its label/chevron.
  final EdgeInsets anchorPadding;

  /// Background color of the closed-state anchor.
  final Color anchorBackgroundColor;

  /// Foreground color (label + chevron) of the anchor when a value is
  /// selected.
  final Color anchorForegroundColor;

  /// Border color of the anchor.
  final Color anchorBorderColor;

  /// Border thickness of the anchor, in logical pixels.
  final double anchorBorderWidth;

  /// Corner radius of the anchor.
  final BorderRadius anchorRadius;

  /// Foreground color used when no value is selected and the placeholder is
  /// being rendered instead.
  final Color placeholderColor;

  /// Text style for the anchor's label and every item's label.
  final TextStyle textStyle;

  /// Color of the chevron icon at the trailing edge of the anchor and the
  /// checkmark used to indicate the selected item.
  final Color iconColor;

  /// Background fill of the popover surface.
  final Color popoverBackgroundColor;

  /// Border color of the popover.
  final Color popoverBorderColor;

  /// Border thickness of the popover, in logical pixels.
  final double popoverBorderWidth;

  /// Corner radius of the popover.
  final BorderRadius popoverRadius;

  /// Drop-shadow elevation (blur radius) cast by the popover.
  final double popoverElevation;

  /// Color of the popover's drop shadow.
  final Color popoverShadowColor;

  /// Inner padding of the popover between its border and the item column.
  final EdgeInsets popoverPadding;

  /// Vertical gap between the anchor and the popover, in logical pixels.
  final double popoverGap;

  /// Hard cap on the popover's height, in logical pixels. The item column
  /// scrolls when its intrinsic height exceeds this.
  final double popoverMaxHeight;

  /// Minimum height of each item row, in logical pixels.
  final double itemMinHeight;

  /// Inner padding of each item row.
  final EdgeInsets itemPadding;

  /// Foreground color of each item's label in its idle (unfocused,
  /// unselected) state.
  final Color itemForegroundColor;

  /// Background color of the focused (keyboard or mouse-hovered) item.
  final Color itemFocusedBackgroundColor;

  /// Background color of the currently-selected item.
  final Color itemSelectedBackgroundColor;

  /// Foreground color of the currently-selected item's label.
  final Color itemSelectedForegroundColor;

  /// Corner radius of each item's hover/selected fill.
  final BorderRadius itemRadius;

  /// Opacity multiplier applied when the widget (or an individual item) is
  /// disabled.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MSelectStyle applyDelta(MSelectStyleDelta? delta) {
    if (delta == null) return this;
    return MSelectStyle(
      minHeight: delta.minHeight ?? minHeight,
      anchorPadding: delta.anchorPadding ?? anchorPadding,
      anchorBackgroundColor:
          delta.anchorBackgroundColor ?? anchorBackgroundColor,
      anchorForegroundColor:
          delta.anchorForegroundColor ?? anchorForegroundColor,
      anchorBorderColor: delta.anchorBorderColor ?? anchorBorderColor,
      anchorBorderWidth: delta.anchorBorderWidth ?? anchorBorderWidth,
      anchorRadius: delta.anchorRadius ?? anchorRadius,
      placeholderColor: delta.placeholderColor ?? placeholderColor,
      textStyle: delta.textStyle ?? textStyle,
      iconColor: delta.iconColor ?? iconColor,
      popoverBackgroundColor:
          delta.popoverBackgroundColor ?? popoverBackgroundColor,
      popoverBorderColor: delta.popoverBorderColor ?? popoverBorderColor,
      popoverBorderWidth: delta.popoverBorderWidth ?? popoverBorderWidth,
      popoverRadius: delta.popoverRadius ?? popoverRadius,
      popoverElevation: delta.popoverElevation ?? popoverElevation,
      popoverShadowColor: delta.popoverShadowColor ?? popoverShadowColor,
      popoverPadding: delta.popoverPadding ?? popoverPadding,
      popoverGap: delta.popoverGap ?? popoverGap,
      popoverMaxHeight: delta.popoverMaxHeight ?? popoverMaxHeight,
      itemMinHeight: delta.itemMinHeight ?? itemMinHeight,
      itemPadding: delta.itemPadding ?? itemPadding,
      itemForegroundColor: delta.itemForegroundColor ?? itemForegroundColor,
      itemFocusedBackgroundColor:
          delta.itemFocusedBackgroundColor ?? itemFocusedBackgroundColor,
      itemSelectedBackgroundColor:
          delta.itemSelectedBackgroundColor ?? itemSelectedBackgroundColor,
      itemSelectedForegroundColor:
          delta.itemSelectedForegroundColor ?? itemSelectedForegroundColor,
      itemRadius: delta.itemRadius ?? itemRadius,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MSelectStyle &&
        other.minHeight == minHeight &&
        other.anchorPadding == anchorPadding &&
        other.anchorBackgroundColor == anchorBackgroundColor &&
        other.anchorForegroundColor == anchorForegroundColor &&
        other.anchorBorderColor == anchorBorderColor &&
        other.anchorBorderWidth == anchorBorderWidth &&
        other.anchorRadius == anchorRadius &&
        other.placeholderColor == placeholderColor &&
        other.textStyle == textStyle &&
        other.iconColor == iconColor &&
        other.popoverBackgroundColor == popoverBackgroundColor &&
        other.popoverBorderColor == popoverBorderColor &&
        other.popoverBorderWidth == popoverBorderWidth &&
        other.popoverRadius == popoverRadius &&
        other.popoverElevation == popoverElevation &&
        other.popoverShadowColor == popoverShadowColor &&
        other.popoverPadding == popoverPadding &&
        other.popoverGap == popoverGap &&
        other.popoverMaxHeight == popoverMaxHeight &&
        other.itemMinHeight == itemMinHeight &&
        other.itemPadding == itemPadding &&
        other.itemForegroundColor == itemForegroundColor &&
        other.itemFocusedBackgroundColor == itemFocusedBackgroundColor &&
        other.itemSelectedBackgroundColor == itemSelectedBackgroundColor &&
        other.itemSelectedForegroundColor == itemSelectedForegroundColor &&
        other.itemRadius == itemRadius &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        minHeight,
        anchorPadding,
        anchorBackgroundColor,
        anchorForegroundColor,
        anchorBorderColor,
        anchorBorderWidth,
        anchorRadius,
        placeholderColor,
        textStyle,
        iconColor,
        popoverBackgroundColor,
        popoverBorderColor,
        popoverBorderWidth,
        popoverRadius,
        popoverElevation,
        popoverShadowColor,
        popoverPadding,
        popoverGap,
        popoverMaxHeight,
        itemMinHeight,
        itemPadding,
        itemForegroundColor,
        itemFocusedBackgroundColor,
        itemSelectedBackgroundColor,
        itemSelectedForegroundColor,
        itemRadius,
        disabledOpacity,
      ]);
}

/// A nullable overlay of [MSelectStyle] fields.
///
/// Pass an instance into `MSelect(style: ...)` to override individual fields
/// of the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MSelectStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MSelectStyleDelta({
    this.minHeight,
    this.anchorPadding,
    this.anchorBackgroundColor,
    this.anchorForegroundColor,
    this.anchorBorderColor,
    this.anchorBorderWidth,
    this.anchorRadius,
    this.placeholderColor,
    this.textStyle,
    this.iconColor,
    this.popoverBackgroundColor,
    this.popoverBorderColor,
    this.popoverBorderWidth,
    this.popoverRadius,
    this.popoverElevation,
    this.popoverShadowColor,
    this.popoverPadding,
    this.popoverGap,
    this.popoverMaxHeight,
    this.itemMinHeight,
    this.itemPadding,
    this.itemForegroundColor,
    this.itemFocusedBackgroundColor,
    this.itemSelectedBackgroundColor,
    this.itemSelectedForegroundColor,
    this.itemRadius,
    this.disabledOpacity,
  });

  /// Override for [MSelectStyle.minHeight].
  final double? minHeight;

  /// Override for [MSelectStyle.anchorPadding].
  final EdgeInsets? anchorPadding;

  /// Override for [MSelectStyle.anchorBackgroundColor].
  final Color? anchorBackgroundColor;

  /// Override for [MSelectStyle.anchorForegroundColor].
  final Color? anchorForegroundColor;

  /// Override for [MSelectStyle.anchorBorderColor].
  final Color? anchorBorderColor;

  /// Override for [MSelectStyle.anchorBorderWidth].
  final double? anchorBorderWidth;

  /// Override for [MSelectStyle.anchorRadius].
  final BorderRadius? anchorRadius;

  /// Override for [MSelectStyle.placeholderColor].
  final Color? placeholderColor;

  /// Override for [MSelectStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MSelectStyle.iconColor].
  final Color? iconColor;

  /// Override for [MSelectStyle.popoverBackgroundColor].
  final Color? popoverBackgroundColor;

  /// Override for [MSelectStyle.popoverBorderColor].
  final Color? popoverBorderColor;

  /// Override for [MSelectStyle.popoverBorderWidth].
  final double? popoverBorderWidth;

  /// Override for [MSelectStyle.popoverRadius].
  final BorderRadius? popoverRadius;

  /// Override for [MSelectStyle.popoverElevation].
  final double? popoverElevation;

  /// Override for [MSelectStyle.popoverShadowColor].
  final Color? popoverShadowColor;

  /// Override for [MSelectStyle.popoverPadding].
  final EdgeInsets? popoverPadding;

  /// Override for [MSelectStyle.popoverGap].
  final double? popoverGap;

  /// Override for [MSelectStyle.popoverMaxHeight].
  final double? popoverMaxHeight;

  /// Override for [MSelectStyle.itemMinHeight].
  final double? itemMinHeight;

  /// Override for [MSelectStyle.itemPadding].
  final EdgeInsets? itemPadding;

  /// Override for [MSelectStyle.itemForegroundColor].
  final Color? itemForegroundColor;

  /// Override for [MSelectStyle.itemFocusedBackgroundColor].
  final Color? itemFocusedBackgroundColor;

  /// Override for [MSelectStyle.itemSelectedBackgroundColor].
  final Color? itemSelectedBackgroundColor;

  /// Override for [MSelectStyle.itemSelectedForegroundColor].
  final Color? itemSelectedForegroundColor;

  /// Override for [MSelectStyle.itemRadius].
  final BorderRadius? itemRadius;

  /// Override for [MSelectStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MSelectStyleDelta &&
        other.minHeight == minHeight &&
        other.anchorPadding == anchorPadding &&
        other.anchorBackgroundColor == anchorBackgroundColor &&
        other.anchorForegroundColor == anchorForegroundColor &&
        other.anchorBorderColor == anchorBorderColor &&
        other.anchorBorderWidth == anchorBorderWidth &&
        other.anchorRadius == anchorRadius &&
        other.placeholderColor == placeholderColor &&
        other.textStyle == textStyle &&
        other.iconColor == iconColor &&
        other.popoverBackgroundColor == popoverBackgroundColor &&
        other.popoverBorderColor == popoverBorderColor &&
        other.popoverBorderWidth == popoverBorderWidth &&
        other.popoverRadius == popoverRadius &&
        other.popoverElevation == popoverElevation &&
        other.popoverShadowColor == popoverShadowColor &&
        other.popoverPadding == popoverPadding &&
        other.popoverGap == popoverGap &&
        other.popoverMaxHeight == popoverMaxHeight &&
        other.itemMinHeight == itemMinHeight &&
        other.itemPadding == itemPadding &&
        other.itemForegroundColor == itemForegroundColor &&
        other.itemFocusedBackgroundColor == itemFocusedBackgroundColor &&
        other.itemSelectedBackgroundColor == itemSelectedBackgroundColor &&
        other.itemSelectedForegroundColor == itemSelectedForegroundColor &&
        other.itemRadius == itemRadius &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        minHeight,
        anchorPadding,
        anchorBackgroundColor,
        anchorForegroundColor,
        anchorBorderColor,
        anchorBorderWidth,
        anchorRadius,
        placeholderColor,
        textStyle,
        iconColor,
        popoverBackgroundColor,
        popoverBorderColor,
        popoverBorderWidth,
        popoverRadius,
        popoverElevation,
        popoverShadowColor,
        popoverPadding,
        popoverGap,
        popoverMaxHeight,
        itemMinHeight,
        itemPadding,
        itemForegroundColor,
        itemFocusedBackgroundColor,
        itemSelectedBackgroundColor,
        itemSelectedForegroundColor,
        itemRadius,
        disabledOpacity,
      ]);
}
