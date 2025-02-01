import 'package:flutter/widgets.dart';

/// The fully-resolved visual style for an [MDateField].
///
/// Carries the anchor (input surface) and the popover calendar in a single
/// flat data class — mirroring [MSelectStyle]'s split-but-flat layout so a
/// caller-supplied delta can override just the anchor's border or just the
/// calendar's row size without re-supplying the whole table.
@immutable
class MDateFieldStyle {
  /// Builds a date-field style with every field specified.
  const MDateFieldStyle({
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
    required this.popoverBackgroundColor,
    required this.popoverBorderColor,
    required this.popoverBorderWidth,
    required this.popoverRadius,
    required this.popoverElevation,
    required this.popoverShadowColor,
    required this.popoverPadding,
    required this.popoverGap,
    required this.popoverHeaderTextStyle,
    required this.popoverHeaderForegroundColor,
    required this.popoverWeekdayTextStyle,
    required this.popoverWeekdayColor,
    required this.cellSize,
    required this.cellTextStyle,
    required this.cellForegroundColor,
    required this.cellMutedForegroundColor,
    required this.cellFocusedBackgroundColor,
    required this.cellSelectedBackgroundColor,
    required this.cellSelectedForegroundColor,
    required this.cellRadius,
  });

  // ────────── anchor ──────────

  /// Minimum height of the anchor (text-input) surface, in logical pixels.
  /// Touch modality resolves to a larger height than mouse modality.
  final double minHeight;

  /// Inner padding between the anchor border and the text/decorations.
  final EdgeInsets padding;

  /// Background fill of the anchor.
  final Color backgroundColor;

  /// Border color in the idle state (unfocused, no error).
  final Color borderColor;

  /// Border color when the anchor has keyboard focus and is not in an error
  /// state.
  final Color focusedBorderColor;

  /// Border color when the field is in an error state, regardless of focus.
  final Color errorBorderColor;

  /// Border thickness, in logical pixels.
  final double borderWidth;

  /// Corner radius of the anchor.
  final BorderRadius radius;

  /// Text style applied to the editable text and to the placeholder.
  final TextStyle textStyle;

  /// Color applied to the placeholder string when the field is empty.
  final Color placeholderColor;

  /// Color of the blinking text-input cursor.
  final Color cursorColor;

  /// Color of the highlighted text selection.
  final Color selectionColor;

  /// Color applied to the trailing calendar icon (and any leading/trailing
  /// caller-supplied decorations that don't install their own IconTheme).
  final Color iconColor;

  /// Horizontal gap between a decoration and the text, in logical pixels.
  final double decorationGap;

  /// Opacity multiplier applied when the field is disabled.
  final double disabledOpacity;

  // ────────── popover calendar ──────────

  /// Background fill of the calendar popover.
  final Color popoverBackgroundColor;

  /// Border color of the calendar popover.
  final Color popoverBorderColor;

  /// Border thickness of the calendar popover.
  final double popoverBorderWidth;

  /// Corner radius of the calendar popover.
  final BorderRadius popoverRadius;

  /// Shadow blur radius behind the popover. Zero disables the shadow.
  final double popoverElevation;

  /// Shadow color behind the popover.
  final Color popoverShadowColor;

  /// Inner padding inside the popover, between the border and the calendar
  /// grid.
  final EdgeInsets popoverPadding;

  /// Vertical gap, in logical pixels, between the bottom of the anchor and
  /// the top of the popover.
  final double popoverGap;

  /// Text style for the month-name title in the popover header.
  final TextStyle popoverHeaderTextStyle;

  /// Foreground color of the month-name title and the chevron buttons in
  /// the header.
  final Color popoverHeaderForegroundColor;

  /// Text style for the weekday-name row beneath the header.
  final TextStyle popoverWeekdayTextStyle;

  /// Color of the weekday-name row.
  final Color popoverWeekdayColor;

  /// Side length of one day cell, in logical pixels. Cells are square.
  final double cellSize;

  /// Text style for each day cell's number.
  final TextStyle cellTextStyle;

  /// Foreground color of in-month day cells.
  final Color cellForegroundColor;

  /// Foreground color of out-of-month "padding" day cells (the leading
  /// days of the previous month and the trailing days of the next month).
  final Color cellMutedForegroundColor;

  /// Background fill for the cell that currently has keyboard focus inside
  /// the popover.
  final Color cellFocusedBackgroundColor;

  /// Background fill for the cell that matches the current controller
  /// value.
  final Color cellSelectedBackgroundColor;

  /// Foreground color for the selected cell, layered on top of the
  /// selected background.
  final Color cellSelectedForegroundColor;

  /// Corner radius of each day cell.
  final BorderRadius cellRadius;

