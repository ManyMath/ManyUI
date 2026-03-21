import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../foundation/overlay_anchor.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'tooltip_style.dart';

/// A small floating label anchored to a child widget.
///
/// `MTooltip` wraps any widget and surfaces a textual hint on its preferred
/// side on hover (mouse), long-press (touch), or programmatic trigger. If the
/// hint would cross a viewport edge, it automatically flips vertically and
/// shifts horizontally to remain readable. The hint never blocks pointer
/// events on the rest of the screen — unlike
/// [MSelect]'s popover, the tooltip surface is fully click-through, and an
/// outside tap dismisses it without being swallowed.
///
/// ```dart
/// MTooltip(
///   message: 'Settings',
///   child: MButton(
///     onPressed: () {},
///     child: const Icon(Icons.settings),
///   ),
/// )
/// ```
///
/// **Modality.**
/// - `MInputModality.mouse`: show after `style.showDelay` of continuous
///   hover; hide after `style.hideDelay` once the pointer leaves both the
///   anchor and the tooltip surface.
/// - `MInputModality.touch`: show on long-press; hide on pointer-up or on a
///   tap anywhere outside the anchor.
/// - Other modalities: tooltip can still be shown programmatically by
///   driving the [controller], but no automatic gesture triggers fire.
///
/// **Semantics.** The message is injected into the anchor's accessibility
/// tree via `Semantics(tooltip: ...)`; the tooltip surface itself does not
/// add a separate semantic node, so screen readers read the label exactly
/// once.
class MTooltip extends StatefulWidget {
  /// Builds a tooltip-wrapped [child].
  const MTooltip({
    required this.message,
    required this.child,
    this.placement = MTooltipPlacement.above,
    this.modality,
    this.style,
    this.enabled = true,
    super.key,
  });

  /// The text shown inside the tooltip surface and injected into the
  /// anchor's `Semantics(tooltip: ...)`.
  final String message;

  /// The widget the tooltip is anchored to.
  final Widget child;

  /// The preferred side for the tooltip relative to [child].
  ///
  /// The tooltip automatically flips to the opposite side when there is not
  /// enough room, and shifts within the viewport at horizontal edges.
  final MTooltipPlacement placement;

  /// The input modality this tooltip should respond to.
  ///
  /// When null, resolves from [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MTooltipStyle].
  final MTooltipStyleDelta? style;

  /// When false, the tooltip does not render and ignores hover/long-press.
  /// The child is still rendered.
  final bool enabled;

  @override
  State<MTooltip> createState() => _MTooltipState();
}

class _MTooltipState extends State<MTooltip> {
  final MOverlayAnchorController _anchor = MOverlayAnchorController(
    debugLabel: 'MTooltip',
  );

  Timer? _showTimer;
  Timer? _hideTimer;
  Size _anchorSize = Size.zero;
  Offset _anchorOffset = Offset.zero;
  bool _pointerInsideAnchor = false;
  // Subscribed to GestureBinding.pointerRouter while the tooltip is open so a
  // tap anywhere on the screen can dismiss it without being swallowed.
  PointerRoute? _outsideTapRoute;

  @override
  void dispose() {
    _cancelTimers();
    _detachOutsideTap();
    _anchor.dispose();
    super.dispose();
  }

  void _cancelTimers() {
    _showTimer?.cancel();
    _showTimer = null;
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _measureAnchor() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _anchorSize = box.size;

    final RenderBox? overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (overlayBox != null && overlayBox.hasSize) {
      _anchorOffset = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    } else {
      _anchorOffset = box.localToGlobal(Offset.zero);
    }
  }

  void _scheduleShow(Duration delay) {
    if (!widget.enabled || _anchor.isOpen || _showTimer != null) return;
    _hideTimer?.cancel();
    _hideTimer = null;
    if (delay == Duration.zero) {
      _showNow();
    } else {
      _showTimer = Timer(delay, _showNow);
    }
  }

  void _scheduleHide(Duration delay) {
    if (!_anchor.isOpen) return;
    _showTimer?.cancel();
    _showTimer = null;
    if (delay == Duration.zero) {
      _hideNow();
    } else {
      _hideTimer = Timer(delay, _hideNow);
    }
  }

  void _showNow() {
    _showTimer = null;
    if (!mounted || _anchor.isOpen) return;
    _measureAnchor();
    setState(() {});
    _anchor.open(autofocus: false);
    _attachOutsideTap();
  }

  void _hideNow() {
    _hideTimer = null;
    if (!_anchor.isOpen) return;
    _anchor.close();
    _detachOutsideTap();
    if (mounted) setState(() {});
  }

