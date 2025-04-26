import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/color_scheme.dart';
import '../../theme/typography.dart';
import 'accordion_style.dart';

/// The resolution table for [MAccordion].
///
/// Lives on `MThemeData.accordion`. Touch modality bumps the header to a
/// taller hit target.
///
/// ```dart
/// final MAccordionStyle style = theme.accordion.resolve(
///   modality: MInputModality.mouse,
///   colors: theme.colors,
///   typography: theme.typography,
///   radius: theme.radius,
/// );
/// ```
@immutable
class MAccordionStyles {
  /// Builds a styles table.
  const MAccordionStyles();

  /// Returns the resolved [MAccordionStyle] under [modality] and the supplied
  /// theme tokens.
  MAccordionStyle resolve({
    required MInputModality modality,
    required MColorScheme colors,
    required MTypography typography,
    required double radius,
  }) {
    final bool touch = modality == MInputModality.touch;

    return MAccordionStyle(
      surfaceBackgroundColor: colors.background,
      surfaceBorderColor: colors.border,
      surfaceBorderWidth: 1,
      surfaceRadius: BorderRadius.all(Radius.circular(radius)),
      itemDividerColor: colors.border,
      itemDividerThickness: 1,
      headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      headerHeight: touch ? 56 : 44,
      headerForegroundColor: colors.foreground,
      headerTitleTextStyle: typography.label.copyWith(color: colors.foreground),
      headerHoveredBackgroundColor: colors.accent,
      chevronColor: colors.mutedForeground,
      chevronSize: 16,
      bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      bodyForegroundColor: colors.foreground,
      bodyTextStyle: typography.body.copyWith(color: colors.foreground),
      expandDuration: const Duration(milliseconds: 200),
      disabledOpacity: 0.5,
    );
  }

  @override
  bool operator ==(Object other) => other is MAccordionStyles;

  @override
  int get hashCode => (MAccordionStyles).hashCode;
}