  /// Returns a copy with [delta]'s non-null fields overlaid on top of this
  /// style.
  MDateFieldStyle applyDelta(MDateFieldStyleDelta? delta) {
    if (delta == null) return this;
    return MDateFieldStyle(
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
      popoverBackgroundColor:
          delta.popoverBackgroundColor ?? popoverBackgroundColor,
      popoverBorderColor: delta.popoverBorderColor ?? popoverBorderColor,
      popoverBorderWidth: delta.popoverBorderWidth ?? popoverBorderWidth,
      popoverRadius: delta.popoverRadius ?? popoverRadius,
      popoverElevation: delta.popoverElevation ?? popoverElevation,
      popoverShadowColor: delta.popoverShadowColor ?? popoverShadowColor,
      popoverPadding: delta.popoverPadding ?? popoverPadding,
      popoverGap: delta.popoverGap ?? popoverGap,
      popoverHeaderTextStyle:
          delta.popoverHeaderTextStyle ?? popoverHeaderTextStyle,
      popoverHeaderForegroundColor:
          delta.popoverHeaderForegroundColor ?? popoverHeaderForegroundColor,
      popoverWeekdayTextStyle:
          delta.popoverWeekdayTextStyle ?? popoverWeekdayTextStyle,
      popoverWeekdayColor: delta.popoverWeekdayColor ?? popoverWeekdayColor,
      cellSize: delta.cellSize ?? cellSize,
      cellTextStyle: delta.cellTextStyle ?? cellTextStyle,
      cellForegroundColor: delta.cellForegroundColor ?? cellForegroundColor,
      cellMutedForegroundColor:
          delta.cellMutedForegroundColor ?? cellMutedForegroundColor,
      cellFocusedBackgroundColor:
          delta.cellFocusedBackgroundColor ?? cellFocusedBackgroundColor,
      cellSelectedBackgroundColor:
          delta.cellSelectedBackgroundColor ?? cellSelectedBackgroundColor,
      cellSelectedForegroundColor:
          delta.cellSelectedForegroundColor ?? cellSelectedForegroundColor,
      cellRadius: delta.cellRadius ?? cellRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MDateFieldStyle &&
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
        other.disabledOpacity == disabledOpacity &&
        other.popoverBackgroundColor == popoverBackgroundColor &&
        other.popoverBorderColor == popoverBorderColor &&
        other.popoverBorderWidth == popoverBorderWidth &&
        other.popoverRadius == popoverRadius &&
        other.popoverElevation == popoverElevation &&
        other.popoverShadowColor == popoverShadowColor &&
        other.popoverPadding == popoverPadding &&
        other.popoverGap == popoverGap &&
        other.popoverHeaderTextStyle == popoverHeaderTextStyle &&
        other.popoverHeaderForegroundColor == popoverHeaderForegroundColor &&
        other.popoverWeekdayTextStyle == popoverWeekdayTextStyle &&
        other.popoverWeekdayColor == popoverWeekdayColor &&
        other.cellSize == cellSize &&
        other.cellTextStyle == cellTextStyle &&
        other.cellForegroundColor == cellForegroundColor &&
        other.cellMutedForegroundColor == cellMutedForegroundColor &&
        other.cellFocusedBackgroundColor == cellFocusedBackgroundColor &&
        other.cellSelectedBackgroundColor == cellSelectedBackgroundColor &&
        other.cellSelectedForegroundColor == cellSelectedForegroundColor &&
        other.cellRadius == cellRadius;
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
        popoverBackgroundColor,
        popoverBorderColor,
        popoverBorderWidth,
        popoverRadius,
        popoverElevation,
        popoverShadowColor,
        popoverPadding,
        popoverGap,
        popoverHeaderTextStyle,
        popoverHeaderForegroundColor,
        popoverWeekdayTextStyle,
        popoverWeekdayColor,
        cellSize,
        cellTextStyle,
        cellForegroundColor,
        cellMutedForegroundColor,
        cellFocusedBackgroundColor,
        cellSelectedBackgroundColor,
        cellSelectedForegroundColor,
        cellRadius,
      ]);
}

/// A nullable overlay of [MDateFieldStyle] fields.
///
/// Pass an instance into `MDateField(style: ...)` to override individual
/// fields of the theme-resolved style.
@immutable
class MDateFieldStyleDelta {
  /// Builds a delta with the supplied field overrides.
  const MDateFieldStyleDelta({
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
    this.popoverBackgroundColor,
    this.popoverBorderColor,
    this.popoverBorderWidth,
    this.popoverRadius,
    this.popoverElevation,
    this.popoverShadowColor,
    this.popoverPadding,
    this.popoverGap,
    this.popoverHeaderTextStyle,
    this.popoverHeaderForegroundColor,
    this.popoverWeekdayTextStyle,
    this.popoverWeekdayColor,
    this.cellSize,
    this.cellTextStyle,
    this.cellForegroundColor,
    this.cellMutedForegroundColor,
    this.cellFocusedBackgroundColor,
    this.cellSelectedBackgroundColor,
    this.cellSelectedForegroundColor,
    this.cellRadius,
  });

  /// Override for [MDateFieldStyle.minHeight].
  final double? minHeight;

  /// Override for [MDateFieldStyle.padding].
  final EdgeInsets? padding;

  /// Override for [MDateFieldStyle.backgroundColor].
  final Color? backgroundColor;

  /// Override for [MDateFieldStyle.borderColor].
  final Color? borderColor;

  /// Override for [MDateFieldStyle.focusedBorderColor].
  final Color? focusedBorderColor;

