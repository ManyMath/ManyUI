import 'package:flutter/widgets.dart';

import 'theme_data.dart';

/// [InheritedWidget] carrier for [MThemeData].
///
/// Falls back to `MThemeData.light()` when no ancestor is installed.
class MTheme extends InheritedWidget {
  /// Installs [data] for all descendants.
  const MTheme({required this.data, required super.child, super.key});

  /// The theme this widget exposes to descendants.
  final MThemeData data;

  /// Returns the nearest [MThemeData], falling back to `MThemeData.light()`.
  static MThemeData of(BuildContext context) {
    final MTheme? inherited =
        context.dependOnInheritedWidgetOfExactType<MTheme>();
    return inherited?.data ?? MThemeData.light();
  }

  /// Returns the nearest [MThemeData], or `null` if no ancestor exists.
  static MThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MTheme>()?.data;
  }

  @override
  bool updateShouldNotify(MTheme oldWidget) => data != oldWidget.data;
}

/// Convenience accessors on `BuildContext` for the ambient [MThemeData].
extension MThemeBuildContext on BuildContext {
  /// Shorthand for `MTheme.of(this)`.
  MThemeData get mTheme => MTheme.of(this);
}
