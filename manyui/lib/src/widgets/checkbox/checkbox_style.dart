import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MCheckbox].
///
/// Every field is required. Build by hand for advanced theming, or let the
/// theme resolve one via `theme.checkbox.resolve(...)` and tweak through an
/// [MCheckboxStyleDelta].
@immutable
class MCheckboxStyle {
  /// Builds a checkbox style with every field specified.
  const MCheckboxStyle({
    required this.size,
    required this.borderColor,
    required this.borderWidth,
    required this.uncheckedBackgroundColor,
    required this.checkedBackgroundColor,
    required this.checkmarkColor,
    required this.checkmarkThickness,
    required this.radius,
    required this.disabledOpacity,
  });

  /// The edge length of the checkbox's square hit/paint surface, in logical
  /// pixels. Touch modality resolves to a larger size than mouse modality.
  final double size;

  /// The border color of the box in the unchecked state.
  final Color borderColor;

  /// The border thickness in logical pixels.
  final double borderWidth;

  /// The fill color when unchecked. Usually transparent or a very faint tint.
  final Color uncheckedBackgroundColor;

  /// The fill color when checked. Typically `colors.primary`.
  final Color checkedBackgroundColor;

  /// The color of the checkmark stroke.
  final Color checkmarkColor;

  /// The stroke thickness of the checkmark, in logical pixels.
  final double checkmarkThickness;

  /// The corner radius of the box.
  final BorderRadiusGeometry radius;

  /// The opacity multiplier applied when the widget is disabled.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MCheckboxStyle applyDelta(MCheckboxStyleDelta? delta) {
    if (delta == null) return this;
    return MCheckboxStyle(
      size: delta.size ?? size,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      uncheckedBackgroundColor:
          delta.uncheckedBackgroundColor ?? uncheckedBackgroundColor,
      checkedBackgroundColor:
          delta.checkedBackgroundColor ?? checkedBackgroundColor,
      checkmarkColor: delta.checkmarkColor ?? checkmarkColor,
      checkmarkThickness: delta.checkmarkThickness ?? checkmarkThickness,
      radius: delta.radius ?? radius,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCheckboxStyle &&
        other.size == size &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.uncheckedBackgroundColor == uncheckedBackgroundColor &&
        other.checkedBackgroundColor == checkedBackgroundColor &&
        other.checkmarkColor == checkmarkColor &&
        other.checkmarkThickness == checkmarkThickness &&
        other.radius == radius &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(
        size,
        borderColor,
        borderWidth,
        uncheckedBackgroundColor,
        checkedBackgroundColor,
        checkmarkColor,
        checkmarkThickness,
        radius,
        disabledOpacity,
      );
}

/// A nullable overlay of [MCheckboxStyle] fields.
///
/// Pass an instance into `MCheckbox(style: ...)` to override individual fields
/// of the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MCheckboxStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null
  /// and pass through the underlying style unchanged.
  const MCheckboxStyleDelta({
    this.size,
    this.borderColor,
    this.borderWidth,
    this.uncheckedBackgroundColor,
    this.checkedBackgroundColor,
    this.checkmarkColor,
    this.checkmarkThickness,
    this.radius,
    this.disabledOpacity,
  });

  /// Override for [MCheckboxStyle.size].
  final double? size;

  /// Override for [MCheckboxStyle.borderColor].
  final Color? borderColor;

  /// Override for [MCheckboxStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MCheckboxStyle.uncheckedBackgroundColor].
  final Color? uncheckedBackgroundColor;

  /// Override for [MCheckboxStyle.checkedBackgroundColor].
  final Color? checkedBackgroundColor;

  /// Override for [MCheckboxStyle.checkmarkColor].
  final Color? checkmarkColor;

  /// Override for [MCheckboxStyle.checkmarkThickness].
  final double? checkmarkThickness;

  /// Override for [MCheckboxStyle.radius].
  final BorderRadiusGeometry? radius;

  /// Override for [MCheckboxStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCheckboxStyleDelta &&
        other.size == size &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.uncheckedBackgroundColor == uncheckedBackgroundColor &&
        other.checkedBackgroundColor == checkedBackgroundColor &&
        other.checkmarkColor == checkmarkColor &&
        other.checkmarkThickness == checkmarkThickness &&
        other.radius == radius &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(
        size,
        borderColor,
        borderWidth,
        uncheckedBackgroundColor,
        checkedBackgroundColor,
        checkmarkColor,
        checkmarkThickness,
        radius,
        disabledOpacity,
      );
}
