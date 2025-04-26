import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'accordion_style.dart';

/// Selection mode for [MAccordion].
enum MAccordionMode {
  /// At most one item expanded at a time.
  single,

  /// Any number of items expanded simultaneously.
  multiple,
}

/// A single item declaration consumed by [MAccordion].
@immutable
class MAccordionItem {
  /// Builds an accordion item.
  const MAccordionItem({
    required this.id,
    required this.title,
    required this.content,
    this.trailing,
    this.enabled = true,
  });

  /// Unique identifier within the enclosing [MAccordion].
  final String id;

  /// The widget rendered in the header strip for this item.
  final Widget title;

  /// The widget revealed when this item is expanded.
  final Widget content;

  /// Optional widget rendered between the title and the chevron (e.g. a
  /// badge or icon). Renders to the right of [title] but to the left of the
  /// chevron.
  final Widget? trailing;

  /// Whether this item responds to user interaction.
  final bool enabled;
}

/// A vertical strip of expand/collapse items.
///
/// State is an `MController<Set<String>>` of expanded item ids. In
/// [MAccordionMode.single] mode at most one item is expanded at a time;
/// in [MAccordionMode.multiple] any number may be open simultaneously.
///
/// ```dart
/// MAccordion(
///   mode: MAccordionMode.single,
///   items: const <MAccordionItem>[
///     MAccordionItem(id: 'one', title: Text('One'), content: Text('Body 1')),
///     MAccordionItem(id: 'two', title: Text('Two'), content: Text('Body 2')),
///   ],
/// )
/// ```
///
/// Up/Down move focus between headers (wraparound, skips disabled).
/// Home/End jump to first/last enabled header.
/// Enter/Space/numpadEnter toggle the focused header.
class MAccordion extends StatefulWidget {
  /// Builds an accordion.
  const MAccordion({
    required this.items,
    this.mode = MAccordionMode.single,
    this.controller,
    this.initialExpanded = const <String>{},
    this.onChanged,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    super.key,
  });

  /// The item declarations rendered in the accordion. Must contain at least
  /// one entry; each `id` must be unique.
  final List<MAccordionItem> items;

  /// Single-expand vs multi-expand mode.
  final MAccordionMode mode;

  /// The state source for this accordion.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the widget creates and owns one seeded with
  /// [initialExpanded].
  final MController<Set<String>>? controller;

  /// The seed set for the internal controller. Ignored when [controller] is
  /// non-null. Defaults to the empty set (nothing expanded).
  final Set<String> initialExpanded;

  /// Called whenever the expanded-set changes — through user interaction or
  /// programmatic mutation of the underlying controller.
  final ValueChanged<Set<String>>? onChanged;

  /// Whether the accordion as a whole responds to user interaction.
  /// Disabling the accordion disables every item regardless of its own
  /// [MAccordionItem.enabled] flag.
  final bool enabled;

  /// The input modality this accordion should size itself for.
  ///
  /// When null, resolves from [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MAccordionStyle].
  final MAccordionStyleDelta? style;

  /// An optional accessibility label for the accordion as a whole.
  final String? semanticLabel;

  @override
  State<MAccordion> createState() => _MAccordionState();
}

class _MAccordionState extends State<MAccordion> {
  late MController<Set<String>> _controller;
  bool _ownsController = false;

