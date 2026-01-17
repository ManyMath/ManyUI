import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../progress/progress.dart';

/// Horizontal alignment for [MLoadingState] content.
enum MLoadingStateAlignment {
  /// Align indicator and message to the leading edge.
  start,

  /// Center indicator and message.
  center,
}

/// A compact loading or in-progress placeholder.
///
/// `MLoadingState` is intentionally unframed so it can sit inside panes,
/// cards, lists, and centered viewports without adding another surface.
class MLoadingState extends StatelessWidget {
  /// Builds a loading state.
  const MLoadingState({
    required this.message,
    this.semanticLabel,
    this.indicator,
    this.alignment = MLoadingStateAlignment.center,
    this.maxWidth = 320,
    this.spacing = 10,
    super.key,
  });

  /// Visible loading message.
  final String message;

  /// Accessibility label for the default progress indicator.
  ///
  /// Defaults to [message]. Ignored when [indicator] is supplied.
  final String? semanticLabel;

  /// Optional custom indicator. When omitted, a themed indeterminate circular
  /// progress indicator is used.
  final Widget? indicator;

  /// Content alignment.
  final MLoadingStateAlignment alignment;

  /// Maximum width for the message.
  final double maxWidth;

  /// Vertical spacing between indicator and message.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final centered = alignment == MLoadingStateAlignment.center;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          indicator ??
              MCircularProgress.indeterminate(
                semanticLabel: semanticLabel ?? message,
              ),
          SizedBox(height: spacing),
          Text(
            message,
            style: theme.typography.bodySmall.copyWith(
              color: theme.colors.mutedForeground,
            ),
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
        ],
      ),
    );
  }
}
