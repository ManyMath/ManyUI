import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MTextField].
///
/// Carries the surface (background, border, radius), the text appearance
/// (cursor + placeholder + label color), and the layout (min height, inner
/// padding, the gap between leading/trailing decorations and the text). Build
/// by hand for advanced theming, or let the theme resolve one via
/// `theme.textField.resolve(...)` and tweak through an [MTextFieldStyleDelta].
@immutable
class MTextFieldStyle {
  /// Builds a text-field style with every field specified.
  const MTextFieldStyle({
    required this.minHeight,
    required this.padding,
    required this.backgroundColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.borderWidth,
    required this.radius,
    required this.textStyle,
    required this.placeholderColor,
    required this.cursorColor,
    required this.selectionColor,
    required this.iconColor,
    required this.decorationGap,
    required this.disabledOpacity,
  });

  /// Minimum height of the field surface, in logical pixels. Touch modality
  /// resolves to a larger height than mouse modality.
  final double minHeight;

  /// Inner padding between the border and the text/decorations.
  final EdgeInsets padding;

  /// Background fill of the field.
  final Color backgroundColor;

  /// Border color in the idle state (unfocused, no error).
  final Color borderColor;

  /// Border color when the field has keyboard focus and is not in an error
  /// state.
  final Color focusedBorderColor;

  /// Border color when the field is in an error state, regardless of focus.
  final Color errorBorderColor;

  /// Border thickness, in logical pixels. The same thickness is used for all
  /// states; only the color changes.
  final double borderWidth;

  /// Corner radius of the field's surface.
  final BorderRadius radius;

  /// Text style applied to the field's content and to the placeholder.
  ///
  /// The placeholder is recolored with [placeholderColor] but inherits the
  /// rest of the style (size, weight, line height).
  final TextStyle textStyle;

  /// Color applied to the placeholder string when the field is empty.
  final Color placeholderColor;

  /// Color of the blinking text-input cursor.
  final Color cursorColor;

  /// Color of the highlighted text selection.
  final Color selectionColor;

  /// Color applied to leading and trailing decoration icons.
  ///
  /// Decorations that supply their own [IconTheme] override this.
  final Color iconColor;

  /// Horizontal gap between a leading/trailing decoration and the text, in
  /// logical pixels.
  final double decorationGap;

  /// Opacity multiplier applied when the field is disabled.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MTextFieldStyle applyDelta(MTextFieldStyleDelta? delta) {
    if (delta == null) return this;
    return MTextFieldStyle(
      minHeight: delta.minHeight ?? minHeight,
      padding: delta.padding ?? padding,
      backgroundColor: delta.backgroundColor ?? backgroundColor,
      borderColor: delta.borderColor ?? borderColor,
      focusedBorderColor: delta.focusedBorderColor ?? focusedBorderColor,
      errorBorderColor: delta.errorBorderColor ?? errorBorderColor,
      borderWidth: delta.borderWidth ?? borderWidth,
      radius: delta.radius ?? radius,
      textStyle: delta.textStyle ?? textStyle,
      placeholderColor: delta.placeholderColor ?? placeholderColor,
      cursorColor: delta.cursorColor ?? cursorColor,
      selectionColor: delta.selectionColor ?? selectionColor,
      iconColor: delta.iconColor ?? iconColor,
      decorationGap: delta.decorationGap ?? decorationGap,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MTextFieldStyle &&
        other.minHeight == minHeight &&
        other.padding == padding &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.focusedBorderColor == focusedBorderColor &&
        other.errorBorderColor == errorBorderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.textStyle == textStyle &&
        other.placeholderColor == placeholderColor &&
        other.cursorColor == cursorColor &&
        other.selectionColor == selectionColor &&
        other.iconColor == iconColor &&
        other.decorationGap == decorationGap &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        minHeight,
        padding,
        backgroundColor,
        borderColor,
        focusedBorderColor,
        errorBorderColor,
        borderWidth,
        radius,
        textStyle,
        placeholderColor,
        cursorColor,
        selectionColor,
        iconColor,
        decorationGap,
        disabledOpacity,
      ]);
}

/// A nullable overlay of [MTextFieldStyle] fields.
///
/// Pass an instance into `MTextField(style: ...)` to override individual
/// fields of the theme-resolved style. Any field left null keeps the theme
/// value.
@immutable
class MTextFieldStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MTextFieldStyleDelta({
    this.minHeight,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth,
    this.radius,
    this.textStyle,
    this.placeholderColor,
    this.cursorColor,
    this.selectionColor,
    this.iconColor,
    this.decorationGap,
    this.disabledOpacity,
  });

  /// Override for [MTextFieldStyle.minHeight].
  final double? minHeight;

  /// Override for [MTextFieldStyle.padding].
  final EdgeInsets? padding;

  /// Override for [MTextFieldStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MTextFieldStyle.borderColor].
  final Color? borderColor;

  /// Override for [MTextFieldStyle.focusedBorderColor].
  final Color? focusedBorderColor;

  /// Override for [MTextFieldStyle.errorBorderColor].
  final Color? errorBorderColor;

  /// Override for [MTextFieldStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MTextFieldStyle.radius].
  final BorderRadius? radius;

  /// Override for [MTextFieldStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MTextFieldStyle.placeholderColor].
  final Color? placeholderColor;

  /// Override for [MTextFieldStyle.cursorColor].
  final Color? cursorColor;

  /// Override for [MTextFieldStyle.selectionColor].
  final Color? selectionColor;

  /// Override for [MTextFieldStyle.iconColor].
  final Color? iconColor;

  /// Override for [MTextFieldStyle.decorationGap].
  final double? decorationGap;

  /// Override for [MTextFieldStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MTextFieldStyleDelta &&
        other.minHeight == minHeight &&
        other.padding == padding &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.focusedBorderColor == focusedBorderColor &&
        other.errorBorderColor == errorBorderColor &&
        other.borderWidth == borderWidth &&
        other.radius == radius &&
        other.textStyle == textStyle &&
        other.placeholderColor == placeholderColor &&
        other.cursorColor == cursorColor &&
        other.selectionColor == selectionColor &&
        other.iconColor == iconColor &&
        other.decorationGap == decorationGap &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        minHeight,
        padding,
        backgroundColor,
        borderColor,
        focusedBorderColor,
        errorBorderColor,
        borderWidth,
        radius,
        textStyle,
        placeholderColor,
        cursorColor,
        selectionColor,
        iconColor,
        decorationGap,
        disabledOpacity,
      ]);
}
