import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MAccordion].
///
/// Every field is required. Build by hand for advanced theming, or let the
/// theme resolve one via `theme.accordion.resolve(...)` and tweak through an
/// [MAccordionStyleDelta].
@immutable
class MAccordionStyle {
  /// Builds an accordion style with every field specified.
  const MAccordionStyle({
    required this.surfaceBackgroundColor,
    required this.surfaceBorderColor,
    required this.surfaceBorderWidth,
    required this.surfaceRadius,
    required this.itemDividerColor,
    required this.itemDividerThickness,
    required this.headerPadding,
    required this.headerHeight,
    required this.headerForegroundColor,
    required this.headerTitleTextStyle,
    required this.headerHoveredBackgroundColor,
    required this.chevronColor,
    required this.chevronSize,
    required this.bodyPadding,
    required this.bodyForegroundColor,
    required this.bodyTextStyle,
    required this.expandDuration,
    required this.disabledOpacity,
  });

  /// Fill color of the outer accordion surface.
  final Color surfaceBackgroundColor;

  /// Border stroke around the outer surface, or null/transparent for none.
  final Color? surfaceBorderColor;

  /// Border thickness of the outer surface in logical pixels.
  final double surfaceBorderWidth;

  /// Corner radius of the outer surface.
  final BorderRadiusGeometry surfaceRadius;

  /// Hairline divider color between items.
  final Color itemDividerColor;

  /// Hairline divider thickness between items.
  final double itemDividerThickness;

  /// Inner padding of each item's header strip.
  final EdgeInsetsGeometry headerPadding;

  /// Minimum height of an item header in logical pixels. Touch modality may
  /// resolve to a larger height.
  final double headerHeight;

  /// Foreground color used in the header (title and trailing).
  final Color headerForegroundColor;

  /// Text style applied to header titles.
  final TextStyle headerTitleTextStyle;

  /// Background color of a hovered header.
  final Color headerHoveredBackgroundColor;

  /// Stroke / fill color of the chevron indicator.
  final Color chevronColor;

  /// Edge length of the chevron icon in logical pixels.
  final double chevronSize;

  /// Inner padding of an item's body when expanded.
  final EdgeInsetsGeometry bodyPadding;

  /// Foreground color used in the expanded body.
  final Color bodyForegroundColor;

  /// Text style applied to plain-text body content.
  final TextStyle bodyTextStyle;

  /// Duration of the expand/collapse animation.
  final Duration expandDuration;

  /// Opacity multiplier applied to a disabled item.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MAccordionStyle applyDelta(MAccordionStyleDelta? delta) {
    if (delta == null) return this;
    return MAccordionStyle(
      surfaceBackgroundColor:
          delta.surfaceBackgroundColor ?? surfaceBackgroundColor,
      surfaceBorderColor: delta.surfaceBorderColor ?? surfaceBorderColor,
      surfaceBorderWidth: delta.surfaceBorderWidth ?? surfaceBorderWidth,
      surfaceRadius: delta.surfaceRadius ?? surfaceRadius,
      itemDividerColor: delta.itemDividerColor ?? itemDividerColor,
      itemDividerThickness: delta.itemDividerThickness ?? itemDividerThickness,
      headerPadding: delta.headerPadding ?? headerPadding,
      headerHeight: delta.headerHeight ?? headerHeight,
      headerForegroundColor:
          delta.headerForegroundColor ?? headerForegroundColor,
      headerTitleTextStyle:
          delta.headerTitleTextStyle ?? headerTitleTextStyle,
      headerHoveredBackgroundColor:
          delta.headerHoveredBackgroundColor ?? headerHoveredBackgroundColor,
      chevronColor: delta.chevronColor ?? chevronColor,
      chevronSize: delta.chevronSize ?? chevronSize,
      bodyPadding: delta.bodyPadding ?? bodyPadding,
      bodyForegroundColor: delta.bodyForegroundColor ?? bodyForegroundColor,
      bodyTextStyle: delta.bodyTextStyle ?? bodyTextStyle,
      expandDuration: delta.expandDuration ?? expandDuration,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MAccordionStyle &&
        other.surfaceBackgroundColor == surfaceBackgroundColor &&
        other.surfaceBorderColor == surfaceBorderColor &&
        other.surfaceBorderWidth == surfaceBorderWidth &&
        other.surfaceRadius == surfaceRadius &&
        other.itemDividerColor == itemDividerColor &&
        other.itemDividerThickness == itemDividerThickness &&
        other.headerPadding == headerPadding &&
        other.headerHeight == headerHeight &&
        other.headerForegroundColor == headerForegroundColor &&
        other.headerTitleTextStyle == headerTitleTextStyle &&
        other.headerHoveredBackgroundColor == headerHoveredBackgroundColor &&
        other.chevronColor == chevronColor &&
        other.chevronSize == chevronSize &&
        other.bodyPadding == bodyPadding &&
        other.bodyForegroundColor == bodyForegroundColor &&
        other.bodyTextStyle == bodyTextStyle &&
        other.expandDuration == expandDuration &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        surfaceBackgroundColor,
        surfaceBorderColor,
        surfaceBorderWidth,
        surfaceRadius,
        itemDividerColor,
        itemDividerThickness,
        headerPadding,
        headerHeight,
        headerForegroundColor,
        headerTitleTextStyle,
        headerHoveredBackgroundColor,
        chevronColor,
        chevronSize,
        bodyPadding,
        bodyForegroundColor,
        bodyTextStyle,
        expandDuration,
        disabledOpacity,
      ]);
}

