import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'progress_style.dart';

/// A linear progress bar.
///
/// Tracks an `MController<double>` in `[0, 1]` (determinate) or animates
/// a sliding indicator on a fixed loop ([MProgress.indeterminate]).
/// Determinate value changes tween rather than snap. Renders via
/// `CustomPaint`, independent of Material.
///
/// ```dart
/// MProgress(initialValue: 0.4)
/// MProgress.indeterminate()
/// ```
class MProgress extends StatefulWidget {
  /// Builds a determinate progress bar.
  const MProgress({
    this.controller,
    this.initialValue = 0,
    this.enabled = true,
    this.style,
    this.semanticLabel,
    super.key,
  })  : indeterminate = false;

  /// Builds an indeterminate progress bar.
  ///
  /// The widget owns its own animation; no [controller] or [initialValue] is
  /// meaningful in this mode.
  const MProgress.indeterminate({
    this.enabled = true,
    this.style,
    this.semanticLabel,
    super.key,
  })  : controller = null,
        initialValue = 0,
        indeterminate = true;

  /// The state source for this progress bar (determinate only).
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the widget creates and owns one seeded with
  /// [initialValue] (clamped to `[0, 1]` on first build).
  final MController<double>? controller;

  /// The seed value for the internal controller. Ignored when [controller] is
  /// non-null or when [indeterminate] is true. Clamped to `[0, 1]`.
  final double initialValue;

  /// Whether this is an indeterminate progress bar.
  final bool indeterminate;

  /// Whether the bar appears enabled. Disabled bars render at reduced opacity
  /// and freeze the indeterminate animation. Programmatic
  /// `controller.value =` is still honored (controllers are authoritative).
  final bool enabled;

  /// Field-wise overrides for the theme-resolved [MProgressStyle].
  final MProgressStyleDelta? style;

  /// An optional accessibility label.
  final String? semanticLabel;

  @override
  State<MProgress> createState() => _MProgressState();
}

class _MProgressState extends State<MProgress>
    with SingleTickerProviderStateMixin {
  MController<double>? _controller;
  bool _ownsController = false;
  AnimationController? _indeterminateController;

  @override
  void initState() {
    super.initState();
    if (!widget.indeterminate) {
      _bindController(widget.controller);
    }
    // Indeterminate animation is started in [didChangeDependencies] so that
    // theme lookups happen after the inherited-widget graph is wired.
  }

  @override
  void didUpdateWidget(covariant MProgress old) {
    super.didUpdateWidget(old);
    if (widget.indeterminate) {
      _ensureIndeterminate();
    } else if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }

    // Switching modes between builds is unusual but defensible: if we moved
    // from indeterminate to determinate, drop the animation controller.
    if (!widget.indeterminate && _indeterminateController != null) {
      _indeterminateController!.dispose();
      _indeterminateController = null;
    }
    if (widget.indeterminate && _controller != null) {
      _unbindController();
    }
  }

  void _bindController(MController<double>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller =
          MController<double>(widget.initialValue.clamp(0.0, 1.0).toDouble());
      _ownsController = true;
    }
    _controller!.addListener(_onControllerChanged);
  }

  void _unbindController() {
    _controller?.removeListener(_onControllerChanged);
    if (_ownsController) _controller?.dispose();
    _controller = null;
    _ownsController = false;
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _ensureIndeterminate() {
    final MThemeData theme = MTheme.of(context);
    final MProgressStyle resolved =
        theme.progress.resolve(colors: theme.colors).applyDelta(widget.style);
    if (_indeterminateController == null) {
      _indeterminateController = AnimationController(
        vsync: this,
        duration: resolved.indeterminateDuration,
      );
      if (widget.enabled) _indeterminateController!.repeat();
    } else {
      if (_indeterminateController!.duration != resolved.indeterminateDuration) {
        _indeterminateController!.duration = resolved.indeterminateDuration;
      }
      if (widget.enabled && !_indeterminateController!.isAnimating) {
        _indeterminateController!.repeat();
      } else if (!widget.enabled && _indeterminateController!.isAnimating) {
        _indeterminateController!.stop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.indeterminate) {
      _ensureIndeterminate();
    }
  }

  @override
  void dispose() {
    _unbindController();
    _indeterminateController?.dispose();
    _indeterminateController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MProgressStyle resolved =
        theme.progress.resolve(colors: theme.colors).applyDelta(widget.style);

    Widget bar = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : resolved.minWidth;
        final double width = available < resolved.minWidth
            ? resolved.minWidth
            : available;

        if (widget.indeterminate) {
          final AnimationController c = _indeterminateController!;
          return AnimatedBuilder(
            animation: c,
            builder: (BuildContext _, Widget? __) {
              return SizedBox(
                width: width,
                height: resolved.thickness,
                child: CustomPaint(
                  painter: _LinearIndeterminatePainter(
                    t: c.value,
                    trackColor: resolved.trackColor,
                    valueColor: resolved.valueColor,
                    trackRadius: resolved.trackRadius,
                    valueRadius: resolved.valueRadius,
                  ),
                ),
              );
            },
          );
        }

        final double clamped = _controller!.value.clamp(0.0, 1.0).toDouble();
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: clamped),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          builder: (BuildContext _, double value, Widget? __) {
            return SizedBox(
              width: width,
              height: resolved.thickness,
              child: CustomPaint(
                painter: _LinearDeterminatePainter(
                  value: value,
                  trackColor: resolved.trackColor,
                  valueColor: resolved.valueColor,
                  trackRadius: resolved.trackRadius,
                  valueRadius: resolved.valueRadius,
                ),
              ),
            );
          },
        );
      },
    );

    if (!widget.enabled) {
      bar = Opacity(opacity: resolved.disabledOpacity, child: bar);
    }

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      value: widget.indeterminate
          ? null
          : '${(_controller!.value.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%',
      child: bar,
    );
  }
}

