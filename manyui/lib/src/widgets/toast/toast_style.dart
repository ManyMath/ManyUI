import 'package:flutter/widgets.dart';

/// Where on the viewport an [MToast] stack anchors itself.
///
/// Defaults differ by modality in practice, but the route doesn't pick for
/// you — `showMToast` exposes the anchor so the caller decides.
enum MToastAnchor {
  /// Stack hugs the top-start corner; new toasts shift existing ones downward.
  topStart,

  /// Stack hugs the top-end corner; new toasts shift existing ones downward.
  topEnd,

  /// Stack hugs the bottom-start corner; new toasts shift existing ones
  /// upward.
  bottomStart,

  /// Stack hugs the bottom-end corner; new toasts shift existing ones upward.
  bottomEnd,
}

/// The fully-resolved visual style for an [MToast].
///
/// Toasts have no scrim. The shadcn token list stays minimal — same call as
/// MDialog/MSheet (both inline `Color(0x80000000)` for their scrims).
@immutable
class MToastStyle {
  /// Builds a toast style with every field specified.
  const MToastStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.padding,
    required this.elevation,
    required this.shadowColor,
    required this.maxWidth,
    required this.edgeInset,
    required this.gap,
  });

  /// The fill color of the toast body.
  final Color backgroundColor;

  /// The default text color inside the toast. Applied via a [DefaultTextStyle]
  /// wrapper so caller content inherits it.
  final Color foregroundColor;

  /// The stroke color of the border, or null for no border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels.
  final double borderWidth;

  /// The corner radius of the toast body.
  final BorderRadiusGeometry radius;

  /// Inner padding between the toast's edge and its content.
  final EdgeInsetsGeometry padding;

  /// The drop-shadow blur radius. 0 disables the shadow.
  final double elevation;

  /// The drop-shadow color.
  final Color shadowColor;

  /// The maximum width the toast body is allowed to take. Content narrower
  /// than this sizes naturally; wider content is clamped.
  final double maxWidth;

  /// The inset from the anchored viewport edge in logical pixels.
  final double edgeInset;

  /// Vertical gap between stacked toasts in logical pixels.
  final double gap;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MToastStyle applyDelta(MToastStyleDelta? delta) {
    if (delta == null) return this;
    return MToastStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      radius: delta.radius ?? radius,
      padding: delta.padding ?? padding,
      elevation: delta.elevation ?? elevation,
      shadowColor: delta.shadowColor ?? shadowColor,
      maxWidth: delta.maxWidth ?? maxWidth,
      edgeInset: delta.edgeInset ?? edgeInset,
      gap: delta.gap ?? gap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MToastStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.maxWidth == maxWidth &&
        other.edgeInset == edgeInset &&
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
        maxWidth,
        edgeInset,
        gap,
      );
}

/// A nullable overlay of [MToastStyle] fields.
@immutable
class MToastStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MToastStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.radius,
    this.padding,
    this.elevation,
    this.shadowColor,
    this.maxWidth,
    this.edgeInset,
    this.gap,
  });

  /// Override for [MToastStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MToastStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MToastStyle.borderColor].
  final Color? borderColor;

  /// Override for [MToastStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MToastStyle.radius].
  final BorderRadiusGeometry? radius;

  /// Override for [MToastStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MToastStyle.elevation].
  final double? elevation;

  /// Override for [MToastStyle.shadowColor].
  final Color? shadowColor;

  /// Override for [MToastStyle.maxWidth].
  final double? maxWidth;

  /// Override for [MToastStyle.edgeInset].
  final double? edgeInset;

  /// Override for [MToastStyle.gap].
  final double? gap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MToastStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.maxWidth == maxWidth &&
        other.edgeInset == edgeInset &&
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
        maxWidth,
        edgeInset,
        gap,
      );
}
