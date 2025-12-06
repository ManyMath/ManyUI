import 'package:flutter/widgets.dart';

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
class MListTile extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MListTileStyle resolved = theme.listTile
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(style);

    final Color foreground =
        selected ? resolved.selectedForegroundColor : resolved.foregroundColor;

    final Widget content = Container(
      padding: resolved.padding,
      decoration: BoxDecoration(
        color: selected ? resolved.selectedBackgroundColor : resolved.backgroundColor,
        borderRadius: resolved.radius,
      ),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            SizedBox(width: resolved.horizontalGap),
          ],
          Expanded(
            child: DefaultTextStyle.merge(
              style: resolved.titleStyle.copyWith(color: foreground),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Semantics(excludeSemantics: true, child: title),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: resolved.subtitleStyle
                          .copyWith(color: resolved.subtitleColor),
                      child: Semantics(excludeSemantics: true, child: subtitle!),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null) ...<Widget>[
            SizedBox(width: resolved.horizontalGap),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(container: true, label: semanticLabel, child: content);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
