import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'slider_style.dart';

/// A horizontal value selector for a `double` in `[min, max]`.
///
/// Accepts an `MController<double>?`; when null, owns one seeded with
/// [initialValue]. Pass [divisions] to snap to evenly-spaced stops.
/// The value is always clamped to `[min, max]`.
///
/// ```dart
/// MSlider(
///   initialValue: 0.5,
///   onChanged: (double v) => print('value = $v'),
/// )
/// ```
class MSlider extends StatefulWidget {
  /// Builds a slider.
  const MSlider({
    this.controller,
    this.initialValue = 0,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    this.semanticFormatterCallback,
    this.autofocus = false,
    this.focusNode,
    super.key,
  })  : assert(min < max, 'min must be strictly less than max'),
        assert(divisions == null || divisions > 0,
            'divisions must be null or positive');

  /// The state source for this slider.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the slider creates and owns one seeded with
  /// [initialValue] (clamped to `[min, max]` on first build).
  final MController<double>? controller;

  /// The seed value for the internal controller.
  ///
  /// Ignored when [controller] is non-null. Clamped to `[min, max]`.
  final double initialValue;

  /// The minimum allowed value. Must be strictly less than [max].
  final double min;

  /// The maximum allowed value. Must be strictly greater than [min].
  final double max;

  /// The number of evenly-spaced stops between [min] and [max]. When non-null
  /// the slider snaps to the nearest stop on every change.
  final int? divisions;

  /// Called whenever the value changes — either through user interaction or
  /// programmatic mutation of the underlying controller.
  ///
  /// Use this as a notification hook; the canonical source of truth is the
  /// controller itself.
  final ValueChanged<double>? onChanged;

  /// Called once at the start of a drag gesture.
  final ValueChanged<double>? onChangeStart;

  /// Called once at the end of a drag gesture.
  final ValueChanged<double>? onChangeEnd;

  /// Whether the slider responds to user interaction.
  ///
  /// Disabled sliders dim their surface and ignore taps, drags, and keyboard
  /// input. The controller's value is preserved and reported through
  /// semantics so screen readers can still announce the state.
  final bool enabled;

  /// The input modality this slider should size itself for.
  ///
  /// When null, the slider resolves modality from
  /// [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MSliderStyle].
  final MSliderStyleDelta? style;

  /// An optional accessibility label.
  ///
  /// Pair with an `MLabel` (Phase 7+) for visible labels.
  final String? semanticLabel;

  /// Formats the current value for screen readers. When null the slider
  /// reports the raw double rounded to two decimal places.
  final String Function(double value)? semanticFormatterCallback;

  /// Whether this slider should request focus on first build.
  final bool autofocus;

  /// An optional [FocusNode] the caller owns.
  ///
  /// When null, the slider creates and disposes its own node.
  final FocusNode? focusNode;

  @override
  State<MSlider> createState() => _MSliderState();
}

