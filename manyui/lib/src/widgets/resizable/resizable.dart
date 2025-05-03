import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'resizable_style.dart';

/// A single pane declaration consumed by [MResizable].
@immutable
class MResizableChild {
  /// Builds a resizable child.
  const MResizableChild({
    required this.child,
    this.minSize = 0.05,
    this.maxSize = 1.0,
    this.id,
  })  : assert(minSize >= 0 && minSize <= 1,
            'minSize must be in [0, 1].'),
        assert(maxSize > 0 && maxSize <= 1,
            'maxSize must be in (0, 1].'),
        assert(minSize <= maxSize, 'minSize must be <= maxSize.');

  /// The widget rendered inside this pane.
  final Widget child;

  /// Lower bound on this pane's fraction of available space, in [0, 1].
  /// A drag that would push this pane below [minSize] clamps.
  final double minSize;

  /// Upper bound on this pane's fraction of available space, in (0, 1].
  final double maxSize;

  /// Optional identifier surfaced in debug labels.
  final String? id;
}

/// A horizontally- or vertically-split surface whose panes can be resized by
/// dragging the handles between them.
///
/// N child panes ([MResizableChild]s) are separated by N-1 grabbable handles.
/// Pane sizes are fractions of the available main-axis extent summing to 1,
/// held in an `MController<List<double>>`. Drags are clamped to each pane's
/// [MResizableChild.minSize].
///
/// ```dart
/// MResizable(
///   axis: Axis.horizontal,
///   children: <MResizableChild>[
///     MResizableChild(minSize: 0.2, child: LeftPane()),
///     MResizableChild(minSize: 0.2, child: RightPane()),
///   ],
/// )
/// ```
///
/// Each handle is focusable. Arrow keys nudge by `keyboardStep`;
/// Shift+arrow nudges by `keyboardFineStep`; Home/End jump to the limit.
class MResizable extends StatefulWidget {
  /// Builds a resizable split surface.
  const MResizable({
    required this.children,
    this.axis = Axis.horizontal,
    this.controller,
    this.initialSizes,
    this.onChanged,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    super.key,
  }) : assert(children.length >= 2,
            'MResizable requires at least two children.');

  /// The pane declarations rendered in main-axis order. Must contain at least
  /// two entries.
  final List<MResizableChild> children;

  /// Main axis the panes are laid out along.
  ///
  /// [Axis.horizontal] arranges children left-to-right; [Axis.vertical]
  /// arranges them top-to-bottom.
  final Axis axis;

  /// The state source for this resizable.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the widget creates and owns one seeded with
  /// [initialSizes] (or, if that is also null, an equal-sized split across
  /// [children]).
  ///
  /// The controller's value length must equal [children].length.
  final MController<List<double>>? controller;

  /// The seed list for the internal controller. Ignored when [controller] is
  /// non-null. When null, defaults to an equal split across [children].
  ///
  /// Must have the same length as [children] and sum to 1 (within rounding
  /// error).
  final List<double>? initialSizes;

  /// Called whenever the size list changes — through drag, keyboard nudge,
  /// or programmatic mutation of the underlying controller.
  final ValueChanged<List<double>>? onChanged;

  /// Whether the resizable responds to user interaction. Disabling dims the
  /// surface but does not freeze the controller's value — programmatic
  /// mutation is still honored.
  final bool enabled;

  /// The input modality this resizable should size handles for.
  ///
  /// When null, resolves from [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MResizableStyle].
  final MResizableStyleDelta? style;

  /// An optional accessibility label for the resizable as a whole.
  final String? semanticLabel;

  @override
  State<MResizable> createState() => _MResizableState();
}

class _MResizableState extends State<MResizable> {
  late MController<List<double>> _controller;
  bool _ownsController = false;

