import 'package:flutter/widgets.dart';

/// Standard wrapping row for groups of action controls.
///
/// Arranges buttons and other compact controls in a row, wrapping them
/// when the available width is too small.
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
