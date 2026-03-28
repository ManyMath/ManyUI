import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/overlay_anchor.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'popover_style.dart';

/// Builds the contents of an [MPopover]'s overlay surface.
///
/// The [close] callback hides the popover and returns focus to the anchor.
/// Use it inside content to "commit" a result and dismiss in one call:
///
/// ```dart
/// popoverBuilder: (BuildContext context, VoidCallback close) {
///   return Column(
///     children: <Widget>[
///       MButton(onPressed: () { /* save */ close(); }, child: const Text('OK')),
///     ],
///   );
/// }
/// ```
typedef MPopoverContentBuilder =
    Widget Function(BuildContext context, VoidCallback close);

/// Drives an [MPopover]'s open/close state.
///
/// Hold one in `State` (caller-owned) or let [MPopover] create its own when
/// `controller` is null. [open], [close], and [toggle] notify listeners so
/// callers can rebuild on state changes.
class MPopoverController extends ChangeNotifier {
  /// Whether the popover is currently shown.
  bool get isOpen => _isOpen;
  bool _isOpen = false;

  /// Show the popover.
  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Hide the popover. Safe to call when already closed.
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Toggle the popover.
  void toggle() => _isOpen ? close() : open();
}

/// A floating surface anchored to a child widget.
///
/// `MPopover` wraps any widget — the [child] — as an anchor, and shows an
/// overlay surface built by [popoverBuilder] when the [controller] is open.
/// The popover is **modal**: a translucent dismiss layer behind it closes
/// the popover when tapped outside. Escape also closes it. Focus is trapped
/// inside the popover while it is open and returns to the anchor on close.
///
/// Open/close is purely state-driven through [MPopoverController]; the anchor
/// is unopinionated — the caller wires up its own gesture (e.g. a button)
/// that calls `controller.toggle()` or `controller.open()`. If [controller]
/// is null, `MPopover` creates and owns one internally and exposes the same
/// open behavior via tapping the anchor.
///
/// ```dart
/// final MPopoverController c = MPopoverController();
/// MPopover(
///   controller: c,
///   popoverBuilder: (BuildContext context, VoidCallback close) {
///     return SizedBox(
///       width: 200,
///       child: Column(children: <Widget>[
///         MButton(onPressed: close, child: const Text('Done')),
///       ]),
///     );
///   },
///   child: MButton(onPressed: c.toggle, child: const Text('Open')),
/// );
/// ```
///
/// The popover prefers to open below the anchor, flips above when that side
/// has more usable room, and clamps its surface inside the viewport.
class MPopover extends StatefulWidget {
  /// Builds a popover.
  const MPopover({
    required this.child,
    required this.popoverBuilder,
    this.controller,
    this.onClose,
    this.onKeyEvent,
    this.style,
    this.semanticLabel,
    this.matchAnchorWidth = false,
    super.key,
  });

  /// The anchor widget rendered in the normal layout flow.
  final Widget child;

  /// Builds the popover's content. Called every frame the popover is open.
  ///
  /// The `close` callback dismisses the popover and returns focus to the
  /// anchor — equivalent to calling `controller.close()`.
  final MPopoverContentBuilder popoverBuilder;

  /// The controller that drives open/close. When null, the widget creates
  /// and owns one internally; tapping the anchor toggles it.
  final MPopoverController? controller;

  /// Called whenever the popover transitions open→closed, regardless of
  /// cause (outside tap, Escape, programmatic close).
  final VoidCallback? onClose;

  /// Handler for keyboard events while the popover holds focus.
  ///
  /// Escape is always handled internally (closes the popover); this callback
  /// fires for every key event including Escape, returning [KeyEventResult]
  /// to control bubble-up. Return [KeyEventResult.ignored] to let the
  /// default Escape handling proceed.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Field-wise overrides for the theme-resolved [MPopoverStyle].
  final MPopoverStyleDelta? style;

  /// An optional accessibility label applied to the popover surface.
  final String? semanticLabel;

  /// When true, the popover's surface is constrained to at least the
  /// anchor's measured width. Useful for menu-style consumers (mirrors
  /// `MSelect`'s behavior). Defaults to false — content sizes naturally.
  final bool matchAnchorWidth;