  // One FocusNode per handle. There are children.length - 1 handles, keyed
  // by handle index "handle-$i".
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};

  int? _activeHandleIndex;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(covariant MResizable old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
    _syncFocusNodes();
  }

  void _bindController(MController<List<double>>? external) {
    if (external != null) {
      assert(external.value.length == widget.children.length,
          'Controller value length must equal children.length.');
      _controller = external;
      _ownsController = false;
    } else {
      final List<double> seed = widget.initialSizes != null
          ? List<double>.from(widget.initialSizes!)
          : List<double>.filled(
              widget.children.length, 1.0 / widget.children.length);
      assert(seed.length == widget.children.length,
          'initialSizes length must equal children.length.');
      _controller = MController<List<double>>(_normalize(seed));
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

  void _syncFocusNodes() {
    final Set<String> ids = <String>{};
    for (int i = 0; i < widget.children.length - 1; i++) {
      ids.add('handle-$i');
    }
    final List<String> stale =
        _focusNodes.keys.where((String id) => !ids.contains(id)).toList();
    for (final String id in stale) {
      _focusNodes.remove(id)?.dispose();
    }
    for (final String id in ids) {
      _focusNodes.putIfAbsent(
        id,
        () => FocusNode(debugLabel: 'MResizableHandle($id)'),
      );
    }
  }

  @override
  void dispose() {
    _unbindController();
    for (final FocusNode node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
    super.dispose();
  }

  // Renormalize a fractions list so it sums to exactly 1. Tolerates rounding
  // error but renormalizes any deviation by scaling all entries equally.
  List<double> _normalize(List<double> fractions) {
    double sum = 0;
    for (final double f in fractions) {
      sum += f;
    }
    if (sum <= 0) {
      return List<double>.filled(fractions.length, 1.0 / fractions.length);
    }
    if ((sum - 1.0).abs() < 1e-9) return fractions;
    return <double>[for (final double f in fractions) f / sum];
  }

  // Clamp adjacent fractions on a drag of handle [i] by [delta]. Returns the
  // updated fractions list. Positive delta grows pane i and shrinks pane i+1.
  List<double> _applyDrag(int handleIndex, double delta) {
    final List<double> next = List<double>.from(_controller.value);
    final MResizableChild left = widget.children[handleIndex];
    final MResizableChild right = widget.children[handleIndex + 1];
    final double leftMin = left.minSize;
    final double leftMax = left.maxSize;
    final double rightMin = right.minSize;
    final double rightMax = right.maxSize;

    final double leftCurrent = next[handleIndex];
    final double rightCurrent = next[handleIndex + 1];

    // Bounds on the *delta* given each pane's min and max.
    final double maxIncrease = <double>[
      leftMax - leftCurrent,
      rightCurrent - rightMin,
    ].reduce((double a, double b) => a < b ? a : b);
    final double maxDecrease = <double>[
      leftCurrent - leftMin,
      rightMax - rightCurrent,
    ].reduce((double a, double b) => a < b ? a : b);

    final double clamped = delta > 0
        ? (delta > maxIncrease ? maxIncrease : delta)
        : (delta < -maxDecrease ? -maxDecrease : delta);

    next[handleIndex] = leftCurrent + clamped;
    next[handleIndex + 1] = rightCurrent - clamped;
    return next;
  }

  void _setFractions(List<double> next) {
    final List<double> normalized = _normalize(next);
    // ChangeNotifier compares with ==; List equality is identity. Use a fresh
    // list to ensure notify always fires when content differs.
    bool same = normalized.length == _controller.value.length;
    if (same) {
      for (int i = 0; i < normalized.length; i++) {
        if ((normalized[i] - _controller.value[i]).abs() > 1e-9) {
          same = false;
          break;
        }
      }
    }
    if (same) return;
    _controller.value = normalized;
    widget.onChanged?.call(normalized);
  }

  void _onHandleDragStart(int handleIndex) {
    _focusNodes['handle-$handleIndex']?.requestFocus();
    setState(() => _activeHandleIndex = handleIndex);
  }

  void _onHandleDragUpdate(int handleIndex, double deltaPx, double mainAxisExtent) {
    if (mainAxisExtent <= 0) return;
    final double deltaFrac = deltaPx / mainAxisExtent;
    final List<double> next = _applyDrag(handleIndex, deltaFrac);
    _setFractions(next);
  }

  void _onHandleDragEnd() {
    if (_activeHandleIndex != null) {
      setState(() => _activeHandleIndex = null);
    }
  }

  void _nudge(int handleIndex, double deltaFrac) {
    _focusNodes['handle-$handleIndex']?.requestFocus();
    final List<double> next = _applyDrag(handleIndex, deltaFrac);
    _setFractions(next);
  }

  void _jumpToEdge(int handleIndex, {required bool toEnd}) {
    _focusNodes['handle-$handleIndex']?.requestFocus();
    final List<double> next = _applyDrag(
      handleIndex,
      toEnd ? double.infinity : -double.infinity,
    );
    _setFractions(next);
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality modality =
        MInputModalityScope.resolve(context, widget.modality);
    final MResizableStyle resolved = theme.resizable
        .resolve(modality: modality, colors: theme.colors)
        .applyDelta(widget.style);

    final List<double> fractions = _normalize(_controller.value);

    Widget layout = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double mainExtent = widget.axis == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        final List<Widget> slats = <Widget>[];
        for (int i = 0; i < widget.children.length; i++) {
          final int flex = (fractions[i] * 1000000).round().clamp(1, 1 << 30);
          slats.add(Flexible(
            fit: FlexFit.tight,
            flex: flex,
            child: widget.children[i].child,
          ));
          if (i < widget.children.length - 1) {
            slats.add(_Handle(
              axis: widget.axis,
              style: resolved,
              enabled: widget.enabled,
              focusNode: _focusNodes['handle-$i']!,
              isActive: _activeHandleIndex == i,
              currentFraction: fractions[i],
              nextFraction: fractions[i + 1],
              onDragStart: () => _onHandleDragStart(i),
              onDragDelta: (double d) =>
                  _onHandleDragUpdate(i, d, mainExtent),
              onDragEnd: _onHandleDragEnd,
              onNudgeForward: () => _nudge(i, resolved.keyboardStep),
              onNudgeBackward: () => _nudge(i, -resolved.keyboardStep),
              onFineForward: () => _nudge(i, resolved.keyboardFineStep),
              onFineBackward: () => _nudge(i, -resolved.keyboardFineStep),
              onJumpEnd: () => _jumpToEdge(i, toEnd: true),
              onJumpStart: () => _jumpToEdge(i, toEnd: false),
            ));
          }
        }

        return widget.axis == Axis.horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: slats,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: slats,
              );
      },
    );

    if (!widget.enabled) {
      layout = Opacity(opacity: resolved.disabledOpacity, child: layout);
    }

    if (widget.semanticLabel == null) return layout;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: layout,
    );
  }
}

