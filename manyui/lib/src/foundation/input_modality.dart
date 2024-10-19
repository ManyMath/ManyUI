import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The input mode driving an interactive widget.
///
/// Affects hit-target sizes, hover behavior, and keyboard shortcut hints.
/// Resolution order: explicit `modality` param -> nearest
/// [MInputModalityScope] ancestor -> [MInputModality.defaultForPlatform].
enum MInputModality {
  /// Finger on a touchscreen -- large hit targets, no hover.
  touch,

  /// Mouse or trackpad -- fine hit targets, hover effects.
  mouse,

  /// Physical keyboard navigation -- focus rings, shortcut hints, no hover.
  keyboard,

  /// Pen or stylus -- like [mouse] with finer targeting.
  stylus;

  /// Platform-derived default: iOS/Android -> touch, desktop -> mouse.
  static MInputModality defaultForPlatform(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return MInputModality.touch;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return MInputModality.mouse;
    }
  }
}

/// Installs a fixed [MInputModality] for a subtree.
class MInputModalityScope extends InheritedWidget {
  /// Wraps [child] in a scope that exposes [modality] to descendants.
  const MInputModalityScope({
    required this.modality,
    required super.child,
    super.key,
  });

  /// The modality exposed to descendants.
  final MInputModality modality;

  /// Returns the nearest [MInputModality] above [context], or the platform
  /// default. For the full explicit -> scope -> platform chain, use [resolve].
  static MInputModality of(BuildContext context) {
    final MInputModalityScope? scope =
        context.dependOnInheritedWidgetOfExactType<MInputModalityScope>();
    return scope?.modality ??
        MInputModality.defaultForPlatform(defaultTargetPlatform);
  }

  /// Resolves the modality: explicit param -> ancestor scope -> platform default.
  static MInputModality resolve(
    BuildContext context,
    MInputModality? explicit,
  ) {
    if (explicit != null) return explicit;
    return of(context);
  }

  @override
  bool updateShouldNotify(MInputModalityScope oldWidget) =>
      modality != oldWidget.modality;
}
