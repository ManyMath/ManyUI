import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../label/label.dart';

/// A labeled form-control stack.
///
/// `MField` gives forms one shared pattern for visible labels, control
/// spacing, optional helper text, and optional validation text. Pass the same
/// [focusNode] to both `MField` and the control when tapping the label should
/// focus the control.
class MField extends StatelessWidget {
  /// Builds a field.
  const MField({
    required this.label,
    required this.child,
    this.description,
    this.errorText,
    this.focusNode,
    this.enabled = true,
    this.semanticLabel,
    this.spacing = 8,
    this.messageSpacing = 6,
    super.key,
  });

  /// Visible label.
  final String label;

  /// The control or content associated with [label].
  final Widget child;

  /// Helper text shown below [child] when [errorText] is empty.
  final String? description;

  /// Validation/error text shown below [child]. Replaces [description].
  final String? errorText;

  /// Optional focus node routed from the label to the control.
  final FocusNode? focusNode;

  /// Whether the label is enabled.
  final bool enabled;

  /// Optional screen-reader label for the visible label text.
  final String? semanticLabel;

  /// Space between the label and [child].
  final double spacing;

  /// Space between [child] and helper/error text.
  final double messageSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final String? error = errorText != null && errorText!.isNotEmpty
        ? errorText
        : null;
    final String? helper =
        error == null && description != null && description!.isNotEmpty
        ? description
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MLabel(
          label,
          focusNode: focusNode,
          enabled: enabled,
          semanticLabel: semanticLabel,
        ),
        SizedBox(height: spacing),
        child,
        if (error != null) ...<Widget>[
          SizedBox(height: messageSpacing),
          Semantics(
            container: true,
            liveRegion: true,
            child: Text(
              error,
              style: theme.typography.bodySmall.copyWith(
                color: theme.colors.destructive,
              ),
            ),
          ),
        ] else if (helper != null) ...<Widget>[
          SizedBox(height: messageSpacing),
          Text(
            helper,
            style: theme.typography.bodySmall.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}
