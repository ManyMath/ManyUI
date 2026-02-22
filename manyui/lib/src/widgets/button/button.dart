import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../foundation/pressable.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'button_style.dart';

/// A pressable surface with a label.
///
/// Callback-driven, no controller. Variant picks a color role; size picks
/// hit-target and padding; modality adjusts hit-target generosity.
/// Null callbacks renders the button disabled.
///
/// ```dart
/// MButton(
///   onPressed: () => print('hi'),
///   variant: MButtonVariant.primary,
///   size: MButtonSize.md,
///   child: const Text('Submit'),
/// )
/// ```
class MButton extends StatelessWidget {
  /// Builds a button.
  const MButton({
    this.onPressed,
    this.onLongPress,
    this.variant = MButtonVariant.primary,
    this.size = MButtonSize.md,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    required this.child,
    super.key,
  });

  /// Called on tap, Enter, or Space. When null (with null [onLongPress])
  /// the button is disabled.
  final VoidCallback? onPressed;

  /// Called on long-press. Optional; mainly useful on touch modality.
  final VoidCallback? onLongPress;

  /// The visual variant. Defaults to [MButtonVariant.primary].
  final MButtonVariant variant;

  /// The hit-target and padding scale. Defaults to [MButtonSize.md].
  final MButtonSize size;

  /// Input modality for sizing and behavior. Resolved from scope when null.
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MButtonStyle].
  final MButtonStyleDelta? style;

  /// Accessibility label. Defaults to the child's semantic text.
  /// Set for icon-only buttons.
  final String? semanticLabel;

  /// Request focus on first build.
  final bool autofocus;

  /// Caller-owned focus node. Widget creates its own when null.
  final FocusNode? focusNode;

  /// The button's content -- text, icon, or combination.
  final Widget child;

  /// Whether this button is enabled (has at least one callback wired).
  bool get _enabled => onPressed != null || onLongPress != null;

  @override
  Widget build(BuildContext context) {
    return MPressable(
      onPressed: onPressed,
      onLongPress: onLongPress,
      modality: modality,
      autofocus: autofocus,
      focusNode: focusNode,
      builder: (BuildContext context, MPressableStates states) {
        final MThemeData theme = MTheme.of(context);
        final MButtonStyle baseStyle = theme.button.resolve(
          variant: variant,
          size: size,
          modality: states.modality,
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        );
        final MButtonStyle resolved = baseStyle.applyDelta(style);

        final Color background = states.hovered
            ? resolved.hoverBackgroundColor
            : resolved.backgroundColor;

        Widget labelContent = DefaultTextStyle.merge(
          style: resolved.textStyle.copyWith(color: resolved.foregroundColor),
          child: IconTheme.merge(
            data: IconThemeData(color: resolved.foregroundColor),
            child: child,
          ),
        );
        if (semanticLabel != null) {
          labelContent = Semantics(
            label: semanticLabel,
            excludeSemantics: true,
            child: labelContent,
          );
        }
        final Widget label = labelContent;

        Widget surface = ConstrainedBox(
          constraints: BoxConstraints(minHeight: resolved.minHeight),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: resolved.radius,
              border: resolved.borderColor != null
                  ? Border.all(
                      color: resolved.borderColor!,
                      width: resolved.borderWidth,
                    )
                  : null,
            ),
            child: Padding(
              padding: resolved.padding,
              child: Align(
                alignment: Alignment.center,
                widthFactor: 1,
                heightFactor: 1,
                child: label,
              ),
            ),
          ),
        );

        if (!_enabled) {
          surface = Opacity(opacity: 0.5, child: surface);
        }

        return surface;
      },
    );
  }
}
