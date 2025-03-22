import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'tabs_style.dart';

/// A single tab declaration consumed by [MTabs].
///
/// All `content` widgets stay mounted for the lifetime of [MTabs] via
/// [IndexedStack], so tab-local state survives switching.
@immutable
class MTab {
  /// Builds a tab declaration.
  const MTab({
    required this.id,
    required this.title,
    required this.content,
    this.enabled = true,
  });

  /// Unique identifier within the enclosing [MTabs].
  final String id;

  /// The widget shown in the strip for this tab.
  final Widget title;

  /// The widget shown in the content area when this tab is active.
  final Widget content;

  /// Whether this tab responds to user interaction.
  final bool enabled;
}

/// Controller for [MTabs]; stores the active tab id.
///
/// ```dart
/// final MTabsController tabs = MTabsController('overview');
/// tabs.addListener(() => print('switched to ${tabs.value}'));
/// tabs.value = 'settings';
/// ```
class MTabsController extends MController<String> {
  /// Builds a controller seeded with the supplied tab [id].
  MTabsController(super.initial);
}

/// A persistent-state navigation control: a horizontal strip of tab titles
/// with a content area that swaps based on the active tab.
///
/// ```dart
/// MTabs(
///   controller: MTabsController('overview'),
///   tabs: const <MTab>[
///     MTab(id: 'overview', title: Text('Overview'), content: _Overview()),
///     MTab(id: 'settings', title: Text('Settings'), content: _Settings()),
///   ],
/// )
/// ```
///
/// All content panes mount on first build and stay alive — tab-local state
/// (scroll position, text-field contents) survives switching back and forth.
/// Left/Right move focus between tabs and activate on focus; Home and End
/// jump to the first and last enabled tab respectively. Disabled tabs are
/// skipped by keyboard navigation.
class MTabs extends StatefulWidget {
  /// Builds a tab strip.
  const MTabs({
    required this.tabs,
    this.controller,
    this.initialId,
    this.onChanged,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    super.key,
  });

  /// The tab declarations rendered in the strip and content area.
  ///
  /// Must contain at least one entry. Each tab's [MTab.id] must be unique
  /// within the list.
  final List<MTab> tabs;

  /// The state source for this strip.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the strip creates and owns one seeded with
  /// [initialId] (or the first tab's id if [initialId] is null).
  final MTabsController? controller;

  /// The seed id for the internal controller. Ignored when [controller] is
  /// non-null. Defaults to the first tab's id.
  final String? initialId;

  /// Called whenever the active tab changes — either through user
  /// interaction or programmatic mutation of the underlying controller.
  final ValueChanged<String>? onChanged;

  /// Whether the strip as a whole responds to user interaction. Disabling
  /// the strip disables every tab regardless of its own [MTab.enabled] flag.
  final bool enabled;

  /// The input modality this strip should size itself for.
  ///
  /// When null, the strip resolves modality from
  /// [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MTabsStyle].
  final MTabsStyleDelta? style;

  /// An optional accessibility label for the strip as a whole.
  final String? semanticLabel;

  @override
  State<MTabs> createState() => _MTabsState();
}

