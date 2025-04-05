import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import '../menu/menu_item.dart';
import '../popover/popover.dart' show MPopoverController;
import 'context_menu_style.dart';

/// A right-click / long-press menu anchored to the pointer location.
///
/// Wraps a [child] target region. On secondary-button click (mouse) or
/// long-press (touch) anywhere inside [child], a popover of [items] opens
/// at the pointer location. The popover is modal: a translucent dismiss
/// layer behind it closes the menu on outside tap; Escape also closes.
/// Focus is trapped inside the popover and returns on close.
///
/// ```dart
/// MContextMenu(
///   items: <MMenuItem>[
///     MMenuItem(id: 'copy', title: const Text('Copy'), onTap: _copy),
///     MMenuItem(id: 'paste', title: const Text('Paste'), onTap: _paste),
///   ],
///   child: Container(color: const Color(0xFFEEEEEE)),
/// )
/// ```
///
/// Up/Down navigate enabled items with wraparound; Home/End jump to
/// first/last; Enter/Space activate; Escape closes.
class MContextMenu extends StatefulWidget {
  /// Builds a context menu.
  const MContextMenu({
    required this.child,
    required this.items,
    this.controller,
    this.onOpen,
    this.onClose,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    super.key,
  });

  /// The target region wrapped by the gesture detector.
  final Widget child;

  /// The items rendered in the popover.
  ///
  /// Must contain at least one entry; each [MMenuItem.id] must be unique.
  final List<MMenuItem> items;

  /// The controller that drives open/close state.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, [MContextMenu] creates and owns one
  /// internally.
  final MPopoverController? controller;

  /// Called when the menu opens.
  final VoidCallback? onOpen;

  /// Called when the menu closes, regardless of cause (outside tap,
  /// Escape, item activation, programmatic close).
  final VoidCallback? onClose;

  /// Whether the menu responds to user gestures. Disabling the widget
  /// closes any currently open menu and ignores future right-clicks /
  /// long-presses on [child]. Programmatic `controller.open()` is still
  /// honored — controllers are authoritative.
  final bool enabled;

  /// The input modality this menu should size itself for. When null, the
  /// menu resolves modality from [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MContextMenuStyle].
  final MContextMenuStyleDelta? style;

  /// An optional accessibility label applied to the popover surface.
  final String? semanticLabel;

  @override
  State<MContextMenu> createState() => _MContextMenuState();
}

class _MContextMenuState extends State<MContextMenu> {
  late MPopoverController _controller;
  bool _ownsController = false;

  final OverlayPortalController _portal = OverlayPortalController();
  final FocusScopeNode _scope =
      FocusScopeNode(debugLabel: 'MContextMenu scope');

  // Pointer location captured by the gesture detector, in **global** coords.
  // The overlay layout delegate converts back to overlay-local at paint time.
  Offset? _globalAnchor;

