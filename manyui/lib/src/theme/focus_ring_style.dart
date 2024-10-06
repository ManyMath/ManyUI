import 'package:flutter/widgets.dart';

/// The shape parameters for the focus ring drawn by `MFocusRing`.
///
/// Color is read from `MColorScheme.ring`, not stored here — keeping shape
/// separate from color lets a single ring style work in both light and dark
/// themes.
@immutable
class MFocusRingStyle {
  /// Builds a focus ring style.
  const MFocusRingStyle({
    this.width = 2,
    this.offset = 2,
    this.radius = const Radius.circular(6),
  });

  /// The thickness of the ring outline, in logical pixels.
  final double width;

  /// The gap between the focused widget's edge and the ring, in logical
  /// pixels. Positive values push the ring outward.
  final double offset;

  /// The corner radius of the ring's bounding box.
  final Radius radius;

  /// Returns a copy with specific fields overridden.
  MFocusRingStyle copyWith({double? width, double? offset, Radius? radius}) {
    return MFocusRingStyle(
      width: width ?? this.width,
      offset: offset ?? this.offset,
      radius: radius ?? this.radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MFocusRingStyle &&
        other.width == width &&
        other.offset == offset &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(width, offset, radius);
}
