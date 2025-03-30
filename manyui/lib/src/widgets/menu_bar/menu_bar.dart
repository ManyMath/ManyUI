import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../foundation/overlay_anchor.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import '../menu/menu_item.dart';
import 'menu_bar_style.dart';

export '../menu/menu_item.dart' show MMenuItem;

/// A single menu declaration consumed by [MMenuBar].
///
/// `id` is the value the [MMenuBarController] stores while this menu is
/// open. `title` is rendered inside the strip; `items` are rendered inside
/// the popover that appears below the title when the menu opens.
@immutable
class MMenu {
  /// Builds a menu declaration.
  const MMenu({
    required this.id,
    required this.title,
    required this.items,
    this.enabled = true,
  });

  /// Stable identifier for this menu within its enclosing [MMenuBar].
  final String id;

  /// The widget rendered inside the strip for this menu.
  final Widget title;

  /// The items rendered inside the popover when this menu is open.
  final List<MMenuItem> items;

  /// Whether this menu responds to user interaction.
  final bool enabled;
}

/// Controller for [MMenuBar]; stores the open menu id or null.
///
/// ```dart
/// final MMenuBarController menus = MMenuBarController();
/// menus.value = 'file';  // opens "File"
/// menus.value = null;    // closes everything
/// ```
class MMenuBarController extends MController<String?> {
  /// Builds a controller seeded with the supplied menu [id] (or `null` for
  /// "no menu open").
  MMenuBarController([super.initial]);
}

/// A top-of-screen menu strip: a horizontal row of clickable menu titles,
/// each of which opens an anchored popover of items below it.
///
/// ```dart
/// MMenuBar(
///   menus: <MMenu>[
///     MMenu(id: 'file', title: const Text('File'), items: <MMenuItem>[
///       MMenuItem(id: 'new', title: const Text('New'), onTap: _newDoc),
///       MMenuItem(id: 'open', title: const Text('Open'), onTap: _openDoc),
///     ]),
///     MMenu(id: 'edit', title: const Text('Edit'), items: <MMenuItem>[
///       MMenuItem(id: 'undo', title: const Text('Undo'), onTap: _undo),
///     ]),
///   ],
/// )
/// ```
///
/// Click-to-open: tapping a menu title opens its popover (and tapping again
/// closes it). When any menu is already open, moving the pointer onto a
/// different menu title swaps which menu is open without re-clicking — the
/// platform menu-bar idiom. Keyboard nav follows the WAI-ARIA menu bar
/// pattern: Left/Right cycle the focused menu title (skipping disabled
/// menus); Down or Enter opens it and moves focus to the first item;
/// Up/Down within the open popover navigate between enabled items; Enter
/// activates the focused item (closing the menu); Escape closes and returns
/// focus to the menu title.
class MMenuBar extends StatefulWidget {
  /// Builds a menu bar.
  const MMenuBar({
    required this.menus,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    super.key,
  });

  /// The menus rendered in the strip.
  ///
  /// Must contain at least one entry. Each menu's [MMenu.id] must be unique
  /// within the list.
  final List<MMenu> menus;

  /// The state source for this bar.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the bar creates and owns one seeded with
  /// `null` (no menu open).
  final MMenuBarController? controller;

  /// Called whenever the open menu changes — either through user interaction
  /// or programmatic mutation of the underlying controller. The argument is
  /// the newly-open menu's id, or `null` when the bar transitioned to
  /// "no menu open".
  final ValueChanged<String?>? onChanged;

  /// Whether the bar as a whole responds to user interaction. Disabling the
  /// bar disables every menu regardless of its own [MMenu.enabled] flag and
  /// closes any currently open menu.
  final bool enabled;

  /// The input modality this bar should size itself for. When null, the bar
  /// resolves modality from [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MMenuBarStyle].
  final MMenuBarStyleDelta? style;

  /// An optional accessibility label for the bar as a whole.
  final String? semanticLabel;

