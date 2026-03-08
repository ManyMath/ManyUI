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

  /// Plus glyph, used for create and add actions.
  static const MIconData plus = MIconData._(_plusPath, semanticLabel: 'Add');

  /// Right-facing play glyph, used to start previews and playback.
  static const MIconData play = MIconData._(
    _playPath,
    semanticLabel: 'Play',
    filled: true,
  );

  /// Magnifying glass glyph, used for search.
  static const MIconData search = MIconData._(
    _searchPath,
    semanticLabel: 'Search',
  );

  /// Three horizontal lines, used for navigation menus.
  static const MIconData menu = MIconData._(_menuPath, semanticLabel: 'Menu');

  /// Three horizontal dots, used for overflow menus.
  static const MIconData moreHorizontal = MIconData._(
    _moreHorizontalPath,
    semanticLabel: 'More options',
    filled: true,
  );

  /// Circular arrow glyph, used for refresh and retry actions.
  static const MIconData refresh = MIconData._(
    _refreshPath,
    semanticLabel: 'Refresh',
  );

  /// Pencil glyph, used for edit actions.
  static const MIconData edit = MIconData._(_editPath, semanticLabel: 'Edit');

  /// Trash can glyph, used for destructive delete actions.
  static const MIconData trash = MIconData._(
    _trashPath,
    semanticLabel: 'Delete',
  );

  /// Two overlapping rectangles, used for copy actions.
  static const MIconData copy = MIconData._(_copyPath, semanticLabel: 'Copy');

  /// Gear-like settings glyph.
  static const MIconData settings = MIconData._(
    _settingsPath,
    semanticLabel: 'Settings',
  );

  /// Padlock glyph, used for vaults and protected content.
  static const MIconData lock = MIconData._(_lockPath, semanticLabel: 'Locked');

  /// Open padlock glyph, used for unlock actions.
  static const MIconData unlock = MIconData._(
    _unlockPath,
    semanticLabel: 'Unlocked',
  );

  /// Folder glyph, used for files, vaults, and groups.
  static const MIconData folder = MIconData._(
    _folderPath,
    semanticLabel: 'Folder',
  );

  /// Speech bubble glyph, used for rooms and conversations.
  static const MIconData message = MIconData._(
    _messagePath,
    semanticLabel: 'Message',
  );

  /// Two-person glyph, used for members and accounts.
  static const MIconData users = MIconData._(
    _usersPath,
    semanticLabel: 'People',
  );

  /// Connected-node glyph, used for networks and relations.
  static const MIconData network = MIconData._(
    _networkPath,
    semanticLabel: 'Network',
  );

  /// House glyph, used for overview and home navigation.
  static const MIconData home = MIconData._(_homePath, semanticLabel: 'Home');

  /// Circled information glyph.
  static const MIconData info = MIconData._(
    _infoPath,
    semanticLabel: 'Information',
  );

  /// Upward arrow glyph.
  static const MIconData arrowUp = MIconData._(
    _arrowUpPath,
    semanticLabel: 'Move up',
  );

  /// Downward arrow glyph.
  static const MIconData arrowDown = MIconData._(
    _arrowDownPath,
    semanticLabel: 'Move down',
  );

  /// Rightward arrow glyph.
  static const MIconData arrowRight = MIconData._(
    _arrowRightPath,
    semanticLabel: 'Continue',
  );

  /// Document glyph, used for pages and text files.
  static const MIconData fileText = MIconData._(
    _fileTextPath,
    semanticLabel: 'Document',
  );

  /// Overlapping geometric shapes, used for object types and schemas.
  static const MIconData shapes = MIconData._(
    _shapesPath,
    semanticLabel: 'Types',
  );

  /// Chain-link glyph, used for relations and links.
  static const MIconData link = MIconData._(_linkPath, semanticLabel: 'Link');

  /// Tag glyph, used for labels and properties.
  static const MIconData tag = MIconData._(_tagPath, semanticLabel: 'Tag');

  /// Checked square glyph, used for tasks and completed states.
  static const MIconData checkSquare = MIconData._(
    _checkSquarePath,
    semanticLabel: 'Completed',
  );

  /// Quote marks, used for quoted content.
  static const MIconData quote = MIconData._(
    _quotePath,
    semanticLabel: 'Quote',
  );

  /// Calendar glyph, used for dates.
  static const MIconData calendar = MIconData._(
    _calendarPath,
    semanticLabel: 'Date',
  );

  /// Key glyph, used for credentials and recovery keys.
  static const MIconData key = MIconData._(_keyPath, semanticLabel: 'Key');

  /// Shield glyph, used for security status.
  static const MIconData shield = MIconData._(
    _shieldPath,
    semanticLabel: 'Security',
  );

  /// Clock glyph, used for recent activity and time.
  static const MIconData clock = MIconData._(_clockPath, semanticLabel: 'Time');

  /// Paperclip glyph, used for attachments.
  static const MIconData attachment = MIconData._(
    _attachmentPath,
    semanticLabel: 'Attach',
  );

  /// Four outward-facing corners, used to maximize a pane or document.
  static const MIconData maximize = MIconData._(
    _maximizePath,
    semanticLabel: 'Maximize',
  );

  /// Four inward-facing corners, used to restore a maximized surface.
  static const MIconData restore = MIconData._(
    _restorePath,
    semanticLabel: 'Restore',
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

  static Path _plusPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.5, s * 0.2)
      ..lineTo(s * 0.5, s * 0.8)
      ..moveTo(s * 0.2, s * 0.5)
      ..lineTo(s * 0.8, s * 0.5);
  }

  static Path _maximizePath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.4, s * 0.18)
      ..lineTo(s * 0.18, s * 0.18)
      ..lineTo(s * 0.18, s * 0.4)
      ..moveTo(s * 0.6, s * 0.18)
      ..lineTo(s * 0.82, s * 0.18)
      ..lineTo(s * 0.82, s * 0.4)
      ..moveTo(s * 0.82, s * 0.6)
      ..lineTo(s * 0.82, s * 0.82)
      ..lineTo(s * 0.6, s * 0.82)
      ..moveTo(s * 0.4, s * 0.82)
      ..lineTo(s * 0.18, s * 0.82)
      ..lineTo(s * 0.18, s * 0.6);
  }

  static Path _restorePath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.18, s * 0.4)
      ..lineTo(s * 0.4, s * 0.4)
      ..lineTo(s * 0.4, s * 0.18)
      ..moveTo(s * 0.6, s * 0.18)
      ..lineTo(s * 0.6, s * 0.4)
      ..lineTo(s * 0.82, s * 0.4)
      ..moveTo(s * 0.82, s * 0.6)
      ..lineTo(s * 0.6, s * 0.6)
      ..lineTo(s * 0.6, s * 0.82)
      ..moveTo(s * 0.4, s * 0.82)
      ..lineTo(s * 0.4, s * 0.6)
      ..lineTo(s * 0.18, s * 0.6);
  }

  static Path _playPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.3, s * 0.17)
      ..lineTo(s * 0.82, s * 0.5)
      ..lineTo(s * 0.3, s * 0.83)
      ..close();
  }

  static Path _searchPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.43, s * 0.43), radius: s * 0.27),
      )
      ..moveTo(s * 0.63, s * 0.63)
      ..lineTo(s * 0.84, s * 0.84);
  }

  static Path _menuPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.18, s * 0.28)
      ..lineTo(s * 0.82, s * 0.28)
      ..moveTo(s * 0.18, s * 0.5)
      ..lineTo(s * 0.82, s * 0.5)
      ..moveTo(s * 0.18, s * 0.72)
      ..lineTo(s * 0.82, s * 0.72);
  }

  static Path _moreHorizontalPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.22, s * 0.5), radius: s * 0.07),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.5, s * 0.5), radius: s * 0.07),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.78, s * 0.5), radius: s * 0.07),
      );
  }

  static Path _refreshPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.78, s * 0.33)
      ..quadraticBezierTo(s * 0.66, s * 0.16, s * 0.46, s * 0.17)
      ..quadraticBezierTo(s * 0.2, s * 0.19, s * 0.17, s * 0.48)
      ..quadraticBezierTo(s * 0.14, s * 0.77, s * 0.43, s * 0.82)
      ..quadraticBezierTo(s * 0.7, s * 0.87, s * 0.82, s * 0.64)
      ..moveTo(s * 0.78, s * 0.16)
      ..lineTo(s * 0.78, s * 0.34)
      ..lineTo(s * 0.6, s * 0.34);
  }

  static Path _editPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.2, s * 0.8)
      ..lineTo(s * 0.25, s * 0.6)
      ..lineTo(s * 0.65, s * 0.2)
      ..lineTo(s * 0.8, s * 0.35)
      ..lineTo(s * 0.4, s * 0.75)
      ..close()
      ..moveTo(s * 0.57, s * 0.28)
      ..lineTo(s * 0.72, s * 0.43);
  }

  static Path _trashPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.23, s * 0.3)
      ..lineTo(s * 0.77, s * 0.3)
      ..moveTo(s * 0.36, s * 0.3)
      ..lineTo(s * 0.39, s * 0.18)
      ..lineTo(s * 0.61, s * 0.18)
      ..lineTo(s * 0.64, s * 0.3)
      ..moveTo(s * 0.3, s * 0.3)
      ..lineTo(s * 0.34, s * 0.82)
      ..lineTo(s * 0.66, s * 0.82)
      ..lineTo(s * 0.7, s * 0.3)
      ..moveTo(s * 0.44, s * 0.42)
      ..lineTo(s * 0.44, s * 0.68)
      ..moveTo(s * 0.56, s * 0.42)
      ..lineTo(s * 0.56, s * 0.68);
  }

  static Path _copyPath(double size) {
    final double s = size;
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.32, s * 0.28, s * 0.5, s * 0.54),
          Radius.circular(s * 0.06),
        ),
      )
      ..moveTo(s * 0.27, s * 0.68)
      ..lineTo(s * 0.22, s * 0.68)
      ..quadraticBezierTo(s * 0.16, s * 0.68, s * 0.16, s * 0.61)
      ..lineTo(s * 0.16, s * 0.23)
      ..quadraticBezierTo(s * 0.16, s * 0.17, s * 0.23, s * 0.17)
      ..lineTo(s * 0.61, s * 0.17)
      ..quadraticBezierTo(s * 0.68, s * 0.17, s * 0.68, s * 0.23)
      ..lineTo(s * 0.68, s * 0.24);
  }

  static Path _settingsPath(double size) {
    final double s = size;
    final Offset c = Offset(s * 0.5, s * 0.5);
    final Path path = Path()
      ..addOval(Rect.fromCircle(center: c, radius: s * 0.17));
    for (int i = 0; i < 8; i++) {
      final double angle = i * math.pi / 4;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final Offset from = c + direction * (s * 0.28);
      final Offset to = c + direction * (s * 0.4);
      path
        ..moveTo(from.dx, from.dy)
        ..lineTo(to.dx, to.dy);
    }
    return path;
  }

  static Path _lockPath(double size) {
    final double s = size;
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.2, s * 0.42, s * 0.6, s * 0.42),
          Radius.circular(s * 0.07),
        ),
      )
      ..moveTo(s * 0.32, s * 0.42)
      ..lineTo(s * 0.32, s * 0.33)
      ..quadraticBezierTo(s * 0.32, s * 0.14, s * 0.5, s * 0.14)
      ..quadraticBezierTo(s * 0.68, s * 0.14, s * 0.68, s * 0.33)
      ..lineTo(s * 0.68, s * 0.42)
      ..moveTo(s * 0.5, s * 0.57)
      ..lineTo(s * 0.5, s * 0.7);
  }

  static Path _unlockPath(double size) {
    final double s = size;
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.2, s * 0.42, s * 0.6, s * 0.42),
          Radius.circular(s * 0.07),
        ),
      )
      ..moveTo(s * 0.62, s * 0.42)
      ..lineTo(s * 0.62, s * 0.32)
      ..quadraticBezierTo(s * 0.62, s * 0.15, s * 0.45, s * 0.15)
      ..quadraticBezierTo(s * 0.3, s * 0.15, s * 0.29, s * 0.28)
      ..moveTo(s * 0.5, s * 0.57)
      ..lineTo(s * 0.5, s * 0.7);
  }

  static Path _folderPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.14, s * 0.28)
      ..quadraticBezierTo(s * 0.14, s * 0.21, s * 0.22, s * 0.21)
      ..lineTo(s * 0.43, s * 0.21)
      ..lineTo(s * 0.51, s * 0.31)
      ..lineTo(s * 0.78, s * 0.31)
      ..quadraticBezierTo(s * 0.86, s * 0.31, s * 0.86, s * 0.39)
      ..lineTo(s * 0.86, s * 0.74)
      ..quadraticBezierTo(s * 0.86, s * 0.82, s * 0.78, s * 0.82)
      ..lineTo(s * 0.22, s * 0.82)
      ..quadraticBezierTo(s * 0.14, s * 0.82, s * 0.14, s * 0.74)
      ..close();
  }

  static Path _messagePath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.18, s * 0.2)
      ..lineTo(s * 0.82, s * 0.2)
      ..quadraticBezierTo(s * 0.88, s * 0.2, s * 0.88, s * 0.27)
      ..lineTo(s * 0.88, s * 0.65)
      ..quadraticBezierTo(s * 0.88, s * 0.72, s * 0.81, s * 0.72)
      ..lineTo(s * 0.45, s * 0.72)
      ..lineTo(s * 0.25, s * 0.86)
      ..lineTo(s * 0.29, s * 0.72)
      ..lineTo(s * 0.18, s * 0.72)
      ..quadraticBezierTo(s * 0.12, s * 0.72, s * 0.12, s * 0.65)
      ..lineTo(s * 0.12, s * 0.27)
      ..quadraticBezierTo(s * 0.12, s * 0.2, s * 0.18, s * 0.2)
      ..close();
  }

  static Path _usersPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.4, s * 0.34), radius: s * 0.14),
      )
      ..moveTo(s * 0.14, s * 0.8)
      ..quadraticBezierTo(s * 0.17, s * 0.56, s * 0.4, s * 0.56)
      ..quadraticBezierTo(s * 0.63, s * 0.56, s * 0.66, s * 0.8)
      ..moveTo(s * 0.6, s * 0.22)
      ..quadraticBezierTo(s * 0.75, s * 0.23, s * 0.75, s * 0.36)
      ..quadraticBezierTo(s * 0.75, s * 0.48, s * 0.63, s * 0.5)
      ..moveTo(s * 0.68, s * 0.59)
      ..quadraticBezierTo(s * 0.84, s * 0.62, s * 0.86, s * 0.79);
  }

  static Path _networkPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.5, s * 0.2), radius: s * 0.1),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.2, s * 0.76), radius: s * 0.1),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.8, s * 0.76), radius: s * 0.1),
      )
      ..moveTo(s * 0.45, s * 0.29)
      ..lineTo(s * 0.25, s * 0.67)
      ..moveTo(s * 0.55, s * 0.29)
      ..lineTo(s * 0.75, s * 0.67)
      ..moveTo(s * 0.31, s * 0.76)
      ..lineTo(s * 0.69, s * 0.76);
  }

  static Path _homePath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.14, s * 0.48)
      ..lineTo(s * 0.5, s * 0.17)
      ..lineTo(s * 0.86, s * 0.48)
      ..moveTo(s * 0.23, s * 0.42)
      ..lineTo(s * 0.23, s * 0.83)
      ..lineTo(s * 0.77, s * 0.83)
      ..lineTo(s * 0.77, s * 0.42)
      ..moveTo(s * 0.43, s * 0.83)
      ..lineTo(s * 0.43, s * 0.6)
      ..lineTo(s * 0.57, s * 0.6)
      ..lineTo(s * 0.57, s * 0.83);
  }

  static Path _infoPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.5, s * 0.5), radius: s * 0.36),
      )
      ..moveTo(s * 0.5, s * 0.43)
      ..lineTo(s * 0.5, s * 0.7)
      ..moveTo(s * 0.5, s * 0.3)
      ..lineTo(s * 0.5, s * 0.31);
  }

  static Path _arrowUpPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.5, s * 0.82)
      ..lineTo(s * 0.5, s * 0.2)
      ..moveTo(s * 0.24, s * 0.46)
      ..lineTo(s * 0.5, s * 0.2)
      ..lineTo(s * 0.76, s * 0.46);
  }

  static Path _arrowDownPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.5, s * 0.18)
      ..lineTo(s * 0.5, s * 0.8)
      ..moveTo(s * 0.24, s * 0.54)
      ..lineTo(s * 0.5, s * 0.8)
      ..lineTo(s * 0.76, s * 0.54);
  }

  static Path _arrowRightPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.18, s * 0.5)
      ..lineTo(s * 0.8, s * 0.5)
      ..moveTo(s * 0.54, s * 0.24)
      ..lineTo(s * 0.8, s * 0.5)
      ..lineTo(s * 0.54, s * 0.76);
  }

  static Path _fileTextPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.25, s * 0.13)
      ..lineTo(s * 0.58, s * 0.13)
      ..lineTo(s * 0.78, s * 0.33)
      ..lineTo(s * 0.78, s * 0.84)
      ..lineTo(s * 0.25, s * 0.84)
      ..close()
      ..moveTo(s * 0.58, s * 0.13)
      ..lineTo(s * 0.58, s * 0.33)
      ..lineTo(s * 0.78, s * 0.33)
      ..moveTo(s * 0.36, s * 0.5)
      ..lineTo(s * 0.67, s * 0.5)
      ..moveTo(s * 0.36, s * 0.63)
      ..lineTo(s * 0.67, s * 0.63)
      ..moveTo(s * 0.36, s * 0.75)
      ..lineTo(s * 0.55, s * 0.75);
  }

  static Path _shapesPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.36, s * 0.36), radius: s * 0.2),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.45, s * 0.45, s * 0.39, s * 0.39),
          Radius.circular(s * 0.05),
        ),
      );
  }

  static Path _linkPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(s * 0.37, s * 0.59),
          width: s * 0.48,
          height: s * 0.3,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: Offset(s * 0.63, s * 0.41),
          width: s * 0.48,
          height: s * 0.3,
        ),
      )
      ..moveTo(s * 0.39, s * 0.57)
      ..lineTo(s * 0.61, s * 0.43);
  }

  static Path _tagPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.14, s * 0.2)
      ..lineTo(s * 0.51, s * 0.2)
      ..lineTo(s * 0.84, s * 0.53)
      ..lineTo(s * 0.53, s * 0.84)
      ..lineTo(s * 0.14, s * 0.45)
      ..close()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.31, s * 0.37), radius: s * 0.055),
      );
  }

  static Path _checkSquarePath(double size) {
    final double s = size;
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.14, s * 0.14, s * 0.72, s * 0.72),
          Radius.circular(s * 0.07),
        ),
      )
      ..moveTo(s * 0.3, s * 0.51)
      ..lineTo(s * 0.44, s * 0.65)
      ..lineTo(s * 0.72, s * 0.34);
  }

  static Path _quotePath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.42, s * 0.25)
      ..quadraticBezierTo(s * 0.18, s * 0.33, s * 0.18, s * 0.58)
      ..lineTo(s * 0.18, s * 0.74)
      ..lineTo(s * 0.43, s * 0.74)
      ..lineTo(s * 0.43, s * 0.5)
      ..lineTo(s * 0.28, s * 0.5)
      ..moveTo(s * 0.82, s * 0.25)
      ..quadraticBezierTo(s * 0.58, s * 0.33, s * 0.58, s * 0.58)
      ..lineTo(s * 0.58, s * 0.74)
      ..lineTo(s * 0.83, s * 0.74)
      ..lineTo(s * 0.83, s * 0.5)
      ..lineTo(s * 0.68, s * 0.5);
  }

  static Path _calendarPath(double size) {
    final double s = size;
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.14, s * 0.2, s * 0.72, s * 0.66),
          Radius.circular(s * 0.06),
        ),
      )
      ..moveTo(s * 0.14, s * 0.39)
      ..lineTo(s * 0.86, s * 0.39)
      ..moveTo(s * 0.32, s * 0.12)
      ..lineTo(s * 0.32, s * 0.28)
      ..moveTo(s * 0.68, s * 0.12)
      ..lineTo(s * 0.68, s * 0.28)
      ..moveTo(s * 0.31, s * 0.55)
      ..lineTo(s * 0.31, s * 0.56)
      ..moveTo(s * 0.5, s * 0.55)
      ..lineTo(s * 0.5, s * 0.56)
      ..moveTo(s * 0.69, s * 0.55)
      ..lineTo(s * 0.69, s * 0.56)
      ..moveTo(s * 0.31, s * 0.7)
      ..lineTo(s * 0.31, s * 0.71)
      ..moveTo(s * 0.5, s * 0.7)
      ..lineTo(s * 0.5, s * 0.71);
  }

  static Path _keyPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.34, s * 0.44), radius: s * 0.2),
      )
      ..moveTo(s * 0.49, s * 0.58)
      ..lineTo(s * 0.82, s * 0.82)
      ..moveTo(s * 0.67, s * 0.71)
      ..lineTo(s * 0.74, s * 0.64)
      ..moveTo(s * 0.74, s * 0.77)
      ..lineTo(s * 0.81, s * 0.7);
  }

  static Path _shieldPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.5, s * 0.12)
      ..lineTo(s * 0.82, s * 0.25)
      ..lineTo(s * 0.78, s * 0.62)
      ..quadraticBezierTo(s * 0.74, s * 0.8, s * 0.5, s * 0.9)
      ..quadraticBezierTo(s * 0.26, s * 0.8, s * 0.22, s * 0.62)
      ..lineTo(s * 0.18, s * 0.25)
      ..close();
  }

  static Path _clockPath(double size) {
    final double s = size;
    return Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.5, s * 0.5), radius: s * 0.36),
      )
      ..moveTo(s * 0.5, s * 0.28)
      ..lineTo(s * 0.5, s * 0.52)
      ..lineTo(s * 0.66, s * 0.62);
  }

  static Path _attachmentPath(double size) {
    final double s = size;
    return Path()
      ..moveTo(s * 0.35, s * 0.45)
      ..lineTo(s * 0.59, s * 0.21)
      ..quadraticBezierTo(s * 0.73, s * 0.08, s * 0.85, s * 0.21)
      ..quadraticBezierTo(s * 0.96, s * 0.33, s * 0.83, s * 0.47)
      ..lineTo(s * 0.48, s * 0.82)
      ..quadraticBezierTo(s * 0.29, s * 1, s * 0.13, s * 0.83)
      ..quadraticBezierTo(s * -0.02, s * 0.66, s * 0.16, s * 0.48)
      ..lineTo(s * 0.46, s * 0.18)
      ..moveTo(s * 0.27, s * 0.56)
      ..lineTo(s * 0.58, s * 0.25)
      ..quadraticBezierTo(s * 0.65, s * 0.18, s * 0.71, s * 0.25)
      ..quadraticBezierTo(s * 0.77, s * 0.32, s * 0.7, s * 0.39)
      ..lineTo(s * 0.44, s * 0.65)
      ..quadraticBezierTo(s * 0.37, s * 0.72, s * 0.3, s * 0.65);
  }
}
