import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'icon_data.dart';

/// A small hand-drawn glyph, painted with a [CustomPainter] rather than a
/// font/SVG asset, matches `MFocusRing`'s `_RingPainter` and `MCheckbox`'s
/// `_CheckboxPainter` precedent; the library has no asset/font pipeline.
///
/// Reads [IconTheme] for its default color/size, same as Flutter's own
/// `Icon` widget, so it merges automatically inside `MButton`/`MBadge` (which
/// already call `IconTheme.merge` around their child).
///
/// ```dart
/// MIcon(MIconData.chevronDown)
/// MIcon(MIconData.sun, size: 20, semanticLabel: 'Switch to light theme')
/// ```
class MIcon extends StatelessWidget {
  /// Builds an icon from [MIconData].
  const MIcon(
    this.icon, {
    this.size,
    this.color,
    this.semanticLabel,
    this.strokeWidth,
    super.key,
  });

  /// The glyph to paint.
  final MIconData icon;

  /// The icon's edge length. Falls back to [IconTheme], then 24.
  final double? size;

  /// The stroke/fill color. Falls back to [IconTheme], then the theme's
  /// `colors.foreground`.
  final Color? color;

  /// Overrides [MIconData.semanticLabel] for this call site.
  final String? semanticLabel;

  /// Stroke width for line-based glyphs (chevrons, check, close, sun rays).
  /// Falls back to a size-proportional default.
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final IconThemeData iconTheme = IconTheme.of(context);
    final double resolvedSize = size ?? iconTheme.size ?? 24;
    final Color resolvedColor =
        color ?? iconTheme.color ?? theme.colors.foreground;
    final double resolvedStrokeWidth = strokeWidth ?? resolvedSize / 12;

    return Semantics(
      label: semanticLabel ?? icon.semanticLabel,
      image: true,
      child: SizedBox(
        width: resolvedSize,
        height: resolvedSize,
        child: CustomPaint(
          painter: _IconPainter(
            icon: icon,
            color: resolvedColor,
            strokeWidth: resolvedStrokeWidth,
          ),
        ),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  const _IconPainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
  });

  final MIconData icon;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = icon.buildPath(size.width);
    final Paint paint = Paint()..color = color;
    if (icon.filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IconPainter old) {
    return icon != old.icon ||
        color != old.color ||
        strokeWidth != old.strokeWidth;
  }
}
