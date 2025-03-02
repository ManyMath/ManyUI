import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MPopover].
///
/// Carries only the popover surface visual — anchor styling lives with the
/// caller's anchor widget, since [MPopover] wraps an arbitrary child.
@immutable
class MPopoverStyle {
  /// Builds a popover style with every field specified.
  const MPopoverStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.padding,
    required this.elevation,
    required this.shadowColor,
    required this.gap,
  });

  /// The fill color of the popover body.
  final Color backgroundColor;

  /// The default text color inside the popover. Applied via a
  /// [DefaultTextStyle] wrapper so caller content inherits it.
  final Color foregroundColor;

  /// The stroke color of the border, or null for no border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels.
  final double borderWidth;

  /// The corner radius of the popover body.
  final BorderRadiusGeometry radius;

  /// Inner padding between the popover's edge and its content.
  final EdgeInsetsGeometry padding;

  /// The drop-shadow blur radius. 0 disables the shadow.
  final double elevation;

  /// The drop-shadow color.
  final Color shadowColor;

  /// The space between the anchor and the popover surface, in logical pixels.
  final double gap;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MPopoverStyle applyDelta(MPopoverStyleDelta? delta) {
    if (delta == null) return this;
    return MPopoverStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      radius: delta.radius ?? radius,
      padding: delta.padding ?? padding,
      elevation: delta.elevation ?? elevation,
      shadowColor: delta.shadowColor ?? shadowColor,
      gap: delta.gap ?? gap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MPopoverStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.gap == gap;
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
        gap,
      );
}

/// A nullable overlay of [MPopoverStyle] fields.
@immutable
class MPopoverStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MPopoverStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.radius,
    this.padding,
    this.elevation,
    this.shadowColor,
    this.gap,
  });

  /// Override for [MPopoverStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MPopoverStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MPopoverStyle.borderColor].
  final Color? borderColor;

  /// Override for [MPopoverStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MPopoverStyle.radius].
  final BorderRadiusGeometry? radius;

  /// Override for [MPopoverStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MPopoverStyle.elevation].
  final double? elevation;

  /// Override for [MPopoverStyle.shadowColor].
  final Color? shadowColor;

  /// Override for [MPopoverStyle.gap].
  final double? gap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MPopoverStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.gap == gap;
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
        gap,
      );
}