  @override
  State<MMenuBar> createState() => _MMenuBarState();
}

class _MMenuBarState extends State<MMenuBar> {
  late MMenuBarController _controller;
  bool _ownsController = false;

  // One FocusNode per menu title, keyed by menu id. Synced in initState and
  // didUpdateWidget; nodes for removed menus are disposed.
  final Map<String, FocusNode> _titleNodes = <String, FocusNode>{};

  // One MOverlayAnchorController per menu, keyed by menu id. Only the
  // currently-open menu's anchor is open at any time.
  final Map<String, MOverlayAnchorController> _anchors =
      <String, MOverlayAnchorController>{};

  // The focused-item id inside the currently-open menu. Null when no menu is
  // open or when no item has been focused yet (e.g. mouse just opened the
  // menu and the user hasn't pressed Down). Drives item highlighting and
  // Enter activation.
  String? _focusedItemId;

  // The most-recently-focused title id. Updated by each FocusableActionDetector's
  // onFocusChange. Used by keyboard nav instead of polling primaryFocus —
  // FocusManager dispatches focus changes asynchronously, but our shortcut
  // handler needs an answer right now.
  String? _focusedTitleId;

  // Shared tap-region group id for the strip and each popover. A
  // PointerDown outside every TapRegion in this group fires `onTapOutside`
  // on the popover and closes the open menu — without installing a
  // full-screen modal barrier that would swallow taps on sibling titles.
  late final Object _tapRegionGroup = Object();

  late final Map<Type, Action<Intent>> _stripActions = <Type, Action<Intent>>{
    _MoveMenuFocusIntent: CallbackAction<_MoveMenuFocusIntent>(
      onInvoke: (_MoveMenuFocusIntent intent) {
        _moveTitleFocus(intent.direction);
        return null;
      },
    ),
    _OpenFocusedMenuIntent: CallbackAction<_OpenFocusedMenuIntent>(
      onInvoke: (_) {
        _openFocusedMenu();
        return null;
      },
    ),
    _MoveItemFocusIntent: CallbackAction<_MoveItemFocusIntent>(
      onInvoke: (_MoveItemFocusIntent intent) {
        final String? openId = _controller.value;
        if (openId == null) return null;
        final MMenu menu =
            widget.menus.firstWhere((MMenu m) => m.id == openId);
        _moveItemFocus(menu, intent.delta);
        return null;
      },
    ),
    _CloseMenuIntent: CallbackAction<_CloseMenuIntent>(
      onInvoke: (_) {
        if (_controller.value == null) return null;
        final String openId = _controller.value!;
        final MMenu menu =
            widget.menus.firstWhere((MMenu m) => m.id == openId);
        _closeFromPopover(menu);
        return null;
      },
    ),
  };