  /// Override for [MDateFieldStyle.errorBorderColor].
  final Color? errorBorderColor;

  /// Override for [MDateFieldStyle.borderWidth].
  final double? borderWidth;

  /// Override for [MDateFieldStyle.radius].
  final BorderRadius? radius;

  /// Override for [MDateFieldStyle.textStyle].
  final TextStyle? textStyle;

  /// Override for [MDateFieldStyle.placeholderColor].
  final Color? placeholderColor;

  /// Override for [MDateFieldStyle.cursorColor].
  final Color? cursorColor;

  /// Override for [MDateFieldStyle.selectionColor].
  final Color? selectionColor;

  /// Override for [MDateFieldStyle.iconColor].
  final Color? iconColor;

  /// Override for [MDateFieldStyle.decorationGap].
  final double? decorationGap;

  /// Override for [MDateFieldStyle.disabledOpacity].
  final double? disabledOpacity;

  /// Override for [MDateFieldStyle.popoverBackgroundColor].
  final Color? popoverBackgroundColor;

  /// Override for [MDateFieldStyle.popoverBorderColor].
  final Color? popoverBorderColor;

  /// Override for [MDateFieldStyle.popoverBorderWidth].
  final double? popoverBorderWidth;

  /// Override for [MDateFieldStyle.popoverRadius].
  final BorderRadius? popoverRadius;

  /// Override for [MDateFieldStyle.popoverElevation].
  final double? popoverElevation;

  /// Override for [MDateFieldStyle.popoverShadowColor].
  final Color? popoverShadowColor;

  /// Override for [MDateFieldStyle.popoverPadding].
  final EdgeInsets? popoverPadding;

  /// Override for [MDateFieldStyle.popoverGap].
  final double? popoverGap;

  /// Override for [MDateFieldStyle.popoverHeaderTextStyle].
  final TextStyle? popoverHeaderTextStyle;

  /// Override for [MDateFieldStyle.popoverHeaderForegroundColor].
  final Color? popoverHeaderForegroundColor;

  /// Override for [MDateFieldStyle.popoverWeekdayTextStyle].
  final TextStyle? popoverWeekdayTextStyle;

  /// Override for [MDateFieldStyle.popoverWeekdayColor].
  final Color? popoverWeekdayColor;

  /// Override for [MDateFieldStyle.cellSize].
  final double? cellSize;

  /// Override for [MDateFieldStyle.cellTextStyle].
  final TextStyle? cellTextStyle;

  /// Override for [MDateFieldStyle.cellForegroundColor].
  final Color? cellForegroundColor;

  /// Override for [MDateFieldStyle.cellMutedForegroundColor].
  final Color? cellMutedForegroundColor;

  /// Override for [MDateFieldStyle.cellFocusedBackgroundColor].
  final Color? cellFocusedBackgroundColor;

  /// Override for [MDateFieldStyle.cellSelectedBackgroundColor].
  final Color? cellSelectedBackgroundColor;

  /// Override for [MDateFieldStyle.cellSelectedForegroundColor].
  final Color? cellSelectedForegroundColor;

  /// Override for [MDateFieldStyle.cellRadius].
  final BorderRadius? cellRadius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MDateFieldStyleDelta &&
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
        other.disabledOpacity == disabledOpacity &&
        other.popoverBackgroundColor == popoverBackgroundColor &&
        other.popoverBorderColor == popoverBorderColor &&
        other.popoverBorderWidth == popoverBorderWidth &&
        other.popoverRadius == popoverRadius &&
        other.popoverElevation == popoverElevation &&
        other.popoverShadowColor == popoverShadowColor &&
        other.popoverPadding == popoverPadding &&
        other.popoverGap == popoverGap &&
        other.popoverHeaderTextStyle == popoverHeaderTextStyle &&
        other.popoverHeaderForegroundColor == popoverHeaderForegroundColor &&
        other.popoverWeekdayTextStyle == popoverWeekdayTextStyle &&
        other.popoverWeekdayColor == popoverWeekdayColor &&
        other.cellSize == cellSize &&
        other.cellTextStyle == cellTextStyle &&
        other.cellForegroundColor == cellForegroundColor &&
        other.cellMutedForegroundColor == cellMutedForegroundColor &&
        other.cellFocusedBackgroundColor == cellFocusedBackgroundColor &&
        other.cellSelectedBackgroundColor == cellSelectedBackgroundColor &&
        other.cellSelectedForegroundColor == cellSelectedForegroundColor &&
        other.cellRadius == cellRadius;
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
        popoverBackgroundColor,
        popoverBorderColor,
        popoverBorderWidth,
        popoverRadius,
        popoverElevation,
        popoverShadowColor,
        popoverPadding,
        popoverGap,
        popoverHeaderTextStyle,
        popoverHeaderForegroundColor,
        popoverWeekdayTextStyle,
        popoverWeekdayColor,
        cellSize,
        cellTextStyle,
        cellForegroundColor,
        cellMutedForegroundColor,
        cellFocusedBackgroundColor,
        cellSelectedBackgroundColor,
        cellSelectedForegroundColor,
        cellRadius,
      ]);
}
