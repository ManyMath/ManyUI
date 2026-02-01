import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';

/// A low-emphasis inset surface for content nested inside larger panels.
///
/// Use `MInsetPanel` for bounded detail areas inside cards, dialogs, and
/// forms: recovery phrases, preview summaries, compact lists, and other
/// content that needs grouping without becoming another full card.
class MInsetPanel extends StatelessWidget {
  /// Builds an inset panel.
  const MInsetPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.radius,
    super.key,
  });

  /// Panel content.
  final Widget child;

  /// Space between the panel edge and [child].
  final EdgeInsetsGeometry padding;

  /// Optional override for the panel fill. Defaults to `theme.colors.muted`.
  final Color? backgroundColor;

  /// Optional override for inherited text/icon color.
  final Color? foregroundColor;

  /// Optional border color. Defaults to no border so inset panels stay quieter
  /// than [MCard].
  final Color? borderColor;

  /// Border width when [borderColor] is supplied.
  final double borderWidth;

  /// Optional corner radius. Defaults to the theme radius.
  final BorderRadiusGeometry? radius;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final Color resolvedForeground = foregroundColor ?? theme.colors.foreground;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colors.muted,
        borderRadius: radius ?? BorderRadius.circular(theme.radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: Padding(
        padding: padding,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: resolvedForeground),
          child: IconTheme.merge(
            data: IconThemeData(color: resolvedForeground),
            child: child,
          ),
        ),
      ),
    );
  }
}
