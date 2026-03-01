import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A hand-authored glyph for [MIcon].
///
/// Paths are defined in a normalized 24x24 unit square (matching
/// `MCheckbox`'s `_CheckboxPainter` convention) and scaled to the requested
/// size at paint time. Straight lines and simple curves only, no traced
/// third-party icon set, to avoid a licensing question for this starter set.
@immutable
class MIconData {
  const MIconData._(
    this._buildPath, {
    required this.semanticLabel,
    this.filled = false,
  });

  final Path Function(double size) _buildPath;

  /// The default accessibility label for this glyph, used when the call
  /// site doesn't override [MIcon.semanticLabel].
  final String semanticLabel;

  /// Whether [MIcon] should fill this glyph's path rather than stroke it.
  ///
  /// Filled glyphs (sun's disc + rays, moon's crescent) are built from
  /// closed shapes; the line glyphs (chevrons, check, close) are open
  /// polylines meant to be stroked.
  final bool filled;

  /// Builds this glyph's path scaled to a [size]x[size] box.
  Path buildPath(double size) => _buildPath(size);

  /// Sun glyph, used for light/dark theme toggles.
  static const MIconData sun = MIconData._(
    _sunPath,
    semanticLabel: 'Light theme',
    filled: true,
  );

  /// Moon glyph, used for light/dark theme toggles.
  static const MIconData moon = MIconData._(
    _moonPath,
    semanticLabel: 'Dark theme',
    filled: true,
  );

  /// Downward chevron, used for expand affordances.
  static const MIconData chevronDown = MIconData._(
    _chevronDownPath,
    semanticLabel: 'Expand',
  );

  /// Rightward chevron, used for collapse/forward affordances.
  static const MIconData chevronRight = MIconData._(
    _chevronRightPath,
    semanticLabel: 'Collapse',
  );

  /// Leftward chevron, used for back navigation.
  static const MIconData chevronLeft = MIconData._(
    _chevronLeftPath,
    semanticLabel: 'Back',
  );

  /// Checkmark, for confirmation affordances outside `MCheckbox`.
  static const MIconData check = MIconData._(
    _checkPath,
    semanticLabel: 'Checked',
  );

  /// Close/dismiss glyph.
  static const MIconData close = MIconData._(
    _closePath,
    semanticLabel: 'Close',
  );

  /// Open eye glyph, for a "reveal secret" toggle in its shown state.
  static const MIconData eye = MIconData._(_eyePath, semanticLabel: 'Show');

  /// Eye-with-slash glyph, for a "reveal secret" toggle in its hidden state.
  static const MIconData eyeOff = MIconData._(
    _eyeOffPath,
    semanticLabel: 'Hide',
  );

  static Path _sunPath(double size) {
    final double s = size;
    final Path path = Path();
    final Offset center = Offset(s * 0.5, s * 0.5);
    path.addOval(Rect.fromCircle(center: center, radius: s * 0.22));
    for (int i = 0; i < 8; i++) {
      final double angle = i * 45 * math.pi / 180;
      final double inner = s * 0.34;
      final double outer = s * 0.46;
      final double rayWidth = s * 0.045;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final Offset normal = Offset(-direction.dy, direction.dx) * rayWidth;
      final Offset from = center + direction * inner;
      final Offset to = center + direction * outer;
      path
        ..moveTo(from.dx + normal.dx, from.dy + normal.dy)
        ..lineTo(to.dx + normal.dx, to.dy + normal.dy)
        ..lineTo(to.dx - normal.dx, to.dy - normal.dy)
        ..lineTo(from.dx - normal.dx, from.dy - normal.dy)
        ..close();
    }
    return path;
  }

  static Path _moonPath(double size) {
    final double s = size;
    final Rect outer = Rect.fromCircle(
      center: Offset(s * 0.5, s * 0.5),
      radius: s * 0.38,
    );
    final Rect inner = Rect.fromCircle(
      center: Offset(s * 0.62, s * 0.4),
      radius: s * 0.32,
    );
    return Path.combine(
      PathOperation.difference,
      Path()..addOval(outer),
      Path()..addOval(inner),
    );
  }

  static Path _chevronDownPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.22, s * 0.38)
      ..lineTo(s * 0.5, s * 0.64)
      ..lineTo(s * 0.78, s * 0.38);
  }

  static Path _chevronRightPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.38, s * 0.22)
      ..lineTo(s * 0.64, s * 0.5)
      ..lineTo(s * 0.38, s * 0.78);
  }

  static Path _chevronLeftPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.62, s * 0.22)
      ..lineTo(s * 0.36, s * 0.5)
      ..lineTo(s * 0.62, s * 0.78);
  }

  static Path _checkPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.2, s * 0.52)
      ..lineTo(s * 0.42, s * 0.74)
      ..lineTo(s * 0.8, s * 0.3);
  }

  static Path _closePath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.24, s * 0.24)
      ..lineTo(s * 0.76, s * 0.76)
      ..moveTo(s * 0.76, s * 0.24)
      ..lineTo(s * 0.24, s * 0.76);
  }

  static Path _eyePath(double size) {
    final double s = size;
    final Rect pupil = Rect.fromCircle(
      center: Offset(s * 0.5, s * 0.5),
      radius: s * 0.1,
    );
    return Path()
      // Almond-shaped outline via two quadratic arcs meeting at the corners.
      ..moveTo(s * 0.1, s * 0.5)
      ..quadraticBezierTo(s * 0.5, s * 0.22, s * 0.9, s * 0.5)
      ..quadraticBezierTo(s * 0.5, s * 0.78, s * 0.1, s * 0.5)
      ..close()
      ..addOval(pupil);
  }

  static Path _eyeOffPath(double size) {
    final double s = size;
    final Rect pupil = Rect.fromCircle(
      center: Offset(s * 0.5, s * 0.5),
      radius: s * 0.1,
    );
    return Path()
      ..moveTo(s * 0.1, s * 0.5)
      ..quadraticBezierTo(s * 0.5, s * 0.22, s * 0.9, s * 0.5)
      ..quadraticBezierTo(s * 0.5, s * 0.78, s * 0.1, s * 0.5)
      ..close()
      ..addOval(pupil)
      // Slash through the whole glyph, drawn as a second subpath so the
      // stroke pass renders it as its own open polyline.
      ..moveTo(s * 0.18, s * 0.18)
      ..lineTo(s * 0.82, s * 0.82);
  }
}
