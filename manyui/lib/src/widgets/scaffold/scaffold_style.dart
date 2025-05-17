import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MScaffold].
///
/// Every field is required. Most users build a style by letting the theme
/// resolve one via `theme.scaffold.resolve(...)` and then folding in
/// field-wise tweaks through an [MScaffoldStyleDelta] on the widget itself.
@immutable
class MScaffoldStyle {
  /// Builds a scaffold style with every field specified.
  const MScaffoldStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.bodyPadding,
    required this.headerPadding,
    required this.footerPadding,
  });

  /// The full-screen background fill. Defaults to `colors.background`.
  final Color backgroundColor;

  /// The default text and icon color inside the scaffold. Defaults to
  /// `colors.foreground`.
  final Color foregroundColor;

  /// Padding applied to the [MScaffold.body] inside the safe area.
  final EdgeInsetsGeometry bodyPadding;

  /// Padding applied to the optional [MScaffold.header] slot.
  final EdgeInsetsGeometry headerPadding;

  /// Padding applied to the optional [MScaffold.footer] slot.
  final EdgeInsetsGeometry footerPadding;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MScaffoldStyle applyDelta(MScaffoldStyleDelta? delta) {
    if (delta == null) return this;
    return MScaffoldStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      bodyPadding: delta.bodyPadding ?? bodyPadding,
      headerPadding: delta.headerPadding ?? headerPadding,
      footerPadding: delta.footerPadding ?? footerPadding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MScaffoldStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.bodyPadding == bodyPadding &&
        other.headerPadding == headerPadding &&
        other.footerPadding == footerPadding;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        bodyPadding,
        headerPadding,
        footerPadding,
      );
}

/// A nullable overlay of [MScaffoldStyle] fields.
///
/// Pass an instance into `MScaffold(style: ...)` to override individual
/// fields of the theme-resolved style. Any field left null keeps the theme
/// value.
@immutable
class MScaffoldStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null
  /// and pass through the underlying style unchanged.
  const MScaffoldStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.bodyPadding,
    this.headerPadding,
    this.footerPadding,
  });

  /// Override for [MScaffoldStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MScaffoldStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MScaffoldStyle.bodyPadding].
  final EdgeInsetsGeometry? bodyPadding;

  /// Override for [MScaffoldStyle.headerPadding].
  final EdgeInsetsGeometry? headerPadding;

  /// Override for [MScaffoldStyle.footerPadding].
  final EdgeInsetsGeometry? footerPadding;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MScaffoldStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.bodyPadding == bodyPadding &&
        other.headerPadding == headerPadding &&
        other.footerPadding == footerPadding;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        bodyPadding,
        headerPadding,
        footerPadding,
      );
}
