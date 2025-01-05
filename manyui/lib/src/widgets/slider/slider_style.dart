import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MSlider].
///
/// Every field is required. Build by hand for advanced theming, or let the
/// theme resolve one via `theme.slider.resolve(...)` and tweak through an
/// [MSliderStyleDelta].
@immutable
class MSliderStyle {
  /// Builds a slider style with every field specified.
  const MSliderStyle({
    required this.trackHeight,
    required this.thumbDiameter,
    required this.minTrackWidth,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    required this.thumbColor,
    required this.thumbBorderColor,
    required this.thumbBorderWidth,
    required this.disabledOpacity,
  });

  /// The track thickness in logical pixels.
  final double trackHeight;

  /// The diameter of the circular thumb in logical pixels.
  ///
  /// Touch-modality thumbs are sized to meet the WCAG ≥ 24-px hit target
  /// without relying on additional surrounding padding.
  final double thumbDiameter;

  /// The minimum width of the rendered track, in logical pixels. The slider
  /// otherwise expands horizontally to fit its parent.
  final double minTrackWidth;

  /// The fill color of the active (left-of-thumb) track segment. Typically
  /// `colors.primary`.
  final Color activeTrackColor;

  /// The fill color of the inactive (right-of-thumb) track segment. Typically
  /// `colors.input` so it reads as a subtle channel.
  final Color inactiveTrackColor;

  /// The thumb fill color. Typically `colors.background` so the thumb stands
  /// off the active track.
  final Color thumbColor;

  /// The hairline ring around the thumb. Set transparent to omit.
  final Color thumbBorderColor;

  /// The thumb border thickness in logical pixels.
  final double thumbBorderWidth;

  /// The opacity multiplier applied when the widget is disabled.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MSliderStyle applyDelta(MSliderStyleDelta? delta) {
    if (delta == null) return this;
    return MSliderStyle(
      trackHeight: delta.trackHeight ?? trackHeight,
      thumbDiameter: delta.thumbDiameter ?? thumbDiameter,
      minTrackWidth: delta.minTrackWidth ?? minTrackWidth,
      activeTrackColor: delta.activeTrackColor ?? activeTrackColor,
      inactiveTrackColor: delta.inactiveTrackColor ?? inactiveTrackColor,
      thumbColor: delta.thumbColor ?? thumbColor,
      thumbBorderColor: delta.thumbBorderColor ?? thumbBorderColor,
      thumbBorderWidth: delta.thumbBorderWidth ?? thumbBorderWidth,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MSliderStyle &&
        other.trackHeight == trackHeight &&
        other.thumbDiameter == thumbDiameter &&
        other.minTrackWidth == minTrackWidth &&
        other.activeTrackColor == activeTrackColor &&
        other.inactiveTrackColor == inactiveTrackColor &&
        other.thumbColor == thumbColor &&
        other.thumbBorderColor == thumbBorderColor &&
        other.thumbBorderWidth == thumbBorderWidth &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(
        trackHeight,
        thumbDiameter,
        minTrackWidth,
        activeTrackColor,
        inactiveTrackColor,
        thumbColor,
        thumbBorderColor,
        thumbBorderWidth,
        disabledOpacity,
      );
}

/// A nullable overlay of [MSliderStyle] fields.
///
/// Pass an instance into `MSlider(style: ...)` to override individual fields
/// of the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MSliderStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null
  /// and pass through the underlying style unchanged.
  const MSliderStyleDelta({
    this.trackHeight,
    this.thumbDiameter,
    this.minTrackWidth,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.thumbBorderColor,
    this.thumbBorderWidth,
    this.disabledOpacity,
  });

  /// Override for [MSliderStyle.trackHeight].
  final double? trackHeight;

  /// Override for [MSliderStyle.thumbDiameter].
  final double? thumbDiameter;

  /// Override for [MSliderStyle.minTrackWidth].
  final double? minTrackWidth;

  /// Override for [MSliderStyle.activeTrackColor].
  final Color? activeTrackColor;

  /// Override for [MSliderStyle.inactiveTrackColor].
  final Color? inactiveTrackColor;

  /// Override for [MSliderStyle.thumbColor].
  final Color? thumbColor;

  /// Override for [MSliderStyle.thumbBorderColor].
  final Color? thumbBorderColor;

  /// Override for [MSliderStyle.thumbBorderWidth].
  final double? thumbBorderWidth;

  /// Override for [MSliderStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MSliderStyleDelta &&
        other.trackHeight == trackHeight &&
        other.thumbDiameter == thumbDiameter &&
        other.minTrackWidth == minTrackWidth &&
        other.activeTrackColor == activeTrackColor &&
        other.inactiveTrackColor == inactiveTrackColor &&
        other.thumbColor == thumbColor &&
        other.thumbBorderColor == thumbBorderColor &&
        other.thumbBorderWidth == thumbBorderWidth &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(
        trackHeight,
        thumbDiameter,
        minTrackWidth,
        activeTrackColor,
        inactiveTrackColor,
        thumbColor,
        thumbBorderColor,
        thumbBorderWidth,
        disabledOpacity,
      );
}
