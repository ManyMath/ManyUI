import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';

void main() {
  group('MWidgetsApp', () {
    testWidgets('mounts without a MaterialApp or CupertinoApp ancestor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MWidgetsApp(
          home: Center(child: Text('home')),
        ),
      );
      expect(find.text('home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('installs MTheme so descendants see MThemeData',
        (WidgetTester tester) async {
      late MThemeData seen;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              seen = MTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.colors.background, const MColorScheme.light().background);
    });

    testWidgets('installs MInputModalityScope with a platform-derived default',
        (WidgetTester tester) async {
      late MInputModality seen;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (BuildContext context) {
              seen = MInputModalityScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // iOS → touch.
      expect(seen, MInputModality.touch);
    });

    testWidgets('themeMode.light forces the light theme', (tester) async {
      late MThemeData seen;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(),
          darkTheme: MThemeData.dark(),
          themeMode: MThemeMode.light,
          home: Builder(
            builder: (BuildContext context) {
              seen = MTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.colors.background, const MColorScheme.light().background);
    });

    testWidgets('themeMode.dark forces the dark theme', (tester) async {
      late MThemeData seen;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(),
          darkTheme: MThemeData.dark(),
          themeMode: MThemeMode.dark,
          home: Builder(
            builder: (BuildContext context) {
              seen = MTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.colors.background, const MColorScheme.dark().background);
    });

    testWidgets('themeMode.system tracks platformBrightness', (tester) async {
      late MThemeData seen;
      Widget app() => MediaQuery(
            data: const MediaQueryData(platformBrightness: Brightness.dark),
            child: MWidgetsApp(
              theme: MThemeData.light(),
              darkTheme: MThemeData.dark(),
              builder: (BuildContext context, Widget? child) {
                seen = MTheme.of(context);
                return child ?? const SizedBox.shrink();
              },
              home: const SizedBox.shrink(),
            ),
          );
      await tester.pumpWidget(app());
      expect(seen.colors.background, const MColorScheme.dark().background);
    });

    testWidgets('DefaultTextStyle inherits the theme body typography',
        (tester) async {
      TextStyle? captured;
      await tester.pumpWidget(
        MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              captured = DefaultTextStyle.of(context).style;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // body slot fontSize is 14 per MTypography.standard.
      expect(captured!.fontSize, 14);
      expect(captured!.color, const MColorScheme.light().foreground);
    });

    testWidgets(
        'does not depend on Material — the Material widget is absent in-tree',
        (tester) async {
      await tester.pumpWidget(
        const MWidgetsApp(home: Center(child: Text('home'))),
      );
      // package:flutter/material.dart's Material widget would be in the tree
      // if MaterialApp were used. We can't import it here without dragging it
      // in, but we can confirm the runtimeType chain doesn't include
      // 'Material' or 'CupertinoApp' as ancestors.
      bool foundMaterial = false;
      bool foundCupertinoApp = false;
      for (final Widget w in tester.allWidgets) {
        final String name = w.runtimeType.toString();
        if (name == 'Material' || name == 'MaterialApp') foundMaterial = true;
        if (name == 'CupertinoApp') foundCupertinoApp = true;
      }
      expect(foundMaterial, isFalse);
      expect(foundCupertinoApp, isFalse);
    });
  });

  group('MWidgetsApp.router', () {
    testWidgets('routes a page that resolves MThemeData (light)',
        (tester) async {
      late MThemeData seen;
      await tester.pumpWidget(
        MWidgetsApp.router(
          theme: MThemeData.light(),
          darkTheme: MThemeData.dark(),
          themeMode: MThemeMode.light,
          routerConfig: _RouterConfigStub(
            (BuildContext context) {
              seen = MTheme.of(context);
              return const Text('routed');
            },
          ),
        ),
      );
      expect(find.text('routed'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(seen.colors.background, const MColorScheme.light().background);
    });

    testWidgets('routes a page that resolves MThemeData (dark)',
        (tester) async {
      late MThemeData seen;
      await tester.pumpWidget(
        MWidgetsApp.router(
          theme: MThemeData.light(),
          darkTheme: MThemeData.dark(),
          themeMode: MThemeMode.dark,
          routerConfig: _RouterConfigStub(
            (BuildContext context) {
              seen = MTheme.of(context);
              return const Text('routed');
            },
          ),
        ),
      );
      expect(find.text('routed'), findsOneWidget);
      expect(seen.colors.background, const MColorScheme.dark().background);
    });

    test('asserts when neither routerConfig nor routerDelegate is given', () {
      expect(
        () => MWidgetsApp.router(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts when routerConfig and routerDelegate are both given', () {
      expect(
        () => MWidgetsApp.router(
          routerConfig: _RouterConfigStub((_) => const SizedBox.shrink()),
          routerDelegate: _RouterConfigStub((_) => const SizedBox.shrink())
              .routerDelegate,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

/// A trivial [RouterConfig] showing a single page from [builder], enough to
/// exercise [MWidgetsApp.router] without pulling in go_router.
class _RouterConfigStub implements RouterConfig<Object> {
  _RouterConfigStub(this._builder);

  final WidgetBuilder _builder;

  @override
  RouteInformationProvider? get routeInformationProvider => null;

  @override
  RouteInformationParser<Object>? get routeInformationParser => null;

  @override
  BackButtonDispatcher? get backButtonDispatcher => null;

  @override
  RouterDelegate<Object> get routerDelegate => _StubRouterDelegate(_builder);
}

class _StubRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _StubRouterDelegate(this._builder);

  final WidgetBuilder _builder;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: <Page<dynamic>>[
        _StubPage(_builder),
      ],
      onDidRemovePage: (Page<Object?> page) {},
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

/// A widgets-only [Page] (no Material/Cupertino) so the router tests keep the
/// "no Material in tree" invariant.
class _StubPage extends Page<void> {
  const _StubPage(this._builder);

  final WidgetBuilder _builder;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
      settings: this,
      pageBuilder: (BuildContext context, _, __) => Builder(builder: _builder),
    );
  }
}
