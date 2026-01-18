import 'package:flutter/widgets.dart';

import '../foundation/input_modality.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';

/// Which theme an [MWidgetsApp] should use.
///
/// Mirrors Flutter's Material `ThemeMode`. Defined locally because the core
/// does not depend on `package:flutter/material.dart`.
enum MThemeMode {
  /// Follow `MediaQuery.platformBrightnessOf(context)`.
  system,

  /// Always use the light theme.
  light,

  /// Always use the dark theme.
  dark,
}

/// The root app widget for a manyui application.
///
/// Wraps Flutter's [WidgetsApp] (not `MaterialApp` or `CupertinoApp`) and
/// adds [MTheme], [MInputModalityScope], and a [DefaultTextStyle] from the
/// theme's `body` slot.
class MWidgetsApp extends StatelessWidget {
  /// Builds a manyui root app driving an imperative [Navigator] (Navigator 1.0).
  const MWidgetsApp({
    super.key,
    this.home,
    this.theme,
    this.darkTheme,
    this.themeMode = MThemeMode.system,
    this.title = '',
    this.color = const Color(0xFF000000),
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.locale,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.localizationsDelegates,
    this.shortcuts,
    this.actions,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
  })  : _usesRouter = false,
        routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null,
        routerConfig = null;

  /// Builds a manyui root app driving a [Router] (Navigator 2.0).
  ///
  /// Like `MaterialApp.router`: attach a router via a single [routerConfig]
  /// (go_router's `GoRouter` is a `RouterConfig<Object>`) or via the
  /// [routeInformationParser] + [routerDelegate] pair (plus optional
  /// [routeInformationProvider] / [backButtonDispatcher]).
  ///
  /// The imperative [Navigator] fields ([home], [routes], etc.) don't apply
  /// here. The theme wrapper sits above the [Router], so routed subtrees still
  /// resolve [MTheme.of].
  const MWidgetsApp.router({
    super.key,
    this.theme,
    this.darkTheme,
    this.themeMode = MThemeMode.system,
    this.title = '',
    this.color = const Color(0xFF000000),
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.backButtonDispatcher,
    this.routerConfig,
    this.builder,
    this.locale,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.localizationsDelegates,
    this.shortcuts,
    this.actions,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
  })  : assert(
          routerDelegate != null || routerConfig != null,
          'Either one of routerDelegate or routerConfig must be provided.',
        ),
        assert(
          !(routerConfig != null &&
              (routeInformationProvider != null ||
                  routeInformationParser != null ||
                  routerDelegate != null ||
                  backButtonDispatcher != null)),
          'If routerConfig is provided, none of the other router delegates may '
          'be provided.',
        ),
        assert(
          routeInformationProvider == null || routeInformationParser != null,
          'If routeInformationProvider is provided, routeInformationParser must '
          'also be provided.',
        ),
        _usesRouter = true,
        home = null,
        routes = const <String, WidgetBuilder>{},
        initialRoute = null,
        onGenerateRoute = null,
        onUnknownRoute = null,
        navigatorKey = null,
        navigatorObservers = const <NavigatorObserver>[];

  /// The widget shown at the default route.
  final Widget? home;

  /// The light theme. If null, falls back to `MThemeData.light()`.
  final MThemeData? theme;

  /// The dark theme. If null, falls back to `MThemeData.dark()`.
  final MThemeData? darkTheme;

  /// Which of [theme] / [darkTheme] to use.
  ///
  /// Defaults to [MThemeMode.system], which reads
  /// `MediaQuery.platformBrightnessOf(context)`.
  final MThemeMode themeMode;

  /// The app's title for OS-level task switchers.
  final String title;

  /// The primary color shown by the OS in task switcher tiles, etc.
  final Color color;

  /// Static named routes for [Navigator].
  final Map<String, WidgetBuilder> routes;

  /// The initial route name to push.
  final String? initialRoute;

  /// Callback for dynamically generating routes.
  final RouteFactory? onGenerateRoute;

  /// Callback for routes [onGenerateRoute] does not handle.
  final RouteFactory? onUnknownRoute;

