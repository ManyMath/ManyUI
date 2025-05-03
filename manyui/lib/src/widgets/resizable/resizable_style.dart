import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MResizable].
///
/// Every field is required. Build by hand for advanced theming, or let the
/// theme resolve one via `theme.resizable.resolve(...)` and tweak through an
/// [MResizableStyleDelta].
@immutable
class MResizableStyle {
  /// Builds a resizable style with every field specified.
  const MResizableStyle({
    required this.handleColor,
    required this.handleHoveredColor,
    required this.handleActiveColor,
    required this.handleThickness,
    required this.handleHitThickness,
    required this.gripColor,
    required this.gripLength,
    required this.gripStrokeWidth,
    required this.showGripIndicator,
    required this.keyboardStep,
    required this.keyboardFineStep,
    required this.disabledOpacity,
  });

  /// Fill color of the visible handle stroke at rest.
  final Color handleColor;

  /// Fill color of the visible handle stroke while a pointer is hovering it.
  final Color handleHoveredColor;

  /// Fill color of the visible handle stroke while it is being dragged.
  final Color handleActiveColor;

  /// Visible thickness of the handle along its cross axis, in logical pixels.
  final double handleThickness;

  /// Hit-test thickness of the handle along its cross axis, in logical pixels.
  /// Always >= [handleThickness]. Touch modality bumps this.
  final double handleHitThickness;

  /// Stroke color of the optional grip indicator drawn at the center of each
  /// handle.
  final Color gripColor;

  /// Length of the grip indicator along the main axis of the handle, in
  /// logical pixels.
  final double gripLength;

  /// Stroke width of the grip indicator, in logical pixels.
  final double gripStrokeWidth;

  /// Whether to render the grip indicator.
  final bool showGripIndicator;

  /// Fraction of available space a single arrow-key press shifts a handle by.
  final double keyboardStep;

  /// Fraction of available space a Shift+arrow press shifts a handle by.
  final double keyboardFineStep;

  /// Opacity multiplier applied when the resizable is disabled.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MResizableStyle applyDelta(MResizableStyleDelta? delta) {
    if (delta == null) return this;
    return MResizableStyle(
      handleColor: delta.handleColor ?? handleColor,
      handleHoveredColor: delta.handleHoveredColor ?? handleHoveredColor,
      handleActiveColor: delta.handleActiveColor ?? handleActiveColor,
      handleThickness: delta.handleThickness ?? handleThickness,
      handleHitThickness: delta.handleHitThickness ?? handleHitThickness,
      gripColor: delta.gripColor ?? gripColor,
      gripLength: delta.gripLength ?? gripLength,
      gripStrokeWidth: delta.gripStrokeWidth ?? gripStrokeWidth,
      showGripIndicator: delta.showGripIndicator ?? showGripIndicator,
      keyboardStep: delta.keyboardStep ?? keyboardStep,
      keyboardFineStep: delta.keyboardFineStep ?? keyboardFineStep,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MResizableStyle &&
        other.handleColor == handleColor &&
        other.handleHoveredColor == handleHoveredColor &&
        other.handleActiveColor == handleActiveColor &&
        other.handleThickness == handleThickness &&
        other.handleHitThickness == handleHitThickness &&
        other.gripColor == gripColor &&
        other.gripLength == gripLength &&
        other.gripStrokeWidth == gripStrokeWidth &&
        other.showGripIndicator == showGripIndicator &&
        other.keyboardStep == keyboardStep &&
        other.keyboardFineStep == keyboardFineStep &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        handleColor,
        handleHoveredColor,
        handleActiveColor,
        handleThickness,
        handleHitThickness,
        gripColor,
        gripLength,
        gripStrokeWidth,
        showGripIndicator,
        keyboardStep,
        keyboardFineStep,
        disabledOpacity,
      ]);
}

/// A nullable overlay of [MResizableStyle] fields.
///
/// Pass an instance into `MResizable(style: ...)` to override individual
/// fields of the theme-resolved style. Any field left null keeps the theme
/// value.
@immutable
class MResizableStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null and
  /// pass through the underlying style unchanged.
  const MResizableStyleDelta({
    this.handleColor,
    this.handleHoveredColor,
    this.handleActiveColor,
    this.handleThickness,
    this.handleHitThickness,
    this.gripColor,
    this.gripLength,
    this.gripStrokeWidth,
    this.showGripIndicator,
    this.keyboardStep,
    this.keyboardFineStep,
    this.disabledOpacity,
  });

  /// Override for [MResizableStyle.handleColor].
  final Color? handleColor;

  /// Override for [MResizableStyle.handleHoveredColor].
  final Color? handleHoveredColor;

  /// Override for [MResizableStyle.handleActiveColor].
  final Color? handleActiveColor;

  /// Override for [MResizableStyle.handleThickness].
  final double? handleThickness;

  /// Override for [MResizableStyle.handleHitThickness].
  final double? handleHitThickness;

  /// Override for [MResizableStyle.gripColor].
  final Color? gripColor;

  /// Override for [MResizableStyle.gripLength].
  final double? gripLength;

  /// Override for [MResizableStyle.gripStrokeWidth].
  final double? gripStrokeWidth;

  /// Override for [MResizableStyle.showGripIndicator].
  final bool? showGripIndicator;

  /// Override for [MResizableStyle.keyboardStep].
  final double? keyboardStep;

  /// Override for [MResizableStyle.keyboardFineStep].
  final double? keyboardFineStep;

  /// Override for [MResizableStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MResizableStyleDelta &&
        other.handleColor == handleColor &&
        other.handleHoveredColor == handleHoveredColor &&
        other.handleActiveColor == handleActiveColor &&
        other.handleThickness == handleThickness &&
        other.handleHitThickness == handleHitThickness &&
        other.gripColor == gripColor &&
        other.gripLength == gripLength &&
        other.gripStrokeWidth == gripStrokeWidth &&
        other.showGripIndicator == showGripIndicator &&
        other.keyboardStep == keyboardStep &&
        other.keyboardFineStep == keyboardFineStep &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        handleColor,
        handleHoveredColor,
        handleActiveColor,
        handleThickness,
        handleHitThickness,
        gripColor,
        gripLength,
        gripStrokeWidth,
        showGripIndicator,
        keyboardStep,
        keyboardFineStep,
        disabledOpacity,
      ]);
}