  @override
  State<MPopover> createState() => _MPopoverState();
}

class _MPopoverState extends State<MPopover> {
  late MPopoverController _controller;
  bool _ownsController = false;

  final MOverlayAnchorController _anchor = MOverlayAnchorController(
    debugLabel: 'MPopover',
  );

  final FocusNode _anchorFocusNode = FocusNode(debugLabel: 'MPopover anchor');

  double _anchorWidth = 0;
  double _anchorHeight = 0;
  double _anchorLeft = 0;
  double _anchorTop = 0;
  double _viewportWidth = 0;
  double _viewportHeight = 0;
  int _geometryWatchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant MPopover old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
      // Sync the overlay to whatever the new controller's state says.
      // Deferred because didUpdateWidget runs during build — OverlayPortal
      // refuses show()/hide() in the build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncOverlayWithController();
      });
    }
  }

  void _bindController(MPopoverController? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MPopoverController();
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);
  }

  void _unbindController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    _syncOverlayWithController();
  }

  void _syncOverlayWithController() {
    final bool wantOpen = _controller.isOpen;
    if (wantOpen && !_anchor.isOpen) {
      _measureAnchor();
      _startGeometryWatch();
      _anchor.open(anchorFocusNode: _anchorFocusNode);
      if (mounted) setState(() {});
    } else if (!wantOpen && _anchor.isOpen) {
      _stopGeometryWatch();
      _anchor.close();
      widget.onClose?.call();
      if (mounted) setState(() {});
    }
  }

  bool _measureAnchor() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return false;

    final double anchorWidth = box.size.width;
    final double anchorHeight = box.size.height;
    late final double viewportWidth;
    late final double viewportHeight;
    late final Offset origin;

    final RenderBox? overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (overlayBox != null && overlayBox.hasSize) {
      viewportWidth = overlayBox.size.width;
      viewportHeight = overlayBox.size.height;
      origin = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    } else {
      final Size viewport = MediaQuery.sizeOf(context);
      viewportWidth = viewport.width;
      viewportHeight = viewport.height;
      origin = box.localToGlobal(Offset.zero);
    }

    final bool changed =
        _anchorWidth != anchorWidth ||
        _anchorHeight != anchorHeight ||
        _anchorLeft != origin.dx ||
        _anchorTop != origin.dy ||
        _viewportWidth != viewportWidth ||
        _viewportHeight != viewportHeight;
    _anchorWidth = anchorWidth;
    _anchorHeight = anchorHeight;
    _anchorLeft = origin.dx;
    _anchorTop = origin.dy;
    _viewportWidth = viewportWidth;
    _viewportHeight = viewportHeight;
    return changed;
  }

  void _startGeometryWatch() {
    final int generation = ++_geometryWatchGeneration;

    void measureAfterFrame(Duration _) {
      if (!mounted ||
          generation != _geometryWatchGeneration ||
          !_controller.isOpen) {
        return;
      }
      if (_measureAnchor()) setState(() {});
      // This callback does not request a frame. It observes scroll, resize,
      // layout, and animation frames the app was already going to produce.
      WidgetsBinding.instance.addPostFrameCallback(measureAfterFrame);
    }

    WidgetsBinding.instance.addPostFrameCallback(measureAfterFrame);
  }

  void _stopGeometryWatch() => _geometryWatchGeneration += 1;

  void _handleDismiss() {
    // Outside tap on the modal barrier — drive close through the controller
    // so listeners observe the state change.
    _controller.close();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final KeyEventResult fromCaller =
        widget.onKeyEvent?.call(node, event) ?? KeyEventResult.ignored;
    if (fromCaller == KeyEventResult.handled) return fromCaller;

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return fromCaller;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _controller.close();
      return KeyEventResult.handled;
    }
    return fromCaller;
  }

  @override
  void dispose() {
    _stopGeometryWatch();
    _unbindController();
    _anchor.dispose();
    _anchorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MPopoverStyle resolved = theme.popover
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    // Tap-on-anchor behavior. When the caller supplies their own controller,
    // they own the open/close; we still wrap the anchor in a Focus so
    // Tab-navigation can land on it. When we own the controller, tapping the
    // anchor toggles.
    Widget anchor = widget.child;

    anchor = Focus(
      focusNode: _anchorFocusNode,
      includeSemantics: false,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: _ownsController ? _controller.toggle : null,
        child: anchor,
      ),
    );

    final Widget portal = MOverlayAnchor(
      controller: _anchor,
      anchor: anchor,
      // Normalize the follower to the overlay viewport. The layout delegate
      // then positions the measured surface relative to the anchor rect in a
      // single frame, so a bottom-edge menu never flashes offscreen first.
      overlayOffset: Offset(-_anchorLeft, -_anchorTop),
      onDismiss: _handleDismiss,
      onKeyEvent: _onKeyEvent,
      overlayBuilder: (BuildContext overlayContext) {
        final Widget overlay = _buildOverlay(overlayContext, resolved);
        return SizedBox(
          width: _viewportWidth,
          height: _viewportHeight,
          child: CustomSingleChildLayout(
            delegate: _PopoverPositionDelegate(
              anchorRect: Rect.fromLTWH(
                _anchorLeft,
                _anchorTop,
                _anchorWidth,
                _anchorHeight,
              ),
              gap: resolved.gap,
            ),
            child: overlay,
          ),
        );
      },
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      expanded: _controller.isOpen,
      child: portal,
    );
  }

  Widget _buildOverlay(BuildContext overlayContext, MPopoverStyle s) {
    final Widget body = widget.popoverBuilder(
      overlayContext,
      _controller.close,
    );

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: s.backgroundColor,
        borderRadius: s.radius,
        border: s.borderColor != null
            ? Border.all(color: s.borderColor!, width: s.borderWidth)
            : null,
        boxShadow: s.elevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: s.shadowColor,
                  blurRadius: s.elevation,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: s.padding,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: s.foregroundColor),
          child: body,
        ),
      ),
    );

    if (widget.matchAnchorWidth && _anchorWidth > 0) {
      surface = ConstrainedBox(
        constraints: BoxConstraints(minWidth: _anchorWidth),
        child: surface,
      );
    }

    return surface;
  }
}