class _MTabsState extends State<MTabs> {
  late MTabsController _controller;
  bool _ownsController = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    _MoveTabFocusIntent: CallbackAction<_MoveTabFocusIntent>(
      onInvoke: (_MoveTabFocusIntent intent) {
        _moveFocus(intent.direction);
        return null;
      },
    ),
  };

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowLeft):
        _MoveTabFocusIntent(_MoveDirection.previous),
    SingleActivator(LogicalKeyboardKey.arrowRight):
        _MoveTabFocusIntent(_MoveDirection.next),
    SingleActivator(LogicalKeyboardKey.home):
        _MoveTabFocusIntent(_MoveDirection.first),
    SingleActivator(LogicalKeyboardKey.end):
        _MoveTabFocusIntent(_MoveDirection.last),
  };

  // One FocusNode per tab. Built lazily; rebuilt on tabs-list change. Keyed
  // by tab id so a reorder doesn't dispose nodes whose tabs survived.
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(covariant MTabs old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
    _syncFocusNodes();
  }

  void _bindController(MTabsController? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      final String seed = widget.initialId ?? widget.tabs.first.id;
      _controller = MTabsController(seed);
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
    final Set<String> ids = widget.tabs.map((MTab t) => t.id).toSet();
    final List<String> stale =
        _focusNodes.keys.where((String id) => !ids.contains(id)).toList();
    for (final String id in stale) {
      _focusNodes.remove(id)?.dispose();
    }
    for (final MTab tab in widget.tabs) {
      _focusNodes.putIfAbsent(
        tab.id,
        () => FocusNode(debugLabel: 'MTab(${tab.id})'),
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

  bool _effectiveEnabledFor(MTab tab) => widget.enabled && tab.enabled;

  int _activeIndex() {
    final int i = widget.tabs.indexWhere((MTab t) => t.id == _controller.value);
    return i;
  }

  void _activate(MTab tab) {
    if (!_effectiveEnabledFor(tab)) return;
    // Move focus to the tab so subsequent keyboard nav from this row works.
    _focusNodes[tab.id]?.requestFocus();
    if (_controller.value == tab.id) return;
    _controller.value = tab.id;
    widget.onChanged?.call(tab.id);
  }

  void _moveFocus(_MoveDirection direction) {
    final List<MTab> enabledTabs =
        widget.tabs.where(_effectiveEnabledFor).toList();
    if (enabledTabs.isEmpty) return;

    final FocusNode? primary = FocusManager.instance.primaryFocus;
    String? currentId;
    for (final MapEntry<String, FocusNode> entry in _focusNodes.entries) {
      if (identical(entry.value, primary)) {
        currentId = entry.key;
        break;
      }
    }
    int currentInEnabled = -1;
    if (currentId != null) {
      currentInEnabled =
          enabledTabs.indexWhere((MTab t) => t.id == currentId);
    }

    MTab target;
    switch (direction) {
      case _MoveDirection.previous:
        target = currentInEnabled <= 0
            ? enabledTabs.last
            : enabledTabs[currentInEnabled - 1];
      case _MoveDirection.next:
        target = currentInEnabled < 0 || currentInEnabled >= enabledTabs.length - 1
            ? enabledTabs.first
            : enabledTabs[currentInEnabled + 1];
      case _MoveDirection.first:
        target = enabledTabs.first;
      case _MoveDirection.last:
        target = enabledTabs.last;
    }

    final FocusNode? node = _focusNodes[target.id];
    if (node != null) {
      node.requestFocus();
      _activate(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
    final MTabsStyle resolved = theme.tabs
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
          typography: theme.typography,
        )
        .applyDelta(widget.style);

    final int active = _activeIndex();

    final List<Widget> stripChildren = <Widget>[];
    for (int i = 0; i < widget.tabs.length; i++) {
      if (i > 0) {
        stripChildren.add(SizedBox(width: resolved.tabSpacing));
      }
      final MTab tab = widget.tabs[i];
      stripChildren.add(
        _MTabButton(
          tab: tab,
          isActive: i == active,
          enabled: _effectiveEnabledFor(tab),
          style: resolved,
          focusNode: _focusNodes[tab.id]!,
          onActivate: () => _activate(tab),
        ),
      );
    }

    // The IndexedStack needs a non-negative index even when the controller
    // points to no matching tab. Clamp to 0 in that case; the surface still
    // shows tab[0]'s content but no strip tab is highlighted.
    final int stackIndex = active < 0 ? 0 : active;

    final Widget strip = Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: _actions,
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: SizedBox(
            height: resolved.tabHeight + resolved.stripDividerThickness,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: resolved.stripDividerThickness,
                    color: resolved.stripDividerColor,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stripChildren,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final Widget content = Padding(
      padding: resolved.contentPadding,
      child: IndexedStack(
        index: stackIndex,
        sizing: StackFit.loose,
        children: <Widget>[
          for (final MTab tab in widget.tabs) KeyedSubtree(
            key: ValueKey<String>('m-tab-content-${tab.id}'),
            child: tab.content,
          ),
        ],
      ),
    );

    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[strip, content],
    );

    if (widget.semanticLabel == null) return column;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: column,
    );
  }
}

class _MTabButton extends StatefulWidget {
  const _MTabButton({
    required this.tab,
    required this.isActive,
    required this.enabled,
    required this.style,
    required this.focusNode,
    required this.onActivate,
  });

  final MTab tab;
  final bool isActive;
  final bool enabled;
  final MTabsStyle style;
  final FocusNode focusNode;
  final VoidCallback onActivate;

  @override
  State<_MTabButton> createState() => _MTabButtonState();
}

class _MTabButtonState extends State<_MTabButton> {
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        if (widget.enabled) widget.onActivate();
        return null;
      },
    ),
  };

  void _onShowFocus(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final MTabsStyle style = widget.style;
    final Color foreground = widget.isActive
        ? style.activeForegroundColor
        : style.inactiveForegroundColor;

    Widget title = DefaultTextStyle.merge(
      style: style.titleTextStyle.copyWith(color: foreground),
      child: widget.tab.title,
    );

    title = Padding(padding: style.tabPadding, child: Center(child: title));

    Widget tabBody = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isActive
                ? style.indicatorColor
                : const Color(0x00000000),
            width: style.indicatorThickness,
          ),
        ),
      ),
      child: title,
    );

    tabBody = SizedBox(height: style.tabHeight, child: tabBody);

    if (!widget.enabled) {
      tabBody = Opacity(opacity: style.disabledOpacity, child: tabBody);
    }

    tabBody = MFocusRing(focused: _focused, child: tabBody);

    final Widget interactive = FocusableActionDetector(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      onShowFocusHighlight: _onShowFocus,
      mouseCursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: _actions,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onActivate : null,
        child: tabBody,
      ),
    );

    return Semantics(
      selected: widget.isActive,
      enabled: widget.enabled,
      button: true,
      container: true,
      child: interactive,
    );
  }
}

enum _MoveDirection { previous, next, first, last }

class _MoveTabFocusIntent extends Intent {
  const _MoveTabFocusIntent(this.direction);

  final _MoveDirection direction;
}