class _Handle extends StatefulWidget {
  const _Handle({
    required this.axis,
    required this.style,
    required this.enabled,
    required this.focusNode,
    required this.isActive,
    required this.currentFraction,
    required this.nextFraction,
    required this.onDragStart,
    required this.onDragDelta,
    required this.onDragEnd,
    required this.onNudgeForward,
    required this.onNudgeBackward,
    required this.onFineForward,
    required this.onFineBackward,
    required this.onJumpEnd,
    required this.onJumpStart,
  });

  final Axis axis;
  final MResizableStyle style;
  final bool enabled;
  final FocusNode focusNode;
  final bool isActive;
  final double currentFraction;
  final double nextFraction;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragDelta;
  final VoidCallback onDragEnd;
  final VoidCallback onNudgeForward;
  final VoidCallback onNudgeBackward;
  final VoidCallback onFineForward;
  final VoidCallback onFineBackward;
  final VoidCallback onJumpEnd;
  final VoidCallback onJumpStart;

  @override
  State<_Handle> createState() => _HandleState();
}

class _HandleState extends State<_Handle> {
  bool _focused = false;
  bool _hovered = false;

  late final Map<Type, Action<Intent>> _actions = _buildActions();

  Map<Type, Action<Intent>> _buildActions() {
    return <Type, Action<Intent>>{
      _NudgeIntent: CallbackAction<_NudgeIntent>(
        onInvoke: (_NudgeIntent intent) {
          if (!widget.enabled) return null;
          switch (intent.kind) {
            case _NudgeKind.forward:
              widget.onNudgeForward();
            case _NudgeKind.backward:
              widget.onNudgeBackward();
            case _NudgeKind.fineForward:
              widget.onFineForward();
            case _NudgeKind.fineBackward:
              widget.onFineBackward();
            case _NudgeKind.jumpEnd:
              widget.onJumpEnd();
            case _NudgeKind.jumpStart:
              widget.onJumpStart();
          }
          return null;
        },
      ),
    };
  }