  static const Map<ShortcutActivator, Intent> _stripShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowLeft):
        _MoveMenuFocusIntent(_MoveDirection.previous),
    SingleActivator(LogicalKeyboardKey.arrowRight):
        _MoveMenuFocusIntent(_MoveDirection.next),
    SingleActivator(LogicalKeyboardKey.home):
        _MoveMenuFocusIntent(_MoveDirection.first),
    SingleActivator(LogicalKeyboardKey.end):
        _MoveMenuFocusIntent(_MoveDirection.last),
    SingleActivator(LogicalKeyboardKey.arrowDown): _OpenFocusedMenuIntent(),
    SingleActivator(LogicalKeyboardKey.arrowUp): _MoveItemFocusIntent(-1),
    SingleActivator(LogicalKeyboardKey.escape): _CloseMenuIntent(),
  };

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    _syncTitleNodes();
    _syncAnchors();
    if (_controller.value != null) _focusedTitleId = _controller.value;
    if (!widget.enabled && _controller.value != null) {
      // Defer — assigning the controller during initState triggers
      // _onControllerChanged → _syncOpenAnchor, which calls into the
      // OverlayPortal, illegal during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.value = null;
      });
    } else if (_controller.value != null) {
      // OverlayPortal refuses show()/hide() in the build phase, so defer the
      // initial open-sync until after the first frame. Also seed focus on
      // the matching title so keyboard nav has a starting point even when
      // the menu was opened programmatically rather than via tap.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncOpenAnchor();
        final FocusNode? node = _titleNodes[_controller.value];
        node?.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant MMenuBar old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
      // Defer overlay sync — OverlayPortal refuses show()/hide() in the build
      // phase, and didUpdateWidget runs during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncOpenAnchor();
      });
    }
    if (!widget.enabled && _controller.value != null) {
      // Disabling the bar closes any open menu. Defer the assignment — the
      // listener's call into _syncOpenAnchor must run outside the build
      // phase to satisfy OverlayPortal's show()/hide() preconditions.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !widget.enabled) _controller.value = null;
      });
    }
    _syncTitleNodes();
    _syncAnchors();
  }

  void _bindController(MMenuBarController? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MMenuBarController();
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
    _syncOpenAnchor();
    if (_controller.value == null) {
      _focusedItemId = null;
    } else {
      // Tracking the focused title id lets the keyboard handlers act
      // immediately on the freshly-opened menu's id, even when the open was
      // driven programmatically rather than via tap.
      _focusedTitleId = _controller.value;
    }
    setState(() {});
  }

  void _syncTitleNodes() {
    final Set<String> ids = widget.menus.map((MMenu m) => m.id).toSet();
    final List<String> stale =
        _titleNodes.keys.where((String id) => !ids.contains(id)).toList();
    for (final String id in stale) {
      _titleNodes.remove(id)?.dispose();
    }
    for (final MMenu menu in widget.menus) {
      _titleNodes.putIfAbsent(
        menu.id,
        () => FocusNode(debugLabel: 'MMenu(${menu.id}) title'),
      );
    }
  }

  void _syncAnchors() {
    final Set<String> ids = widget.menus.map((MMenu m) => m.id).toSet();
    final List<String> stale =
        _anchors.keys.where((String id) => !ids.contains(id)).toList();
    for (final String id in stale) {
      _anchors.remove(id)?.dispose();
    }
    for (final MMenu menu in widget.menus) {
      _anchors.putIfAbsent(
        menu.id,
        () => MOverlayAnchorController(debugLabel: 'MMenuBar(${menu.id})'),
      );
    }
  }

  void _syncOpenAnchor() {
    final String? wantOpen = _controller.value;
    for (final MapEntry<String, MOverlayAnchorController> entry
        in _anchors.entries) {
      final bool shouldBeOpen = entry.key == wantOpen;
      if (shouldBeOpen && !entry.value.isOpen) {
        // Intentionally do not pass anchorFocusNode — return-focus is
        // handled explicitly by `_closeFromPopover` so it doesn't fire
        // during menu-to-menu swaps and steal focus back to the old title.
        entry.value.open(autofocus: false);
      } else if (!shouldBeOpen && entry.value.isOpen) {
        entry.value.close();
      }
    }
  }

  @override
  void dispose() {
    _unbindController();
    for (final FocusNode node in _titleNodes.values) {
      node.dispose();
    }
    _titleNodes.clear();
    for (final MOverlayAnchorController a in _anchors.values) {
      a.dispose();
    }
    _anchors.clear();
    super.dispose();
  }

  bool _effectiveEnabledFor(MMenu menu) => widget.enabled && menu.enabled;

  // Public-facing activation entry points.

  void _activateTitle(MMenu menu) {
    if (!_effectiveEnabledFor(menu)) return;
    // If this menu is open AND an item inside it is focused (via keyboard
    // navigation), Enter on the title activates the focused item — not the
    // title itself. Tap-on-title still falls through to the toggle path
    // because the GestureDetector calls _activateTitle directly without
    // any focused-item context.
    if (_controller.value == menu.id && _focusedItemId != null) {
      final MMenuItem item =
          menu.items.firstWhere((MMenuItem i) => i.id == _focusedItemId);
      _activateItem(menu, item);
      return;
    }
    _focusedTitleId = menu.id;
    _titleNodes[menu.id]?.requestFocus();
    final String? current = _controller.value;
    final String? next = current == menu.id ? null : menu.id;
    _setControllerValue(next);
  }

  void _hoverSwitch(MMenu menu) {
    // Hover-to-switch only takes effect when *some* menu is already open —
    // and only to enabled menus. Hovering over a closed menu bar is a no-op.
    if (!_effectiveEnabledFor(menu)) return;
    if (_controller.value == null) return;
    if (_controller.value == menu.id) return;
    _setControllerValue(menu.id);
  }

  void _setControllerValue(String? next) {
    if (_controller.value == next) return;
    _controller.value = next;
    widget.onChanged?.call(next);
  }

  // Title-strip keyboard nav.

  void _moveTitleFocus(_MoveDirection direction) {
    final List<MMenu> enabled =
        widget.menus.where(_effectiveEnabledFor).toList();
    if (enabled.isEmpty) return;

    final String? currentId = _focusedTitleId;
    final int idx = currentId == null
        ? -1
        : enabled.indexWhere((MMenu m) => m.id == currentId);

    MMenu target;
    switch (direction) {
      case _MoveDirection.previous:
        target = idx <= 0 ? enabled.last : enabled[idx - 1];
      case _MoveDirection.next:
        target = idx < 0 || idx >= enabled.length - 1
            ? enabled.first
            : enabled[idx + 1];
      case _MoveDirection.first:
        target = enabled.first;
      case _MoveDirection.last:
        target = enabled.last;
    }

    _focusedTitleId = target.id;
    _titleNodes[target.id]?.requestFocus();
    // If a menu is already open, sliding focus between titles also slides
    // which menu is open — this is the open-menu Left/Right behavior the
    // WAI-ARIA pattern prescribes.
    if (_controller.value != null) {
      _setControllerValue(target.id);
    }
  }

  void _openFocusedMenu() {
    // Down arrow on the strip. When no menu is open, this opens the
    // focused menu and moves item-focus to the first enabled item. When the
    // focused menu is already open, advance item-focus instead — the user
    // is navigating through the open popover.
    final String? focusedId = _focusedTitleId;
    if (focusedId == null) return;
    final MMenu menu =
        widget.menus.firstWhere((MMenu m) => m.id == focusedId);
    if (!_effectiveEnabledFor(menu)) return;
    if (_controller.value == menu.id) {
      _moveItemFocus(menu, 1);
      return;
    }
    _setControllerValue(menu.id);
    _focusFirstItem(menu);
  }

  void _focusFirstItem(MMenu menu) {
    final MMenuItem? first =
        menu.items.where((MMenuItem i) => i.enabled).cast<MMenuItem?>().firstWhere(
              (MMenuItem? _) => true,
              orElse: () => null,
            );
    if (first == null) return;
    setState(() => _focusedItemId = first.id);
  }

  void _focusLastItem(MMenu menu) {
    MMenuItem? last;
    for (final MMenuItem i in menu.items) {
      if (i.enabled) last = i;
    }
    final MMenuItem? captured = last;
    if (captured == null) return;
    setState(() => _focusedItemId = captured.id);
  }

  void _moveItemFocus(MMenu menu, int delta) {
    final List<MMenuItem> enabled =
        menu.items.where((MMenuItem i) => i.enabled).toList();
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

  void _activateItem(MMenu menu, MMenuItem item) {
    if (!item.enabled) return;
    item.onTap?.call();
    // Close after activation; the controller listener also clears
    // _focusedItemId.
    _setControllerValue(null);
  }

  void _closeFromPopover(MMenu menu) {
    _setControllerValue(null);
    // Return focus to the menu title.
    _titleNodes[menu.id]?.requestFocus();
  }

  KeyEventResult _popoverKeyEvent(MMenu menu, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _closeFromPopover(menu);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveItemFocus(menu, 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveItemFocus(menu, -1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _focusFirstItem(menu);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _focusLastItem(menu);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      final String? focused = _focusedItemId;
      if (focused == null) return KeyEventResult.ignored;
      final MMenuItem? item = menu.items
          .where((MMenuItem i) => i.id == focused)
          .cast<MMenuItem?>()
          .firstWhere((MMenuItem? _) => true, orElse: () => null);
      if (item == null) return KeyEventResult.ignored;
      _activateItem(menu, item);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveTitleFocus(_MoveDirection.previous);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveTitleFocus(_MoveDirection.next);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onPopoverDismiss(MMenu menu) {
    // Outside tap on the modal barrier — drive close through the controller
    // so listeners observe the state change.
    _setControllerValue(null);
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
    final MMenuBarStyle resolved = theme.menuBar
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
          typography: theme.typography,
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final String? openId = _controller.value;

    final List<Widget> stripChildren = <Widget>[];
    for (int i = 0; i < widget.menus.length; i++) {
      if (i > 0) {
        stripChildren.add(SizedBox(width: resolved.titleSpacing));
      }
      final MMenu menu = widget.menus[i];
      stripChildren.add(
        _MMenuTitle(
          menu: menu,
          isOpen: openId == menu.id,
          enabled: _effectiveEnabledFor(menu),
          style: resolved,
          focusNode: _titleNodes[menu.id]!,
          anchor: _anchors[menu.id]!,
          onTap: () => _activateTitle(menu),
          onHoverEnter: () => _hoverSwitch(menu),
          onFocusChange: (bool focused) {
            if (focused) _focusedTitleId = menu.id;
          },
          buildOverlay: (BuildContext overlayContext) =>
              _buildPopover(overlayContext, menu, resolved),
          onKeyEvent: (FocusNode n, KeyEvent e) =>
              _popoverKeyEvent(menu, n, e),
        ),
      );
    }

    final Widget strip = Shortcuts(
      shortcuts: _stripShortcuts,
      child: Actions(
        actions: _stripActions,
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: TapRegion(
            groupId: _tapRegionGroup,
            child: SizedBox(
              height: resolved.titleHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: stripChildren,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.semanticLabel == null) return strip;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: strip,
    );
  }

  Widget _buildPopover(
    BuildContext overlayContext,
    MMenu menu,
    MMenuBarStyle s,
  ) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < menu.items.length; i++) {
      if (i > 0) rows.add(SizedBox(height: s.itemSpacing));
      final MMenuItem item = menu.items[i];
      rows.add(
        _MMenuItemRow(
          item: item,
          style: s,
          isFocused: item.id == _focusedItemId,
          enabled: widget.enabled && menu.enabled && item.enabled,
          onTap: () => _activateItem(menu, item),
          onHover: () {
            if (_focusedItemId != item.id) {
              setState(() => _focusedItemId = item.id);
            }
          },
        ),
      );
    }

    final Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: s.popoverBackgroundColor,
        borderRadius: s.popoverRadius,
        border: s.popoverBorderColor != null
            ? Border.all(
                color: s.popoverBorderColor!,
                width: s.popoverBorderWidth,
              )
            : null,
        boxShadow: s.popoverElevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: s.popoverShadowColor,
                  blurRadius: s.popoverElevation,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: s.popoverPadding,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: s.popoverForegroundColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ),
    );

    return TapRegion(
      groupId: _tapRegionGroup,
      onTapOutside: (PointerDownEvent _) {
        // Tap landed outside the strip AND outside this popover — close.
        _onPopoverDismiss(menu);
      },
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: s.popoverMinWidth,
            maxWidth: 320,
          ),
          child: surface,
        ),
      ),
    );
  }
}

