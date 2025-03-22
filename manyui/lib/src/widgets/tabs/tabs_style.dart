import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MTabs] strip.
///
/// Every field is required. Build by hand for advanced theming, or let the
/// theme resolve one via `theme.tabs.resolve(...)` and tweak through an
/// [MTabsStyleDelta].
@immutable
class MTabsStyle {
  /// Builds a tabs style with every field specified.
  const MTabsStyle({
    required this.tabHeight,
    required this.tabPadding,
    required this.tabSpacing,
    required this.activeForegroundColor,
    required this.inactiveForegroundColor,
    required this.disabledOpacity,
    required this.indicatorColor,
    required this.indicatorThickness,
    required this.stripDividerColor,
    required this.stripDividerThickness,
    required this.contentPadding,
    required this.titleTextStyle,
  });

  /// The height of each tab in the strip, in logical pixels. Touch modality
  /// resolves to a larger height than mouse modality so the hit target stays
  /// comfortable.
  final double tabHeight;

  /// Inner padding of each tab between its edge and its title.
  final EdgeInsetsGeometry tabPadding;

  /// Horizontal spacing between adjacent tabs in the strip, in logical pixels.
  final double tabSpacing;

  /// The text color used for the active tab's title.
  final Color activeForegroundColor;

  /// The text color used for inactive tabs' titles.
  final Color inactiveForegroundColor;

  /// The opacity multiplier applied to a disabled tab.
  final double disabledOpacity;

  /// The color of the bottom-border indicator under the active tab.
  final Color indicatorColor;

  /// The thickness of the active-tab indicator in logical pixels.
  final double indicatorThickness;

  /// The color of the strip's bottom divider that runs the full width of the
  /// tab bar.
  final Color stripDividerColor;

  /// The thickness of the strip's bottom divider in logical pixels.
  final double stripDividerThickness;

  /// Padding applied around the active tab's content pane.
  final EdgeInsetsGeometry contentPadding;

  /// The text style applied to each tab's title.
  final TextStyle titleTextStyle;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MTabsStyle applyDelta(MTabsStyleDelta? delta) {
    if (delta == null) return this;
    return MTabsStyle(
      tabHeight: delta.tabHeight ?? tabHeight,
      tabPadding: delta.tabPadding ?? tabPadding,
      tabSpacing: delta.tabSpacing ?? tabSpacing,
      activeForegroundColor:
          delta.activeForegroundColor ?? activeForegroundColor,
      inactiveForegroundColor:
          delta.inactiveForegroundColor ?? inactiveForegroundColor,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
      indicatorColor: delta.indicatorColor ?? indicatorColor,
      indicatorThickness: delta.indicatorThickness ?? indicatorThickness,
      stripDividerColor: delta.stripDividerColor ?? stripDividerColor,
      stripDividerThickness:
          delta.stripDividerThickness ?? stripDividerThickness,
      contentPadding: delta.contentPadding ?? contentPadding,
      titleTextStyle: delta.titleTextStyle ?? titleTextStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MTabsStyle &&
        other.tabHeight == tabHeight &&
        other.tabPadding == tabPadding &&
        other.tabSpacing == tabSpacing &&
        other.activeForegroundColor == activeForegroundColor &&
        other.inactiveForegroundColor == inactiveForegroundColor &&
        other.disabledOpacity == disabledOpacity &&
        other.indicatorColor == indicatorColor &&
        other.indicatorThickness == indicatorThickness &&
        other.stripDividerColor == stripDividerColor &&
        other.stripDividerThickness == stripDividerThickness &&
        other.contentPadding == contentPadding &&
        other.titleTextStyle == titleTextStyle;
  }

  @override
  int get hashCode => Object.hash(
        tabHeight,
        tabPadding,
        tabSpacing,
        activeForegroundColor,
        inactiveForegroundColor,
        disabledOpacity,
        indicatorColor,
        indicatorThickness,
        stripDividerColor,
        stripDividerThickness,
        contentPadding,
        titleTextStyle,
      );
}

/// A nullable overlay of [MTabsStyle] fields.
///
/// Pass an instance into `MTabs(style: ...)` to override individual fields of
/// the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MTabsStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null and
  /// pass through the underlying style unchanged.
  const MTabsStyleDelta({
    this.tabHeight,
    this.tabPadding,
    this.tabSpacing,
    this.activeForegroundColor,
    this.inactiveForegroundColor,
    this.disabledOpacity,
    this.indicatorColor,
    this.indicatorThickness,
    this.stripDividerColor,
    this.stripDividerThickness,
    this.contentPadding,
    this.titleTextStyle,
  });

  /// Override for [MTabsStyle.tabHeight].
  final double? tabHeight;

  /// Override for [MTabsStyle.tabPadding].
  final EdgeInsetsGeometry? tabPadding;

  /// Override for [MTabsStyle.tabSpacing].
  final double? tabSpacing;

  /// Override for [MTabsStyle.activeForegroundColor].
  final Color? activeForegroundColor;

  /// Override for [MTabsStyle.inactiveForegroundColor].
  final Color? inactiveForegroundColor;

  /// Override for [MTabsStyle.disabledOpacity].
  final double? disabledOpacity;

  /// Override for [MTabsStyle.indicatorColor].
  final Color? indicatorColor;

  /// Override for [MTabsStyle.indicatorThickness].
  final double? indicatorThickness;

  /// Override for [MTabsStyle.stripDividerColor].
  final Color? stripDividerColor;

  /// Override for [MTabsStyle.stripDividerThickness].
  final double? stripDividerThickness;

  /// Override for [MTabsStyle.contentPadding].
  final EdgeInsetsGeometry? contentPadding;

  /// Override for [MTabsStyle.titleTextStyle].
  final TextStyle? titleTextStyle;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MTabsStyleDelta &&
        other.tabHeight == tabHeight &&
        other.tabPadding == tabPadding &&
        other.tabSpacing == tabSpacing &&
        other.activeForegroundColor == activeForegroundColor &&
        other.inactiveForegroundColor == inactiveForegroundColor &&
        other.disabledOpacity == disabledOpacity &&
        other.indicatorColor == indicatorColor &&
        other.indicatorThickness == indicatorThickness &&
        other.stripDividerColor == stripDividerColor &&
        other.stripDividerThickness == stripDividerThickness &&
        other.contentPadding == contentPadding &&
        other.titleTextStyle == titleTextStyle;
  }

  @override
  int get hashCode => Object.hash(
        tabHeight,
        tabPadding,
        tabSpacing,
        activeForegroundColor,
        inactiveForegroundColor,
        disabledOpacity,
        indicatorColor,
        indicatorThickness,
        stripDividerColor,
        stripDividerThickness,
        contentPadding,
        titleTextStyle,
      );
}
