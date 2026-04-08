import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../action_row/action_row.dart';

/// A responsive header for cards, panels, and content sections.
///
/// `MSectionHeader` standardizes the common "section title, supporting copy,
/// status badge, and trailing actions" shape used inside app content. On narrow
/// layouts status and actions stack below the title so long titles and controls
/// do not fight for the same row.
class MSectionHeader extends StatelessWidget {
  /// Builds a section header.
  const MSectionHeader({
    required this.title,
    this.description,
    this.leading,
    this.status,
    this.actions = const <Widget>[],
    this.compactBreakpoint = 520,
    this.spacing = 12,
    this.actionSpacing = 8,
    this.runSpacing = 8,
    this.descriptionSpacing = 8,
    this.titleMaxLines = 2,
    this.descriptionMaxLines = 3,
    this.titleStyle,
    this.descriptionStyle,
    super.key,
  });

  /// Primary section title.
  final String title;

  /// Optional supporting copy shown below [title].
  final String? description;

  /// Optional leading control or icon shown before [title].
  final Widget? leading;

  /// Optional status chip/badge shown between title copy and actions.
  final Widget? status;

  /// Header actions. They wrap as needed and align to the trailing edge.
  final List<Widget> actions;

  /// Width below which status/actions stack under the title copy.
  final double compactBreakpoint;

  /// Space between title/status/action regions.
  final double spacing;

  /// Horizontal spacing between [actions].
  final double actionSpacing;

  /// Vertical spacing when status/actions wrap or stack.
  final double runSpacing;

  /// Space between [title] and [description].
  final double descriptionSpacing;

  /// Maximum visible title lines.
  final int titleMaxLines;

  /// Maximum visible description lines.
  final int descriptionMaxLines;

  /// Optional title text style override.
  final TextStyle? titleStyle;

  /// Optional description text style override.
  final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final compact = constraints.maxWidth < compactBreakpoint;
        final constrained = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : compactBreakpoint;
        return compact
            ? _buildCompact(constrained)
            : _buildExpanded(constrained);
      },
    );
  }

  Widget _buildExpanded(double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: _TitleBlock(header: this)),
        if (status != null) ...<Widget>[
          SizedBox(width: spacing),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: math.min(320, width * 0.35)),
            child: Align(alignment: Alignment.centerRight, child: status),
          ),
        ],
        if (actions.isNotEmpty) ...<Widget>[
          SizedBox(width: spacing),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: MActionRow(
                spacing: actionSpacing,
                runSpacing: runSpacing,
                children: actions,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompact(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _TitleBlock(header: this),
        if (status != null) ...<Widget>[
          SizedBox(height: runSpacing),
          Align(alignment: Alignment.centerLeft, child: status),
        ],
        if (actions.isNotEmpty) ...<Widget>[
          SizedBox(height: runSpacing),
          Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: MActionRow(
                spacing: actionSpacing,
                runSpacing: runSpacing,
                children: actions,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.header});

  final MSectionHeader header;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final String? description =
        header.description != null && header.description!.isNotEmpty
        ? header.description
        : null;
    final titleStyle = header.titleStyle ?? theme.typography.headlineSmall;
    final descriptionStyle =
        header.descriptionStyle ??
        theme.typography.bodySmall.copyWith(
          color: theme.colors.mutedForeground,
        );

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          header: true,
          container: true,
          excludeSemantics: true,
          label: header.title,
          child: Text(
            header.title,
            style: titleStyle,
            maxLines: header.titleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (description != null) ...<Widget>[
          SizedBox(height: header.descriptionSpacing),
          Text(
            description,
            style: descriptionStyle,
            maxLines: header.descriptionMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    if (header.leading == null) {
      return textBlock;
    }

    return Row(
      crossAxisAlignment: description == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        header.leading!,
        SizedBox(width: header.spacing),
        Expanded(child: textBlock),
      ],
    );
  }
}