  // The focused-item id while the menu is open. Drives item highlighting
  // and Enter activation. Cleared on close.
  String? _focusedItemId;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    if (_controller.isOpen) {
      // Defer overlay portal show until after the first frame — OverlayPortal
      // refuses show()/hide() during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.isOpen) _syncOverlay();
      });
    }
  }

  @override
  void didUpdateWidget(covariant MContextMenu old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncOverlay();
      });
    }
    if (!widget.enabled && _controller.isOpen) {
      // Disabling closes any open menu. Defer the assignment — the
      // listener's call into _syncOverlay must run outside build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !widget.enabled) _controller.close();
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
    _syncOverlay();
  }

  void _syncOverlay() {
    final bool wantOpen = _controller.isOpen;
    if (wantOpen && !_portal.isShowing) {
      _portal.show();
      // First enabled item gets focus when the menu opens via the
      // controller — driven by initial keyboard down, this gives Up/Down
      // an immediate target.
      _focusedItemId = _firstEnabledId();
      // Move FocusScope focus to the popover after the portal mounts.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scope.parent != null) _scope.requestFocus();
      });
      widget.onOpen?.call();
      setState(() {});
    } else if (!wantOpen && _portal.isShowing) {
      _portal.hide();
      _focusedItemId = null;
      widget.onClose?.call();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _unbindController();
    _scope.dispose();
    super.dispose();
  }

  String? _firstEnabledId() {
    for (final MMenuItem i in widget.items) {
      if (i.enabled) return i.id;
    }
    return null;
  }

  void _openAt(Offset globalPosition) {
    if (!widget.enabled) return;
    _globalAnchor = globalPosition;
    if (_controller.isOpen) {
      // Re-open at a new location — same single popover, just move the
      // anchor and rebuild.
      setState(() {});
    } else {
      _controller.open();
    }
  }

  void _close() {
    _controller.close();
  }

  void _moveItemFocus(int delta) {
    final List<MMenuItem> enabled =
        widget.items.where((MMenuItem i) => i.enabled).toList();
    if (enabled.isEmpty) return;
    final int current = _focusedItemId == null
        ? -1
        : enabled.indexWhere((MMenuItem i) => i.id == _focusedItemId);
    int next;
    if (current < 0) {
      next = delta > 0 ? 0 : enabled.length - 1;
    } else {
      next = (current + delta) % enabled.length;
      if (next < 0) next += enabled.length;
    }
    setState(() => _focusedItemId = enabled[next].id);
  }

  void _focusFirstItem() {
    final String? id = _firstEnabledId();
    if (id == null) return;
    setState(() => _focusedItemId = id);
  }

  void _focusLastItem() {
    String? last;
    for (final MMenuItem i in widget.items) {
      if (i.enabled) last = i.id;
    }
    if (last == null) return;
    setState(() => _focusedItemId = last);
  }

  void _activateItem(MMenuItem item) {
    if (!item.enabled) return;
    item.onTap?.call();
    _close();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveItemFocus(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveItemFocus(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _focusFirstItem();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _focusLastItem();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      final String? focused = _focusedItemId;
      if (focused == null) return KeyEventResult.ignored;
      final MMenuItem? item = widget.items
          .where((MMenuItem i) => i.id == focused)
          .cast<MMenuItem?>()
          .firstWhere((MMenuItem? _) => true, orElse: () => null);
      if (item == null) return KeyEventResult.ignored;
      _activateItem(item);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
    final MContextMenuStyle resolved = theme.contextMenu
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
          typography: theme.typography,
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final bool isTouch = resolvedModality == MInputModality.touch;

    // Gesture detector wrapping the child. Secondary-button tap (mouse)
    // and long-press (touch) both open at the pointer location.
    //
    // We use a Listener for the secondary-button path because GestureDetector
    // doesn't expose a position-aware secondaryTap by default in the
    // gesture-arena friendly variant. Listener gives us raw pointer events
    // without arena contention.
    final Widget target = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent e) {
        if (!widget.enabled) return;
        if (e.kind == PointerDeviceKind.mouse &&
            e.buttons & kSecondaryMouseButton != 0) {
          _openAt(e.position);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onLongPressStart: (LongPressStartDetails d) {
          if (!widget.enabled) return;
          if (!isTouch) return;
          _openAt(d.globalPosition);
        },
        child: widget.child,
      ),
    );

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (BuildContext overlayContext) =>
          _buildOverlay(overlayContext, resolved),
      child: target,
    );
  }

  Widget _buildOverlay(BuildContext overlayContext, MContextMenuStyle s) {
    // The overlay portal renders its overlay child inside the ambient
    // Overlay, whose local coordinate system matches the global one (the
    // Overlay fills the screen). So the pointer position recorded by the
    // gesture detector — which is in global coords — can be used directly
    // as the anchor for the layout delegate.
    //
    // When no pointer gesture has been recorded (e.g. programmatic open),
    // fall back to the overlay's center so the menu has a sensible
    // default position.
    Offset localAnchor;
    if (_globalAnchor != null) {
      localAnchor = _globalAnchor!;
    } else {
      final RenderBox? overlayBox =
          overlayContext.findRenderObject() as RenderBox?;
      localAnchor = overlayBox != null
          ? overlayBox.size.center(Offset.zero)
          : Offset.zero;
    }

    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < widget.items.length; i++) {
      if (i > 0) rows.add(SizedBox(height: s.itemSpacing));
      final MMenuItem item = widget.items[i];
      rows.add(
        _MContextMenuItemRow(
          item: item,
          style: s,
          isFocused: item.id == _focusedItemId,
          enabled: widget.enabled && item.enabled,
          onTap: () => _activateItem(item),
          onHover: () {
            if (_focusedItemId != item.id) {
              setState(() => _focusedItemId = item.id);
            }
          },
        ),
      );
    }

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: s.surfaceBackgroundColor,
        borderRadius: s.surfaceRadius,
        border: s.surfaceBorderColor != null
            ? Border.all(
                color: s.surfaceBorderColor!,
                width: s.surfaceBorderWidth,
              )
            : null,
        boxShadow: s.surfaceElevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: s.surfaceShadowColor,
                  blurRadius: s.surfaceElevation,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: s.surfacePadding,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: s.surfaceForegroundColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ),
    );

    surface = IntrinsicWidth(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: s.surfaceMinWidth,
          maxWidth: s.surfaceMaxWidth,
        ),
        child: surface,
      ),
    );

    if (widget.semanticLabel != null) {
      surface = Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.semanticLabel,
        child: surface,
      );
    }

    final Widget positioned = CustomSingleChildLayout(
      delegate: _PointerAnchoredMenuLayout(
        anchor: localAnchor,
        viewportPadding: s.viewportPadding,
      ),
      child: surface,
    );

    final Widget focused = FocusScope(
      node: _scope,
      onKeyEvent: _onKeyEvent,
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: positioned,
      ),
    );

    return Stack(
      children: <Widget>[
        // Translucent modal barrier — a tap anywhere outside the popover
        // closes the menu. HitTestBehavior.translucent lets the barrier
        // paint nothing while still receiving the tap.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
            // Right-click on the barrier should also be able to open a new
            // menu at the new location — without first closing-then-reopening
            // (which would feel sluggish). We listen for secondary-button
            // events and re-anchor in place.
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (PointerDownEvent e) {
                if (e.kind == PointerDeviceKind.mouse &&
                    e.buttons & kSecondaryMouseButton != 0) {
                  // Re-anchor without closing; setState rebuilds the layout.
                  setState(() {
                    _globalAnchor = e.position;
                    _focusedItemId = _firstEnabledId();
                  });
                }
              },
            ),
          ),
        ),
        focused,
      ],
    );
  }
}

