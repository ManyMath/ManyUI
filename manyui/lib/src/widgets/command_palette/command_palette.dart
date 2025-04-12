import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'command_item.dart';
import 'command_palette_style.dart';

/// Centered modal palette with a typeahead-filtered list of commands.
///
/// Embeds a search field above a scrollable list of [MCommandItem]s.
/// Typing filters by substring match against each item's
/// [MCommandItem.searchText] joined with its [MCommandItem.keywords].
/// Up/Down navigate with wraparound, skipping disabled items.
/// Enter activates the focused item; Escape pops with null.
///
/// Most callers use [showMCommandPalette] rather than constructing this
/// directly.
class MCommandPalette<T> extends StatefulWidget {
  /// Builds a command-palette body.
  const MCommandPalette({
    required this.items,
    this.placeholder,
    this.style,
    this.semanticLabel,
    this.dismissible = true,
    super.key,
  });

  /// The full set of commands available before any filtering.
  ///
  /// Each [MCommandItem.id] must be unique within this list.
  final List<MCommandItem<T>> items;

  /// Optional placeholder text shown in the search field when empty.
  final String? placeholder;

  /// Field-wise overrides for the theme-resolved [MCommandPaletteStyle].
  final MCommandPaletteStyleDelta? style;

  /// An optional accessibility label applied to the palette surface.
  final String? semanticLabel;

  /// Whether Escape pops the route. Defaults to true. The scrim-tap is
  /// controlled by the enclosing route's [PopupRoute.barrierDismissible].
  final bool dismissible;

  @override
  State<MCommandPalette<T>> createState() => _MCommandPaletteState<T>();
}

class _MCommandPaletteState<T> extends State<MCommandPalette<T>> {
  final TextEditingController _query = TextEditingController();
  final UndoHistoryController _undo = UndoHistoryController();
  final FocusNode _searchFocus =
      FocusNode(debugLabel: 'MCommandPalette search');
  final ScrollController _scroll = ScrollController();

