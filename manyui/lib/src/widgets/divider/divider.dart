import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'divider_style.dart';

/// The orientation of an [MDivider].
enum MDividerOrientation {
  /// A horizontal rule that spans the available width.
  horizontal,

  /// A vertical rule that spans the available height.
  vertical,
}

/// A thin rule for separating content.
///
/// Non-interactive. Renders a 1-logical-pixel stroke in `colors.border` by
/// default; override the color or thickness through [style] or by replacing
/// `MThemeData.divider`.
///
/// `MDivider` sizes the cross axis to its [MDividerStyle.thickness] and
/// expands on the main axis. Wrap it in a fixed-size box if the parent
/// doesn't constrain the main axis (e.g. a `Row` with a vertical divider
/// needs an explicit height).
class MDivider extends StatelessWidget {
  /// Builds a divider.
  const MDivider({
    this.orientation = MDividerOrientation.horizontal,
    this.style,
    super.key,
  });

  /// Whether the rule runs horizontally or vertically.
  final MDividerOrientation orientation;

  /// Field-wise overrides for the theme-resolved [MDividerStyle].
  final MDividerStyleDelta? style;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MDividerStyle resolved =
        theme.divider.resolve(colors: theme.colors).applyDelta(style);

    final bool horizontal = orientation == MDividerOrientation.horizontal;
    return Semantics(
      container: true,
      child: SizedBox(
        height: horizontal ? resolved.thickness : null,
        width: horizontal ? null : resolved.thickness,
        child: ColoredBox(color: resolved.color),
      ),
    );
  }
}
