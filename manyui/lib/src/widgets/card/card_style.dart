import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MCard].
///
/// Every field is required. Most users build a style by letting the theme
/// resolve one via `theme.card.resolve(...)` and then folding in field-wise
/// tweaks through an [MCardStyleDelta] on the widget itself.
@immutable
class MCardStyle {
  /// Builds a card style with every field specified.
  const MCardStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.padding,
    required this.radius,
  });

  /// The fill color of the card body. Defaults to `colors.card`.
  final Color backgroundColor;

  /// The default text and icon color inside the card. Defaults to
  /// `colors.cardForeground`.
  final Color foregroundColor;

  /// The stroke color of the card border, or null for no border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels. Ignored when
  /// [borderColor] is null.
  final double borderWidth;

  /// The padding between the card's edge and its child content.
  final EdgeInsetsGeometry padding;

  /// The corner radius of the card body.
  final BorderRadiusGeometry radius;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MCardStyle applyDelta(MCardStyleDelta? delta) {
    if (delta == null) return this;
    return MCardStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      padding: delta.padding ?? padding,
      radius: delta.radius ?? radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCardStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        padding,
        radius,
      );
}

/// A nullable overlay of [MCardStyle] fields.
///
/// Pass an instance into `MCard(style: ...)` to override individual fields
/// of the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MCardStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null
  /// and pass through the underlying style unchanged.
  const MCardStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.radius,
  });

  /// Override for [MCardStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MCardStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MCardStyle.borderColor].
  final Color? borderColor;

  /// Override for [MCardStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MCardStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MCardStyle.radius].
  final BorderRadiusGeometry? radius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCardStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        padding,
        radius,
      );
}
