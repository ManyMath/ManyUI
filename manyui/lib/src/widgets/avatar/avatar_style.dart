import 'package:flutter/widgets.dart';

/// The shape an [MAvatar] renders.
enum MAvatarShape {
  /// A perfect circle, the default. Sets a half-size border radius internally
  /// so the surface is clipped to a round profile shape.
  circle,

  /// A rounded square — corners follow the theme's default radius.
  square,
}

/// The fully-resolved visual style for an [MAvatar].
@immutable
class MAvatarStyle {
  /// Builds an avatar style with every field specified.
  const MAvatarStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.textStyle,
    required this.squareRadius,
  });

  /// The fill color of the avatar surface when the image is missing or fails
  /// to load. Defaults to `colors.muted`.
  final Color backgroundColor;

  /// The text and icon color used by the fallback content.
  final Color foregroundColor;

  /// The stroke color of the avatar's outline, or null for no border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels.
  final double borderWidth;

  /// The text style applied to the fallback content (typically initials).
  final TextStyle textStyle;

  /// The corner radius to use when the avatar shape is [MAvatarShape.square].
  /// Ignored for the circle shape (which uses a half-size radius).
  final BorderRadiusGeometry squareRadius;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MAvatarStyle applyDelta(MAvatarStyleDelta? delta) {
    if (delta == null) return this;
    return MAvatarStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      textStyle: delta.textStyle ?? textStyle,
      squareRadius: delta.squareRadius ?? squareRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MAvatarStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.textStyle == textStyle &&
        other.squareRadius == squareRadius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        textStyle,
        squareRadius,
      );
}

/// A nullable overlay of [MAvatarStyle] fields.
@immutable
class MAvatarStyleDelta {
  /// Builds a delta with optional field overrides.
  const MAvatarStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.textStyle,
    this.squareRadius,
  });

  /// Override for [MAvatarStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MAvatarStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MAvatarStyle.borderColor].
  final Color? borderColor;

  /// Override for [MAvatarStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MAvatarStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MAvatarStyle.squareRadius].
  final BorderRadiusGeometry? squareRadius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MAvatarStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.textStyle == textStyle &&
        other.squareRadius == squareRadius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        textStyle,
        squareRadius,
      );
}
