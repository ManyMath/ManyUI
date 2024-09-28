import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

/// The 19 shadcn-aligned color tokens that drive every manyui widget.
///
/// Token names mirror shadcn's CSS variables (`--background`, `--foreground`,
/// etc.) in camelCase form. Pair tokens (`primary` + `primaryForeground`) are
/// always defined together so that foreground contrast on the matching surface
/// is the theme author's call, not the widget's.
///
/// Use [MColorScheme.light] or [MColorScheme.dark] for the default neutral
/// palettes. Build a custom scheme with the unnamed constructor.
@immutable
class MColorScheme {
  /// The default light-mode scheme. Neutral grays on a white background, with
  /// a near-black primary, a red destructive, and a slate ring.
  const MColorScheme.light()
      : background = const Color(0xFFFFFFFF),
        foreground = const Color(0xFF0A0A0A),
        card = const Color(0xFFFFFFFF),
        cardForeground = const Color(0xFF0A0A0A),
        popover = const Color(0xFFFFFFFF),
        popoverForeground = const Color(0xFF0A0A0A),
        primary = const Color(0xFF171717),
        primaryForeground = const Color(0xFFFAFAFA),
        secondary = const Color(0xFFF5F5F5),
        secondaryForeground = const Color(0xFF171717),
        muted = const Color(0xFFF5F5F5),
        mutedForeground = const Color(0xFF737373),
        accent = const Color(0xFFF5F5F5),
        accentForeground = const Color(0xFF171717),
        destructive = const Color(0xFFEF4444),
        destructiveForeground = const Color(0xFFFAFAFA),
        border = const Color(0xFFE5E5E5),
        input = const Color(0xFFE5E5E5),
        ring = const Color(0xFF0A0A0A);

  /// The default dark-mode scheme. Near-black background, near-white
  /// foreground, with token roles mirrored from [MColorScheme.light].
  const MColorScheme.dark()
      : background = const Color(0xFF0A0A0A),
        foreground = const Color(0xFFFAFAFA),
        card = const Color(0xFF0A0A0A),
        cardForeground = const Color(0xFFFAFAFA),
        popover = const Color(0xFF0A0A0A),
        popoverForeground = const Color(0xFFFAFAFA),
        primary = const Color(0xFFFAFAFA),
        primaryForeground = const Color(0xFF171717),
        secondary = const Color(0xFF262626),
        secondaryForeground = const Color(0xFFFAFAFA),
        muted = const Color(0xFF262626),
        mutedForeground = const Color(0xFFA1A1AA),
        accent = const Color(0xFF262626),
        accentForeground = const Color(0xFFFAFAFA),
        destructive = const Color(0xFF7F1D1D),
        destructiveForeground = const Color(0xFFFAFAFA),
        border = const Color(0xFF262626),
        input = const Color(0xFF262626),
        ring = const Color(0xFFD4D4D8);

  /// Builds a scheme with every token explicitly specified.
  const MColorScheme({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
  });

  /// The app's base surface color.
  final Color background;

  /// The default text and icon color on [background].
  final Color foreground;

  /// The surface color for [card]-rooted widgets.
  final Color card;

  /// The default text and icon color on [card].
  final Color cardForeground;

  /// The surface color for popover/menu/tooltip layers.
  final Color popover;

  /// The default text and icon color on [popover].
  final Color popoverForeground;

  /// The primary action color (e.g. a confirm button background).
  final Color primary;

  /// The text and icon color on [primary].
  final Color primaryForeground;

  /// The secondary action color (e.g. a low-emphasis button background).
  final Color secondary;

  /// The text and icon color on [secondary].
  final Color secondaryForeground;

  /// The muted surface color for disabled or de-emphasized regions.
  final Color muted;

  /// The text and icon color on [muted], typically used for helper text.
  final Color mutedForeground;

  /// The accent color used for hovered or highlighted regions.
  final Color accent;

  /// The text and icon color on [accent].
  final Color accentForeground;

  /// The destructive action color (e.g. a delete button).
  final Color destructive;

  /// The text and icon color on [destructive].
  final Color destructiveForeground;

  /// The default border color for cards, inputs, and dividers.
  final Color border;

  /// The default border color for text inputs.
  final Color input;

  /// The focus-ring color used by [MFocusRing].
  final Color ring;

  /// Returns a copy of this scheme with the supplied tokens overridden.
  MColorScheme copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? popover,
    Color? popoverForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentForeground,
    Color? destructive,
    Color? destructiveForeground,
    Color? border,
    Color? input,
    Color? ring,
  }) {
    return MColorScheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      popover: popover ?? this.popover,
      popoverForeground: popoverForeground ?? this.popoverForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      destructive: destructive ?? this.destructive,
      destructiveForeground:
          destructiveForeground ?? this.destructiveForeground,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MColorScheme &&
        other.background == background &&
        other.foreground == foreground &&
        other.card == card &&
        other.cardForeground == cardForeground &&
        other.popover == popover &&
        other.popoverForeground == popoverForeground &&
        other.primary == primary &&
        other.primaryForeground == primaryForeground &&
        other.secondary == secondary &&
        other.secondaryForeground == secondaryForeground &&
        other.muted == muted &&
        other.mutedForeground == mutedForeground &&
        other.accent == accent &&
        other.accentForeground == accentForeground &&
        other.destructive == destructive &&
        other.destructiveForeground == destructiveForeground &&
        other.border == border &&
        other.input == input &&
        other.ring == ring;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
        background,
        foreground,
        card,
        cardForeground,
        popover,
        popoverForeground,
        primary,
        primaryForeground,
        secondary,
        secondaryForeground,
        muted,
        mutedForeground,
        accent,
        accentForeground,
        destructive,
        destructiveForeground,
        border,
        input,
        ring,
      ]);
}