/// A circular progress indicator.
///
/// The round sibling of [MProgress]. Determinate when given a [controller] or
/// [initialValue]; use [MCircularProgress.indeterminate] for a spinning
/// indicator. Shares the same [MProgressStyle] resolution table as
/// [MProgress] — `theme.progress`.
class MCircularProgress extends StatefulWidget {
  /// Builds a determinate circular progress indicator.
  const MCircularProgress({
    this.controller,
    this.initialValue = 0,
    this.enabled = true,
    this.style,
    this.semanticLabel,
    super.key,
  })  : indeterminate = false;

  /// Builds an indeterminate circular progress indicator.
  const MCircularProgress.indeterminate({
    this.enabled = true,
    this.style,
    this.semanticLabel,
    super.key,
  })  : controller = null,
        initialValue = 0,
        indeterminate = true;

  /// The state source for this circular progress indicator (determinate only).
  final MController<double>? controller;

  /// The seed value for the internal controller. Clamped to `[0, 1]`.
  final double initialValue;

  /// Whether this is an indeterminate indicator.
  final bool indeterminate;

  /// Whether the indicator appears enabled.
  final bool enabled;

  /// Field-wise overrides for the theme-resolved [MProgressStyle].
  final MProgressStyleDelta? style;

  /// An optional accessibility label.
  final String? semanticLabel;

  @override
  State<MCircularProgress> createState() => _MCircularProgressState();
}

class _MCircularProgressState extends State<MCircularProgress>
    with SingleTickerProviderStateMixin {
  MController<double>? _controller;
  bool _ownsController = false;
  AnimationController? _indeterminateController;

  @override
  void initState() {
    super.initState();
    if (!widget.indeterminate) {
      _bindController(widget.controller);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.indeterminate) {
      _ensureIndeterminate();
    }
  }

  @override
  void didUpdateWidget(covariant MCircularProgress old) {
    super.didUpdateWidget(old);
    if (widget.indeterminate) {
      _ensureIndeterminate();
    } else if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
    if (!widget.indeterminate && _indeterminateController != null) {
      _indeterminateController!.dispose();
      _indeterminateController = null;
    }
    if (widget.indeterminate && _controller != null) {
      _unbindController();
    }
  }

  void _bindController(MController<double>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller =
          MController<double>(widget.initialValue.clamp(0.0, 1.0).toDouble());
      _ownsController = true;
    }
    _controller!.addListener(_onControllerChanged);
  }

  void _unbindController() {
    _controller?.removeListener(_onControllerChanged);
    if (_ownsController) _controller?.dispose();
    _controller = null;
    _ownsController = false;
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _ensureIndeterminate() {
    final MThemeData theme = MTheme.of(context);
    final MProgressStyle resolved =
        theme.progress.resolve(colors: theme.colors).applyDelta(widget.style);
    if (_indeterminateController == null) {
      _indeterminateController = AnimationController(
        vsync: this,
        duration: resolved.indeterminateDuration,
      );
      if (widget.enabled) _indeterminateController!.repeat();
    } else {
      if (_indeterminateController!.duration != resolved.indeterminateDuration) {
        _indeterminateController!.duration = resolved.indeterminateDuration;
      }
      if (widget.enabled && !_indeterminateController!.isAnimating) {
        _indeterminateController!.repeat();
      } else if (!widget.enabled && _indeterminateController!.isAnimating) {
        _indeterminateController!.stop();
      }
    }
  }

  @override
  void dispose() {
    _unbindController();
    _indeterminateController?.dispose();
    _indeterminateController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MProgressStyle resolved =
        theme.progress.resolve(colors: theme.colors).applyDelta(widget.style);

    final double diameter = resolved.diameter;
    Widget body;
    if (widget.indeterminate) {
      final AnimationController c = _indeterminateController!;
      body = AnimatedBuilder(
        animation: c,
        builder: (BuildContext _, Widget? __) {
          return SizedBox(
            width: diameter,
            height: diameter,
            child: CustomPaint(
              painter: _CircularIndeterminatePainter(
                t: c.value,
                trackColor: resolved.trackColor,
                valueColor: resolved.valueColor,
                thickness: resolved.thickness,
              ),
            ),
          );
        },
      );
    } else {
      final double clamped = _controller!.value.clamp(0.0, 1.0).toDouble();
      body = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        builder: (BuildContext _, double value, Widget? __) {
          return SizedBox(
            width: diameter,
            height: diameter,
            child: CustomPaint(
              painter: _CircularDeterminatePainter(
                value: value,
                trackColor: resolved.trackColor,
                valueColor: resolved.valueColor,
                thickness: resolved.thickness,
              ),
            ),
          );
        },
      );
    }

    if (!widget.enabled) {
      body = Opacity(opacity: resolved.disabledOpacity, child: body);
    }

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      value: widget.indeterminate
          ? null
          : '${(_controller!.value.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%',
      child: body,
    );
  }
}

