import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../foundation/overlay_anchor.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'select_style.dart';

/// One row in an [MSelect]'s popover.
@immutable
class MSelectItem<T> {
  /// Builds an item.
  const MSelectItem({
    required this.value,
    required this.label,
    this.enabled = true,
    this.leading,
    this.trailing,
  });

  /// The payload this item writes into the select's controller when chosen.
  final T value;

  /// The string shown for this row. Also used for type-to-search.
  final String label;

  /// Whether this row responds to user interaction.
  final bool enabled;

  /// An optional widget placed before [label] (typically an icon).
  final Widget? leading;

  /// An optional widget placed after [label] (typically a hint or shortcut
  /// glyph).
  final Widget? trailing;
}

/// A button-anchored single-select dropdown with keyboard support.
///
/// Closed, `MSelect<T>` renders as a button-style anchor showing the
/// currently-selected item's label (or the [placeholder] when no value is
/// set). Tapping the anchor, pressing Enter/Space while it is focused, or
/// pressing arrow-down opens a popover containing a column of selectable
/// rows.
///
/// Selection is held by an [MController] of type `T?` — nullable so "no
/// selection" is representable. Callers may supply [controller] (and own
/// its lifecycle), or omit it and let `MSelect` create and dispose one
/// seeded with [initialValue].
///
/// ```dart
/// MSelect<String>(
///   placeholder: 'Pick a fruit',
///   items: const <MSelectItem<String>>[
///     MSelectItem<String>(value: 'apple', label: 'Apple'),
///     MSelectItem<String>(value: 'banana', label: 'Banana'),
///   ],
///   onChanged: (String? v) => print('picked $v'),
/// )
/// ```
class MSelect<T> extends StatefulWidget {
  /// Builds a select.
  const MSelect({
    required this.items,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// The options shown in the popover.
  final List<MSelectItem<T>> items;

  /// The state source for this select.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the widget creates and owns one seeded with
  /// [initialValue].
  final MController<T?>? controller;

  /// The seed value for the internal controller. Pass `null` to start with
  /// no selection.
  ///
  /// Ignored when [controller] is non-null.
  final T? initialValue;

  /// Called whenever the selection changes — either through user interaction
  /// or programmatic mutation of the underlying controller.
  final ValueChanged<T?>? onChanged;

  /// The text shown in the anchor when no value is selected.
  final String? placeholder;

  /// Whether the select responds to user interaction.
  final bool enabled;

  /// The input modality this select should size itself for.
  ///
  /// When null, the select resolves modality from
  /// [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MSelectStyle].
  final MSelectStyleDelta? style;

  /// An optional accessibility label for the anchor.
  ///
  /// Pair with an `MLabel` for visible labels.
  final String? semanticLabel;

  /// Whether the anchor should request focus on first build.
  final bool autofocus;

  /// An optional [FocusNode] the caller owns for the anchor.
  ///
  /// When null, the anchor creates and disposes its own node.
  final FocusNode? focusNode;

  @override
  State<MSelect<T>> createState() => _MSelectState<T>();
}

class _MSelectState<T> extends State<MSelect<T>> {
  late MController<T?> _controller;
  bool _ownsController = false;

  final MOverlayAnchorController _anchor =
      MOverlayAnchorController(debugLabel: 'MSelect popover');

  FocusNode? _ownedAnchorNode;
  bool _anchorFocused = false;
  bool _open = false;
  int _focusedIndex = -1;
  double _anchorWidth = 0;
  String _searchBuffer = '';
  DateTime _lastKeyAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _searchTimeout = Duration(milliseconds: 600);

  late final Map<Type, Action<Intent>> _anchorActions =
      <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        _open ? _closePopover(commit: false) : _openPopover();
        return null;
      },
    ),
    DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
      onInvoke: (DirectionalFocusIntent intent) {
        if (intent.direction == TraversalDirection.down ||
            intent.direction == TraversalDirection.up) {
          if (!_open) _openPopover();
        }
        return null;
      },
    ),
  };

  static const Map<ShortcutActivator, Intent> _anchorShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        DirectionalFocusIntent(TraversalDirection.down),
    SingleActivator(LogicalKeyboardKey.arrowUp):
        DirectionalFocusIntent(TraversalDirection.up),
  };

  FocusNode get _anchorNode {
    if (widget.focusNode != null) return widget.focusNode!;
    return _ownedAnchorNode ??= FocusNode(debugLabel: 'MSelect anchor');
  }

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant MSelect<T> old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
  }

  void _bindController(MController<T?>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MController<T?>(widget.initialValue);
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

  @override
  void dispose() {
    _unbindController();
    _ownedAnchorNode?.dispose();
    _anchor.dispose();
    super.dispose();
  }

  int _firstEnabledIndex({int from = 0, int step = 1}) {
    if (widget.items.isEmpty) return -1;
    int i = from;
    while (i >= 0 && i < widget.items.length) {
      if (widget.items[i].enabled) return i;
      i += step;
    }
    return -1;
  }

  int _indexOfValue(T? value) {
    if (value == null) return -1;
    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].value == value) return i;
    }
    return -1;
  }

  void _openPopover() {
    if (!widget.enabled || _open) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    _anchorWidth = box?.size.width ?? 0;

    final int selected = _indexOfValue(_controller.value);
    int initialFocus = selected;
    if (initialFocus < 0 || !widget.items[initialFocus].enabled) {
      initialFocus = _firstEnabledIndex();
    }

    setState(() {
      _open = true;
      _focusedIndex = initialFocus;
      _searchBuffer = '';
    });
    _anchor.open(anchorFocusNode: _anchorNode);
  }

  void _closePopover({required bool commit, T? committedValue}) {
    if (!_open) return;
    if (commit && committedValue != null) {
      if (_controller.value != committedValue) {
        _controller.value = committedValue;
        widget.onChanged?.call(committedValue);
      }
    }
    setState(() {
      _open = false;
      _focusedIndex = -1;
      _searchBuffer = '';
    });
    // Helper handles hide + return-focus-to-anchor.
    _anchor.close();
  }

  void _moveFocus(int direction) {
    if (widget.items.isEmpty) return;
    int next = _focusedIndex;
    do {
      next += direction;
      if (next < 0) next = widget.items.length - 1;
      if (next >= widget.items.length) next = 0;
      if (next == _focusedIndex) return;
    } while (!widget.items[next].enabled);
    setState(() => _focusedIndex = next);
  }

  void _activateFocused() {
    if (_focusedIndex < 0 || _focusedIndex >= widget.items.length) return;
    final MSelectItem<T> item = widget.items[_focusedIndex];
    if (!item.enabled) return;
    _closePopover(commit: true, committedValue: item.value);
  }

  void _typeAhead(String char) {
    if (char.isEmpty) return;
    final DateTime now = DateTime.now();
    if (now.difference(_lastKeyAt) > _searchTimeout) {
      _searchBuffer = '';
    }
    _searchBuffer += char.toLowerCase();
    _lastKeyAt = now;

    for (int i = 0; i < widget.items.length; i++) {
      final MSelectItem<T> item = widget.items[i];
      if (!item.enabled) continue;
      if (item.label.toLowerCase().startsWith(_searchBuffer)) {
        setState(() => _focusedIndex = i);
        return;
      }
    }
  }

  void _onAnchorShowFocus(bool value) {
    if (_anchorFocused != value) {
      setState(() => _anchorFocused = value);
    }
  }

  KeyEventResult _onPopoverKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _closePopover(commit: false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      final int first = _firstEnabledIndex();
      if (first >= 0) setState(() => _focusedIndex = first);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      final int last =
          _firstEnabledIndex(from: widget.items.length - 1, step: -1);
      if (last >= 0) setState(() => _focusedIndex = last);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _activateFocused();
      return KeyEventResult.handled;
    }
    // Type-to-search: a printable character. `character` is set by Flutter
    // on KeyDownEvent for keys that produce text.
    final String? ch = event.character;
    if (ch != null && ch.length == 1) {
      final int code = ch.codeUnitAt(0);
      // Printable ASCII or any non-control character.
      if (code >= 0x20 && code != 0x7F) {
        _typeAhead(ch);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
    final MSelectStyle resolved = theme.select
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final int selectedIndex = _indexOfValue(_controller.value);
    final MSelectItem<T>? selectedItem =
        selectedIndex >= 0 ? widget.items[selectedIndex] : null;

    Widget anchor = _buildAnchor(resolved, selectedItem);
    anchor = MFocusRing(focused: _anchorFocused, child: anchor);

    final Widget anchorDetector = FocusableActionDetector(
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      focusNode: _anchorNode,
      onShowFocusHighlight: _onAnchorShowFocus,
      mouseCursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: _anchorShortcuts,
      actions: _anchorActions,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled
            ? () => _open ? _closePopover(commit: false) : _openPopover()
            : null,
        child: anchor,
      ),
    );

    final Widget portal = MOverlayAnchor(
      controller: _anchor,
      anchor: anchorDetector,
      overlayOffset: Offset(0, resolved.minHeight + resolved.popoverGap),
      onDismiss: () => _closePopover(commit: false),
      onKeyEvent: _onPopoverKey,
      overlayBuilder: (BuildContext overlayContext) =>
          _buildOverlay(overlayContext, resolved, theme),
    );

    return Semantics(
      button: true,
      enabled: widget.enabled,
      expanded: _open,
      label: widget.semanticLabel,
      container: true,
      child: portal,
    );
  }

  Widget _buildAnchor(MSelectStyle s, MSelectItem<T>? selectedItem) {
    final String? label = selectedItem?.label;
    final bool showPlaceholder = label == null;
    final Color foreground =
        showPlaceholder ? s.placeholderColor : s.anchorForegroundColor;
    final TextStyle textStyle = s.textStyle.copyWith(color: foreground);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (selectedItem?.leading != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: selectedItem!.leading!,
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            label ?? widget.placeholder ?? '',
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 6),
        _Chevron(color: s.iconColor),
      ],
    );

    Widget surface = ConstrainedBox(
      constraints: BoxConstraints(minHeight: s.minHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: s.anchorBackgroundColor,
          borderRadius: s.anchorRadius,
          border: Border.all(
            color: s.anchorBorderColor,
            width: s.anchorBorderWidth,
          ),
        ),
        child: Padding(
          padding: s.anchorPadding,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: 1,
            child: content,
          ),
        ),
      ),
    );

    if (!widget.enabled) {
      surface = Opacity(opacity: s.disabledOpacity, child: surface);
    }
    return surface;
  }

  Widget _buildOverlay(
    BuildContext overlayContext,
    MSelectStyle s,
    MThemeData theme,
  ) {
    final int selectedIndex = _indexOfValue(_controller.value);

    final Widget popoverBody = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: s.popoverMaxHeight,
        minWidth: _anchorWidth,
        maxWidth: _anchorWidth,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: s.popoverBackgroundColor,
          borderRadius: s.popoverRadius,
          border: Border.all(
            color: s.popoverBorderColor,
            width: s.popoverBorderWidth,
          ),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < widget.items.length; i++)
                  _SelectItemRow<T>(
                    item: widget.items[i],
                    index: i,
                    focused: i == _focusedIndex,
                    selected: i == selectedIndex,
                    style: s,
                    onHover: () {
                      if (widget.items[i].enabled &&
                          _focusedIndex != i) {
                        setState(() => _focusedIndex = i);
                      }
                    },
                    onTap: () {
                      if (!widget.items[i].enabled) return;
                      _closePopover(
                        commit: true,
                        committedValue: widget.items[i].value,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return popoverBody;
  }
}

class _SelectItemRow<T> extends StatelessWidget {
  const _SelectItemRow({
    required this.item,
    required this.index,
    required this.focused,
    required this.selected,
    required this.style,
    required this.onHover,
    required this.onTap,
  });

  final MSelectItem<T> item;
  final int index;
  final bool focused;
  final bool selected;
  final MSelectStyle style;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = focused
        ? style.itemFocusedBackgroundColor
        : (selected ? style.itemSelectedBackgroundColor : null) ??
            const Color(0x00000000);
    final Color foreground = selected
        ? style.itemSelectedForegroundColor
        : style.itemForegroundColor;

    Widget content = Row(
      children: <Widget>[
        if (item.leading != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: item.leading!,
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            item.label,
            style: style.textStyle.copyWith(color: foreground),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (selected) ...<Widget>[
          const SizedBox(width: 6),
          _Check(color: foreground),
        ] else if (item.trailing != null) ...<Widget>[
          const SizedBox(width: 6),
          IconTheme.merge(
            data: IconThemeData(color: style.iconColor),
            child: item.trailing!,
          ),
        ],
      ],
    );

    content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.itemMinHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: style.itemRadius,
        ),
        child: Padding(
          padding: style.itemPadding,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: 1,
            child: content,
          ),
        ),
      ),
    );

    if (!item.enabled) {
      content = Opacity(opacity: style.disabledOpacity, child: content);
    }

    return Semantics(
      button: true,
      enabled: item.enabled,
      selected: selected,
      label: item.label,
      container: true,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: item.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => onHover(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.enabled ? onTap : null,
          child: content,
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(painter: _ChevronPainter(color: color)),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final double w = size.width;
    final double h = size.height;
    final Path path = Path()
      ..moveTo(w * 0.2, h * 0.4)
      ..lineTo(w * 0.5, h * 0.7)
      ..lineTo(w * 0.8, h * 0.4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}

class _Check extends StatelessWidget {
  const _Check({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: CustomPaint(painter: _CheckPainter(color: color)),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final double w = size.width;
    final double h = size.height;
    final Path path = Path()
      ..moveTo(w * 0.2, h * 0.55)
      ..lineTo(w * 0.45, h * 0.78)
      ..lineTo(w * 0.82, h * 0.28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.color != color;
}
