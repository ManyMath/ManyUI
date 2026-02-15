import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../action_row/action_row.dart';

/// Standard action row for dialog bodies.
///
/// Dialog actions use a wrapping row rather than a fixed [Row] so long labels
/// and compact windows do not overflow. Buttons are usually ordered from the
/// least-destructive or cancelling action to the committing action.
class MDialogActions extends StatelessWidget {
  /// Builds a wrapping dialog action row.
  const MDialogActions({
    required this.children,
    this.alignment = WrapAlignment.end,
    this.spacing = 8,
    this.runSpacing = 8,
    super.key,
  });

  /// Action widgets, usually [MButton]s.
  final List<Widget> children;

  /// Main-axis alignment for each action run.
  final WrapAlignment alignment;

  /// Horizontal space between actions.
  final double spacing;

  /// Vertical space between wrapped action runs.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return MActionRow(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}

/// Standard title, description, content, and action layout for dialog bodies.
///
/// `MDialogContent` is the reusable body pattern for custom dialogs that need
/// their own state or return type. Pair it with [showMDialog] for the route
/// and provide form fields or other custom controls through [content].
class MDialogContent extends StatelessWidget {
  /// Builds a dialog body layout.
  const MDialogContent({
    required this.title,
    this.description,
    this.content,
    this.actions = const <Widget>[],
    this.maxWidth = 420,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.titleStyle,
    this.descriptionStyle,
    super.key,
  });

  /// Primary dialog title.
  final String title;

  /// Optional supporting text rendered below [title].
  final String? description;

  /// Optional custom body content, such as form fields or status details.
  final Widget? content;

  /// Optional action widgets rendered in a wrapping action row.
  final List<Widget> actions;

  /// Maximum width for the dialog body.
  final double maxWidth;

  /// Cross-axis alignment for the title, description, content, and actions.
  final CrossAxisAlignment crossAxisAlignment;

  /// Optional title text style. Defaults to `theme.typography.title`.
  final TextStyle? titleStyle;

  /// Optional description text style. Defaults to muted small body text.
  final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final bool hasDescription = description != null && description!.isNotEmpty;
    final bool hasContent = content != null;
    final bool hasActions = actions.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              title,
              style:
                  titleStyle ??
                  theme.typography.title.copyWith(
                    color: theme.colors.foreground,
                  ),
            ),
          ),
          if (hasDescription) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              description!,
              style:
                  descriptionStyle ??
                  theme.typography.bodySmall.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
            ),
          ],
          if (hasContent) ...<Widget>[const SizedBox(height: 16), content!],
          if (hasActions) ...<Widget>[
            SizedBox(height: hasContent ? 24 : 20),
            MDialogActions(children: actions),
          ],
        ],
      ),
    );
  }
}