  // The focused-item id while the palette is open. Drives the highlight and
  // Enter-activation. Cleared when no items match the filter.
  String? _focusedItemId;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
    _focusedItemId = _firstEnabledId(_filterItems(''));
  }

  @override
  void dispose() {
    _query.removeListener(_onQueryChanged);
    _query.dispose();
    _undo.dispose();
    _searchFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final List<MCommandItem<T>> filtered = _filterItems(_query.text);
    // Preserve focused id if it's still in the filtered set; otherwise jump
    // to the first enabled item of the new set.
    final bool stillVisible = _focusedItemId != null &&
        filtered.any((MCommandItem<T> i) =>
            i.id == _focusedItemId && i.enabled);
    setState(() {
      _focusedItemId = stillVisible ? _focusedItemId : _firstEnabledId(filtered);
    });
  }

  List<MCommandItem<T>> _filterItems(String query) {
    if (query.isEmpty) return widget.items;
    final String q = query.toLowerCase();
    return widget.items.where((MCommandItem<T> item) {
      final String haystack = <String>[
        item.searchText ?? '',
        ...item.keywords,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  String? _firstEnabledId(List<MCommandItem<T>> from) {
    for (final MCommandItem<T> i in from) {
      if (i.enabled) return i.id;
    }
    return null;
  }

  void _moveItemFocus(int delta, List<MCommandItem<T>> filtered) {
    final List<MCommandItem<T>> enabled =
        filtered.where((MCommandItem<T> i) => i.enabled).toList();
    if (enabled.isEmpty) return;
    final int current = _focusedItemId == null
        ? -1
        : enabled.indexWhere((MCommandItem<T> i) => i.id == _focusedItemId);
    int next;
    if (current < 0) {
      next = delta > 0 ? 0 : enabled.length - 1;
    } else {
      next = (current + delta) % enabled.length;
      if (next < 0) next += enabled.length;
    }
    setState(() => _focusedItemId = enabled[next].id);
  }

  void _focusFirst(List<MCommandItem<T>> filtered) {
    final String? id = _firstEnabledId(filtered);
    if (id == null) return;
    setState(() => _focusedItemId = id);
  }

  void _focusLast(List<MCommandItem<T>> filtered) {
    String? last;
    for (final MCommandItem<T> i in filtered) {
      if (i.enabled) last = i.id;
    }
    if (last == null) return;
    setState(() => _focusedItemId = last);
  }

  void _activate(MCommandItem<T> item) {
    if (!item.enabled) return;
    item.onTap?.call();
    Navigator.of(context).pop(item);
  }

  void _dismiss() {
    Navigator.of(context).pop();
  }

  KeyEventResult _onKeyEvent(
    FocusNode node,
    KeyEvent event,
    List<MCommandItem<T>> filtered,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      if (!widget.dismissible) return KeyEventResult.ignored;
      _dismiss();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveItemFocus(1, filtered);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveItemFocus(-1, filtered);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _focusFirst(filtered);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _focusLast(filtered);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      final String? focused = _focusedItemId;
      if (focused == null) return KeyEventResult.handled;
      final int idx = filtered
          .indexWhere((MCommandItem<T> i) => i.id == focused && i.enabled);
      if (idx < 0) return KeyEventResult.handled;
      _activate(filtered[idx]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MCommandPaletteStyle resolved = theme.commandPalette
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final List<MCommandItem<T>> filtered = _filterItems(_query.text);
    final bool empty = filtered.isEmpty;

    final Widget searchField = _buildSearchField(theme, resolved);
    final Widget body = empty
        ? _buildEmptyState(resolved)
        : _buildList(resolved, filtered);

    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(padding: resolved.searchPadding, child: searchField),
        Container(height: 1, color: resolved.searchDividerColor),
        Flexible(child: body),
      ],
    );

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: resolved.surfaceBackgroundColor,
        borderRadius: resolved.surfaceRadius,
        border: resolved.surfaceBorderColor != null
            ? Border.all(
                color: resolved.surfaceBorderColor!,
                width: resolved.surfaceBorderWidth,
              )
            : null,
        boxShadow: resolved.surfaceElevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: resolved.surfaceShadowColor,
                  blurRadius: resolved.surfaceElevation,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: resolved.surfaceRadius,
        child: Padding(
          padding: resolved.surfacePadding,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: resolved.surfaceForegroundColor),
            child: column,
          ),
        ),
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

    // FocusScope wraps the whole surface so arrow/Enter/Escape are caught
    // regardless of whether the search field or an item row owns primary
    // focus. The search-field EditableText below still gets text keys.
    return FocusScope(
      autofocus: true,
      onKeyEvent: (FocusNode n, KeyEvent e) => _onKeyEvent(n, e, filtered),
      child: surface,
    );
  }

  Widget _buildSearchField(MThemeData theme, MCommandPaletteStyle s) {
    final TextStyle textStyle =
        s.searchTextStyle.copyWith(color: s.surfaceForegroundColor);
    final bool showPlaceholder =
        _query.text.isEmpty && (widget.placeholder?.isNotEmpty ?? false);

    final Widget editable = EditableText(
      controller: _query,
      focusNode: _searchFocus,
      autofocus: true,
      maxLines: 1,
      keyboardType: TextInputType.text,
      style: textStyle,
      cursorColor: theme.colors.foreground,
      backgroundCursorColor: theme.colors.foreground,
      selectionColor: theme.colors.primary.withValues(alpha: 0.3),
      undoController: _undo,
      contextMenuBuilder: null,
      rendererIgnoresPointer: false,
      enableInteractiveSelection: true,
    );

    return Stack(
      children: <Widget>[
        if (showPlaceholder)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  widget.placeholder!,
                  style: textStyle.copyWith(color: s.searchPlaceholderColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: editable,
        ),
      ],
    );
  }

  Widget _buildEmptyState(MCommandPaletteStyle s) {
    return Padding(
      padding: s.listPadding.add(const EdgeInsets.symmetric(vertical: 24)),
      child: Center(
        child: Text(
          s.emptyText,
          style: s.emptyTextStyle,
        ),
      ),
    );
  }

  Widget _buildList(
    MCommandPaletteStyle s,
    List<MCommandItem<T>> filtered,
  ) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < filtered.length; i++) {
      if (i > 0) rows.add(SizedBox(height: s.itemSpacing));
      final MCommandItem<T> item = filtered[i];
      rows.add(_CommandRow<T>(
        item: item,
        style: s,
        isFocused: item.id == _focusedItemId,
        onTap: () => _activate(item),
        onHover: () {
          if (_focusedItemId != item.id) {
            setState(() => _focusedItemId = item.id);
          }
        },
      ));
    }
    return Padding(
      padding: s.listPadding,
      child: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        ),
      ),
    );
  }
}

