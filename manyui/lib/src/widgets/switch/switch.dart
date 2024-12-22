import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'switch_style.dart';

/// A boolean toggle rendered as a pill-shaped track with a circular thumb.
///
/// `MSwitch` is the second widget that exercises the `MController<bool>`
/// contract. State ownership follows the same convention as [MCheckbox]:
/// callers may supply a [controller] (and own its lifecycle), or omit it
/// and let the widget create and dispose one internally. [initialValue]
/// seeds the internal controller and is ignored when [controller] is
/// supplied.
///
/// ```dart
/// MSwitch(
///   initialValue: true,
///   onChanged: (bool v) => print('on = $v'),
/// )
/// ```
///
/// Set [enabled] to `false` to render a non-interactive surface. The
/// callback and controller still receive the current value, but tap and
/// keyboard activation are no-ops.
class MSwitch extends StatefulWidget {
  /// Builds a switch.
  const MSwitch({
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

  /// The state source for this switch.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the switch creates and owns one seeded with
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

  /// Whether the switch responds to user interaction.
  ///
  /// Disabled switches dim their surface and ignore taps and keyboard
  /// activation. The controller's value is preserved and reported through
  /// semantics so screen readers can still announce the state.
  final bool enabled;

  /// The input modality this switch should size itself for.
  ///
  /// When null, the switch resolves modality from
  /// [MInputModalityScope.resolve] (the standard explicit → scope →
  /// platform-default chain).
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MSwitchStyle].
  final MSwitchStyleDelta? style;

  /// An optional accessibility label.
  ///
  /// When null, the switch exposes its on/off state through semantics but
  /// supplies no label — pair the switch with a sibling `Text` and an
  /// `MLabel` (Phase 7+) for a labeled control.
  final String? semanticLabel;

  /// Whether this switch should request focus on first build.
  final bool autofocus;

  /// An optional [FocusNode] the caller owns.
  ///
  /// When null, the switch creates and disposes its own node.
  final FocusNode? focusNode;

  @override
  State<MSwitch> createState() => _MSwitchState();
}

class _MSwitchState extends State<MSwitch> {
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
  void didUpdateWidget(covariant MSwitch old) {
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

    final MSwitchStyle resolved = theme.switch_
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
        )
        .applyDelta(widget.style);

    final bool on = _controller.value;

    Widget surface = SizedBox(
      width: resolved.trackWidth,
      height: resolved.trackHeight,
      child: CustomPaint(
        painter: _SwitchPainter(
          on: on,
          trackWidth: resolved.trackWidth,
          trackHeight: resolved.trackHeight,
          thumbDiameter: resolved.thumbDiameter,
          thumbPadding: resolved.thumbPadding,
          offTrackColor: resolved.offTrackColor,
          onTrackColor: resolved.onTrackColor,
          thumbColor: resolved.thumbColor,
          borderColor: resolved.borderColor,
          borderWidth: resolved.borderWidth,
        ),
      ),
    );

    if (!widget.enabled) {
      surface = Opacity(opacity: resolved.disabledOpacity, child: surface);
    }

    surface = MFocusRing(focused: _focused, child: surface);

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
        child: surface,
      ),
    );

    return Semantics(
      toggled: on,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      container: true,
      child: detector,
    );
  }
}

class _SwitchPainter extends CustomPainter {
  const _SwitchPainter({
    required this.on,
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbDiameter,
    required this.thumbPadding,
    required this.offTrackColor,
    required this.onTrackColor,
    required this.thumbColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final bool on;
  final double trackWidth;
  final double trackHeight;
  final double thumbDiameter;
  final double thumbPadding;
  final Color offTrackColor;
  final Color onTrackColor;
  final Color thumbColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect trackRect = Offset.zero & size;
    final RRect track =
        RRect.fromRectAndRadius(trackRect, Radius.circular(size.height / 2));

    final Paint fill = Paint()
      ..style = PaintingStyle.fill
      ..color = on ? onTrackColor : offTrackColor;
    canvas.drawRRect(track, fill);

    if (borderWidth > 0 && borderColor.a != 0) {
      final Paint border = Paint()
        ..style = PaintingStyle.stroke
        ..color = borderColor
        ..strokeWidth = borderWidth;
      canvas.drawRRect(track.deflate(borderWidth / 2), border);
    }

    // Thumb travels from (thumbPadding) on the left to
    // (trackWidth - thumbPadding - thumbDiameter) on the right. Vertically
    // centered.
    final double leftX = thumbPadding;
    final double rightX = trackWidth - thumbPadding - thumbDiameter;
    final double thumbX = on ? rightX : leftX;
    final double thumbY = (trackHeight - thumbDiameter) / 2;

    final Paint thumb = Paint()
      ..style = PaintingStyle.fill
      ..color = thumbColor;
    canvas.drawOval(
      Rect.fromLTWH(thumbX, thumbY, thumbDiameter, thumbDiameter),
      thumb,
    );
  }

  @override
  bool shouldRepaint(_SwitchPainter old) {
    return on != old.on ||
        trackWidth != old.trackWidth ||
        trackHeight != old.trackHeight ||
        thumbDiameter != old.thumbDiameter ||
        thumbPadding != old.thumbPadding ||
        offTrackColor != old.offTrackColor ||
        onTrackColor != old.onTrackColor ||
        thumbColor != old.thumbColor ||
        borderColor != old.borderColor ||
        borderWidth != old.borderWidth;
  }
}
