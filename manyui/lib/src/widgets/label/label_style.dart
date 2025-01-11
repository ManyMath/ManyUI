import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MLabel].
///
/// Three fields: the [textStyle] for the label string, the [disabledColor]
/// blended in when the label is disabled, and the [gap] between the label
/// and its associated child (when one is supplied).
@immutable
class MLabelStyle {
  /// Builds a label style with every field specified.
  const MLabelStyle({
    required this.textStyle,
    required this.disabledColor,
    required this.gap,
  });

  /// The text style applied to the label's string.
  final TextStyle textStyle;

  /// The color applied to the label when it is disabled.
  ///
  /// Replaces [textStyle]'s color verbatim — not blended — so a delta that
  /// sets `textStyle.color` will not affect the disabled-state rendering.
  final Color disabledColor;

  /// The space between the label and its associated child, in logical
  /// pixels. Used only when [MLabel] is constructed with both a text and
  /// a non-null child slot.
  final double gap;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MLabelStyle applyDelta(MLabelStyleDelta? delta) {
    if (delta == null) return this;
    return MLabelStyle(
      textStyle: delta.textStyle ?? textStyle,
      disabledColor: delta.disabledColor ?? disabledColor,
      gap: delta.gap ?? gap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MLabelStyle &&
        other.textStyle == textStyle &&
        other.disabledColor == disabledColor &&
        other.gap == gap;
  }

  @override
  int get hashCode => Object.hash(textStyle, disabledColor, gap);
}

/// A nullable overlay of [MLabelStyle] fields.
@immutable
class MLabelStyleDelta {
  /// Builds a delta with optional field overrides.
  const MLabelStyleDelta({this.textStyle, this.disabledColor, this.gap});

  /// Override for [MLabelStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MLabelStyle.disabledColor].
  final Color? disabledColor;

  /// Override for [MLabelStyle.gap].
  final double? gap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MLabelStyleDelta &&
        other.textStyle == textStyle &&
        other.disabledColor == disabledColor &&
        other.gap == gap;
  }

  @override
  int get hashCode => Object.hash(textStyle, disabledColor, gap);
}
