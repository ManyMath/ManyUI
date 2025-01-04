import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'radio_style.dart';

/// A mutually-exclusive selection control rendered as a small circle with an
/// inner dot when selected.
///
/// `MRadio<T>` is always paired with an ancestor [MRadioGroup] of the same
/// `T`. The group holds the shared [MController] of type `T?` — each radio
/// reads `selected == (group.value == widget.value)` and writes
/// `widget.value` back into the group on activation.
///
/// ```dart
/// MRadioGroup<String>(
///   initialValue: 'a',
///   onChanged: (String? v) => print('picked $v'),
///   child: Row(children: const <Widget>[
///     MRadio<String>(value: 'a'),
///     SizedBox(width: 12),
///     MRadio<String>(value: 'b'),
///   ]),
/// )
/// ```
///
/// Set [enabled] to `false` to render a single radio as non-interactive even
/// when the group is enabled. Disabling the group disables every descendant
/// radio.
class MRadio<T> extends StatefulWidget {
  /// Builds a radio bound to a [value] within the ancestor [MRadioGroup].
  const MRadio({
    required this.value,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// The value this radio writes into the group's controller when selected.
  final T value;

  /// Whether this individual radio responds to user interaction.
  ///
  /// Disabled radios dim their surface and ignore taps and keyboard
  /// activation. They still report their checked state through semantics so
  /// screen readers can announce the group's selection.
  final bool enabled;

  /// The input modality this radio should size itself for.
  ///
  /// When null, the radio resolves modality from
  /// [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MRadioStyle].
  final MRadioStyleDelta? style;

  /// An optional accessibility label for this individual option.
  ///
  /// Pair with an `MLabel` (Phase 7+) for visible labels.
  final String? semanticLabel;

  /// Whether this radio should request focus on first build.
  final bool autofocus;

  /// An optional [FocusNode] the caller owns.
  ///
  /// When null, the radio creates and disposes its own node.
  final FocusNode? focusNode;

  @override
  State<MRadio<T>> createState() => _MRadioState<T>();
}

class _MRadioState<T> extends State<MRadio<T>> {
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        _activate();
        return null;
      },
    ),
  };

  _MRadioGroupScope<T>? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _MRadioGroupScope<T>? next = context
        .dependOnInheritedWidgetOfExactType<_MRadioGroupScope<T>>();
    assert(
      next != null,
      'MRadio<$T> must be a descendant of MRadioGroup<$T>.',
    );
    if (!identical(_scope, next)) {
      _scope?.controller.removeListener(_onGroupChanged);
      _scope = next;
      _scope?.controller.addListener(_onGroupChanged);
    }
  }

  void _onGroupChanged() {
    if (mounted) setState(() {});
  }

  void _activate() {
    final _MRadioGroupScope<T>? scope = _scope;
    if (scope == null) return;
    if (!_effectiveEnabled) return;
    if (scope.controller.value == widget.value) return;
    scope.controller.value = widget.value;
    scope.onChanged?.call(widget.value);
  }

  void _onShowFocus(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  bool get _effectiveEnabled =>
      widget.enabled && (_scope?.enabled ?? true);

  @override
  void dispose() {
    _scope?.controller.removeListener(_onGroupChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);

    final MRadioStyle resolved = theme.radio
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
        )
        .applyDelta(widget.style);

    final bool selected = _scope?.controller.value == widget.value;
    final bool enabled = _effectiveEnabled;

    Widget circle = SizedBox(
      width: resolved.size,
      height: resolved.size,
      child: CustomPaint(
        painter: _RadioPainter(
          selected: selected,
          size: resolved.size,
          borderColor: resolved.borderColor,
          borderWidth: resolved.borderWidth,
          uncheckedBackground: resolved.uncheckedBackgroundColor,
          checkedBackground: resolved.checkedBackgroundColor,
          dotColor: resolved.dotColor,
          dotDiameter: resolved.dotDiameter,
        ),
      ),
    );

    if (!enabled) {
      circle = Opacity(opacity: resolved.disabledOpacity, child: circle);
    }

    circle = MFocusRing(focused: _focused, child: circle);

    final Widget detector = FocusableActionDetector(
      enabled: enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onShowFocusHighlight: _onShowFocus,
      mouseCursor: enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: _actions,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? _activate : null,
        child: circle,
      ),
    );

    return Semantics(
      checked: selected,
      enabled: enabled,
      inMutuallyExclusiveGroup: true,
      label: widget.semanticLabel,
      container: true,
      child: detector,
    );
  }
}

