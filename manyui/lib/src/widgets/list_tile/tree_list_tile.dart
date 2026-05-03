import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import '../icon/icon_data.dart';
import '../icon_button/icon_button.dart';
import '../button/button_style.dart';
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
class MTreeListTile extends StatefulWidget {
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
    this.autofocus = false,
    this.focusNode,
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

  /// Whether this row requests keyboard focus on first build.
  final bool autofocus;

  /// Optional caller-owned focus node for the row action.
  final FocusNode? focusNode;

  static const double _indentStep = 16;
  static const double _chevronSlotWidth = 28;

  @override
  State<MTreeListTile> createState() => _MTreeListTileState();
}

class _MTreeListTileState extends State<MTreeListTile> {
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

    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsets padding = resolved.padding.resolve(textDirection);
    final double startPadding = textDirection == TextDirection.ltr
        ? padding.left
        : padding.right;
    final double endPadding = textDirection == TextDirection.ltr
        ? padding.right
        : padding.left;
    final bool touch =
        MInputModalityScope.resolve(context, null) == MInputModality.touch;
    final String? titleLabel = widget.semanticLabel ?? _textLabel(widget.title);
    final String toggleLabel = <String>[
      widget.expanded ? 'Collapse' : 'Expand',
      if (titleLabel != null && titleLabel.isNotEmpty) titleLabel,
    ].join(' ');

    final Widget chevronSlot = SizedBox(
      width: touch ? 44 : MTreeListTile._chevronSlotWidth,
      child: widget.onToggle == null
          ? null
          : Align(
              alignment: Alignment.centerLeft,
              child: MIconButton(
                icon: widget.expanded
                    ? MIconData.chevronDown
                    : MIconData.chevronRight,
                label: toggleLabel,
                size: touch ? MButtonSize.md : MButtonSize.xs,
                onPressed: widget.onToggle,
              ),
            ),
    );

    final Widget content = Container(
      padding: EdgeInsetsDirectional.only(
        start: startPadding + widget.depth * MTreeListTile._indentStep,
        top: padding.top,
        bottom: padding.bottom,
        end: endPadding,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: resolved.radius,
      ),
      child: Row(
        children: <Widget>[
          chevronSlot,
          Expanded(
            child: DefaultTextStyle.merge(
              style: resolved.titleStyle.copyWith(color: foreground),
              child: widget.semanticLabel == null
                  ? widget.title
                  : ExcludeSemantics(child: widget.title),
            ),
          ),
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

  String? _textLabel(Widget title) {
    if (title is Text) return title.data;
    return null;
  }
}
