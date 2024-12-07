import 'package:flutter/widgets.dart';

/// The visual variant a badge renders as.
///
/// Variants pick a color role from the theme's `MColorScheme`. Unlike
/// [MButtonVariant], badge variants don't track a separate hover state —
/// badges are non-interactive.
enum MBadgeVariant {
  /// Solid, high-emphasis. Background = `colors.primary`, foreground =
  /// `colors.primaryForeground`.
  primary,

  /// Solid, low-emphasis. Background = `colors.secondary`, foreground =
  /// `colors.secondaryForeground`.
  secondary,

  /// Solid, destructive emphasis. Background = `colors.destructive`.
  destructive,

  /// Transparent fill with a border. Foreground = `colors.foreground`.
  outline,
}

/// The fully-resolved visual style for an [MBadge].
@immutable
class MBadgeStyle {
  /// Builds a badge style with every field specified.
  const MBadgeStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.padding,
    required this.textStyle,
    required this.radius,
  });

  /// The fill color of the badge body.
  final Color backgroundColor;

  /// The label and icon color inside the badge.
  final Color foregroundColor;

  /// The stroke color of the border, or null for no border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels.
  final double borderWidth;

  /// The padding between the badge's edge and its label content.
  final EdgeInsetsGeometry padding;

  /// The text style applied to the badge's label.
  final TextStyle textStyle;

  /// The corner radius of the badge body.
  final BorderRadiusGeometry radius;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MBadgeStyle applyDelta(MBadgeStyleDelta? delta) {
    if (delta == null) return this;
    return MBadgeStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      padding: delta.padding ?? padding,
      textStyle: delta.textStyle ?? textStyle,
      radius: delta.radius ?? radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MBadgeStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        padding,
        textStyle,
        radius,
      );
}

/// A nullable overlay of [MBadgeStyle] fields.
@immutable
class MBadgeStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MBadgeStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.textStyle,
    this.radius,
  });

  /// Override for [MBadgeStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MBadgeStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MBadgeStyle.borderColor].
  final Color? borderColor;

  /// Override for [MBadgeStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MBadgeStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MBadgeStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MBadgeStyle.radius].
  final BorderRadiusGeometry? radius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MBadgeStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        padding,
        textStyle,
        radius,
      );
}
