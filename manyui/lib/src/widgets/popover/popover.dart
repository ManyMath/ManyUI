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
typedef MPopoverContentBuilder = Widget Function(
  BuildContext context,
  VoidCallback close,
);

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
/// The popover opens below the anchor and does not auto-flip on overflow.
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

  final MOverlayAnchorController _anchor =
      MOverlayAnchorController(debugLabel: 'MPopover');

  final FocusNode _anchorFocusNode = FocusNode(debugLabel: 'MPopover anchor');

  double _anchorWidth = 0;

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
      _anchor.open(anchorFocusNode: _anchorFocusNode);
      if (mounted) setState(() {});
    } else if (!wantOpen && _anchor.isOpen) {
      _anchor.close();
      widget.onClose?.call();
      if (mounted) setState(() {});
    }
  }

  void _measureAnchor() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    _anchorWidth = (box != null && box.hasSize) ? box.size.width : 0;
  }

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
      overlayOffset: Offset(0, _measuredAnchorHeight() + resolved.gap),
      onDismiss: _handleDismiss,
      onKeyEvent: _onKeyEvent,
      overlayBuilder: (BuildContext overlayContext) =>
          _buildOverlay(overlayContext, resolved),
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      expanded: _controller.isOpen,
      child: portal,
    );
  }

  double _measuredAnchorHeight() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 0;
    return box.size.height;
  }

  Widget _buildOverlay(BuildContext overlayContext, MPopoverStyle s) {
    final Widget body = widget.popoverBuilder(overlayContext, _controller.close);

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