/// Layout delegate that positions a child at [anchor], then slides it
/// inward from each viewport edge until it fits, leaving at least
/// [viewportPadding] logical pixels of clearance.
///
/// Used by [MContextMenu] to clamp the menu's top-left to the pointer
/// location while keeping the surface fully on-screen. v0.1 does NOT
/// auto-flip to anchor the menu's top-right at the pointer when there
/// isn't room to the right; it just slides left.
class _PointerAnchoredMenuLayout extends SingleChildLayoutDelegate {
  _PointerAnchoredMenuLayout({
    required this.anchor,
    required this.viewportPadding,
  });

  final Offset anchor;
  final double viewportPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // Allow the menu to grow up to the viewport size minus padding on
    // each side. The IntrinsicWidth + ConstrainedBox wrapping inside
    // takes care of the desired width.
    final double maxW =
        (constraints.maxWidth - 2 * viewportPadding).clamp(0.0, double.infinity);
    final double maxH =
        (constraints.maxHeight - 2 * viewportPadding).clamp(0.0, double.infinity);
    return BoxConstraints(
      minWidth: 0,
      maxWidth: maxW,
      minHeight: 0,
      maxHeight: maxH,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = anchor.dx;
    double y = anchor.dy;
    // Clamp right edge first (slide left if we would overflow), then left
    // edge (prefer keeping the menu visible if the anchor itself is past
    // the right viewport boundary).
    if (x + childSize.width > size.width - viewportPadding) {
      x = size.width - viewportPadding - childSize.width;
    }
    if (x < viewportPadding) x = viewportPadding;
    if (y + childSize.height > size.height - viewportPadding) {
      y = size.height - viewportPadding - childSize.height;
    }
    if (y < viewportPadding) y = viewportPadding;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _PointerAnchoredMenuLayout old) {
    return old.anchor != anchor || old.viewportPadding != viewportPadding;
  }
}

class _MContextMenuItemRow extends StatelessWidget {
  const _MContextMenuItemRow({
    required this.item,
    required this.style,
    required this.isFocused,
    required this.enabled,
    required this.onTap,
    required this.onHover,
  });

  final MMenuItem item;
  final MContextMenuStyle style;
  final bool isFocused;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final Widget title = DefaultTextStyle.merge(
      style: style.itemTextStyle.copyWith(color: style.itemForegroundColor),
      child: item.title,
    );

    final List<Widget> rowChildren = <Widget>[title];
    if (item.trailing != null) {
      rowChildren.add(const SizedBox(width: 24));
      rowChildren.add(
        DefaultTextStyle.merge(
          style: style.itemTextStyle
              .copyWith(color: style.itemTrailingForegroundColor),
          child: item.trailing!,
        ),
      );
    }

    Widget body = Padding(
      padding: style.itemPadding,
      child: Row(
        mainAxisAlignment: item.trailing != null
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: rowChildren,
      ),
    );

    body = SizedBox(height: style.itemHeight, child: body);

    body = DecoratedBox(
      decoration: BoxDecoration(
        color: isFocused
            ? style.itemHoveredBackgroundColor
            : const Color(0x00000000),
        borderRadius: style.itemRadius,
      ),
      child: body,
    );

    if (!enabled) {
      body = Opacity(opacity: style.disabledOpacity, child: body);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      selected: isFocused,
      container: true,
      child: MouseRegion(
        onEnter: enabled ? (_) => onHover() : null,
        cursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: body,
        ),
      ),
    );
  }
}