/// A nullable overlay of [MAccordionStyle] fields.
///
/// Pass an instance into `MAccordion(style: ...)` to override individual
/// fields of the theme-resolved style. Any field left null keeps the theme
/// value.
@immutable
class MAccordionStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null and
  /// pass through the underlying style unchanged.
  const MAccordionStyleDelta({
    this.surfaceBackgroundColor,
    this.surfaceBorderColor,
    this.surfaceBorderWidth,
    this.surfaceRadius,
    this.itemDividerColor,
    this.itemDividerThickness,
    this.headerPadding,
    this.headerHeight,
    this.headerForegroundColor,
    this.headerTitleTextStyle,
    this.headerHoveredBackgroundColor,
    this.chevronColor,
    this.chevronSize,
    this.bodyPadding,
    this.bodyForegroundColor,
    this.bodyTextStyle,
    this.expandDuration,
    this.disabledOpacity,
  });

  /// Override for [MAccordionStyle.surfaceBackgroundColor].
  final Color? surfaceBackgroundColor;

  /// Override for [MAccordionStyle.surfaceBorderColor].
  final Color? surfaceBorderColor;

  /// Override for [MAccordionStyle.surfaceBorderWidth].
  final double? surfaceBorderWidth;

  /// Override for [MAccordionStyle.surfaceRadius].
  final BorderRadiusGeometry? surfaceRadius;

  /// Override for [MAccordionStyle.itemDividerColor].
  final Color? itemDividerColor;

  /// Override for [MAccordionStyle.itemDividerThickness].
  final double? itemDividerThickness;

  /// Override for [MAccordionStyle.headerPadding].
  final EdgeInsetsGeometry? headerPadding;

  /// Override for [MAccordionStyle.headerHeight].
  final double? headerHeight;

  /// Override for [MAccordionStyle.headerForegroundColor].
  final Color? headerForegroundColor;

  /// Override for [MAccordionStyle.headerTitleTextStyle].
  final TextStyle? headerTitleTextStyle;

  /// Override for [MAccordionStyle.headerHoveredBackgroundColor].
  final Color? headerHoveredBackgroundColor;

  /// Override for [MAccordionStyle.chevronColor].
  final Color? chevronColor;

  /// Override for [MAccordionStyle.chevronSize].
  final double? chevronSize;

  /// Override for [MAccordionStyle.bodyPadding].
  final EdgeInsetsGeometry? bodyPadding;

  /// Override for [MAccordionStyle.bodyForegroundColor].
  final Color? bodyForegroundColor;

  /// Override for [MAccordionStyle.bodyTextStyle].
  final TextStyle? bodyTextStyle;

  /// Override for [MAccordionStyle.expandDuration].
  final Duration? expandDuration;

  /// Override for [MAccordionStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MAccordionStyleDelta &&
        other.surfaceBackgroundColor == surfaceBackgroundColor &&
        other.surfaceBorderColor == surfaceBorderColor &&
        other.surfaceBorderWidth == surfaceBorderWidth &&
        other.surfaceRadius == surfaceRadius &&
        other.itemDividerColor == itemDividerColor &&
        other.itemDividerThickness == itemDividerThickness &&
        other.headerPadding == headerPadding &&
        other.headerHeight == headerHeight &&
        other.headerForegroundColor == headerForegroundColor &&
        other.headerTitleTextStyle == headerTitleTextStyle &&
        other.headerHoveredBackgroundColor == headerHoveredBackgroundColor &&
        other.chevronColor == chevronColor &&
        other.chevronSize == chevronSize &&
        other.bodyPadding == bodyPadding &&
        other.bodyForegroundColor == bodyForegroundColor &&
        other.bodyTextStyle == bodyTextStyle &&
        other.expandDuration == expandDuration &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        surfaceBackgroundColor,
        surfaceBorderColor,
        surfaceBorderWidth,
        surfaceRadius,
        itemDividerColor,
        itemDividerThickness,
        headerPadding,
        headerHeight,
        headerForegroundColor,
        headerTitleTextStyle,
        headerHoveredBackgroundColor,
        chevronColor,
        chevronSize,
        bodyPadding,
        bodyForegroundColor,
        bodyTextStyle,
        expandDuration,
        disabledOpacity,
      ]);
}
