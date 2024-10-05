import 'package:flutter/widgets.dart';

/// Named text-style slots for manyui widgets.
///
/// `fontFamily` is unset by default; the ambient `DefaultTextStyle` (from
/// `MWidgetsApp`) supplies it. Override slots via [copyWith] or install a
/// custom family by wrapping the tree in a `DefaultTextStyle`.
/// Sizes follow shadcn/Tailwind's type scale.
@immutable
class MTypography {
  /// Builds a typography set from explicit text styles.
  const MTypography({
    required this.displayLarge,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineSmall,
    required this.title,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.caption,
    required this.code,
  });

  /// The default typography for both light and dark mode.
  ///
  /// No font family is set — the surrounding `DefaultTextStyle` wins.
  const MTypography.standard()
      : displayLarge = const TextStyle(
          fontSize: 48,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displaySmall = const TextStyle(
          fontSize: 36,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineLarge = const TextStyle(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall = const TextStyle(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        title = const TextStyle(
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
        body = const TextStyle(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w400,
        ),
        bodySmall = const TextStyle(
          fontSize: 13,
          height: 1.45,
          fontWeight: FontWeight.w400,
        ),
        label = const TextStyle(
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w500,
        ),
        caption = const TextStyle(
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w400,
        ),
        code = const TextStyle(
          fontSize: 13,
          height: 1.45,
          fontFamily: 'monospace',
          fontFamilyFallback: <String>['ui-monospace', 'Menlo', 'Consolas'],
          fontWeight: FontWeight.w400,
        );

  /// Display-sized text (largest), used for marketing headers.
  final TextStyle displayLarge;

  /// Display-sized text (small), for page-level headers.
  final TextStyle displaySmall;

  /// Headline text (large), for section headers.
  final TextStyle headlineLarge;

  /// Headline text (small), for subsection headers.
  final TextStyle headlineSmall;

  /// Title text, for card titles and dialog headers.
  final TextStyle title;

  /// The default body text style for paragraphs.
  final TextStyle body;

  /// A smaller body style for dense layouts.
  final TextStyle bodySmall;

  /// Label text used by form fields and buttons.
  final TextStyle label;

  /// Caption text used for helper/secondary content.
  final TextStyle caption;

  /// Monospaced text for inline code and keyboard hints.
  final TextStyle code;

  /// Returns a copy with specific slots overridden.
  MTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineSmall,
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? code,
  }) {
    return MTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      title: title ?? this.title,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      code: code ?? this.code,
    );
  }

  /// Returns a copy with every slot merged on top of the ambient
  /// `DefaultTextStyle`, propagating the system font family into all slots.
  MTypography inheritFromContext(BuildContext context) {
    final TextStyle base = DefaultTextStyle.of(context).style;
    return MTypography(
      displayLarge: base.merge(displayLarge),
      displaySmall: base.merge(displaySmall),
      headlineLarge: base.merge(headlineLarge),
      headlineSmall: base.merge(headlineSmall),
      title: base.merge(title),
      body: base.merge(body),
      bodySmall: base.merge(bodySmall),
      label: base.merge(label),
      caption: base.merge(caption),
      code: base.merge(code),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MTypography &&
        other.displayLarge == displayLarge &&
        other.displaySmall == displaySmall &&
        other.headlineLarge == headlineLarge &&
        other.headlineSmall == headlineSmall &&
        other.title == title &&
        other.body == body &&
        other.bodySmall == bodySmall &&
        other.label == label &&
        other.caption == caption &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(
        displayLarge,
        displaySmall,
        headlineLarge,
        headlineSmall,
        title,
        body,
        bodySmall,
        label,
        caption,
        code,
      );
}