  void _onShowFocus(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  void _onHover(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  String _formatPercent(double f) =>
      '${(f * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final bool horizontal = widget.axis == Axis.horizontal;
    final MResizableStyle s = widget.style;

    final Color visibleColor = !widget.enabled
        ? s.handleColor
        : (widget.isActive
            ? s.handleActiveColor
            : (_hovered ? s.handleHoveredColor : s.handleColor));

    final Widget stroke = Container(
      width: horizontal ? s.handleThickness : double.infinity,
      height: horizontal ? double.infinity : s.handleThickness,
      color: visibleColor,
    );

    Widget visual = Center(child: stroke);

    if (s.showGripIndicator) {
      visual = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          visual,
          CustomPaint(
            painter: _GripPainter(
              axis: widget.axis,
              color: s.gripColor,
              length: s.gripLength,
              strokeWidth: s.gripStrokeWidth,
            ),
            size: Size(s.gripLength + 4, s.gripLength + 4),
          ),
        ],
      );
    }

    Widget hitArea = SizedBox(
      width: horizontal ? s.handleHitThickness : double.infinity,
      height: horizontal ? double.infinity : s.handleHitThickness,
      child: visual,
    );

    hitArea = MFocusRing(focused: _focused, child: hitArea);

    final SystemMouseCursor cursor = widget.enabled
        ? (horizontal
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.resizeRow)
        : SystemMouseCursors.basic;