class _MSliderState extends State<MSlider> {
  late MController<double> _controller;
  bool _ownsController = false;
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    _IncrementIntent: CallbackAction<_IncrementIntent>(
      onInvoke: (_IncrementIntent intent) {
        _step(intent.steps);
        return null;
      },
    ),
    _JumpIntent: CallbackAction<_JumpIntent>(
      onInvoke: (_JumpIntent intent) {
        _jump(intent.toMax);
        return null;
      },
    ),
  };

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowRight): _IncrementIntent(1),
    SingleActivator(LogicalKeyboardKey.arrowLeft): _IncrementIntent(-1),
    SingleActivator(LogicalKeyboardKey.arrowUp): _IncrementIntent(1),
    SingleActivator(LogicalKeyboardKey.arrowDown): _IncrementIntent(-1),
    SingleActivator(LogicalKeyboardKey.pageUp): _IncrementIntent(10),
    SingleActivator(LogicalKeyboardKey.pageDown): _IncrementIntent(-10),
    SingleActivator(LogicalKeyboardKey.home): _JumpIntent(false),
    SingleActivator(LogicalKeyboardKey.end): _JumpIntent(true),
  };

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant MSlider old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    } else if (old.min != widget.min ||
        old.max != widget.max ||
        old.divisions != widget.divisions) {
      // Re-clamp/snap the current value against the new range without
      // notifying if it would be a no-op.
      _writeNormalized(_controller.value, notify: false);
    }
  }

  void _bindController(MController<double>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MController<double>(_normalize(widget.initialValue));
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

  void _onShowFocus(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  double _normalize(double v) {
    final double clamped = v.clamp(widget.min, widget.max).toDouble();
    final int? d = widget.divisions;
    if (d == null) return clamped;
    final double span = widget.max - widget.min;
    final double t = (clamped - widget.min) / span;
    final int nearest = (t * d).round();
    return widget.min + (nearest / d) * span;
  }

  void _writeNormalized(double raw, {bool notify = true}) {
    final double next = _normalize(raw);
    if (next == _controller.value) return;
    _controller.value = next;
    if (notify) widget.onChanged?.call(next);
  }

  double get _stepIncrement {
    final double span = widget.max - widget.min;
    final int? d = widget.divisions;
    if (d != null) return span / d;
    return span * 0.05;
  }

  void _step(int steps) {
    if (!widget.enabled) return;
    _writeNormalized(_controller.value + steps * _stepIncrement);
  }

  void _jump(bool toMax) {
    if (!widget.enabled) return;
    _writeNormalized(toMax ? widget.max : widget.min);
  }

  double _valueFromLocalX(double localX, double trackWidth) {
    if (trackWidth <= 0) return _controller.value;
    final double t = (localX / trackWidth).clamp(0.0, 1.0);
    return widget.min + t * (widget.max - widget.min);
  }

  void _onTapDown(TapDownDetails details, double trackWidth) {
    if (!widget.enabled) return;
    widget.onChangeStart?.call(_controller.value);
    _writeNormalized(_valueFromLocalX(details.localPosition.dx, trackWidth));
    widget.onChangeEnd?.call(_controller.value);
  }

  void _onDragStart(DragStartDetails details, double trackWidth) {
    if (!widget.enabled) return;
    widget.onChangeStart?.call(_controller.value);
    _writeNormalized(_valueFromLocalX(details.localPosition.dx, trackWidth));
  }

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (!widget.enabled) return;
    _writeNormalized(_valueFromLocalX(details.localPosition.dx, trackWidth));
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    widget.onChangeEnd?.call(_controller.value);
  }

  @override
  void dispose() {
    _unbindController();
    super.dispose();
  }

  String _formatValue(double v) {
    if (widget.semanticFormatterCallback != null) {
      return widget.semanticFormatterCallback!(v);
    }
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);

    final MSliderStyle resolved = theme.slider
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
        )
        .applyDelta(widget.style);

    final double current = _controller.value;
    final double t =
        ((current - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

    final double rowHeight = resolved.thumbDiameter;
    final double step = _stepIncrement;
    final double nextUp = (current + step).clamp(widget.min, widget.max);
    final double nextDown = (current - step).clamp(widget.min, widget.max);

    final Widget bar = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : resolved.minTrackWidth;
        final double trackWidth =
            available < resolved.minTrackWidth ? resolved.minTrackWidth : available;

        Widget surface = SizedBox(
          width: trackWidth,
          height: rowHeight,
          child: CustomPaint(
            painter: _SliderPainter(
              t: t,
              trackWidth: trackWidth,
              trackHeight: resolved.trackHeight,
              rowHeight: rowHeight,
              thumbDiameter: resolved.thumbDiameter,
              activeTrackColor: resolved.activeTrackColor,
              inactiveTrackColor: resolved.inactiveTrackColor,
              thumbColor: resolved.thumbColor,
              thumbBorderColor: resolved.thumbBorderColor,
              thumbBorderWidth: resolved.thumbBorderWidth,
            ),
          ),
        );

        if (!widget.enabled) {
          surface =
              Opacity(opacity: resolved.disabledOpacity, child: surface);
        }

        surface = MFocusRing(focused: _focused, child: surface);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.enabled
              ? (TapDownDetails d) => _onTapDown(d, trackWidth)
              : null,
          onHorizontalDragStart: widget.enabled
              ? (DragStartDetails d) => _onDragStart(d, trackWidth)
              : null,
          onHorizontalDragUpdate: widget.enabled
              ? (DragUpdateDetails d) => _onDragUpdate(d, trackWidth)
              : null,
          onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
          child: surface,
        );
      },
    );

    final Widget detector = FocusableActionDetector(
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onShowFocusHighlight: _onShowFocus,
      mouseCursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: _shortcuts,
      actions: _actions,
      child: bar,
    );

    return Semantics(
      slider: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      value: _formatValue(current),
      increasedValue: _formatValue(nextUp),
      decreasedValue: _formatValue(nextDown),
      onIncrease: widget.enabled && current < widget.max
          ? () => _step(1)
          : null,
      onDecrease: widget.enabled && current > widget.min
          ? () => _step(-1)
          : null,
      container: true,
      child: detector,
    );
  }
}

