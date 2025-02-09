import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MOTPField].
///
/// Carries the per-cell surface (background, border, radius), the text
/// appearance (cursor, text style), and the row layout (cell size, gap
/// between cells). Build by hand for advanced theming, or let the theme
/// resolve one via `theme.otpField.resolve(...)` and tweak through an
/// [MOTPFieldStyleDelta].
@immutable
class MOTPFieldStyle {
  /// Builds an OTP-field style with every field specified.
  const MOTPFieldStyle({
    required this.cellSize,
    required this.cellGap,
    required this.cellPadding,
    required this.cellBackgroundColor,
    required this.cellBorderColor,
    required this.cellFocusedBorderColor,
    required this.cellFilledBorderColor,
    required this.cellErrorBorderColor,
    required this.cellBorderWidth,
    required this.cellRadius,
    required this.textStyle,
    required this.cursorColor,
    required this.selectionColor,
    required this.disabledOpacity,
  });

  /// Side length of each cell, in logical pixels. Cells are square. Touch
  /// modality resolves to a larger size than mouse modality.
  final double cellSize;

  /// Horizontal gap between adjacent cells, in logical pixels.
  final double cellGap;

  /// Inner padding of each cell. Centers the single glyph inside the cell
  /// surface.
  final EdgeInsets cellPadding;

  /// Background fill of each cell.
  final Color cellBackgroundColor;

  /// Border color of an empty, unfocused cell.
  final Color cellBorderColor;

  /// Border color of the currently-focused cell (overrides
  /// [cellFilledBorderColor]).
  final Color cellFocusedBorderColor;

  /// Border color of a cell that holds a character and is not currently
  /// focused.
  final Color cellFilledBorderColor;

  /// Border color used for every cell when the field is in an error state,
  /// regardless of focus.
  final Color cellErrorBorderColor;

  /// Border thickness, in logical pixels. The same thickness is used for
  /// all states; only the color changes.
  final double cellBorderWidth;

  /// Corner radius of each cell's surface.
  final BorderRadius cellRadius;

  /// Text style applied to the single glyph inside each cell.
  final TextStyle textStyle;

  /// Color of the blinking text-input cursor inside the focused cell.
  final Color cursorColor;

  /// Color of the highlighted selection inside a cell — mostly invisible at
  /// the single-character cell size, but EditableText still draws one when
  /// the cell content is selected programmatically.
  final Color selectionColor;

  /// Opacity multiplier applied when the field is disabled.
  final double disabledOpacity;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MOTPFieldStyle applyDelta(MOTPFieldStyleDelta? delta) {
    if (delta == null) return this;
    return MOTPFieldStyle(
      cellSize: delta.cellSize ?? cellSize,
      cellGap: delta.cellGap ?? cellGap,
      cellPadding: delta.cellPadding ?? cellPadding,
      cellBackgroundColor: delta.cellBackgroundColor ?? cellBackgroundColor,
      cellBorderColor: delta.cellBorderColor ?? cellBorderColor,
      cellFocusedBorderColor:
          delta.cellFocusedBorderColor ?? cellFocusedBorderColor,
      cellFilledBorderColor:
          delta.cellFilledBorderColor ?? cellFilledBorderColor,
      cellErrorBorderColor: delta.cellErrorBorderColor ?? cellErrorBorderColor,
      cellBorderWidth: delta.cellBorderWidth ?? cellBorderWidth,
      cellRadius: delta.cellRadius ?? cellRadius,
      textStyle: delta.textStyle ?? textStyle,
      cursorColor: delta.cursorColor ?? cursorColor,
      selectionColor: delta.selectionColor ?? selectionColor,
      disabledOpacity: delta.disabledOpacity ?? disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MOTPFieldStyle &&
        other.cellSize == cellSize &&
        other.cellGap == cellGap &&
        other.cellPadding == cellPadding &&
        other.cellBackgroundColor == cellBackgroundColor &&
        other.cellBorderColor == cellBorderColor &&
        other.cellFocusedBorderColor == cellFocusedBorderColor &&
        other.cellFilledBorderColor == cellFilledBorderColor &&
        other.cellErrorBorderColor == cellErrorBorderColor &&
        other.cellBorderWidth == cellBorderWidth &&
        other.cellRadius == cellRadius &&
        other.textStyle == textStyle &&
        other.cursorColor == cursorColor &&
        other.selectionColor == selectionColor &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        cellSize,
        cellGap,
        cellPadding,
        cellBackgroundColor,
        cellBorderColor,
        cellFocusedBorderColor,
        cellFilledBorderColor,
        cellErrorBorderColor,
        cellBorderWidth,
        cellRadius,
        textStyle,
        cursorColor,
        selectionColor,
        disabledOpacity,
      ]);
}