class _CommandRow<T> extends StatelessWidget {
  const _CommandRow({
    required this.item,
    required this.style,
    required this.isFocused,
    required this.onTap,
    required this.onHover,
  });

  final MCommandItem<T> item;
  final MCommandPaletteStyle style;
  final bool isFocused;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rowChildren = <Widget>[];
    if (item.leading != null) {
      rowChildren.add(DefaultTextStyle.merge(
        style: style.itemTitleTextStyle
            .copyWith(color: style.itemForegroundColor),
        child: IconTheme.merge(
          data: IconThemeData(color: style.itemForegroundColor),
          child: item.leading!,
        ),
      ));
      rowChildren.add(SizedBox(width: style.itemLeadingTrailingGap));
    }

    final Widget titleAndSubtitle = item.subtitle == null
        ? DefaultTextStyle.merge(
            style: style.itemTitleTextStyle
                .copyWith(color: style.itemForegroundColor),
            child: item.title,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DefaultTextStyle.merge(
                style: style.itemTitleTextStyle
                    .copyWith(color: style.itemForegroundColor),
                child: item.title,
              ),
              DefaultTextStyle.merge(
                style: style.itemSubtitleTextStyle
                    .copyWith(color: style.itemSubtitleForegroundColor),
                child: item.subtitle!,
              ),
            ],
          );

    rowChildren.add(Expanded(child: titleAndSubtitle));

    if (item.trailing != null) {
      rowChildren.add(SizedBox(width: style.itemLeadingTrailingGap));
      rowChildren.add(DefaultTextStyle.merge(
        style: style.itemTitleTextStyle
            .copyWith(color: style.itemTrailingForegroundColor),
        child: item.trailing!,
      ));
    }

    Widget body = Padding(
      padding: style.itemPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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

    if (!item.enabled) {
      body = Opacity(opacity: style.disabledOpacity, child: body);
    }

    return Semantics(
      button: true,
      enabled: item.enabled,
      selected: isFocused,
      container: true,
      child: MouseRegion(
        onEnter: item.enabled ? (_) => onHover() : null,
        cursor: item.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.enabled ? onTap : null,
          child: body,
        ),
      ),
    );
  }
}

/// A modal route that renders an [MCommandPalette] above a scrim.
///
/// Pushed by [showMCommandPalette]. The route pops with the [MCommandItem]
/// the user activated, or with `null` on dismiss (Escape, scrim tap, or
/// `Navigator.pop` without an argument).
class MCommandPaletteRoute<T> extends PopupRoute<MCommandItem<T>?> {
  /// Builds a command-palette route.
  MCommandPaletteRoute({
    required this.items,
    required this.scrimColor,
    required this.themeData,
    required this.topOffset,
    required this.maxWidth,
    required this.maxHeightFraction,
    this.placeholder,
    this.style,
    this.semanticLabel,
    this.dismissible = true,
    this.transitionDuration = const Duration(milliseconds: 150),
  });

  /// The commands available in the palette.
  final List<MCommandItem<T>> items;

  /// Color of the modal scrim. Resolved from `theme.commandPalette` at push
  /// time so the route is independent of theme changes mid-route.
  final Color scrimColor;

  /// The theme data captured at push time. Re-installed inside the route so
  /// the palette renders against the same theme as its caller even though
  /// the route lives in the [Navigator]'s overlay subtree.
  final MThemeData themeData;