class _LinearDeterminatePainter extends CustomPainter {
  const _LinearDeterminatePainter({
    required this.value,
    required this.trackColor,
    required this.valueColor,
    required this.trackRadius,
    required this.valueRadius,
  });

  final double value;
  final Color trackColor;
  final Color valueColor;
  final Radius trackRadius;
  final Radius valueRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect track = RRect.fromRectAndRadius(
      Offset.zero & size,
      trackRadius,
    );
    final Paint trackPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = trackColor;
    canvas.drawRRect(track, trackPaint);

    final double w = (size.width * value.clamp(0.0, 1.0)).clamp(0.0, size.width);
    if (w > 0) {
      final RRect bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, size.height),
        valueRadius,
      );
      final Paint valuePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = valueColor;
      canvas.drawRRect(bar, valuePaint);
    }
  }

  @override
  bool shouldRepaint(_LinearDeterminatePainter old) {
    return value != old.value ||
        trackColor != old.trackColor ||
        valueColor != old.valueColor ||
        trackRadius != old.trackRadius ||
        valueRadius != old.valueRadius;
  }
}

class _LinearIndeterminatePainter extends CustomPainter {
  const _LinearIndeterminatePainter({
    required this.t,
    required this.trackColor,
    required this.valueColor,
    required this.trackRadius,
    required this.valueRadius,
  });

  // t in [0, 1] — one cycle.
  final double t;
  final Color trackColor;
  final Color valueColor;
  final Radius trackRadius;
  final Radius valueRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect track = RRect.fromRectAndRadius(
      Offset.zero & size,
      trackRadius,
    );
    final Paint trackPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = trackColor;
    canvas.drawRRect(track, trackPaint);

    // Sliding indicator: a 35%-wide bar that moves from left-off-screen to
    // right-off-screen across one cycle.
    const double barFraction = 0.35;
    final double barWidth = size.width * barFraction;
    final double travel = size.width + barWidth;
    final double xLeft = -barWidth + t * travel;
    final double xRight = xLeft + barWidth;
    final double clampedLeft = xLeft.clamp(0.0, size.width);
    final double clampedRight = xRight.clamp(0.0, size.width);
    if (clampedRight > clampedLeft) {
      final RRect bar = RRect.fromRectAndRadius(
        Rect.fromLTRB(clampedLeft, 0, clampedRight, size.height),
        valueRadius,
      );
      final Paint valuePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = valueColor;
      canvas.drawRRect(bar, valuePaint);
    }
  }

  @override
  bool shouldRepaint(_LinearIndeterminatePainter old) {
    return t != old.t ||
        trackColor != old.trackColor ||
        valueColor != old.valueColor ||
        trackRadius != old.trackRadius ||
        valueRadius != old.valueRadius;
  }
}

class _CircularDeterminatePainter extends CustomPainter {
  const _CircularDeterminatePainter({
    required this.value,
    required this.trackColor,
    required this.valueColor,
    required this.thickness,
  });

  final double value;
  final Color trackColor;
  final Color valueColor;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - thickness) / 2;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    final double sweep = value.clamp(0.0, 1.0) * 6.28318530718;
    if (sweep > 0) {
      final Paint valuePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = valueColor;
      canvas.drawArc(arcRect, -1.5707963267948966, sweep, false, valuePaint);
    }
  }

  @override
  bool shouldRepaint(_CircularDeterminatePainter old) {
    return value != old.value ||
        trackColor != old.trackColor ||
        valueColor != old.valueColor ||
        thickness != old.thickness;
  }
}

class _CircularIndeterminatePainter extends CustomPainter {
  const _CircularIndeterminatePainter({
    required this.t,
    required this.trackColor,
    required this.valueColor,
    required this.thickness,
  });

  final double t;
  final Color trackColor;
  final Color valueColor;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - thickness) / 2;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    // A 25%-of-circle arc that rotates around the circle once per cycle.
    const double sweep = 6.28318530718 * 0.25;
    final double start = -1.5707963267948966 + t * 6.28318530718;
    final Paint valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = valueColor;
    canvas.drawArc(arcRect, start, sweep, false, valuePaint);
  }

  @override
  bool shouldRepaint(_CircularIndeterminatePainter old) {
    return t != old.t ||
        trackColor != old.trackColor ||
        valueColor != old.valueColor ||
        thickness != old.thickness;
  }
}
