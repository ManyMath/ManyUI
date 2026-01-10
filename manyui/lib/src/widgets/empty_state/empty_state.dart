import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';

/// Horizontal alignment for [MEmptyState] content.
enum MEmptyStateAlignment {
  /// Align text and actions to the leading edge.
  start,

  /// Center text and actions.
  center,
}

/// A compact empty, placeholder, or zero-result state.
///
/// `MEmptyState` is intentionally unframed so apps can place it inside an
/// existing pane, card, list, or centered viewport without creating nested
/// surfaces. Actions wrap automatically at narrow widths.
class MEmptyState extends StatelessWidget {
  /// Builds an empty state.
  const MEmptyState({
    required this.title,
    this.description,
    this.leading,
    this.actions = const <Widget>[],
    this.alignment = MEmptyStateAlignment.center,
    this.maxWidth = 420,
    this.spacing = 8,
    this.actionsGap = 16,
    this.actionSpacing = 8,
    this.actionRunSpacing = 8,
    super.key,
  });

  /// Primary message.
  final String title;

  /// Optional secondary message.
  final String? description;

  /// Optional icon, badge, or small status widget above the title.
  final Widget? leading;

  /// Optional calls to action. They wrap as the available width narrows.
  final List<Widget> actions;

  /// Content alignment.
  final MEmptyStateAlignment alignment;

  /// Maximum width for text and action wrapping.
  final double maxWidth;

  /// Vertical spacing between the leading widget, title, and description.
  final double spacing;

  /// Vertical spacing between the text block and actions.
  final double actionsGap;

  /// Horizontal spacing between actions.
  final double actionSpacing;

  /// Vertical spacing between wrapped action rows.
  final double actionRunSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final centered = alignment == MEmptyStateAlignment.center;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          if (leading != null) ...<Widget>[
            IconTheme.merge(
              data: IconThemeData(color: theme.colors.mutedForeground),
              child: leading!,
            ),
            SizedBox(height: spacing),
          ],
          Text(
            title,
            style: theme.typography.body.copyWith(
              color: theme.colors.mutedForeground,
            ),
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
          if (description != null && description!.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing),
            Text(
              description!,
              style: theme.typography.bodySmall.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: centered ? TextAlign.center : TextAlign.start,
            ),
          ],
          if (actions.isNotEmpty) ...<Widget>[
            SizedBox(height: actionsGap),
            Wrap(
              alignment: centered ? WrapAlignment.center : WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: actionSpacing,
              runSpacing: actionRunSpacing,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}
