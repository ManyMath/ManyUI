import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MDialog].
///
/// Carries the dialog surface visual *and* the scrim that sits behind it.
/// v0.1 keeps the scrim color inline rather than adding a `colors.scrim` token
/// to [MColorScheme] — MDialog and MSheet are the only consumers and the
/// shadcn token list stays minimal.
@immutable
class MDialogStyle {
  /// Builds a dialog style with every field specified.
  const MDialogStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.padding,
    required this.elevation,
    required this.shadowColor,
    required this.scrimColor,
    required this.maxWidth,
  });

  /// The fill color of the dialog body.
  final Color backgroundColor;

  /// The default text color inside the dialog. Applied via a
  /// [DefaultTextStyle] wrapper so caller content inherits it.
  final Color foregroundColor;

  /// The stroke color of the border, or null for no border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels.
  final double borderWidth;

  /// The corner radius of the dialog body.
  final BorderRadiusGeometry radius;

  /// Inner padding between the dialog's edge and its content.
  final EdgeInsetsGeometry padding;

  /// The drop-shadow blur radius. 0 disables the shadow.
  final double elevation;

  /// The drop-shadow color.
  final Color shadowColor;

  /// The full-screen scrim color rendered behind the dialog.
  final Color scrimColor;

  /// The maximum width the dialog body is allowed to take. Content narrower
  /// than this sizes naturally; wider content is clamped.
  final double maxWidth;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MDialogStyle applyDelta(MDialogStyleDelta? delta) {
    if (delta == null) return this;
    return MDialogStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      radius: delta.radius ?? radius,
      padding: delta.padding ?? padding,
      elevation: delta.elevation ?? elevation,
      shadowColor: delta.shadowColor ?? shadowColor,
      scrimColor: delta.scrimColor ?? scrimColor,
      maxWidth: delta.maxWidth ?? maxWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MDialogStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.scrimColor == scrimColor &&
        other.maxWidth == maxWidth;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        radius,
        padding,
        elevation,
        shadowColor,
        scrimColor,
        maxWidth,
      );
}

/// A nullable overlay of [MDialogStyle] fields.
@immutable
class MDialogStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MDialogStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.radius,
    this.padding,
    this.elevation,
    this.shadowColor,
    this.scrimColor,
    this.maxWidth,
  });

  /// Override for [MDialogStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MDialogStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MDialogStyle.borderColor].
  final Color? borderColor;

  /// Override for [MDialogStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MDialogStyle.radius].
  final BorderRadiusGeometry? radius;

  /// Override for [MDialogStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MDialogStyle.elevation].
  final double? elevation;

  /// Override for [MDialogStyle.shadowColor].
  final Color? shadowColor;

  /// Override for [MDialogStyle.scrimColor].
  final Color? scrimColor;

  /// Override for [MDialogStyle.maxWidth].
  final double? maxWidth;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MDialogStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.scrimColor == scrimColor &&
        other.maxWidth == maxWidth;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        radius,
        padding,
        elevation,
        shadowColor,
        scrimColor,
        maxWidth,
      );
}