  /// A key for the underlying [Navigator].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Observers to attach to the [Navigator].
  final List<NavigatorObserver> navigatorObservers;

  /// Route information provider for the [Router] (`.router` only).
  final RouteInformationProvider? routeInformationProvider;

  /// Route information parser for the [Router] (`.router` only).
  final RouteInformationParser<Object>? routeInformationParser;

  /// Router delegate for the [Router] (`.router` only).
  final RouterDelegate<Object>? routerDelegate;

  /// Back button dispatcher for the [Router] (`.router` only).
  ///
  /// When null, [WidgetsApp.router] supplies a [RootBackButtonDispatcher], as
  /// `MaterialApp.router` does.
  final BackButtonDispatcher? backButtonDispatcher;

  /// Single-object router config (`.router` only). go_router's `GoRouter`
  /// attaches here.
  final RouterConfig<Object>? routerConfig;

  /// Whether this app drives a [Router] (Navigator 2.0) rather than an
  /// imperative [Navigator]. Set by [MWidgetsApp.router].
  final bool _usesRouter;

  /// Wraps every page in additional widgets (e.g. a `MScaffold`).
  final TransitionBuilder? builder;

  /// The locale to use, overriding system locale resolution.
  final Locale? locale;

  /// The locales this app supports.
  final List<Locale> supportedLocales;

  /// Localizations delegates installed for descendants. The Flutter
  /// `WidgetsLocalizations` delegate is always installed even when this is
  /// null.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// App-wide keyboard shortcuts.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// App-wide intent → action bindings.
  final Map<Type, Action<Intent>>? actions;

  /// Show the semantics debugger overlay.
  final bool showSemanticsDebugger;

  /// Show the debug banner in checked-mode builds.
  final bool debugShowCheckedModeBanner;

  MThemeData _resolveTheme(BuildContext context) {
    final MThemeData light = theme ?? MThemeData.light();
    final MThemeData dark = darkTheme ?? MThemeData.dark();
    switch (themeMode) {
      case MThemeMode.light:
        return light;
      case MThemeMode.dark:
        return dark;
      case MThemeMode.system:
        final Brightness brightness = MediaQuery.platformBrightnessOf(context);
        return brightness == Brightness.dark ? dark : light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData resolved = _resolveTheme(context);
    final TextStyle textStyle = resolved.typography
        .inheritFromContext(context)
        .body
        .copyWith(color: resolved.colors.foreground);
    return MTheme(
      data: resolved,
      child: MInputModalityScope(
        modality: MInputModality.defaultForPlatform(resolved.platform),
        child: _usesRouter
            ? WidgetsApp.router(
                routeInformationProvider: routeInformationProvider,
                routeInformationParser: routeInformationParser,
                routerDelegate: routerDelegate,
                backButtonDispatcher: backButtonDispatcher,
                routerConfig: routerConfig,
                builder: builder,
                title: title,
                color: color,
                textStyle: textStyle,
                locale: locale,
                supportedLocales: supportedLocales,
                localizationsDelegates: localizationsDelegates,
                shortcuts: shortcuts,
                actions: actions,
                showSemanticsDebugger: showSemanticsDebugger,
                debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              )
            : WidgetsApp(
                key: null,
                home: home,
                routes: routes,
                initialRoute: initialRoute,
                onGenerateRoute: onGenerateRoute,
                onUnknownRoute: onUnknownRoute,
                navigatorKey: navigatorKey,
                navigatorObservers: navigatorObservers,
                pageRouteBuilder:
                    <T>(RouteSettings settings, WidgetBuilder builder) =>
                        PageRouteBuilder<T>(
                  settings: settings,
                  pageBuilder: (BuildContext context, _, __) => builder(context),
                ),
                builder: builder,
                title: title,
                color: color,
                textStyle: textStyle,
                locale: locale,
                supportedLocales: supportedLocales,
                localizationsDelegates: localizationsDelegates,
                shortcuts: shortcuts,
                actions: actions,
                showSemanticsDebugger: showSemanticsDebugger,
                debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              ),
      ),
    );
  }
}
