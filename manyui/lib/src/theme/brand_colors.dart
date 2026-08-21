import 'dart:ui' show Color;

/// Shared ManyMath colors from `brand/BRAND.md`, section 1.
///
/// Provides light and dark variants of the brand green, accent, and error
/// colors. Use these constants to keep colors consistent across apps.
abstract final class MBrandColors {
  /// The family green, light mode (`--brand`). Primary actions, links,
  /// focus rings, and marks.
  static const Color green = Color(0xFF2E7D32);

  /// The family green, dark mode (`--brand`).
  static const Color greenDark = Color(0xFF78C87C);

  /// The hover-state green, light mode (`--brand-strong`).
  static const Color greenStrong = Color(0xFF236827);

  /// The hover-state green, dark mode (`--brand-strong`).
  static const Color greenStrongDark = Color(0xFF94D697);

  /// Text and icons on brand-green fills, light mode (`--brand-on`).
  static const Color onGreen = Color(0xFFFFFFFF);

  /// Text and icons on brand-green fills, dark mode (`--brand-on`).
  static const Color onGreenDark = Color(0xFF0E1E12);

  /// Tinted green fill for selected rows and soft badges, light mode
  /// (`--brand-soft`).
  static const Color greenSoft = Color(0xFFDCEBE0);

  /// Tinted green fill, dark mode (`--brand-soft`).
  static const Color greenSoftDark = Color(0xFF1D2B20);

  /// Light-mode accent for step numbers and small details (`--accent`).
  /// Use sparingly; avoid body text.
  static const Color accent = Color(0xFFB07F1F);

  /// The accent, dark mode (`--accent`).
  static const Color accentDark = Color(0xFFD9A441);

  /// Errors and destructive actions, light mode (`--danger`).
  static const Color danger = Color(0xFFC33E4B);

  /// Errors and destructive actions, dark mode (`--danger`).
  static const Color dangerDark = Color(0xFFE06C75);
}
