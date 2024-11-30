import 'package:flutter/foundation.dart';

import '../widgets/button/button_styles.dart';
import '../widgets/card/card_styles.dart';
import 'color_scheme.dart';
import 'focus_ring_style.dart';
import 'typography.dart';

/// The root theme object every manyui widget reads from.
///
/// Carries the color scheme, typography, focus-ring shape, default radius,
/// and the host platform. Widget-family sub-styles (button, card, …) will
/// be added in later phases without breaking this constructor — they default
/// to derived values from the tokens above when not supplied.
@immutable
class MThemeData {
  /// Builds a theme data instance.
  ///
  /// [platform] defaults to `defaultTargetPlatform`. Override it in tests to
  /// force a specific platform, or in apps that want to render a different
  /// platform's idiom (e.g. a desktop browser rendering iOS-style controls).
  MThemeData({
    required this.colors,
    MTypography? typography,
    MFocusRingStyle? focusRing,
    MButtonStyles? button,
    MCardStyles? card,
    this.radius = 6,
    TargetPlatform? platform,
  })  : typography = typography ?? const MTypography.standard(),
        focusRing = focusRing ?? const MFocusRingStyle(),
        button = button ?? const MButtonStyles(),
        card = card ?? const MCardStyles(),
        platform = platform ?? defaultTargetPlatform;

  /// The default light theme.
  factory MThemeData.light({TargetPlatform? platform}) {
    return MThemeData(
      colors: const MColorScheme.light(),
      platform: platform,
    );
  }

  /// The default dark theme.
  factory MThemeData.dark({TargetPlatform? platform}) {
    return MThemeData(
      colors: const MColorScheme.dark(),
      platform: platform,
    );
  }

  /// The 19-token color scheme.
  final MColorScheme colors;

  /// The named text styles used by every M-widget that renders text.
  final MTypography typography;

  /// The focus-ring shape used by `MFocusRing`.
  final MFocusRingStyle focusRing;

  /// The resolution table for [MButton] visual styles.
  ///
  /// Exposed as `theme.button.resolve(variant: ..., size: ..., modality: ...)`.
  /// Replace the default `MButtonStyles()` to re-skin every button in the
  /// tree with a different mapping from tokens to styles.
  final MButtonStyles button;

  /// The resolution table for [MCard] visual styles.
  ///
  /// Exposed as `theme.card.resolve(colors: ..., radius: ...)`. Replace the
  /// default `MCardStyles()` to re-skin every card in the tree.
  final MCardStyles card;

  /// The default corner radius for cards, buttons, and inputs.
  ///
  /// Individual widget styles may override this; v0.1 ships a single scalar
  /// rather than the multi-step scale shadcn now uses.
  final double radius;

  /// The host platform this theme renders for.
  ///
  /// Widgets use this to pick between modality-dependent variants (e.g. a
  /// touch-sized vs mouse-sized button). Defaults to
  /// `defaultTargetPlatform`; override for tests or for apps that want to
  /// render a non-host idiom.
  final TargetPlatform platform;

  /// Returns a copy with specific fields overridden.
  MThemeData copyWith({
    MColorScheme? colors,
    MTypography? typography,
    MFocusRingStyle? focusRing,
    MButtonStyles? button,
    MCardStyles? card,
    double? radius,
    TargetPlatform? platform,
  }) {
    return MThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      focusRing: focusRing ?? this.focusRing,
      button: button ?? this.button,
      card: card ?? this.card,
      radius: radius ?? this.radius,
      platform: platform ?? this.platform,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MThemeData &&
        other.colors == colors &&
        other.typography == typography &&
        other.focusRing == focusRing &&
        other.button == button &&
        other.card == card &&
        other.radius == radius &&
        other.platform == platform;
  }

  @override
  int get hashCode => Object.hash(
        colors,
        typography,
        focusRing,
        button,
        card,
        radius,
        platform,
      );
}
