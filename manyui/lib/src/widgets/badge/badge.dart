import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'badge_style.dart';

/// A small, non-interactive label for tagging or status indication.
///
/// Places content, usually `Text`, on a background colored by [variant].
/// Sizes itself to its content; use `Align` or a `Row` to position it.
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

    // Align forces the loosest possible incoming constraints onto its child
    // (sizing itself to whatever the child reports back), so a stretch-
    // aligned Column/Row can't force this badge wider/taller than its
    // content -- the same shape a Text or Icon relies on to stay
    // content-sized in a stretch layout.
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: DecoratedBox(
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
            style: resolved.textStyle.copyWith(color: resolved.foregroundColor),
            child: IconTheme.merge(
              data: IconThemeData(color: resolved.foregroundColor, size: 14),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
