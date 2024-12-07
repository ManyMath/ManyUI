import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'badge_style.dart';

/// A small, non-interactive label for tagging or status indication.
///
/// Pills a small piece of content (usually a `Text`) with a colored surface
/// derived from the chosen [variant]. Sizes itself to its content — wrap it
/// in `Align` or a `Row` to position.
///
/// ```dart
/// MBadge(variant: MBadgeVariant.destructive, child: Text('Beta'))
/// ```
class MBadge extends StatelessWidget {
  /// Builds a badge.
  const MBadge({
    this.variant = MBadgeVariant.primary,
    this.style,
    required this.child,
    super.key,
  });

  /// The visual variant. Defaults to [MBadgeVariant.primary].
  final MBadgeVariant variant;

  /// Field-wise overrides for the theme-resolved [MBadgeStyle].
  final MBadgeStyleDelta? style;

  /// The badge's label content. Usually a `Text`.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MBadgeStyle resolved = theme.badge
        .resolve(
          variant: variant,
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
        )
        .applyDelta(style);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: resolved.backgroundColor,
        borderRadius: resolved.radius,
        border: resolved.borderColor != null
            ? Border.all(
                color: resolved.borderColor!,
                width: resolved.borderWidth,
              )
            : null,
      ),
      child: Padding(
        padding: resolved.padding,
        child: DefaultTextStyle.merge(
          style:
              resolved.textStyle.copyWith(color: resolved.foregroundColor),
          child: IconTheme.merge(
            data: IconThemeData(color: resolved.foregroundColor, size: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}
