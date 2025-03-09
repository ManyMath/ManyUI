import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MSheet].
///
/// Like [MDialogStyle], the sheet style carries both the surface visual and
/// the scrim color rendered behind it. v0.1 keeps the scrim color inline
/// rather than adding a `colors.scrim` token to [MColorScheme] — MDialog and
/// MSheet are the only consumers and the shadcn token list stays minimal.
///
/// Side anchors ([MSheetAnchor.start], [MSheetAnchor.end]) use [sideWidth]
/// for their cross-axis size. Bottom anchors size to the viewport's full
/// width and use [maxHeightFraction] to cap their vertical extent.
@immutable
class MSheetStyle {
  /// Builds a sheet style with every field specified.
  const MSheetStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.padding,
    required this.elevation,
    required this.shadowColor,
    required this.scrimColor,
    required this.sideWidth,
    required this.maxHeightFraction,
    required this.dragHandleColor,
  });

  /// The fill color of the sheet body.
  final Color backgroundColor;

  /// The default text color inside the sheet. Applied via a
  /// [DefaultTextStyle] wrapper so caller content inherits it.
  final Color foregroundColor;

  /// The stroke color of the leading border (the edge the sheet abuts the
  /// app from), or null for no border. Bottom sheets paint a top border;
  /// start sheets paint a right border; end sheets paint a left border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels.
  final double borderWidth;

  /// The corner radius of the sheet body. Bottom sheets round the top
  /// corners only; side sheets round the inboard corners only.
  final BorderRadiusGeometry radius;

  /// Inner padding between the sheet's edge and its content.
  final EdgeInsetsGeometry padding;

  /// The drop-shadow blur radius. 0 disables the shadow.
  final double elevation;

  /// The drop-shadow color.
  final Color shadowColor;

  /// The full-screen scrim color rendered behind the sheet.
  final Color scrimColor;

  /// Cross-axis size used by side anchors ([MSheetAnchor.start],
  /// [MSheetAnchor.end]). Ignored by [MSheetAnchor.bottom], which is always
  /// full-width.
  final double sideWidth;

  /// The maximum vertical extent of a bottom sheet, expressed as a fraction
  /// of the viewport height. Ignored by side anchors, which are full-height.
  final double maxHeightFraction;

  /// The fill color of the drag handle painted at the leading edge of a
  /// bottom sheet under touch modality.
  final Color dragHandleColor;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MSheetStyle applyDelta(MSheetStyleDelta? delta) {
    if (delta == null) return this;
    return MSheetStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      radius: delta.radius ?? radius,
      padding: delta.padding ?? padding,
      elevation: delta.elevation ?? elevation,
      shadowColor: delta.shadowColor ?? shadowColor,
      scrimColor: delta.scrimColor ?? scrimColor,
      sideWidth: delta.sideWidth ?? sideWidth,
      maxHeightFraction: delta.maxHeightFraction ?? maxHeightFraction,
      dragHandleColor: delta.dragHandleColor ?? dragHandleColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MSheetStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.scrimColor == scrimColor &&
        other.sideWidth == sideWidth &&
        other.maxHeightFraction == maxHeightFraction &&
        other.dragHandleColor == dragHandleColor;
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
        sideWidth,
        maxHeightFraction,
        dragHandleColor,
      );
}

/// A nullable overlay of [MSheetStyle] fields.
@immutable
class MSheetStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MSheetStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.radius,
    this.padding,
    this.elevation,
    this.shadowColor,
    this.scrimColor,
    this.sideWidth,
    this.maxHeightFraction,
    this.dragHandleColor,
  });

  /// Override for [MSheetStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MSheetStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MSheetStyle.borderColor].
  final Color? borderColor;

  /// Override for [MSheetStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MSheetStyle.radius].
  final BorderRadiusGeometry? radius;

  /// Override for [MSheetStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MSheetStyle.elevation].
  final double? elevation;

  /// Override for [MSheetStyle.shadowColor].
  final Color? shadowColor;

  /// Override for [MSheetStyle.scrimColor].
  final Color? scrimColor;

  /// Override for [MSheetStyle.sideWidth].
  final double? sideWidth;

  /// Override for [MSheetStyle.maxHeightFraction].
  final double? maxHeightFraction;

  /// Override for [MSheetStyle.dragHandleColor].
  final Color? dragHandleColor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MSheetStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.scrimColor == scrimColor &&
        other.sideWidth == sideWidth &&
        other.maxHeightFraction == maxHeightFraction &&
        other.dragHandleColor == dragHandleColor;
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
        sideWidth,
        maxHeightFraction,
        dragHandleColor,
      );
}