/// A nullable overlay of [MOTPFieldStyle] fields.
///
/// Pass an instance into `MOTPField(style: ...)` to override individual
/// fields of the theme-resolved style. Any field left null keeps the theme
/// value.
@immutable
class MOTPFieldStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MOTPFieldStyleDelta({
    this.cellSize,
    this.cellGap,
    this.cellPadding,
    this.cellBackgroundColor,
    this.cellBorderColor,
    this.cellFocusedBorderColor,
    this.cellFilledBorderColor,
    this.cellErrorBorderColor,
    this.cellBorderWidth,
    this.cellRadius,
    this.textStyle,
    this.cursorColor,
    this.selectionColor,
    this.disabledOpacity,
  });

  /// Override for [MOTPFieldStyle.cellSize].
  final double? cellSize;

  /// Override for [MOTPFieldStyle.cellGap].
  final double? cellGap;

  /// Override for [MOTPFieldStyle.cellPadding].
  final EdgeInsets? cellPadding;

  /// Override for [MOTPFieldStyle.cellBackgroundColor].
  final Color? cellBackgroundColor;

  /// Override for [MOTPFieldStyle.cellBorderColor].
  final Color? cellBorderColor;

  /// Override for [MOTPFieldStyle.cellFocusedBorderColor].
  final Color? cellFocusedBorderColor;

  /// Override for [MOTPFieldStyle.cellFilledBorderColor].
  final Color? cellFilledBorderColor;

  /// Override for [MOTPFieldStyle.cellErrorBorderColor].
  final Color? cellErrorBorderColor;

  /// Override for [MOTPFieldStyle.cellBorderWidth].
  final double? cellBorderWidth;

  /// Override for [MOTPFieldStyle.cellRadius].
  final BorderRadius? cellRadius;

  /// Override for [MOTPFieldStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MOTPFieldStyle.cursorColor].
  final Color? cursorColor;

  /// Override for [MOTPFieldStyle.selectionColor].
  final Color? selectionColor;

  /// Override for [MOTPFieldStyle.disabledOpacity].
  final double? disabledOpacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MOTPFieldStyleDelta &&
        other.cellSize == cellSize &&
        other.cellGap == cellGap &&
        other.cellPadding == cellPadding &&
        other.cellBackgroundColor == cellBackgroundColor &&
        other.cellBorderColor == cellBorderColor &&
        other.cellFocusedBorderColor == cellFocusedBorderColor &&
        other.cellFilledBorderColor == cellFilledBorderColor &&
        other.cellErrorBorderColor == cellErrorBorderColor &&
        other.cellBorderWidth == cellBorderWidth &&
        other.cellRadius == cellRadius &&
        other.textStyle == textStyle &&
        other.cursorColor == cursorColor &&
        other.selectionColor == selectionColor &&
        other.disabledOpacity == disabledOpacity;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        cellSize,
        cellGap,
        cellPadding,
        cellBackgroundColor,
        cellBorderColor,
        cellFocusedBorderColor,
        cellFilledBorderColor,
        cellErrorBorderColor,
        cellBorderWidth,
        cellRadius,
        textStyle,
        cursorColor,
        selectionColor,
        disabledOpacity,
      ]);
}