    final Map<ShortcutActivator, Intent> shortcuts = horizontal
        ? const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowRight):
                _NudgeIntent(_NudgeKind.forward),
            SingleActivator(LogicalKeyboardKey.arrowLeft):
                _NudgeIntent(_NudgeKind.backward),
            SingleActivator(LogicalKeyboardKey.arrowRight, shift: true):
                _NudgeIntent(_NudgeKind.fineForward),
            SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true):
                _NudgeIntent(_NudgeKind.fineBackward),
            SingleActivator(LogicalKeyboardKey.home):
                _NudgeIntent(_NudgeKind.jumpStart),
            SingleActivator(LogicalKeyboardKey.end):
                _NudgeIntent(_NudgeKind.jumpEnd),
          }
        : const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowDown):
                _NudgeIntent(_NudgeKind.forward),
            SingleActivator(LogicalKeyboardKey.arrowUp):
                _NudgeIntent(_NudgeKind.backward),
            SingleActivator(LogicalKeyboardKey.arrowDown, shift: true):
                _NudgeIntent(_NudgeKind.fineForward),
            SingleActivator(LogicalKeyboardKey.arrowUp, shift: true):
                _NudgeIntent(_NudgeKind.fineBackward),
            SingleActivator(LogicalKeyboardKey.home):
                _NudgeIntent(_NudgeKind.jumpStart),
            SingleActivator(LogicalKeyboardKey.end):
                _NudgeIntent(_NudgeKind.jumpEnd),
          };

    final Widget detector = FocusableActionDetector(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      onShowFocusHighlight: _onShowFocus,
      onShowHoverHighlight: _onHover,
      mouseCursor: cursor,
      shortcuts: shortcuts,
      actions: _actions,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: widget.enabled
            ? <Type, GestureRecognizerFactory>{
                horizontal
                        ? HorizontalDragGestureRecognizer
                        : VerticalDragGestureRecognizer:
                    horizontal
                        ? GestureRecognizerFactoryWithHandlers<
                            HorizontalDragGestureRecognizer>(
                            HorizontalDragGestureRecognizer.new,
                            (HorizontalDragGestureRecognizer r) {
                              r.onStart = (DragStartDetails _) {
                                widget.onDragStart();
                              };
                              r.onUpdate = (DragUpdateDetails d) {
                                widget.onDragDelta(d.delta.dx);
                              };
                              r.onEnd = (DragEndDetails _) {
                                widget.onDragEnd();
                              };
                              r.onCancel = widget.onDragEnd;
                            },
                          )
                        : GestureRecognizerFactoryWithHandlers<
                            VerticalDragGestureRecognizer>(
                            VerticalDragGestureRecognizer.new,
                            (VerticalDragGestureRecognizer r) {
                              r.onStart = (DragStartDetails _) {
                                widget.onDragStart();
                              };
                              r.onUpdate = (DragUpdateDetails d) {
                                widget.onDragDelta(d.delta.dy);
                              };
                              r.onEnd = (DragEndDetails _) {
                                widget.onDragEnd();
                              };
                              r.onCancel = widget.onDragEnd;
                            },
                          ),
              }
            : const <Type, GestureRecognizerFactory>{},
        child: hitArea,
      ),
    );

    return Semantics(
      slider: true,
      enabled: widget.enabled,
      value: _formatPercent(widget.currentFraction),
      increasedValue: _formatPercent(widget.currentFraction + s.keyboardStep),
      decreasedValue: _formatPercent(widget.currentFraction - s.keyboardStep),
      onIncrease: widget.enabled ? widget.onNudgeForward : null,
      onDecrease: widget.enabled ? widget.onNudgeBackward : null,
      container: true,
      child: detector,
    );
  }
}

class _GripPainter extends CustomPainter {
  const _GripPainter({
    required this.axis,
    required this.color,
    required this.length,
    required this.strokeWidth,
  });

  final Axis axis;
  final Color color;
  final double length;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final Offset center = Offset(size.width / 2, size.height / 2);
    // Three short marks, each oriented along the cross axis of the handle,
    // stacked along the main axis for a "drag dots" look.
    const int marks = 3;
    final double spacing = length / 4;
    const double markHalfLength = 3;
    for (int i = 0; i < marks; i++) {
      final double offset = (i - 1) * spacing;
      if (axis == Axis.horizontal) {
        // Horizontal-axis layout → vertical handle. Marks stack vertically,
        // each running horizontally across the handle.
        canvas.drawLine(
          Offset(center.dx - markHalfLength, center.dy + offset),
          Offset(center.dx + markHalfLength, center.dy + offset),
          paint,
        );
      } else {
        // Vertical-axis layout → horizontal handle. Marks stack horizontally,
        // each running vertically across the handle.
        canvas.drawLine(
          Offset(center.dx + offset, center.dy - markHalfLength),
          Offset(center.dx + offset, center.dy + markHalfLength),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GripPainter old) =>
      old.axis != axis ||
      old.color != color ||
      old.length != length ||
      old.strokeWidth != strokeWidth;
}

enum _NudgeKind { forward, backward, fineForward, fineBackward, jumpEnd, jumpStart }

class _NudgeIntent extends Intent {
  const _NudgeIntent(this.kind);
  final _NudgeKind kind;
}
