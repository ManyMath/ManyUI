import 'package:flutter/widgets.dart';

/// Owns the lifecycle of a sibling-anchored overlay: the [OverlayPortal]
/// controller, the [LayerLink] threaded between anchor and follower, and the
/// [FocusScopeNode] that hosts the overlay's keyboard focus.
///
/// Hold one in [State] (not in [build] — see [OverlayPortalController]),
/// dispose it in [State.dispose], and hand it to a sibling [MOverlayAnchor]
/// widget. Call [open] and [close] to drive the overlay; [isOpen] reports
/// current state for `setState`-driven flags (e.g. accessibility `expanded`).
///
/// On [close], if [anchorFocusNode] was set when [open] was called, focus
/// returns to it so keyboard users keep their place. This is opt-in because
/// non-modal overlays (tooltips) typically have no anchor focus to return to.
class MOverlayAnchorController {
  /// Creates a controller.
  MOverlayAnchorController({String? debugLabel})
      : _scope = FocusScopeNode(debugLabel: debugLabel ?? 'MOverlayAnchor');

  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final FocusScopeNode _scope;

  bool _open = false;
  FocusNode? _anchorFocusNode;

  /// Whether the overlay is currently shown.
  bool get isOpen => _open;

  /// Show the overlay.
  ///
  /// After the next frame, focus is moved into the overlay's [FocusScope] so
  /// keyboard navigation can pick up immediately. Pass [anchorFocusNode] so
  /// [close] can return focus to it on dismiss.
  void open({FocusNode? anchorFocusNode}) {
    if (_open) return;
    _open = true;
    _anchorFocusNode = anchorFocusNode;
    _portal.show();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scope.parent != null) _scope.requestFocus();
    });
  }

  /// Hide the overlay.
  ///
  /// If [open] was called with an `anchorFocusNode`, focus is returned to it
  /// so keyboard users keep their place. Safe to call when [isOpen] is false.
  void close() {
    if (!_open) return;
    _open = false;
    _portal.hide();
    final FocusNode? anchor = _anchorFocusNode;
    _anchorFocusNode = null;
    if (anchor != null) anchor.requestFocus();
  }

  /// Releases the [FocusScopeNode]. Call from [State.dispose].
  void dispose() {
    _scope.dispose();
  }
}

/// Wraps an anchor widget so it can host a follower overlay.
///
/// Installs the [CompositedTransformTarget] around [anchor] and an
/// [OverlayPortal] whose child is the user-supplied [overlayBuilder] result,
/// positioned by a [CompositedTransformFollower] linked to the anchor.
///
/// The standard popover stack (modal barrier behind, focus-scoped popover in
/// front) is built automatically. Set [modalBarrier] to false for non-modal
/// overlays (tooltips, hover surfaces); the caller is then responsible for
/// listening to outside taps via the gesture router if dismiss-on-tap is
/// wanted.
///
/// Place an instance of [MOverlayAnchor] anywhere a normal widget can go —
/// it needs an ambient [Overlay] (provided by `MWidgetsApp`, or by
/// `pumpManyApp(installOverlay: true)` in tests).
class MOverlayAnchor extends StatelessWidget {
  /// Creates an overlay anchor.
  ///
  /// [controller] owns the open/close lifecycle. [anchor] is rendered in its
  /// normal sibling position. [overlayBuilder] is called every time the
  /// overlay rebuilds; its return value is placed at [overlayOffset] from
  /// the anchor's top-left.
  ///
  /// When [modalBarrier] is true (default), a full-screen translucent gesture
  /// detector behind the overlay calls [onDismiss] on tap, and the popover
  /// surface is wrapped in `Semantics(scopesRoute: true,
  /// explicitChildNodes: true)`. When false, no barrier is installed and no
  /// route-scope semantics are emitted — tooltip-style overlays should pass
  /// false and listen for outside taps themselves.
  ///
  /// [onKeyEvent] is wired to the overlay's [FocusScope.onKeyEvent]. Use it
  /// to handle Escape, arrow keys, type-ahead, etc.
  const MOverlayAnchor({
    required this.controller,
    required this.anchor,
    required this.overlayBuilder,
    this.overlayOffset = Offset.zero,
    this.onDismiss,
    this.onKeyEvent,
    this.modalBarrier = true,
    super.key,
  });

  /// The controller that drives this overlay.
  final MOverlayAnchorController controller;

  /// The widget displayed in the normal layout flow.
  final Widget anchor;

  /// Builds the overlay's content. Called every frame the overlay is open.
  final WidgetBuilder overlayBuilder;

  /// The offset applied to the follower, in the anchor's coordinate space.
  ///
  /// Typically `Offset(0, anchorHeight + gap)` to place the overlay just
  /// below the anchor with a small gap.
  final Offset overlayOffset;

  /// Called when the modal barrier is tapped. Ignored when [modalBarrier] is
  /// false.
  final VoidCallback? onDismiss;

  /// Handler for keyboard events while the overlay holds focus.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Whether to install a full-screen translucent dismiss barrier and emit
  /// route-scope semantics.
  final bool modalBarrier;

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: controller._portal,
      overlayChildBuilder: (BuildContext overlayContext) =>
          _buildOverlay(overlayContext),
      child: CompositedTransformTarget(link: controller._link, child: anchor),
    );
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final Widget body = overlayBuilder(overlayContext);

    final Widget positioned = CompositedTransformFollower(
      link: controller._link,
      showWhenUnlinked: false,
      offset: overlayOffset,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: body,
      ),
    );

    final Widget focused = FocusScope(
      node: controller._scope,
      onKeyEvent: onKeyEvent,
      child: modalBarrier
          ? Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              child: positioned,
            )
          : positioned,
    );

    if (!modalBarrier) return focused;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        focused,
      ],
    );
  }
}
