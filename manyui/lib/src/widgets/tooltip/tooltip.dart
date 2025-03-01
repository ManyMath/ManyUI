import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../foundation/overlay_anchor.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'tooltip_style.dart';

/// A small floating label anchored to a child widget.
///
/// `MTooltip` wraps any widget and surfaces a textual hint above (or below)
/// it on hover (mouse), long-press (touch), or programmatic trigger. The
/// hint never blocks pointer events on the rest of the screen — unlike
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

  /// Where the tooltip sits relative to [child].
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
  final MOverlayAnchorController _anchor =
      MOverlayAnchorController(debugLabel: 'MTooltip');

  Timer? _showTimer;
  Timer? _hideTimer;
  Size _anchorSize = Size.zero;
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
    if (box != null && box.hasSize) _anchorSize = box.size;
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
    GestureBinding.instance.pointerRouter
        .removeGlobalRoute(_outsideTapRoute!);
    _outsideTapRoute = null;
  }

  void _onOutsidePointer(PointerEvent event) {
    if (event is! PointerDownEvent) return;
    if (!mounted || !_anchor.isOpen) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final Offset local = box.globalToLocal(event.position);
    final bool insideAnchor = local.dx >= 0 &&
        local.dy >= 0 &&
        local.dx <= box.size.width &&
        local.dy <= box.size.height;
    if (!insideAnchor) _hideNow();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
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

    final Offset overlayOffset = _resolveOffset(resolved);

    return MOverlayAnchor(
      controller: _anchor,
      anchor: anchor,
      overlayOffset: overlayOffset,
      modalBarrier: false,
      overlayBuilder: (BuildContext overlayContext) {
        return _TooltipSurface(
          message: widget.message,
          style: resolved,
          placement: widget.placement,
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
      },
    );
  }

  Offset _resolveOffset(MTooltipStyle s) {
    // We can't measure the tooltip surface ahead of time, so for "above" we
    // shift up by the tooltip's likely line height plus padding plus gap.
    // The Stack inside _TooltipSurface uses Align(bottomStart) so the
    // surface lines up with the offset's top — works for either placement.
    switch (widget.placement) {
      case MTooltipPlacement.above:
        // Negative y. We don't know exact tooltip height; the surface uses
        // Align(bottomStart) so its bottom edge meets the anchor's top.
        return Offset(0, -s.gap);
      case MTooltipPlacement.below:
        return Offset(0, _anchorSize.height + s.gap);
    }
  }
}

class _TooltipSurface extends StatelessWidget {
  const _TooltipSurface({
    required this.message,
    required this.style,
    required this.placement,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  final String message;
  final MTooltipStyle style;
  final MTooltipPlacement placement;
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

    final Widget hoverable = MouseRegion(
      onEnter: (_) => onHoverEnter(),
      onExit: (_) => onHoverExit(),
      child: body,
    );

    // For above-placement we don't know the surface height in advance, so
    // FractionalTranslation(0, -1) along Y lifts the surface so its bottom
    // edge sits at the anchored Y origin. Below-placement needs no shift.
    // The MouseRegion lives INSIDE the translation so its hit-test bounds
    // sit on the painted surface, not on the pre-translation origin.
    if (placement == MTooltipPlacement.above) {
      return FractionalTranslation(
        translation: const Offset(0, -1),
        child: hoverable,
      );
    }
    return hoverable;
  }
}
