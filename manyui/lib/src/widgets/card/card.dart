import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'card_style.dart';

/// A bordered, padded surface for grouping related content.
///
/// `MCard` is non-interactive — it has no tap, focus, or modality behavior.
/// Wrap it in [GestureDetector] or [MButton] if you need press affordance.
///
/// ```dart
/// MCard(
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: <Widget>[
///       Text('Title'),
///       SizedBox(height: 4),
///       Text('Body text goes here.'),
///     ],
///   ),
/// )
/// ```
class MCard extends StatelessWidget {
  /// Builds a card.
  const MCard({
    this.style,
    required this.child,
    super.key,
  });

  /// Field-wise overrides for the theme-resolved [MCardStyle].
  final MCardStyleDelta? style;

  /// The card's contents.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MCardStyle resolved = theme.card
        .resolve(colors: theme.colors, radius: theme.radius)
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
          style: TextStyle(color: resolved.foregroundColor),
          child: IconTheme.merge(
            data: IconThemeData(color: resolved.foregroundColor),
            child: child,
          ),
        ),
      ),
    );
  }
}