class _IncrementIntent extends Intent {
  const _IncrementIntent(this.steps);
  final int steps;
}

class _JumpIntent extends Intent {
  const _JumpIntent(this.toMax);
  final bool toMax;
}

class _SliderPainter extends CustomPainter {
  const _SliderPainter({
    required this.t,
    required this.trackWidth,
    required this.trackHeight,
    required this.rowHeight,
    required this.thumbDiameter,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    required this.thumbColor,
    required this.thumbBorderColor,
    required this.thumbBorderWidth,
  });

  final double t;
  final double trackWidth;
  final double trackHeight;
  final double rowHeight;
  final double thumbDiameter;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color thumbColor;
  final Color thumbBorderColor;
  final double thumbBorderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = rowHeight / 2;
    // Track spans the full width so click-to-set at x = 0 → t = 0 lines up
    // with the thumb's painted center at (radius, centerY).
    final double thumbRadius = thumbDiameter / 2;
    final double trackTop = centerY - trackHeight / 2;
    final Rect trackRect =
        Rect.fromLTWH(0, trackTop, trackWidth, trackHeight);
    final RRect track = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(trackHeight / 2),
    );

    final Paint inactive = Paint()
      ..style = PaintingStyle.fill
      ..color = inactiveTrackColor;
    canvas.drawRRect(track, inactive);

    final double thumbX = t * trackWidth;
    if (thumbX > 0) {
      final Rect activeRect =
          Rect.fromLTWH(0, trackTop, thumbX, trackHeight);
      final RRect activeRRect = RRect.fromRectAndRadius(
        activeRect,
        Radius.circular(trackHeight / 2),
      );
      final Paint active = Paint()
        ..style = PaintingStyle.fill
        ..color = activeTrackColor;
      canvas.drawRRect(activeRRect, active);
    }

    final Offset thumbCenter = Offset(thumbX, centerY);
    final Paint thumb = Paint()
      ..style = PaintingStyle.fill
      ..color = thumbColor;
    canvas.drawCircle(thumbCenter, thumbRadius, thumb);

    if (thumbBorderWidth > 0 && thumbBorderColor.a != 0) {
      final Paint ring = Paint()
        ..style = PaintingStyle.stroke
        ..color = thumbBorderColor
        ..strokeWidth = thumbBorderWidth;
      canvas.drawCircle(
        thumbCenter,
        thumbRadius - thumbBorderWidth / 2,
        ring,
      );
    }
  }

  @override
  bool shouldRepaint(_SliderPainter old) {
    return t != old.t ||
        trackWidth != old.trackWidth ||
        trackHeight != old.trackHeight ||
        rowHeight != old.rowHeight ||
        thumbDiameter != old.thumbDiameter ||
        activeTrackColor != old.activeTrackColor ||
        inactiveTrackColor != old.inactiveTrackColor ||
        thumbColor != old.thumbColor ||
        thumbBorderColor != old.thumbBorderColor ||
        thumbBorderWidth != old.thumbBorderWidth;
  }
}
