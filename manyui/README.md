# manyui

The core widget and theme package for [manyui](https://github.com/sneurlax/manyui).

This is the only package most users import:

```yaml
dependencies:
  manyui: ^0.1.0
```

```dart
import 'package:manyui/manyui.dart';
```

See the [workspace README](../README.md) for the project pitch, design principles, and quickstart.

## Router-based routing (`MWidgetsApp.router`)

`MWidgetsApp` ships both an imperative (Navigator 1.0) constructor and a
`Router`-based (Navigator 2.0) one, like `MaterialApp` / `CupertinoApp`. Use
`MWidgetsApp.router` to drive any `RouterConfig`, such as a
[`go_router`](https://pub.dev/packages/go_router) `GoRouter` (which is a
`RouterConfig<Object>`):

```dart
MWidgetsApp.router(
  routerConfig: buildRouter(), // returns a GoRouter
  title: 'Survey',
  theme: buildManyTheme(Brightness.light),
  darkTheme: buildManyTheme(Brightness.dark),
  themeMode: MThemeMode.dark,
  // no `home` / `routes` / `onGenerateRoute` on this path
);
```

The `MTheme`, input-modality scope, and themed `DefaultTextStyle` wrap above
the `Router`, so every routed page resolves `MTheme.of(context)` and deep-link
query parameters (`state.uri.queryParameters[...]`) reach their routes.

The `.router` constructor takes either a single `routerConfig` or the
`routeInformationParser` + `routerDelegate` pair (plus optional
`routeInformationProvider` / `backButtonDispatcher`). Don't mix the two, or
combine them with the imperative `home` / `routes` fields.
