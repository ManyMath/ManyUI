import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import '../button/button.dart';
import '../button/button_style.dart';
import '../icon/icon.dart';
import '../icon/icon_data.dart';
import '../tooltip/tooltip.dart';
import '../tooltip/tooltip_style.dart';

/// A square, tooltip-backed icon action.
///
/// Use this for familiar toolbar commands where a text label would add noise.
/// [label] is always exposed to assistive technology and shown as a tooltip
/// for pointer and long-press users.
class MIconButton extends StatelessWidget {
  /// Builds an icon button.
  const MIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.onLongPress,
    this.variant = MButtonVariant.ghost,
    this.size = MButtonSize.md,
    this.modality,
    this.autofocus = false,
    this.focusNode,
    this.tooltipPlacement = MTooltipPlacement.above,
    super.key,
  });

  /// Glyph displayed by the button.
  final MIconData icon;

  /// Accessible name and tooltip copy.
  final String label;

  /// Called when the button is activated.
  final VoidCallback? onPressed;

  /// Called on long press.
  final VoidCallback? onLongPress;

  /// Button color treatment.
  final MButtonVariant variant;

  /// Button hit-target scale.
  final MButtonSize size;

  /// Optional input modality override.
  final MInputModality? modality;

  /// Whether the control requests focus on first build.
  final bool autofocus;

  /// Optional caller-owned focus node.
  final FocusNode? focusNode;

  /// Preferred tooltip placement.
  final MTooltipPlacement tooltipPlacement;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality = MInputModalityScope.resolve(
      context,
      modality,
    );
    final MButtonStyle resolved = theme.button.resolve(
      variant: variant,
      size: size,
      modality: resolvedModality,
      colors: theme.colors,
      typography: theme.typography.inheritFromContext(context),
      radius: theme.radius,
    );
    final double edge = resolved.minHeight;
    final double iconSize = switch (size) {
      MButtonSize.xs => 14,
      MButtonSize.sm => 16,
      MButtonSize.md => 18,
      MButtonSize.lg => 20,
    };

    return MTooltip(
      message: label,
      placement: tooltipPlacement,
      enabled: onPressed != null || onLongPress != null,
      modality: resolvedModality,
      child: MButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        variant: variant,
        size: size,
        modality: resolvedModality,
        style: const MButtonStyleDelta(padding: EdgeInsets.zero),
        semanticLabel: label,
        autofocus: autofocus,
        focusNode: focusNode,
        child: SizedBox.square(
          dimension: edge,
          child: Center(
            child: MIcon(icon, size: iconSize, excludeFromSemantics: true),
          ),
        ),
      ),
    );
  }
}