  void _attachOutsideTap() {
    if (_outsideTapRoute != null) return;
    _outsideTapRoute = _onOutsidePointer;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_outsideTapRoute!);
  }

  void _detachOutsideTap() {
    if (_outsideTapRoute == null) return;
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_outsideTapRoute!);
    _outsideTapRoute = null;
  }

  void _onOutsidePointer(PointerEvent event) {
    if (event is! PointerDownEvent) return;
    if (!mounted || !_anchor.isOpen) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final Offset local = box.globalToLocal(event.position);
    final bool insideAnchor =
        local.dx >= 0 &&
        local.dy >= 0 &&
        local.dx <= box.size.width &&
        local.dy <= box.size.height;
    if (!insideAnchor) _hideNow();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality = MInputModalityScope.resolve(
      context,
      widget.modality,
    );
    final MTooltipStyle resolved = theme.tooltip
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    // Anchor wraps the child with hover and long-press detectors. The wrap
    // is mostly transparent — the child still gets all of its own gestures.
    Widget anchor = widget.child;

    if (widget.enabled && resolvedModality == MInputModality.mouse) {
      anchor = MouseRegion(
        onEnter: (_) {
          _pointerInsideAnchor = true;
          _scheduleShow(resolved.showDelay);
        },
        onExit: (_) {
          _pointerInsideAnchor = false;
          _scheduleHide(resolved.hideDelay);
        },
        child: anchor,
      );
    }

    if (widget.enabled && resolvedModality == MInputModality.touch) {
      anchor = GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onLongPress: _showNow,
        onLongPressEnd: (_) => _hideNow(),
        child: anchor,
      );
    }

    anchor = Semantics(
      tooltip: widget.message,
      container: false,
      child: anchor,
    );

    return MOverlayAnchor(
      controller: _anchor,
      anchor: anchor,
      // Move the follower's coordinate origin back to the overlay origin. The
      // layout delegate can then measure its child and place it against all
      // four viewport edges while the follower still tracks its anchor layer.
      overlayOffset: -_anchorOffset,
      modalBarrier: false,
      overlayBuilder: (BuildContext overlayContext) {
        final Widget surface = _TooltipSurface(
          message: widget.message,
          style: resolved,
          onHoverEnter: () {
            // Pointer crossed into the tooltip — cancel any pending hide so
            // users can move from anchor to surface without losing it.
            _hideTimer?.cancel();
            _hideTimer = null;
          },
          onHoverExit: () {
            if (!_pointerInsideAnchor) _scheduleHide(resolved.hideDelay);
          },
        );
        return CustomSingleChildLayout(
          delegate: _TooltipLayoutDelegate(
            anchor: _anchorOffset & _anchorSize,
            preferredPlacement: widget.placement,
            gap: resolved.gap,
          ),
          child: ExcludeSemantics(child: surface),
        );
      },
    );
  }
}

const double _kTooltipViewportInset = 8;

/// Positions a measured tooltip inside the overlay viewport.
///
/// The preferred side wins whenever it fits. If it does not, the opposite
/// side wins when it fits; when neither side fits, the side with more room is
/// chosen and clamped. Horizontal placement is centered on the anchor and
/// shifted at either edge.
class _TooltipLayoutDelegate extends SingleChildLayoutDelegate {
  const _TooltipLayoutDelegate({
    required this.anchor,
    required this.preferredPlacement,
    required this.gap,
  });

  final Rect anchor;
  final MTooltipPlacement preferredPlacement;
  final double gap;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double horizontalInset = math.min(
      _kTooltipViewportInset,
      constraints.maxWidth / 2,
    );
    final double verticalInset = math.min(
      _kTooltipViewportInset,
      constraints.maxHeight / 2,
    );
    final double maxWidth = math.max(
      0,
      constraints.maxWidth - (horizontalInset * 2),
    );
    final double maxHeight = math.max(
      0,
      constraints.maxHeight - (verticalInset * 2),
    );
    return BoxConstraints.loose(Size(maxWidth, maxHeight));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double horizontalInset = math.min(
      _kTooltipViewportInset,
      size.width / 2,
    );
    final double verticalInset = math.min(
      _kTooltipViewportInset,
      size.height / 2,
    );
    final double minX = horizontalInset;
    final double maxX = size.width - horizontalInset - childSize.width;
    final double centeredX = anchor.center.dx - (childSize.width / 2);
    final double x = centeredX.clamp(minX, maxX).toDouble();

    final double minY = verticalInset;
    final double maxY = size.height - verticalInset - childSize.height;
    final double aboveY = anchor.top - gap - childSize.height;
    final double belowY = anchor.bottom + gap;
    final bool fitsAbove = aboveY >= minY;
    final bool fitsBelow = belowY <= maxY;
    final double availableAbove = anchor.top - gap - minY;
    final double availableBelow =
        size.height - verticalInset - gap - anchor.bottom;

    final bool placeAbove = switch (preferredPlacement) {
      MTooltipPlacement.above when fitsAbove => true,
      MTooltipPlacement.below when fitsBelow => false,
      MTooltipPlacement.above when fitsBelow => false,
      MTooltipPlacement.below when fitsAbove => true,
      MTooltipPlacement.above => availableAbove >= availableBelow,
      MTooltipPlacement.below => availableAbove > availableBelow,
    };
    final double preferredY = placeAbove ? aboveY : belowY;
    return Offset(x, preferredY.clamp(minY, maxY).toDouble());
  }

  @override
  bool shouldRelayout(_TooltipLayoutDelegate oldDelegate) {
    return anchor != oldDelegate.anchor ||
        preferredPlacement != oldDelegate.preferredPlacement ||
        gap != oldDelegate.gap;
  }
}

class _TooltipSurface extends StatelessWidget {
  const _TooltipSurface({
    required this.message,
    required this.style,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  final String message;
  final MTooltipStyle style;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;

  @override
  Widget build(BuildContext context) {
    final MTooltipStyle s = style;

    final Widget body = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: s.maxWidth),
      child: DecoratedBox(
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
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: s.padding,
          child: Text(
            message,
            style: s.textStyle.copyWith(color: s.foregroundColor),
            softWrap: true,
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );

    return MouseRegion(
      key: const ValueKey<String>('MTooltip.surface'),
      onEnter: (_) => onHoverEnter(),
      onExit: (_) => onHoverExit(),
      child: body,
    );
  }
}
