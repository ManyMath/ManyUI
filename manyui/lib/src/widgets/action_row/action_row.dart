import 'package:flutter/widgets.dart';

/// Standard wrapping row for groups of action controls.
///
/// `MActionRow` is the shared layout for button groups and other compact
/// controls that should keep a horizontal rhythm on wide surfaces but wrap
/// cleanly in compact panes.
class MActionRow extends StatelessWidget {
  /// Builds an action row.
  const MActionRow({
    required this.children,
    this.alignment = WrapAlignment.end,
    this.crossAxisAlignment = WrapCrossAlignment.center,
    this.spacing = 8,
    this.runSpacing = 8,
    super.key,
  });

  /// Action widgets, usually buttons or compact controls.
  final List<Widget> children;

  /// Main-axis alignment for each action run.
  final WrapAlignment alignment;

  /// Cross-axis alignment within each run.
  final WrapCrossAlignment crossAxisAlignment;

  /// Horizontal space between actions.
  final double spacing;

  /// Vertical space between wrapped action runs.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}
