import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'checkbox_style.dart';

/// A boolean toggle rendered as a small square with a check mark.
///
/// Accepts an `MController<bool>?`; when null, owns one seeded with
/// [initialValue]. Disabled rendering ignores tap and keyboard events.
///
/// ```dart
/// MCheckbox(
///   initialValue: true,
///   onChanged: (bool v) => print('checked = $v'),
/// )
/// ```
class MCheckbox extends StatefulWidget {
  /// Builds a checkbox.
  const MCheckbox({
    this.controller,
    this.initialValue = false,
    this.onChanged,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// The state source for this checkbox.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the checkbox creates and owns one seeded with
  /// [initialValue].
  final MController<bool>? controller;

  /// The seed value for the internal controller.
  ///
  /// Ignored when [controller] is non-null.
  final bool initialValue;

  /// Called whenever the value changes — either through user interaction or
  /// programmatic mutation of the underlying controller.
  ///
  /// Use this as a notification hook; the canonical source of truth is the
  /// controller itself.
  final ValueChanged<bool>? onChanged;

  /// Whether the checkbox responds to user interaction.
  ///
  /// Disabled checkboxes dim their surface and ignore taps and keyboard
  /// activation. The controller's value is preserved and reported through
  /// semantics so screen readers can still announce the state.
  final bool enabled;

  /// The input modality this checkbox should size itself for.
  ///
  /// When null, the checkbox resolves modality from
  /// [MInputModalityScope.resolve] (the standard explicit → scope →
  /// platform-default chain).
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MCheckboxStyle].
  final MCheckboxStyleDelta? style;

  /// An optional accessibility label.
  ///
  /// When null, the checkbox exposes its checked/unchecked state through
  /// semantics but supplies no label — pair the checkbox with a sibling
  /// `Text` and an `MLabel` (Phase 7+) for a labeled control.
  final String? semanticLabel;

  /// Whether this checkbox should request focus on first build.
  final bool autofocus;

  /// An optional [FocusNode] the caller owns.
  ///
  /// When null, the checkbox creates and disposes its own node.
  final FocusNode? focusNode;

  @override
  State<MCheckbox> createState() => _MCheckboxState();
}

class _MCheckboxState extends State<MCheckbox> {
  late MController<bool> _controller;
  bool _ownsController = false;
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        _toggle();
        return null;
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant MCheckbox old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
  }

  void _bindController(MController<bool>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MController<bool>(widget.initialValue);
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

  void _toggle() {
    if (!widget.enabled) return;
    final bool next = !_controller.value;
    _controller.value = next;
    widget.onChanged?.call(next);
  }

  void _onShowFocus(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  @override
  void dispose() {
    _unbindController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);

    final MCheckboxStyle resolved = theme.checkbox
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final bool checked = _controller.value;

    Widget box = SizedBox(
      width: resolved.size,
      height: resolved.size,
      child: CustomPaint(
        painter: _CheckboxPainter(
          checked: checked,
          borderColor: resolved.borderColor,
          borderWidth: resolved.borderWidth,
          uncheckedBackground: resolved.uncheckedBackgroundColor,
          checkedBackground: resolved.checkedBackgroundColor,
          checkmarkColor: resolved.checkmarkColor,
          checkmarkThickness: resolved.checkmarkThickness,
          radius: resolved.radius.resolve(Directionality.of(context)),
        ),
      ),
    );

    if (!widget.enabled) {
      box = Opacity(opacity: resolved.disabledOpacity, child: box);
    }

    box = MFocusRing(focused: _focused, child: box);

    final Widget detector = FocusableActionDetector(
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onShowFocusHighlight: _onShowFocus,
      mouseCursor: widget.enabled
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
        onTap: widget.enabled ? _toggle : null,
        child: box,
      ),
    );

    return Semantics(
      checked: checked,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      container: true,
      child: detector,
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  const _CheckboxPainter({
    required this.checked,
    required this.borderColor,
    required this.borderWidth,
    required this.uncheckedBackground,
    required this.checkedBackground,
    required this.checkmarkColor,
    required this.checkmarkThickness,
    required this.radius,
  });

  final bool checked;
  final Color borderColor;
  final double borderWidth;
  final Color uncheckedBackground;
  final Color checkedBackground;
  final Color checkmarkColor;
  final double checkmarkThickness;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = radius.toRRect(rect);

    final Paint fill = Paint()
      ..style = PaintingStyle.fill
      ..color = checked ? checkedBackground : uncheckedBackground;
    canvas.drawRRect(rrect, fill);

    if (!checked) {
      final Paint border = Paint()
        ..style = PaintingStyle.stroke
        ..color = borderColor
        ..strokeWidth = borderWidth;
      // Inset by half the stroke so the outer edge of the border sits flush
      // with the resolved box bounds (matches shadcn's hairline outline).
      final RRect inset = rrect.deflate(borderWidth / 2);
      canvas.drawRRect(inset, border);
      return;
    }

    // Checkmark: a two-segment path from (0.22, 0.52) → (0.43, 0.72) →
    // (0.78, 0.32) in normalized space.
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = checkmarkColor
      ..strokeWidth = checkmarkThickness
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.43, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.32);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_CheckboxPainter old) {
    return checked != old.checked ||
        borderColor != old.borderColor ||
        borderWidth != old.borderWidth ||
        uncheckedBackground != old.uncheckedBackground ||
        checkedBackground != old.checkedBackground ||
        checkmarkColor != old.checkmarkColor ||
        checkmarkThickness != old.checkmarkThickness ||
        radius != old.radius;
  }
}
