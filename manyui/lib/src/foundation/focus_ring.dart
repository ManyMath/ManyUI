import 'package:flutter/widgets.dart';

import '../theme/focus_ring_style.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';

/// Paints the standard focus ring around [child] when [focused] is true.
///
/// The ring is painted outside the layout bounds so toggling focus never
/// shifts surrounding content. Color comes from `theme.colors.ring`; shape
/// from [style] if supplied, otherwise from `theme.focusRing`.
///
/// ```dart
/// MFocusRing(
///   focused: hasFocus,
///   child: DecoratedBox(
///     decoration: BoxDecoration(color: theme.colors.primary),
///     child: const Text('Press me'),
///   ),
/// )
/// ```
class MFocusRing extends StatelessWidget {
  /// Creates a focus ring around [child].
  const MFocusRing({
    required this.focused,
    required this.child,
    this.style,
    super.key,
  });

  /// Whether the ring is visible. When false, returns [child] unchanged.
  final bool focused;

  /// The widget the ring surrounds.
  final Widget child;

  /// Shape overrides; falls back to `theme.focusRing` when null.
  final MFocusRingStyle? style;

  @override
  Widget build(BuildContext context) {
    if (!focused) return child;
    final MThemeData theme = MTheme.of(context);
    final MFocusRingStyle resolved = style ?? theme.focusRing;
    return CustomPaint(
      foregroundPainter: _RingPainter(
        color: theme.colors.ring,
        width: resolved.width,
        offset: resolved.offset,
        radius: resolved.radius,
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.color,
    required this.width,
    required this.offset,
    required this.radius,
  });

  final Color color;
  final double width;
  final double offset;
  final Radius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..isAntiAlias = true;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -offset - width / 2,
        -offset - width / 2,
        size.width + 2 * offset + width,
        size.height + 2 * offset + width,
      ),
      radius,
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) {
    return color != old.color ||
        width != old.width ||
        offset != old.offset ||
        radius != old.radius;
  }
}
