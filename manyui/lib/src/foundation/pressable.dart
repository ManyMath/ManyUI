import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/focus_ring_style.dart';
import 'focus_ring.dart';
import 'input_modality.dart';

/// Interaction state passed to [MPressable.builder].
///
/// All flags are false when the pressable is disabled (no callbacks wired);
/// only [disabled] is true and [modality] still reflects the resolved mode.
///
/// ```dart
/// MPressable(
///   onPressed: () {},
///   builder: (context, states) => ColoredBox(
///     color: states.hovered ? Colors.blue : Colors.grey,
///     child: const Text('Press me'),
///   ),
/// )
/// ```
@immutable
class MPressableStates {
  /// Creates an immutable snapshot of a pressable's interaction state.
  const MPressableStates({
    required this.hovered,
    required this.focused,
    required this.pressed,
    required this.disabled,
    required this.modality,
  });

  /// True only on a hover-capable modality (mouse/stylus) while enabled.
  final bool hovered;

  /// Keyboard or programmatic focus highlight is showing.
  final bool focused;

  /// A pointer is currently down on the surface.
  final bool pressed;

  /// No callbacks are wired, so the pressable does not respond to input.
  final bool disabled;

  /// The resolved input modality driving this pressable.
  final MInputModality modality;

  @override
  bool operator ==(Object other) =>
      other is MPressableStates &&
      other.hovered == hovered &&
      other.focused == focused &&
      other.pressed == pressed &&
      other.disabled == disabled &&
      other.modality == modality;

  @override
  int get hashCode =>
      Object.hash(hovered, focused, pressed, disabled, modality);
}

/// A bare interaction primitive: hover, focus, press, keyboard activation,
/// modality-aware cursor and a focus ring, with no opinion on visuals.
///
/// The [builder] decides how to render each [MPressableStates]. This is the
/// shared foundation [MButton] and interactive surfaces (cards, list tiles)
/// build on, so a whole-surface link or pressable card needs no detector
/// boilerplate of its own.
///
/// The pressable is enabled when at least one of [onPressed] or [onLongPress]
/// is non-null. When disabled it takes no focus, shows the basic cursor, and
/// reports `states.disabled == true`.
///
/// ```dart
/// MPressable(
///   onPressed: () => open(uri),
///   semanticLabel: 'survey',
///   builder: (context, states) {
///     final highlighted = states.hovered || states.focused;
///     return MCard(
///       style: highlighted
///           ? MCardStyleDelta(borderColor: theme.colors.ring)
///           : null,
///       child: child,
///     );
///   },
/// )
/// ```
class MPressable extends StatefulWidget {
  /// Builds an interaction primitive whose visuals come from [builder].
  const MPressable({
    this.onPressed,
    this.onLongPress,
    this.modality,
    this.autofocus = false,
    this.focusNode,
    this.mouseCursor,
    this.semanticLabel,
    this.semanticButton = true,
    this.includeFocusRing = true,
    this.focusRingStyle,
    required this.builder,
    super.key,
  });

  /// Called on tap, Enter, NumpadEnter, or Space. When null (with null
  /// [onLongPress]) the pressable is disabled.
  final VoidCallback? onPressed;

  /// Called on long-press. Optional; mainly useful on touch modality.
  final VoidCallback? onLongPress;

  /// Input modality override. Resolved from the nearest
  /// [MInputModalityScope] when null.
  final MInputModality? modality;

  /// Request focus on first build.
  final bool autofocus;

  /// Caller-owned focus node. Widget creates its own when null.
  final FocusNode? focusNode;

  /// The cursor shown over the surface. Defaults to
  /// [SystemMouseCursors.click] when enabled, [SystemMouseCursors.basic]
  /// when disabled.
  final MouseCursor? mouseCursor;

  /// Accessibility label announced for the surface.
  final String? semanticLabel;

  /// Whether the surface is announced as a button. Defaults to true.
  final bool semanticButton;

  /// Whether to wrap [builder]'s output in an [MFocusRing] driven by the
  /// focus highlight. Defaults to true.
  final bool includeFocusRing;

  /// Shape overrides passed through to the [MFocusRing].
  final MFocusRingStyle? focusRingStyle;

  /// Builds the visual surface for the current [MPressableStates].
  final Widget Function(BuildContext context, MPressableStates states) builder;

  /// Whether this pressable is enabled (has at least one callback wired).
  bool get _enabled => onPressed != null || onLongPress != null;

  @override
  State<MPressable> createState() => _MPressableState();
}

class _MPressableState extends State<MPressable> {
  bool _focused = false;
  bool _hovered = false;
  bool _pressed = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onPressed?.call();
        return null;
      },
    ),
  };

  void _onShowFocus(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  void _onShowHover(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget._enabled;
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
    final bool hoverCapable = resolvedModality == MInputModality.mouse ||
        resolvedModality == MInputModality.stylus;

    final MPressableStates states = MPressableStates(
      hovered: enabled && hoverCapable && _hovered,
      focused: enabled && _focused,
      pressed: enabled && _pressed,
      disabled: !enabled,
      modality: resolvedModality,
    );

    Widget surface = widget.builder(context, states);

    if (widget.includeFocusRing) {
      surface = MFocusRing(
        focused: _focused,
        style: widget.focusRingStyle,
        child: surface,
      );
    }

    final Widget detector = FocusableActionDetector(
      enabled: enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onShowFocusHighlight: _onShowFocus,
      onShowHoverHighlight: _onShowHover,
      mouseCursor: widget.mouseCursor ??
          (enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: _actions,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? widget.onPressed : null,
        onLongPress: enabled ? widget.onLongPress : null,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        child: surface,
      ),
    );

    return Semantics(
      button: widget.semanticButton,
      enabled: enabled,
      label: widget.semanticLabel,
      container: true,
      child: detector,
    );
  }
}
