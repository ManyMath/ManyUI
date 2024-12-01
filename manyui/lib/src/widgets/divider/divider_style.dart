import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MDivider].
///
/// Two fields: the stroke [color] and the [thickness] in logical pixels.
/// Orientation is a parameter on the widget itself, not part of the style.
@immutable
class MDividerStyle {
  /// Builds a divider style with both fields specified.
  const MDividerStyle({required this.color, required this.thickness});

  /// The stroke color. Defaults to `colors.border`.
  final Color color;

  /// The thickness of the rule in logical pixels.
  final double thickness;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MDividerStyle applyDelta(MDividerStyleDelta? delta) {
    if (delta == null) return this;
    return MDividerStyle(
      color: delta.color ?? color,
      thickness: delta.thickness ?? thickness,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MDividerStyle &&
        other.color == color &&
        other.thickness == thickness;
  }

  @override
  int get hashCode => Object.hash(color, thickness);
}

/// A nullable overlay of [MDividerStyle] fields.
@immutable
class MDividerStyleDelta {
  /// Builds a delta with optional field overrides.
  const MDividerStyleDelta({this.color, this.thickness});

  /// Override for [MDividerStyle.color].
  final Color? color;

  /// Override for [MDividerStyle.thickness].
  final double? thickness;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MDividerStyleDelta &&
        other.color == color &&
        other.thickness == thickness;
  }

  @override
  int get hashCode => Object.hash(color, thickness);
}
