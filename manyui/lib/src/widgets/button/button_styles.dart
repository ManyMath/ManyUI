import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'button_style.dart';

/// The variant/size/modality resolution table for [MButton].
///
/// Lives on `MThemeData.button` so apps can swap the entire table to
/// re-skin every button in the tree at once. The default table is derived
/// from [MColorScheme] tokens and a baseline size scale that bumps hit
/// targets up under touch modality.
///
/// ```dart
/// final MButtonStyle style = theme.button.resolve(
///   variant: MButtonVariant.primary,
///   size: MButtonSize.md,
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography.inheritFromContext(context),
///   radius: theme.radius,
/// );
/// ```
@immutable
class MButtonStyles {
  /// Builds a styles table.
  ///
  /// The default constructor takes no parameters because the default table
  /// is fully derived from the theme tokens passed into [resolve]. Subclass
  /// (or compose) to swap the resolution rule itself.
  const MButtonStyles();

  /// Returns the resolved [MButtonStyle] for [variant] under [size] and
  /// [modality], using the supplied theme tokens.
  ///
  /// [modality] picks the hit-target scale: a touch-mode `md` button is
  /// 44 px tall, a mouse-mode `md` button is 36 px. The literal DECISIONS
  /// contract used `platform` here; we switched to `modality` because
  /// modality is what actually drives sizing — `platform` is just one of
  /// the inputs that feeds modality resolution. See the
  /// `MButtonStyles.resolve takes modality` note in DECISIONS.md.
  MButtonStyle resolve({
    required MButtonVariant variant,
    required MButtonSize size,
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;

    final double minHeight = switch (size) {
      MButtonSize.xs => touch ? 32 : 24,
      MButtonSize.sm => touch ? 40 : 32,
      MButtonSize.md => touch ? 44 : 36,
      MButtonSize.lg => touch ? 48 : 40,
    };
    final EdgeInsetsGeometry padding = switch (size) {
      MButtonSize.xs => const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      MButtonSize.sm => const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      MButtonSize.md => const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      MButtonSize.lg => const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    };
    final TextStyle textStyle = switch (size) {
      MButtonSize.xs => typography.caption,
      MButtonSize.sm => typography.label,
      MButtonSize.md => typography.label,
      MButtonSize.lg => typography.title,
    };

    final BorderRadius cornerRadius = BorderRadius.circular(radius);

    switch (variant) {
      case MButtonVariant.primary:
        return MButtonStyle(
          backgroundColor: colors.primary,
          hoverBackgroundColor: Color.alphaBlend(
            colors.foreground.withAlpha(20),
            colors.primary,
          ),
          foregroundColor: colors.primaryForeground,
          borderColor: null,
          borderWidth: 0,
          padding: padding,
          minHeight: minHeight,
          textStyle: textStyle,
          radius: cornerRadius,
        );
      case MButtonVariant.secondary:
        return MButtonStyle(
          backgroundColor: colors.secondary,
          hoverBackgroundColor: Color.alphaBlend(
            colors.foreground.withAlpha(15),
            colors.secondary,
          ),
          foregroundColor: colors.secondaryForeground,
          borderColor: null,
          borderWidth: 0,
          padding: padding,
          minHeight: minHeight,
          textStyle: textStyle,
          radius: cornerRadius,
        );
      case MButtonVariant.destructive:
        return MButtonStyle(
          backgroundColor: colors.destructive,
          hoverBackgroundColor: Color.alphaBlend(
            colors.foreground.withAlpha(25),
            colors.destructive,
          ),
          foregroundColor: colors.destructiveForeground,
          borderColor: null,
          borderWidth: 0,
          padding: padding,
          minHeight: minHeight,
          textStyle: textStyle,
          radius: cornerRadius,
        );
      case MButtonVariant.outline:
        return MButtonStyle(
          backgroundColor: const Color(0x00000000),
          hoverBackgroundColor: colors.accent,
          foregroundColor: colors.foreground,
          borderColor: colors.border,
          borderWidth: 1,
          padding: padding,
          minHeight: minHeight,
          textStyle: textStyle,
          radius: cornerRadius,
        );
      case MButtonVariant.ghost:
        return MButtonStyle(
          backgroundColor: const Color(0x00000000),
          hoverBackgroundColor: colors.accent,
          foregroundColor: colors.foreground,
          borderColor: null,
          borderWidth: 0,
          padding: padding,
          minHeight: minHeight,
          textStyle: textStyle,
          radius: cornerRadius,
        );
    }
  }

  @override
  bool operator ==(Object other) => other is MButtonStyles;

  @override
  int get hashCode => (MButtonStyles).hashCode;
}