  // One FocusNode per item. Built lazily; rebuilt on items-list change.
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    _MoveFocusIntent: CallbackAction<_MoveFocusIntent>(
      onInvoke: (_MoveFocusIntent intent) {
        _moveFocus(intent.direction);
        return null;
      },
    ),
  };

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowUp):
        _MoveFocusIntent(_MoveDirection.previous),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        _MoveFocusIntent(_MoveDirection.next),
    SingleActivator(LogicalKeyboardKey.home):
        _MoveFocusIntent(_MoveDirection.first),
    SingleActivator(LogicalKeyboardKey.end):
        _MoveFocusIntent(_MoveDirection.last),
  };

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(covariant MAccordion old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
    _syncFocusNodes();
  }

  void _bindController(MController<Set<String>>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller =
          MController<Set<String>>(Set<String>.from(widget.initialExpanded));
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
    final Set<String> ids =
        widget.items.map((MAccordionItem i) => i.id).toSet();
    final List<String> stale =
        _focusNodes.keys.where((String id) => !ids.contains(id)).toList();
    for (final String id in stale) {
      _focusNodes.remove(id)?.dispose();
    }
    for (final MAccordionItem item in widget.items) {
      _focusNodes.putIfAbsent(
        item.id,
        () => FocusNode(debugLabel: 'MAccordionItem(${item.id})'),
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

  bool _effectiveEnabledFor(MAccordionItem item) =>
      widget.enabled && item.enabled;

  void _toggle(MAccordionItem item) {
    if (!_effectiveEnabledFor(item)) return;
    // Move focus to the item header so subsequent keyboard nav from this row
    // works (Up/Down move from the focused header).
    _focusNodes[item.id]?.requestFocus();
    final Set<String> current = Set<String>.from(_controller.value);
    final bool isExpanded = current.contains(item.id);
    Set<String> next;
    if (widget.mode == MAccordionMode.single) {
      // Single mode: tapping the active item collapses it (empty set is a
      // valid state); tapping any other item collapses the rest and expands
      // the target.
      if (isExpanded) {
        next = <String>{};
      } else {
        next = <String>{item.id};
      }
    } else {
      if (isExpanded) {
        current.remove(item.id);
      } else {
        current.add(item.id);
      }
      next = current;
    }
    _controller.value = next;
    widget.onChanged?.call(next);
  }

  void _moveFocus(_MoveDirection direction) {
    final List<MAccordionItem> enabled =
        widget.items.where(_effectiveEnabledFor).toList();
    if (enabled.isEmpty) return;

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
          enabled.indexWhere((MAccordionItem i) => i.id == currentId);
    }

    MAccordionItem target;
    switch (direction) {
      case _MoveDirection.previous:
        target = currentInEnabled <= 0
            ? enabled.last
            : enabled[currentInEnabled - 1];
      case _MoveDirection.next:
        target = currentInEnabled < 0 || currentInEnabled >= enabled.length - 1
            ? enabled.first
            : enabled[currentInEnabled + 1];
      case _MoveDirection.first:
        target = enabled.first;
      case _MoveDirection.last:
        target = enabled.last;
    }

    _focusNodes[target.id]?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality modality =
        MInputModalityScope.resolve(context, widget.modality);
    final MAccordionStyle resolved = theme.accordion
        .resolve(
          modality: modality,
          colors: theme.colors,
          typography: theme.typography,
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final Set<String> expanded = _controller.value;

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < widget.items.length; i++) {
      if (i > 0) {
        children.add(Container(
          height: resolved.itemDividerThickness,
          color: resolved.itemDividerColor,
        ));
      }
      final MAccordionItem item = widget.items[i];
      children.add(_MAccordionRow(
        item: item,
        isExpanded: expanded.contains(item.id),
        enabled: _effectiveEnabledFor(item),
        style: resolved,
        focusNode: _focusNodes[item.id]!,
        onTap: () => _toggle(item),
      ));
    }

    final BoxDecoration decoration = BoxDecoration(
      color: resolved.surfaceBackgroundColor,
      borderRadius: resolved.surfaceRadius,
      border: (resolved.surfaceBorderColor != null &&
              resolved.surfaceBorderWidth > 0)
          ? Border.all(
              color: resolved.surfaceBorderColor!,
              width: resolved.surfaceBorderWidth,
            )
          : null,
    );

    final Widget body = Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: _actions,
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: ClipRRect(
            borderRadius: resolved.surfaceRadius.resolve(TextDirection.ltr),
            child: DecoratedBox(
              decoration: decoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.semanticLabel == null) return body;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: body,
    );
  }
}

class _MAccordionRow extends StatefulWidget {
  const _MAccordionRow({
    required this.item,
    required this.isExpanded,
    required this.enabled,
    required this.style,
    required this.focusNode,
    required this.onTap,
  });

  final MAccordionItem item;
  final bool isExpanded;
  final bool enabled;
  final MAccordionStyle style;
  final FocusNode focusNode;
  final VoidCallback onTap;

  @override
  State<_MAccordionRow> createState() => _MAccordionRowState();
}

class _MAccordionRowState extends State<_MAccordionRow> {
  bool _focused = false;
  bool _hovered = false;

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

  void _onHover(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final MAccordionStyle s = widget.style;

    final Widget title = DefaultTextStyle.merge(
      style: s.headerTitleTextStyle.copyWith(color: s.headerForegroundColor),
      child: widget.item.title,
    );

    final List<Widget> headerChildren = <Widget>[
      Expanded(child: title),
    ];
    if (widget.item.trailing != null) {
      headerChildren.add(Padding(
        padding: const EdgeInsets.only(left: 8),
        child: DefaultTextStyle.merge(
          style: s.headerTitleTextStyle
              .copyWith(color: s.headerForegroundColor),
          child: widget.item.trailing!,
        ),
      ));
    }
    headerChildren.add(Padding(
      padding: const EdgeInsets.only(left: 8),
      child: AnimatedRotation(
        turns: widget.isExpanded ? 0.5 : 0.0,
        duration: s.expandDuration,
        curve: Curves.easeOutCubic,
        child: _Chevron(color: s.chevronColor, size: s.chevronSize),
      ),
    ));

    Widget header = Padding(
      padding: s.headerPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: headerChildren,
      ),
    );

    header = ConstrainedBox(
      constraints: BoxConstraints(minHeight: s.headerHeight),
      child: header,
    );

    if (widget.enabled && _hovered) {
      header = ColoredBox(
        color: s.headerHoveredBackgroundColor,
        child: header,
      );
    }

    if (!widget.enabled) {
      header = Opacity(opacity: s.disabledOpacity, child: header);
    }

    header = MFocusRing(focused: _focused, child: header);

    final Widget headerInteractive = FocusableActionDetector(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      onShowFocusHighlight: _onShowFocus,
      onShowHoverHighlight: _onHover,
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
        onTap: widget.enabled ? widget.onTap : null,
        child: Semantics(
          button: true,
          enabled: widget.enabled,
          expanded: widget.isExpanded,
          container: true,
          child: header,
        ),
      ),
    );

    // AnimatedSize with a child whose Offstage flag toggles. When the body is
    // mounted but hidden (Offstage), AnimatedSize sees its size go to zero
    // and animates from current to zero (and vice versa).
    final Widget body = AnimatedSize(
      duration: s.expandDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: widget.isExpanded ? 1.0 : 0.0,
          child: Padding(
            padding: s.bodyPadding,
            child: DefaultTextStyle.merge(
              style: s.bodyTextStyle.copyWith(color: s.bodyForegroundColor),
              child: widget.item.content,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        headerInteractive,
        body,
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ChevronPainter(color: color),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.6
      ..color = color;
    final double w = size.width;
    final double h = size.height;
    // Downward chevron ^v: starts at left-top, mid-bottom, right-top.
    final Path path = Path()
      ..moveTo(w * 0.2, h * 0.35)
      ..lineTo(w * 0.5, h * 0.65)
      ..lineTo(w * 0.8, h * 0.35);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}

enum _MoveDirection { previous, next, first, last }

class _MoveFocusIntent extends Intent {
  const _MoveFocusIntent(this.direction);
  final _MoveDirection direction;
}