class _MMenuTitle extends StatefulWidget {
  const _MMenuTitle({
    required this.menu,
    required this.isOpen,
    required this.enabled,
    required this.style,
    required this.focusNode,
    required this.anchor,
    required this.onTap,
    required this.onHoverEnter,
    required this.onFocusChange,
    required this.buildOverlay,
    required this.onKeyEvent,
  });

  final MMenu menu;
  final bool isOpen;
  final bool enabled;
  final MMenuBarStyle style;
  final FocusNode focusNode;
  final MOverlayAnchorController anchor;
  final VoidCallback onTap;
  final VoidCallback onHoverEnter;
  final ValueChanged<bool> onFocusChange;
  final WidgetBuilder buildOverlay;
  final FocusOnKeyEventCallback onKeyEvent;

  @override
  State<_MMenuTitle> createState() => _MMenuTitleState();
}

class _MMenuTitleState extends State<_MMenuTitle> {
  bool _hovered = false;
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        if (widget.enabled) widget.onTap();
        return null;
      },
    ),
  };

  void _onShowFocus(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final MMenuBarStyle s = widget.style;

    Color background;
    if (widget.isOpen) {
      background = s.activeTitleBackgroundColor;
    } else if (_hovered && widget.enabled) {
      background = s.hoveredTitleBackgroundColor;
    } else {
      background = const Color(0x00000000);
    }

    Widget label = DefaultTextStyle.merge(
      style: s.titleTextStyle.copyWith(color: s.titleForegroundColor),
      child: widget.menu.title,
    );

    label = Padding(padding: s.titlePadding, child: Center(child: label));

    Widget body = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: s.titleRadius,
      ),
      child: label,
    );

    body = SizedBox(height: s.titleHeight, child: body);

    if (!widget.enabled) {
      body = Opacity(opacity: s.disabledOpacity, child: body);
    }

    body = MFocusRing(focused: _focused, child: body);

    final Widget interactive = FocusableActionDetector(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      onShowFocusHighlight: _onShowFocus,
      onFocusChange: widget.onFocusChange,
      onShowHoverHighlight: (bool v) {
        if (_hovered != v) setState(() => _hovered = v);
      },
      mouseCursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: _actions,
      child: MouseRegion(
        onEnter: (_) {
          // Hover-to-switch when a sibling menu is open. The state callback is
          // hoisted to the parent _MMenuBarState.
          if (widget.enabled) widget.onHoverEnter();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? widget.onTap : null,
          child: body,
        ),
      ),
    );

    // Wrap in semantics so a11y consumers see the menu title, its open state,
    // and its enabled state.
    final Widget semantic = Semantics(
      button: true,
      enabled: widget.enabled,
      expanded: widget.isOpen,
      container: true,
      child: interactive,
    );

    return MOverlayAnchor(
      controller: widget.anchor,
      anchor: semantic,
      overlayOffset: Offset(0, widget.style.titleHeight + widget.style.popoverGap),
      modalBarrier: false,
      onKeyEvent: widget.onKeyEvent,
      overlayBuilder: widget.buildOverlay,
    );
  }
}

class _MMenuItemRow extends StatelessWidget {
  const _MMenuItemRow({
    required this.item,
    required this.style,
    required this.isFocused,
    required this.enabled,
    required this.onTap,
    required this.onHover,
  });

  final MMenuItem item;
  final MMenuBarStyle style;
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
        cursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: body,
        ),
      ),
    );
  }
}

enum _MoveDirection { previous, next, first, last }

class _MoveMenuFocusIntent extends Intent {
  const _MoveMenuFocusIntent(this.direction);
  final _MoveDirection direction;
}

class _OpenFocusedMenuIntent extends Intent {
  const _OpenFocusedMenuIntent();
}

class _MoveItemFocusIntent extends Intent {
  const _MoveItemFocusIntent(this.delta);
  final int delta;
}

class _CloseMenuIntent extends Intent {
  const _CloseMenuIntent();
}
