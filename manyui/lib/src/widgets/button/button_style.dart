import 'package:flutter/widgets.dart';

/// The visual variant a button renders as.
///
/// Variants pick a base color role from the theme's [MColorScheme]; the
/// [MButtonSize] picks the hit-target and padding scale. The two are
/// orthogonal: every variant supports every size.
enum MButtonVariant {
  /// Solid, high-emphasis. Background = `colors.primary`, foreground =
  /// `colors.primaryForeground`. Use sparingly — one per screen, ideally.
  primary,

  /// Solid, low-emphasis. Background = `colors.secondary`, foreground =
  /// `colors.secondaryForeground`. The default for non-destructive actions.
  secondary,

  /// Solid, action-confirming destruction. Background = `colors.destructive`.
  destructive,

  /// Transparent fill with a border. Foreground = `colors.foreground`,
  /// border = `colors.border`. Use for tertiary actions next to a primary.
  outline,

  /// Transparent fill, no border. The lightest-weight option, usually for
  /// toolbar-style actions where the affordance comes from icon + label.
  ghost,
}

/// The hit-target and padding scale a button renders at.
///
/// All four sizes ship on every variant. Touch modality bumps the resolved
/// minimum height: an `md` button is 36 px tall under mouse but 44 px tall
/// under touch.
enum MButtonSize {
  /// Compact, for inline contexts (toolbars, table rows).
  xs,

  /// Small, for dense forms.
  sm,

  /// The default size — the one most product UI should use.
  md,

  /// Large, for hero CTAs and onboarding flows.
  lg,
}

/// The fully-resolved visual style for an [MButton] under a specific variant,
/// size, platform, and modality.
///
/// Every field is required. Build a style by hand for advanced theming, or
/// (more commonly) let the theme resolve one via
/// `theme.button.resolve(variant: ..., size: ..., platform: ...)` and tweak
/// it through an [MButtonStyleDelta].
@immutable
class MButtonStyle {
  /// Builds a button style with every field specified.
  const MButtonStyle({
    required this.backgroundColor,
    required this.hoverBackgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.padding,
    required this.minHeight,
    required this.textStyle,
    required this.radius,
  });

  /// The fill color of the button's body.
  final Color backgroundColor;

  /// The fill color when the pointer is hovering. On touch and keyboard
  /// modalities, hover state never resolves, so this color is unreachable.
  final Color hoverBackgroundColor;

  /// The color of the button's label text and icon.
  final Color foregroundColor;

  /// The stroke color of the button's border, or null for no border.
  final Color? borderColor;

  /// The thickness of the border in logical pixels. Ignored when
  /// [borderColor] is null.
  final double borderWidth;

  /// The padding between the button's edge and its label content.
  final EdgeInsetsGeometry padding;

  /// The minimum height of the button's box.
  ///
  /// Hit-target sizes follow the modality default: touch buttons resolve
  /// taller than mouse buttons at the same [MButtonSize].
  final double minHeight;

  /// The text style applied to the button's label.
  final TextStyle textStyle;

  /// The corner radius of the button's body.
  final BorderRadiusGeometry radius;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  ///
  /// Used internally by [MButton] to fold user-supplied
  /// [MButtonStyleDelta] tweaks onto a theme-resolved style.
  MButtonStyle applyDelta(MButtonStyleDelta? delta) {
    if (delta == null) return this;
    return MButtonStyle(
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      hoverBackgroundColor: delta.hoverBackgroundColor ?? hoverBackgroundColor,
      foregroundColor: delta.foregroundColor ?? foregroundColor,
      borderColor: delta.borderColor ?? borderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      padding: delta.padding ?? padding,
      minHeight: delta.minHeight ?? minHeight,
      textStyle: delta.textStyle ?? textStyle,
      radius: delta.radius ?? radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MButtonStyle &&
        other.backgroundColor == backgroundColor &&
        other.hoverBackgroundColor == hoverBackgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.minHeight == minHeight &&
        other.textStyle == textStyle &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        hoverBackgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        padding,
        minHeight,
        textStyle,
        radius,
      );
}

/// A nullable overlay of [MButtonStyle] fields.
///
/// Pass an instance into `MButton(style: ...)` to override individual fields
/// of the theme-resolved style. Any field left null keeps the theme value.
@immutable
class MButtonStyleDelta {
  /// Builds a delta with the supplied fields. Unspecified fields are null
  /// and pass through the underlying style unchanged.
  const MButtonStyleDelta({
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.minHeight,
    this.textStyle,
    this.radius,
  });

  /// Override for [MButtonStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MButtonStyle.hoverBackgroundColor].
  final Color? hoverBackgroundColor;

  /// Override for [MButtonStyle.foregroundColor].
  final Color? foregroundColor;

  /// Override for [MButtonStyle.borderColor].
  final Color? borderColor;

  /// Override for [MButtonStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MButtonStyle.padding].
  final EdgeInsetsGeometry? padding;

  /// Override for [MButtonStyle.minHeight].
  final double? minHeight;

  /// Override for [MButtonStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MButtonStyle.radius].
  final BorderRadiusGeometry? radius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MButtonStyleDelta &&
        other.backgroundColor == backgroundColor &&
        other.hoverBackgroundColor == hoverBackgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.minHeight == minHeight &&
        other.textStyle == textStyle &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        hoverBackgroundColor,
        foregroundColor,
        borderColor,
        borderWidth,
        padding,
        minHeight,
        textStyle,
        radius,
      );
}
