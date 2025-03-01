import 'package:flutter/widgets.dart';

/// Where the tooltip's surface sits relative to its anchor.
///
/// v0.1 ships two placements. The popover is positioned via
/// `CompositedTransformFollower` and does not auto-flip when it would
/// overflow the viewport.
enum MTooltipPlacement {
  /// Above the anchor, separated by `gap` logical pixels.
  above,

  /// Below the anchor, separated by `gap` logical pixels.
  below,
}

/// The fully-resolved visual style for an [MTooltip].
@immutable
class MTooltipStyle {
  /// Builds a tooltip style with every field specified.
  const MTooltipStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.padding,
    required this.textStyle,
    required this.radius,
    required this.elevation,
    required this.shadowColor,
    required this.gap,
    required this.maxWidth,
    required this.showDelay,
    required this.hideDelay,
  });

  /// The fill color of the tooltip body.
  final Color backgroundColor;

  /// The text color inside the tooltip.
  final Color foregroundColor;

  /// The stroke color of the border, or null for no border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels.
  final double borderWidth;

  /// The padding between the tooltip's edge and its label.
  final EdgeInsetsGeometry padding;

  /// The text style applied to the tooltip's label.
  final TextStyle textStyle;

  /// The corner radius of the tooltip body.
  final BorderRadiusGeometry radius;

  /// The drop-shadow blur radius. 0 disables the shadow.
  final double elevation;

  /// The drop-shadow color.
  final Color shadowColor;

  /// The space between the anchor and the tooltip surface, in logical pixels.
  final double gap;

  /// An upper bound on the tooltip's width. Long labels wrap rather than
  /// extend off-screen.
  final double maxWidth;

  /// How long the pointer must hover (or how long after focus) before the
  /// tooltip shows on mouse modality.
  final Duration showDelay;

  /// How long after pointer-exit the tooltip waits before hiding. A small
  /// value lets users move from anchor to tooltip without losing it.
  final Duration hideDelay;

  /// Returns a copy with [delta]'s non-null fields overlaid on top.
  MTooltipStyle applyDelta(MTooltipStyleDelta? delta) {
    if (delta == null) return this;
    return MTooltipStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      padding: delta.padding ?? padding,
      textStyle: delta.textStyle ?? textStyle,
      radius: delta.radius ?? radius,
      elevation: delta.elevation ?? elevation,
      shadowColor: delta.shadowColor ?? shadowColor,
      gap: delta.gap ?? gap,
      maxWidth: delta.maxWidth ?? maxWidth,
      showDelay: delta.showDelay ?? showDelay,
      hideDelay: delta.hideDelay ?? hideDelay,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MTooltipStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.radius == radius &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.gap == gap &&
        other.maxWidth == maxWidth &&
        other.showDelay == showDelay &&
        other.hideDelay == hideDelay;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        padding,
        textStyle,
        radius,
        elevation,
        shadowColor,
        gap,
        maxWidth,
        showDelay,
        hideDelay,
      );
}

/// A nullable overlay of [MTooltipStyle] fields.
@immutable
class MTooltipStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MTooltipStyleDelta({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.textStyle,
    this.radius,
    this.elevation,
    this.shadowColor,
    this.gap,
    this.maxWidth,
    this.showDelay,
    this.hideDelay,
  });

  /// Override for [MTooltipStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MTooltipStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MTooltipStyle.borderColor].
  final Color? borderColor;

  /// Override for [MTooltipStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MTooltipStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MTooltipStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MTooltipStyle.radius].
  final BorderRadiusGeometry? radius;

  /// Override for [MTooltipStyle.elevation].
  final double? elevation;

  /// Override for [MTooltipStyle.shadowColor].
  final Color? shadowColor;

  /// Override for [MTooltipStyle.gap].
  final double? gap;

  /// Override for [MTooltipStyle.maxWidth].
  final double? maxWidth;

  /// Override for [MTooltipStyle.showDelay].
  final Duration? showDelay;

  /// Override for [MTooltipStyle.hideDelay].
  final Duration? hideDelay;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MTooltipStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.radius == radius &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.gap == gap &&
        other.maxWidth == maxWidth &&
        other.showDelay == showDelay &&
        other.hideDelay == hideDelay;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        padding,
        textStyle,
        radius,
        elevation,
        shadowColor,
        gap,
        maxWidth,
        showDelay,
        hideDelay,
      );
}
