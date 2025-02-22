import 'package:flutter/widgets.dart';

/// Lifecycle owner for a sibling-anchored overlay.
///
/// Holds the [OverlayPortalController], [LayerLink], and [FocusScopeNode].
/// Hold one in [State] (not in [build]), dispose in [State.dispose], and
/// pass it to a sibling [MOverlayAnchor]. On [close], focus returns to
/// [anchorFocusNode] if it was supplied to [open] -- opt-in because
/// non-modal overlays (tooltips) have no anchor focus to restore.
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
  /// When [autofocus] is true (the default), focus moves into the overlay's
  /// [FocusScope] on the next frame. Pass false for non-modal surfaces
  /// (tooltips) to avoid stealing focus. Pass [anchorFocusNode] so [close]
  /// can restore focus on dismiss.
  void open({FocusNode? anchorFocusNode, bool autofocus = true}) {
    if (_open) return;
    _open = true;
    _anchorFocusNode = anchorFocusNode;
    _portal.show();
    if (autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scope.parent != null) _scope.requestFocus();
      });
    }
  }

  /// Hide the overlay. Returns focus to the anchor node if one was set.
  /// Safe to call when already closed.
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
/// Installs a [CompositedTransformTarget] around [anchor] and an
/// [OverlayPortal] whose child is positioned by a
/// [CompositedTransformFollower]. When [modalBarrier] is true (default), a
/// full-screen dismiss barrier and route-scope semantics are installed.
/// Requires an ambient [Overlay] -- provided by [MWidgetsApp] or
/// `pumpManyApp(installOverlay: true)` in tests.
class MOverlayAnchor extends StatelessWidget {
  /// Creates an overlay anchor.
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
  final Offset overlayOffset;

  /// Called when the modal barrier is tapped. Ignored when [modalBarrier] is
  /// false.
  final VoidCallback? onDismiss;

  /// Handler for keyboard events while the overlay holds focus.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Install a full-screen dismiss barrier and route-scope semantics.
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
