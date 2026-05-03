import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/focus_ring.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'list_tile_style.dart';

/// A tappable row with an optional leading widget, a title, an optional
/// subtitle, and an optional trailing widget.
///
/// Covers the common flat list-row shape (room lists, object lists, vault
/// entry lists): `[leading] title / subtitle [trailing]`, tap-to-select, and
/// a `selected` highlight. For tree-shaped rows with depth indentation and
/// an expand/collapse affordance, use [MTreeListTile] instead.
///
/// ```dart
/// MListTile(
///   leading: MAvatar(fallback: Text('R')),
///   title: Text('Room name'),
///   subtitle: Text('Last message preview'),
///   trailing: MBadge(child: Text('3')),
///   selected: isSelected,
///   onTap: () => select(room),
/// )
/// ```
class MListTile extends StatefulWidget {
  /// Builds a list tile.
  const MListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.semanticLabel,
    this.style,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// The primary content, usually a `Text`. Rendered on one line by default;
  /// wrap in your own `Text(maxLines: ...)` for multi-line titles.
  final Widget title;

  /// Secondary content shown below the title, usually a `Text`.
  final Widget? subtitle;

  /// Content shown before the title/subtitle column, usually an `MAvatar`
  /// or `MIcon`.
  final Widget? leading;

  /// Content shown after the title/subtitle column, usually an `MBadge`.
  final Widget? trailing;

  /// Whether this row is currently selected. Applies the theme's selected
  /// background/foreground colors and sets `Semantics.selected`.
  final bool selected;

  /// Called on tap. Null renders the row non-interactive (no gesture
  /// detector, no button semantics).
  final VoidCallback? onTap;

  /// Accessibility label. Defaults to the title's semantic text when null.
  final String? semanticLabel;

  /// Field-wise overrides for the theme-resolved [MListTileStyle].
  final MListTileStyleDelta? style;

  /// Whether this row requests keyboard focus on first build.
  final bool autofocus;

  /// Optional caller-owned focus node.
  final FocusNode? focusNode;

  @override
  State<MListTile> createState() => _MListTileState();
}

class _MListTileState extends State<MListTile> {
  bool _focused = false;
  bool _hovered = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onTap?.call();
        return null;
      },
    ),
  };

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MListTileStyle resolved = theme.listTile
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final Color foreground = widget.selected
        ? resolved.selectedForegroundColor
        : resolved.foregroundColor;
    final Color background = widget.selected
        ? resolved.selectedBackgroundColor
        : _hovered
        ? resolved.selectedBackgroundColor.withValues(alpha: 0.55)
        : resolved.backgroundColor;

    final Widget content = Container(
      padding: resolved.padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: resolved.radius,
      ),
      child: Row(
        children: <Widget>[
          if (widget.leading != null) ...<Widget>[
            widget.leading!,
            SizedBox(width: resolved.horizontalGap),
          ],
          Expanded(
            child: DefaultTextStyle.merge(
              style: resolved.titleStyle.copyWith(color: foreground),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.semanticLabel == null)
                    widget.title
                  else
                    ExcludeSemantics(child: widget.title),
                  if (widget.subtitle != null)
                    DefaultTextStyle.merge(
                      style: resolved.subtitleStyle.copyWith(
                        color: resolved.subtitleColor,
                      ),
                      child: widget.semanticLabel == null
                          ? widget.subtitle!
                          : ExcludeSemantics(child: widget.subtitle!),
                    ),
                ],
              ),
            ),
          ),
          if (widget.trailing != null) ...<Widget>[
            SizedBox(width: resolved.horizontalGap),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (widget.onTap == null) {
      return Semantics(
        container: true,
        selected: widget.selected,
        label: widget.semanticLabel,
        child: content,
      );
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        onShowFocusHighlight: (bool value) {
          if (_focused != value) setState(() => _focused = value);
        },
        onShowHoverHighlight: (bool value) {
          if (_hovered != value) setState(() => _hovered = value);
        },
        mouseCursor: SystemMouseCursors.click,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: _actions,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: MFocusRing(focused: _focused, child: content),
        ),
      ),
    );
  }
}
