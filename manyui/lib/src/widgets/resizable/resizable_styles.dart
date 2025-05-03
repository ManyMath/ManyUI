import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import 'resizable_style.dart';

/// The resolution table for [MResizable].
///
/// Lives on `MThemeData.resizable`. Touch modality bumps the handle's visible
/// and hit thickness for easier grabbing on fingertip-driven surfaces.
///
/// ```dart
/// final MResizableStyle style = theme.resizable.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
/// );
/// ```
@immutable
class MResizableStyles {
  /// Builds a styles table.
  const MResizableStyles();

  /// Returns the resolved [MResizableStyle] under [modality] and [colors].
  MResizableStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
  }) {
    final bool touch = modality == MInputModality.touch;

    return MResizableStyle(
      handleColor: colors.border,
      handleHoveredColor: colors.foreground.withValues(alpha: 0.4),
      handleActiveColor: colors.primary,
      handleThickness: touch ? 8 : 4,
      handleHitThickness: touch ? 24 : 12,
      gripColor: colors.mutedForeground,
      gripLength: 16,
      gripStrokeWidth: 1.4,
      showGripIndicator: true,
      keyboardStep: 0.05,
      keyboardFineStep: 0.01,
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MResizableStyles;

  @override
  int get hashCode => (MResizableStyles).hashCode;
}
