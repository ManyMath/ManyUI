import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MListTile].
///
/// Every field is required. Most users build a style by letting the theme
/// resolve one via `theme.listTile.resolve(...)` and then folding in
/// field-wise tweaks through an [MListTileStyleDelta] on the widget itself.
@immutable
class MListTileStyle {
  /// Builds a list-tile style with every field specified.
  const MListTileStyle({
    required this.backgroundColor,
    required this.selectedBackgroundColor,
    required this.foregroundColor,
    required this.selectedForegroundColor,
    required this.subtitleColor,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.padding,
    required this.horizontalGap,
    required this.radius,
  });

  /// The fill color of an unselected row. Usually transparent.
  final Color backgroundColor;

  /// The fill color of a selected row. Defaults to `colors.accent`.
  final Color selectedBackgroundColor;

  /// The title text color of an unselected row.
  final Color foregroundColor;

  /// The title text color of a selected row. Defaults to
  /// `colors.accentForeground`.
  final Color selectedForegroundColor;

  /// The subtitle text color. Defaults to `colors.mutedForeground`.
  final Color subtitleColor;

  /// The text style for the title line.
  final TextStyle titleStyle;

  /// The text style for the subtitle line.
  final TextStyle subtitleStyle;

  /// The padding between the row's edge and its content.
  final EdgeInsetsGeometry padding;

  /// The horizontal gap between leading/content/trailing sections.
  final double horizontalGap;

  /// The corner radius of the row's background.
  final BorderRadiusGeometry radius;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MListTileStyle applyDelta(MListTileStyleDelta? delta) {
    if (delta == null) return this;
    return MListTileStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      selectedBackgroundColor:
          delta.selectedBackgroundColor ?? selectedBackgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      selectedForegroundColor:
          delta.selectedForegroundColor ?? selectedForegroundColor,
      subtitleColor: delta.subtitleColor ?? subtitleColor,
      titleStyle: delta.titleStyle ?? titleStyle,
      subtitleStyle: delta.subtitleStyle ?? subtitleStyle,
      padding: delta.padding ?? padding,
      horizontalGap: delta.horizontalGap ?? horizontalGap,
      radius: delta.radius ?? radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MListTileStyle &&
        other.backgroundColor == backgroundColor &&
        other.selectedBackgroundColor == selectedBackgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.selectedForegroundColor == selectedForegroundColor &&
        other.subtitleColor == subtitleColor &&
        other.titleStyle == titleStyle &&
        other.subtitleStyle == subtitleStyle &&
        other.padding == padding &&
        other.horizontalGap == horizontalGap &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    selectedBackgroundColor,
    foregroundColor,
    selectedForegroundColor,
    subtitleColor,
    titleStyle,
    subtitleStyle,
    padding,
    horizontalGap,
    radius,
  );
}

/// A nullable overlay of [MListTileStyle] fields.
///
/// Pass an instance into `MListTile(style: ...)` to override individual
/// fields of the theme-resolved style. Any field left null keeps the theme
/// value.
@immutable
class MListTileStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null
  /// and pass through the underlying style unchanged.
  const MListTileStyleDelta({
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.foregroundColor,
    this.selectedForegroundColor,
    this.subtitleColor,
    this.titleStyle,
    this.subtitleStyle,
    this.padding,
    this.horizontalGap,
    this.radius,
  });

  /// Override for [MListTileStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MListTileStyle.selectedBackgroundColor].
  final Color? selectedBackgroundColor;

  /// Override for [MListTileStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MListTileStyle.selectedForegroundColor].
  final Color? selectedForegroundColor;

  /// Override for [MListTileStyle.subtitleColor].
  final Color? subtitleColor;

  /// Override for [MListTileStyle.titleStyle].
  final TextStyle? titleStyle;

  /// Override for [MListTileStyle.subtitleStyle].
  final TextStyle? subtitleStyle;

  /// Override for [MListTileStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MListTileStyle.horizontalGap].
  final double? horizontalGap;

  /// Override for [MListTileStyle.radius].
  final BorderRadiusGeometry? radius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MListTileStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.selectedBackgroundColor == selectedBackgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.selectedForegroundColor == selectedForegroundColor &&
        other.subtitleColor == subtitleColor &&
        other.titleStyle == titleStyle &&
        other.subtitleStyle == subtitleStyle &&
        other.padding == padding &&
        other.horizontalGap == horizontalGap &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    selectedBackgroundColor,
    foregroundColor,
    selectedForegroundColor,
    subtitleColor,
    titleStyle,
    subtitleStyle,
    padding,
    horizontalGap,
    radius,
  );
}