class _PopoverPositionDelegate extends SingleChildLayoutDelegate {
  const _PopoverPositionDelegate({required this.anchorRect, required this.gap});

  static const double _edgeInset = 8;

  final Rect anchorRect;
  final double gap;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxUsableHeight = math.max(
      0,
      constraints.maxHeight - (_edgeInset * 2),
    );
    final double above = (anchorRect.top - gap - _edgeInset).clamp(
      0,
      maxUsableHeight,
    );
    final double below =
        (constraints.maxHeight - anchorRect.bottom - gap - _edgeInset).clamp(
          0,
          maxUsableHeight,
        );
    return BoxConstraints(
      maxWidth: math.max(0, constraints.maxWidth - (_edgeInset * 2)),
      maxHeight: math.max(above, below),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double roomAbove = math.max(0, anchorRect.top - gap - _edgeInset);
    final double roomBelow = math.max(
      0,
      size.height - anchorRect.bottom - gap - _edgeInset,
    );
    final bool placeBelow =
        childSize.height <= roomBelow || roomBelow >= roomAbove;

    double top = placeBelow
        ? anchorRect.bottom + gap
        : anchorRect.top - gap - childSize.height;
    final double maxTop = math.max(
      _edgeInset,
      size.height - _edgeInset - childSize.height,
    );
    top = top.clamp(_edgeInset, maxTop);

    final bool alignTrailing = anchorRect.center.dx > size.width / 2;
    double left = alignTrailing
        ? anchorRect.right - childSize.width
        : anchorRect.left;
    final double maxLeft = math.max(
      _edgeInset,
      size.width - _edgeInset - childSize.width,
    );
    left = left.clamp(_edgeInset, maxLeft);
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(covariant _PopoverPositionDelegate oldDelegate) {
    return anchorRect != oldDelegate.anchorRect || gap != oldDelegate.gap;
  }
}
