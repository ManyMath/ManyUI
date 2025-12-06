import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import '../icon/icon.dart';
import '../icon/icon_data.dart';
import 'list_tile_style.dart';

/// A tappable, depth-indented row with an optional expand/collapse chevron.
///
/// Covers tree-shaped rows (e.g. a group/folder hierarchy) where
/// [MListTile]'s flat leading/trailing shape doesn't fit: indentation scales
/// with [depth], and a separate tap target toggles [onToggle] independent of
/// the row's own [onTap]/select action.
///
/// ```dart
/// MTreeListTile(
///   depth: 1,
///   title: Text(group.name),
///   selected: group.uuid == selectedUuid,
///   expanded: expanded,
///   onTap: () => select(group),
///   onToggle: group.children.isEmpty ? null : () => toggle(group.uuid),
/// )
/// ```
class MTreeListTile extends StatelessWidget {
  /// Builds a tree list tile.
  const MTreeListTile({
    required this.title,
    required this.depth,
    this.selected = false,
    this.expanded = false,
    this.onTap,
    this.onToggle,
    this.semanticLabel,
    this.style,
    super.key,
  });

  /// The row's content, usually a `Text`.
  final Widget title;

  /// The nesting depth. Each level adds one indentation step before the
  /// chevron/title.
  final int depth;

  /// Whether this row is currently selected.
  final bool selected;

  /// Whether this row's children are currently expanded. Only affects which
  /// chevron glyph is drawn; the caller owns the actual expand/collapse
  /// state and child rows.
  final bool expanded;

  /// Called when the row itself is tapped (selects this row).
  final VoidCallback? onTap;

  /// Called when the chevron is tapped (toggles expansion). Null hides the
  /// chevron and its tap target: pass null for leaf rows with no children.
  final VoidCallback? onToggle;

  /// Accessibility label. Defaults to the title's semantic text when null.
  final String? semanticLabel;

  /// Field-wise overrides for the theme-resolved [MListTileStyle].
  final MListTileStyleDelta? style;

  static const double _indentStep = 16;
  static const double _chevronSlotWidth = 20;

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

    final EdgeInsets padding =
        resolved.padding.resolve(Directionality.of(context));

    final Widget chevronSlot = SizedBox(
      width: _chevronSlotWidth,
      child: onToggle == null
          ? null
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Center(
                child: MIcon(
                  expanded ? MIconData.chevronDown : MIconData.chevronRight,
                  size: 14,
                  color: resolved.subtitleColor,
                ),
              ),
            ),
    );

    final Widget content = Container(
      padding: EdgeInsetsDirectional.only(
        start: padding.left + depth * _indentStep,
        top: padding.top,
        bottom: padding.bottom,
        end: padding.right,
      ),
      decoration: BoxDecoration(
        color: selected ? resolved.selectedBackgroundColor : resolved.backgroundColor,
        borderRadius: resolved.radius,
      ),
      child: Row(
        children: <Widget>[
          chevronSlot,
          Expanded(
            child: DefaultTextStyle.merge(
              style: resolved.titleStyle.copyWith(color: foreground),
              child: Semantics(excludeSemantics: true, child: title),
            ),
          ),
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