/// Groups [MRadio]s of type `T` so they share a single mutually-exclusive
/// selection.
///
/// The group owns an `MController<T?>` (nullable so "no selection" is
/// representable). Callers may supply [controller] (and own its lifecycle),
/// or omit it and let the group create and dispose one seeded with
/// [initialValue]. Arrow keys navigate focus between sibling radios inside
/// the group.
///
/// ```dart
/// MRadioGroup<int>(
///   initialValue: 1,
///   onChanged: (int? v) => print('picked $v'),
///   child: Column(children: const <Widget>[
///     MRadio<int>(value: 1),
///     MRadio<int>(value: 2),
///     MRadio<int>(value: 3),
///   ]),
/// )
/// ```
class MRadioGroup<T> extends StatefulWidget {
  /// Builds a radio group.
  const MRadioGroup({
    required this.child,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  /// The widget subtree containing the radios in this group. Typically a
  /// [Row], [Column], or [Wrap] of [MRadio] widgets.
  final Widget child;

  /// The state source for this group.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the group creates and owns one seeded with
  /// [initialValue].
  final MController<T?>? controller;

  /// The seed value for the internal controller. Pass `null` to start with
  /// no selection.
  ///
  /// Ignored when [controller] is non-null.
  final T? initialValue;

  /// Called whenever the selection changes — either through user interaction
  /// or programmatic mutation of the underlying controller. The argument is
  /// the new selection, or `null` if the group has been cleared.
  final ValueChanged<T?>? onChanged;

  /// Whether the group as a whole responds to user interaction. Disabling
  /// the group disables every descendant [MRadio] regardless of its own
  /// `enabled` flag.
  final bool enabled;

  @override
  State<MRadioGroup<T>> createState() => _MRadioGroupState<T>();
}

class _MRadioGroupState<T> extends State<MRadioGroup<T>> {
  late MController<T?> _controller;
  bool _ownsController = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
      onInvoke: (DirectionalFocusIntent intent) {
        _moveFocus(intent.direction);
        return null;
      },
    ),
  };

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowDown):
        DirectionalFocusIntent(TraversalDirection.down),
    SingleActivator(LogicalKeyboardKey.arrowUp):
        DirectionalFocusIntent(TraversalDirection.up),
    SingleActivator(LogicalKeyboardKey.arrowRight):
        DirectionalFocusIntent(TraversalDirection.right),
    SingleActivator(LogicalKeyboardKey.arrowLeft):
        DirectionalFocusIntent(TraversalDirection.left),
  };

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant MRadioGroup<T> old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
  }

  void _bindController(MController<T?>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MController<T?>(widget.initialValue);
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);
  }

  void _unbindController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _moveFocus(TraversalDirection direction) {
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    if (primary == null) return;
    primary.focusInDirection(direction);
  }

  @override
  void dispose() {
    _unbindController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MRadioGroupScope<T>(
      controller: _controller,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Shortcuts(
          shortcuts: _shortcuts,
          child: Actions(
            actions: _actions,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _MRadioGroupScope<T> extends InheritedWidget {
  const _MRadioGroupScope({
    required this.controller,
    required this.onChanged,
    required this.enabled,
    required super.child,
  });

  final MController<T?> controller;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  @override
  bool updateShouldNotify(_MRadioGroupScope<T> old) {
    return !identical(controller, old.controller) ||
        onChanged != old.onChanged ||
        enabled != old.enabled;
  }
}

class _RadioPainter extends CustomPainter {
  const _RadioPainter({
    required this.selected,
    required this.size,
    required this.borderColor,
    required this.borderWidth,
    required this.uncheckedBackground,
    required this.checkedBackground,
    required this.dotColor,
    required this.dotDiameter,
  });

  final bool selected;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color uncheckedBackground;
  final Color checkedBackground;
  final Color dotColor;
  final double dotDiameter;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Offset center =
        Offset(canvasSize.width / 2, canvasSize.height / 2);
    final double outerRadius = canvasSize.shortestSide / 2;

    final Paint fill = Paint()
      ..style = PaintingStyle.fill
      ..color = selected ? checkedBackground : uncheckedBackground;
    canvas.drawCircle(center, outerRadius, fill);

    // The hairline ring stays visible in both states — matches shadcn's radio,
    // which keeps the outer ring when selected and overlays the dot.
    final Paint border = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, outerRadius - borderWidth / 2, border);

    if (selected) {
      final Paint dot = Paint()
        ..style = PaintingStyle.fill
        ..color = dotColor;
      canvas.drawCircle(center, dotDiameter / 2, dot);
    }
  }

  @override
  bool shouldRepaint(_RadioPainter old) {
    return selected != old.selected ||
        size != old.size ||
        borderColor != old.borderColor ||
        borderWidth != old.borderWidth ||
        uncheckedBackground != old.uncheckedBackground ||
        checkedBackground != old.checkedBackground ||
        dotColor != old.dotColor ||
        dotDiameter != old.dotDiameter;
  }
}
