import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'avatar_style.dart';

/// A small profile-shaped surface for a user image with a text fallback.
///
/// `MAvatar` is non-interactive. When [image] resolves successfully the
/// avatar renders it; when [image] is null or the load fails, the avatar
/// renders [fallback] (typically a `Text` with initials) on a theme-muted
/// background.
///
/// ```dart
/// MAvatar(
///   image: NetworkImage('https://...'),
///   fallback: Text('JD'),
///   size: 40,
/// )
/// ```
class MAvatar extends StatelessWidget {
  /// Builds an avatar.
  const MAvatar({
    this.image,
    this.fallback,
    this.size = 40,
    this.shape = MAvatarShape.circle,
    this.style,
    this.semanticLabel,
    super.key,
  });

  /// The image to display. When null, [fallback] is rendered directly. When
  /// loading fails, the avatar falls back to [fallback].
  final ImageProvider<Object>? image;

  /// Content rendered when [image] is null or fails to load. Usually a
  /// short `Text` with the user's initials.
  final Widget? fallback;

  /// The avatar's diameter (or side length when [shape] is square).
  final double size;

  /// The avatar shape. Defaults to [MAvatarShape.circle].
  final MAvatarShape shape;

  /// Field-wise overrides for the theme-resolved [MAvatarStyle].
  final MAvatarStyleDelta? style;

  /// An optional accessibility label.
  ///
  /// Set this when the avatar represents a specific user — screen readers
  /// otherwise have no way to announce who the avatar is for. The fallback
  /// `Text` is semantically excluded so the label here is authoritative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MAvatarStyle resolved = theme.avatar
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(style);

    final BorderRadiusGeometry borderRadius = shape == MAvatarShape.circle
        ? BorderRadius.circular(size / 2)
        : resolved.squareRadius;

    final Widget fallbackContent = DefaultTextStyle.merge(
      style:
          resolved.textStyle.copyWith(color: resolved.foregroundColor),
      textAlign: TextAlign.center,
      child: IconTheme.merge(
        data: IconThemeData(color: resolved.foregroundColor),
        child: Center(
          // The fallback is always semantically excluded — if the caller
          // wants the avatar announced, semanticLabel carries the label.
          child: ExcludeSemantics(
            child: fallback ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );

    final Widget content = image == null
        ? fallbackContent
        : Image(
            image: image!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
                fallbackContent,
            // Excluded from semantics — semanticLabel below is the source
            // of truth for screen readers.
            excludeFromSemantics: true,
          );

    final Widget surface = ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: resolved.backgroundColor,
            borderRadius: borderRadius,
            border: resolved.borderColor != null
                ? Border.all(
                    color: resolved.borderColor!,
                    width: resolved.borderWidth,
                  )
                : null,
          ),
          child: content,
        ),
      ),
    );

    return Semantics(
      label: semanticLabel,
      image: image != null,
      container: true,
      child: surface,
    );
  }
}