  /// Distance from the top of the viewport to the top of the palette.
  final double topOffset;

  /// Maximum width of the palette surface.
  final double maxWidth;

  /// Maximum height of the palette surface as a fraction of the viewport.
  final double maxHeightFraction;

  /// Optional placeholder text for the search field.
  final String? placeholder;

  /// Field-wise overrides for the theme-resolved [MCommandPaletteStyle].
  final MCommandPaletteStyleDelta? style;

  /// Optional semantic label for the palette surface.
  final String? semanticLabel;

  /// Whether the palette can be dismissed by tapping the scrim or pressing
  /// Escape. Defaults to true.
  final bool dismissible;

  @override
  final Duration transitionDuration;

  @override
  bool get barrierDismissible => dismissible;

  @override
  Color? get barrierColor => scrimColor;

  @override
  String? get barrierLabel => semanticLabel ?? 'Dismiss';

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget palette = MTheme(
      data: themeData,
      child: MCommandPalette<T>(
        items: items,
        placeholder: placeholder,
        style: style,
        semanticLabel: semanticLabel,
        dismissible: dismissible,
      ),
    );

    // Absorb taps inside the surface so a stray pointer doesn't bubble to
    // the modal barrier and dismiss the route.
    final Widget absorbing = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: palette,
    );

    final Widget sized = LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints c) {
        final double maxH = c.maxHeight * maxHeightFraction;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxH,
          ),
          child: absorbing,
        );
      },
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: topOffset),
        child: Align(
          alignment: Alignment.topCenter,
          child: sized,
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}

/// Pushes an [MCommandPaletteRoute] and returns the activated [MCommandItem],
/// or `null` if the user dismissed without picking one.
///
/// The palette is scrim-backed, focus-trapped, and dismissible by scrim-tap
/// or Escape (set [dismissible] to false to suppress both). Activation pops
/// the route automatically — caller content commits via the
/// [MCommandItem.onTap] callback and / or by reading the returned
/// [MCommandItem.value].
///
/// Requires an ambient [Navigator] — provided by [MWidgetsApp].
///
/// ```dart
/// final MCommandItem<String>? picked = await showMCommandPalette<String>(
///   context,
///   placeholder: 'Type a command…',
///   items: <MCommandItem<String>>[
///     MCommandItem<String>(
///       id: 'open',
///       title: const Text('Open File…'),
///       trailing: const Text('⌘O'),
///       searchText: 'open file',
///       value: 'open',
///     ),
///     MCommandItem<String>(
///       id: 'save',
///       title: const Text('Save'),
///       trailing: const Text('⌘S'),
///       searchText: 'save',
///       value: 'save',
///     ),
///   ],
/// );
/// if (picked != null) print('User picked ${picked.value}');
/// ```
///
/// Apps typically wire a global keyboard shortcut (e.g. `Cmd+K` / `Ctrl+K`)
/// via `Shortcuts`/`Actions` that calls this method. v0.1 does **not** bind
/// any shortcut globally.
Future<MCommandItem<T>?> showMCommandPalette<T>(
  BuildContext context, {
  required List<MCommandItem<T>> items,
  String? placeholder,
  MCommandPaletteStyleDelta? style,
  String? semanticLabel,
  bool dismissible = true,
}) {
  final MThemeData theme = MTheme.of(context);
  final MCommandPaletteStyle resolved = theme.commandPalette
      .resolve(
        colors: theme.colors,
        typography: theme.typography.inheritFromContext(context),
        radius: theme.radius,
      )
      .applyDelta(style);

  return Navigator.of(context).push<MCommandItem<T>?>(MCommandPaletteRoute<T>(
    items: items,
    placeholder: placeholder,
    scrimColor: resolved.scrimColor,
    themeData: theme,
    topOffset: resolved.topOffset,
    maxWidth: resolved.maxWidth,
    maxHeightFraction: resolved.maxHeightFraction,
    style: style,
    semanticLabel: semanticLabel,
    dismissible: dismissible,
  ));
}
