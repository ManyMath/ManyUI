import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MRadio].
///
/// Every field is required. Build by hand for advanced theming, or let the
/// theme resolve one via `theme.radio.resolve(...)` and tweak through an
/// [MRadioStyleDelta].
@immutable
class MRadioStyle {
  /// Builds a radio style with every field specified.
  const MRadioStyle({
    required this.size,
    required this.borderColor,
    required this.borderWidth,
    required this.uncheckedBackgroundColor,
    required this.checkedBackgroundColor,
    required this.dotColor,
    required this.dotDiameter,
    required this.disabledOpacity,
  });

  /// The diameter of the radio's circular surface, in logical pixels. Touch
  /// modality resolves to a larger size than mouse modality.
  final double size;

  /// The border color of the ring in both states (the ring stays visible when
  /// the radio is selected to match shadcn's look).
  final Color borderColor;

  /// The border thickness in logical pixels.
  final double borderWidth;

  /// The fill color when unselected. Usually transparent or a very faint tint.
  final Color uncheckedBackgroundColor;

  /// The fill color when selected.
  final Color checkedBackgroundColor;

  /// The color of the inner dot.
  final Color dotColor;

  /// The diameter of the inner dot, in logical pixels.
  final double dotDiameter;

  /// The opacity multiplier applied when the widget is disabled.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MRadioStyle applyDelta(MRadioStyleDelta? delta) {
    if (delta == null) return this;
    return MRadioStyle(
      size: delta.size ?? size,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      uncheckedBackgroundColor:
          delta.uncheckedBackgroundColor ?? uncheckedBackgroundColor,
      checkedBackgroundColor:
          delta.checkedBackgroundColor ?? checkedBackgroundColor,
      dotColor: delta.dotColor ?? dotColor,
      dotDiameter: delta.dotDiameter ?? dotDiameter,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MRadioStyle &&
        other.size == size &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.uncheckedBackgroundColor == uncheckedBackgroundColor &&
        other.checkedBackgroundColor == checkedBackgroundColor &&
        other.dotColor == dotColor &&
        other.dotDiameter == dotDiameter &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(
        size,
        borderColor,
        borderWidth,
        uncheckedBackgroundColor,
        checkedBackgroundColor,
        dotColor,
        dotDiameter,
        disabledOpacity,
      );
}

/// A nullable overlay of [MRadioStyle] fields.
///
/// Pass an instance into `MRadio(style: ...)` to override individual fields of
/// the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MRadioStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null and
  /// pass through the underlying style unchanged.
  const MRadioStyleDelta({
    this.size,
    this.borderColor,
    this.borderWidth,
    this.uncheckedBackgroundColor,
    this.checkedBackgroundColor,
    this.dotColor,
    this.dotDiameter,
    this.disabledOpacity,
  });

  /// Override for [MRadioStyle.size].
  final double? size;

  /// Override for [MRadioStyle.borderColor].
  final Color? borderColor;

  /// Override for [MRadioStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MRadioStyle.uncheckedBackgroundColor].
  final Color? uncheckedBackgroundColor;

  /// Override for [MRadioStyle.checkedBackgroundColor].
  final Color? checkedBackgroundColor;

  /// Override for [MRadioStyle.dotColor].
  final Color? dotColor;

  /// Override for [MRadioStyle.dotDiameter].
  final double? dotDiameter;

  /// Override for [MRadioStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MRadioStyleDelta &&
        other.size == size &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.uncheckedBackgroundColor == uncheckedBackgroundColor &&
        other.checkedBackgroundColor == checkedBackgroundColor &&
        other.dotColor == dotColor &&
        other.dotDiameter == dotDiameter &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(
        size,
        borderColor,
        borderWidth,
        uncheckedBackgroundColor,
        checkedBackgroundColor,
        dotColor,
        dotDiameter,
        disabledOpacity,
      );
}
