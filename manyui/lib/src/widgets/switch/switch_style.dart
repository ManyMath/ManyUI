import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MSwitch].
///
/// Every field is required. Build by hand for advanced theming, or let the
/// theme resolve one via `theme.switch_.resolve(...)` and tweak through an
/// [MSwitchStyleDelta].
@immutable
class MSwitchStyle {
  /// Builds a switch style with every field specified.
  const MSwitchStyle({
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbDiameter,
    required this.thumbPadding,
    required this.offTrackColor,
    required this.onTrackColor,
    required this.thumbColor,
    required this.borderColor,
    required this.borderWidth,
    required this.disabledOpacity,
  });

  /// The width of the track (the pill background), in logical pixels.
  final double trackWidth;

  /// The height of the track (the pill background), in logical pixels. Also
  /// the diameter of the pill caps.
  final double trackHeight;

  /// The diameter of the circular thumb, in logical pixels. Typically just
  /// under [trackHeight] minus twice [thumbPadding].
  final double thumbDiameter;

  /// The inset between the thumb and the track edge, in logical pixels.
  final double thumbPadding;

  /// The track fill color when the switch is off.
  final Color offTrackColor;

  /// The track fill color when the switch is on. Typically `colors.primary`.
  final Color onTrackColor;

  /// The thumb fill color. Typically white-ish in both light and dark modes
  /// (shadcn ships a single thumb color for both states).
  final Color thumbColor;

  /// The hairline border around the track. Set transparent to omit.
  final Color borderColor;

  /// The track border thickness in logical pixels.
  final double borderWidth;

  /// The opacity multiplier applied when the widget is disabled.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MSwitchStyle applyDelta(MSwitchStyleDelta? delta) {
    if (delta == null) return this;
    return MSwitchStyle(
      trackWidth: delta.trackWidth ?? trackWidth,
      trackHeight: delta.trackHeight ?? trackHeight,
      thumbDiameter: delta.thumbDiameter ?? thumbDiameter,
      thumbPadding: delta.thumbPadding ?? thumbPadding,
      offTrackColor: delta.offTrackColor ?? offTrackColor,
      onTrackColor: delta.onTrackColor ?? onTrackColor,
      thumbColor: delta.thumbColor ?? thumbColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MSwitchStyle &&
        other.trackWidth == trackWidth &&
        other.trackHeight == trackHeight &&
        other.thumbDiameter == thumbDiameter &&
        other.thumbPadding == thumbPadding &&
        other.offTrackColor == offTrackColor &&
        other.onTrackColor == onTrackColor &&
        other.thumbColor == thumbColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(
        trackWidth,
        trackHeight,
        thumbDiameter,
        thumbPadding,
        offTrackColor,
        onTrackColor,
        thumbColor,
        borderColor,
        borderWidth,
        disabledOpacity,
      );
}

/// A nullable overlay of [MSwitchStyle] fields.
///
/// Pass an instance into `MSwitch(style: ...)` to override individual fields
/// of the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MSwitchStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null
  /// and pass through the underlying style unchanged.
  const MSwitchStyleDelta({
    this.trackWidth,
    this.trackHeight,
    this.thumbDiameter,
    this.thumbPadding,
    this.offTrackColor,
    this.onTrackColor,
    this.thumbColor,
    this.borderColor,
    this.borderWidth,
    this.disabledOpacity,
  });

  /// Override for [MSwitchStyle.trackWidth].
  final double? trackWidth;

  /// Override for [MSwitchStyle.trackHeight].
  final double? trackHeight;

  /// Override for [MSwitchStyle.thumbDiameter].
  final double? thumbDiameter;

  /// Override for [MSwitchStyle.thumbPadding].
  final double? thumbPadding;

  /// Override for [MSwitchStyle.offTrackColor].
  final Color? offTrackColor;

  /// Override for [MSwitchStyle.onTrackColor].
  final Color? onTrackColor;

  /// Override for [MSwitchStyle.thumbColor].
  final Color? thumbColor;

  /// Override for [MSwitchStyle.borderColor].
  final Color? borderColor;

  /// Override for [MSwitchStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MSwitchStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MSwitchStyleDelta &&
        other.trackWidth == trackWidth &&
        other.trackHeight == trackHeight &&
        other.thumbDiameter == thumbDiameter &&
        other.thumbPadding == thumbPadding &&
        other.offTrackColor == offTrackColor &&
        other.onTrackColor == onTrackColor &&
        other.thumbColor == thumbColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(
        trackWidth,
        trackHeight,
        thumbDiameter,
        thumbPadding,
        offTrackColor,
        onTrackColor,
        thumbColor,
        borderColor,
        borderWidth,
        disabledOpacity,
      );
}
