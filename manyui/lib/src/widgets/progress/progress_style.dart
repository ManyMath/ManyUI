import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MProgress] (linear) and
/// [MCircularProgress].
///
/// Every field is required. Build by hand for advanced theming, or let the
/// theme resolve one via `theme.progress.resolve(...)` and tweak through an
/// [MProgressStyleDelta].
@immutable
class MProgressStyle {
  /// Builds a progress style with every field specified.
  const MProgressStyle({
    required this.thickness,
    required this.minWidth,
    required this.diameter,
    required this.trackColor,
    required this.valueColor,
    required this.trackRadius,
    required this.valueRadius,
    required this.disabledOpacity,
    required this.indeterminateDuration,
  });

  /// The thickness of the rendered bar (or circular ring stroke) in logical
  /// pixels.
  final double thickness;

  /// The minimum width of the linear bar in logical pixels. Linear progress
  /// otherwise expands to fill its parent.
  final double minWidth;

  /// The outer diameter of the circular variant in logical pixels.
  final double diameter;

  /// The fill color of the unfilled (track) portion. Typically `colors.muted`.
  final Color trackColor;

  /// The fill color of the filled (value) portion or the spinning indicator.
  /// Typically `colors.primary`.
  final Color valueColor;

  /// Corner radius of the track rectangle. Use a large value for a fully
  /// rounded track.
  final Radius trackRadius;

  /// Corner radius of the value rectangle (linear only). Separate so callers
  /// can have a fully rounded indicator on a squared track.
  final Radius valueRadius;

  /// Opacity multiplier applied when the widget is disabled.
  final double disabledOpacity;

  /// One cycle duration of the indeterminate animation.
  final Duration indeterminateDuration;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MProgressStyle applyDelta(MProgressStyleDelta? delta) {
    if (delta == null) return this;
    return MProgressStyle(
      thickness: delta.thickness ?? thickness,
      minWidth: delta.minWidth ?? minWidth,
      diameter: delta.diameter ?? diameter,
      trackColor: delta.trackColor ?? trackColor,
      valueColor: delta.valueColor ?? valueColor,
      trackRadius: delta.trackRadius ?? trackRadius,
      valueRadius: delta.valueRadius ?? valueRadius,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
      indeterminateDuration: delta.indeterminateDuration ?? indeterminateDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MProgressStyle &&
        other.thickness == thickness &&
        other.minWidth == minWidth &&
        other.diameter == diameter &&
        other.trackColor == trackColor &&
        other.valueColor == valueColor &&
        other.trackRadius == trackRadius &&
        other.valueRadius == valueRadius &&
        other.disabledOpacity == disabledOpacity &&
        other.indeterminateDuration == indeterminateDuration;
  }

  @override
  int get hashCode => Object.hash(
        thickness,
        minWidth,
        diameter,
        trackColor,
        valueColor,
        trackRadius,
        valueRadius,
        disabledOpacity,
        indeterminateDuration,
      );
}

/// A nullable overlay of [MProgressStyle] fields.
///
/// Pass an instance into `MProgress(style: ...)` or
/// `MCircularProgress(style: ...)` to override individual fields of the
/// theme-resolved style. Any field left null keeps the theme value.
@immutable
class MProgressStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null
  /// and pass through the underlying style unchanged.
  const MProgressStyleDelta({
    this.thickness,
    this.minWidth,
    this.diameter,
    this.trackColor,
    this.valueColor,
    this.trackRadius,
    this.valueRadius,
    this.disabledOpacity,
    this.indeterminateDuration,
  });

  /// Override for [MProgressStyle.thickness].
  final double? thickness;

  /// Override for [MProgressStyle.minWidth].
  final double? minWidth;

  /// Override for [MProgressStyle.diameter].
  final double? diameter;

  /// Override for [MProgressStyle.trackColor].
  final Color? trackColor;

  /// Override for [MProgressStyle.valueColor].
  final Color? valueColor;

  /// Override for [MProgressStyle.trackRadius].
  final Radius? trackRadius;

  /// Override for [MProgressStyle.valueRadius].
  final Radius? valueRadius;

  /// Override for [MProgressStyle.disabledOpacity].
  final double? disabledOpacity;

  /// Override for [MProgressStyle.indeterminateDuration].
  final Duration? indeterminateDuration;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MProgressStyleDelta &&
        other.thickness == thickness &&
        other.minWidth == minWidth &&
        other.diameter == diameter &&
        other.trackColor == trackColor &&
        other.valueColor == valueColor &&
        other.trackRadius == trackRadius &&
        other.valueRadius == valueRadius &&
        other.disabledOpacity == disabledOpacity &&
        other.indeterminateDuration == indeterminateDuration;
  }

  @override
  int get hashCode => Object.hash(
        thickness,
        minWidth,
        diameter,
        trackColor,
        valueColor,
        trackRadius,
        valueRadius,
        disabledOpacity,
        indeterminateDuration,
      );
}
