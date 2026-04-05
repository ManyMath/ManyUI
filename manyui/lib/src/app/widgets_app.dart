import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../foundation/input_modality.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../widgets/context_menu/context_menu_style.dart';

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
  /// Builds a manyui root app.
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
    this.selectableText = true,
  });

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

  /// Wraps every page in additional widgets (e.g. a `MScaffold`).
  final TransitionBuilder? builder;

  /// Whether static text throughout the app is mouse/touch selectable.
  ///
  /// Wraps the app content in a [SelectableRegion] so labels, errors, and
  /// other read-only text can be selected and copied (Cmd/Ctrl-C). Text
  /// fields keep their own selection handling. Defaults to true.
  final bool selectableText;

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
    return MTheme(
      data: resolved,
      child: MInputModalityScope(
        modality: MInputModality.defaultForPlatform(resolved.platform),
        child: WidgetsApp(
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
                    pageBuilder: (BuildContext context, _, __) =>
                        builder(context),
                  ),
          builder: (BuildContext context, Widget? child) {
            Widget wrapped = child ?? const SizedBox.shrink();
            if (selectableText) {
              // SelectableRegion needs an Overlay ancestor for its
              // selection handles; builder runs above the Navigator's
              // Overlay, so provide one.
              wrapped = Overlay.wrap(
                child: SelectableRegion(
                  contextMenuBuilder:
                      (BuildContext context, SelectableRegionState state) {
                        return _buildSelectableRegionContextMenu(
                          context,
                          state,
                          theme: resolved,
                          modality: MInputModality.defaultForPlatform(
                            resolved.platform,
                          ),
                        );
                      },
                  selectionControls: _manyuiSelectionControls,
                  child: DefaultSelectionStyle.merge(
                    cursorColor: resolved.colors.foreground,
                    selectionColor: resolved.colors.ring.withValues(
                      alpha: 0.25,
                    ),
                    child: wrapped,
                  ),
                ),
              );
            }
            // Flutter web can focus its view before the first layout pass.
            // Temporarily excluding descendants prevents reading-order focus
            // traversal from querying RenderBox geometry before it exists.
            if (kIsWeb) wrapped = _MInitialFocusGuard(child: wrapped);
            return builder == null ? wrapped : builder!(context, wrapped);
          },
          title: title,
          color: color,
          textStyle: resolved.typography
              .inheritFromContext(context)
              .body
              .copyWith(color: resolved.colors.foreground),
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

class _MInitialFocusGuard extends StatefulWidget {
  const _MInitialFocusGuard({required this.child});

  final Widget child;

  @override
  State<_MInitialFocusGuard> createState() => _MInitialFocusGuardState();
}

class _MInitialFocusGuardState extends State<_MInitialFocusGuard> {
  bool _laidOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _laidOut = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(excluding: !_laidOut, child: widget.child);
  }
}

final TextSelectionControls _manyuiSelectionControls =
    _MSelectableRegionControls();

class _MSelectableRegionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    return const SizedBox.shrink();
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return Offset.zero;
  }

  @override
  Size getHandleSize(double textLineHeight) => Size.zero;
}

Widget _buildSelectableRegionContextMenu(
  BuildContext context,
  SelectableRegionState selectableRegionState, {
  required MThemeData theme,
  required MInputModality modality,
}) {
  final List<_SelectionMenuItem> items = selectableRegionState
      .contextMenuButtonItems
      .map((ContextMenuButtonItem item) {
        return _SelectionMenuItem(
          label: _contextMenuButtonLabel(context, item),
          onPressed: item.onPressed,
        );
      })
      .where((_SelectionMenuItem item) => item.label.isNotEmpty)
      .toList(growable: false);

  if (items.isEmpty) return const SizedBox.shrink();

  final MContextMenuStyle style = theme.contextMenu.resolve(
    modality: modality,
    colors: theme.colors,
    typography: theme.typography,
    radius: theme.radius,
  );

  return _MSelectionToolbar(
    anchors: selectableRegionState.contextMenuAnchors,
    items: items,
    style: style,
  );
}

String _contextMenuButtonLabel(
  BuildContext context,
  ContextMenuButtonItem item,
) {
  if (item.label != null) return item.label!;

  final WidgetsLocalizations localizations = WidgetsLocalizations.of(context);
  return switch (item.type) {
    ContextMenuButtonType.cut => localizations.cutButtonLabel,
    ContextMenuButtonType.copy => localizations.copyButtonLabel,
    ContextMenuButtonType.paste => localizations.pasteButtonLabel,
    ContextMenuButtonType.selectAll => localizations.selectAllButtonLabel,
    ContextMenuButtonType.lookUp => localizations.lookUpButtonLabel,
    ContextMenuButtonType.searchWeb => localizations.searchWebButtonLabel,
    ContextMenuButtonType.share => localizations.shareButtonLabel,
    ContextMenuButtonType.delete => 'Delete',
    ContextMenuButtonType.liveTextInput => 'Scan text',
    ContextMenuButtonType.custom => '',
  };
}

class _SelectionMenuItem {
  const _SelectionMenuItem({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;
}

class _MSelectionToolbar extends StatelessWidget {
  const _MSelectionToolbar({
    required this.anchors,
    required this.items,
    required this.style,
  });

  final TextSelectionToolbarAnchors anchors;
  final List<_SelectionMenuItem> items;
  final MContextMenuStyle style;

  @override
  Widget build(BuildContext context) {
    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: style.surfaceBackgroundColor,
        borderRadius: style.surfaceRadius,
        border: style.surfaceBorderColor == null
            ? null
            : Border.all(
                color: style.surfaceBorderColor!,
                width: style.surfaceBorderWidth,
              ),
        boxShadow: style.surfaceElevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: style.surfaceShadowColor,
                  blurRadius: style.surfaceElevation,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: style.surfacePadding,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: style.surfaceForegroundColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < items.length; i++) ...<Widget>[
                if (i > 0) SizedBox(height: style.itemSpacing),
                _MSelectionToolbarButton(item: items[i], style: style),
              ],
            ],
          ),
        ),
      ),
    );

    surface = IntrinsicWidth(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: style.surfaceMinWidth,
          maxWidth: style.surfaceMaxWidth,
        ),
        child: surface,
      ),
    );

    return CustomSingleChildLayout(
      delegate: _SelectionToolbarLayout(
        anchors: anchors,
        viewportPadding: style.viewportPadding,
      ),
      child: surface,
    );
  }
}

class _MSelectionToolbarButton extends StatefulWidget {
  const _MSelectionToolbarButton({required this.item, required this.style});

  final _SelectionMenuItem item;
  final MContextMenuStyle style;

  @override
  State<_MSelectionToolbarButton> createState() =>
      _MSelectionToolbarButtonState();
}

class _MSelectionToolbarButtonState extends State<_MSelectionToolbarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.item.onPressed != null;
    final MContextMenuStyle s = widget.style;
    final TextStyle textStyle = s.itemTextStyle.copyWith(
      color: s.itemForegroundColor,
    );

    Widget row = DecoratedBox(
      decoration: BoxDecoration(
        color: _hovered && enabled
            ? s.itemHoveredBackgroundColor
            : const Color(0x00000000),
        borderRadius: s.itemRadius,
      ),
      child: SizedBox(
        height: s.itemHeight,
        child: Padding(
          padding: s.itemPadding,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              widget.item.label,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ),
      ),
    );

    if (!enabled) {
      row = Opacity(opacity: s.disabledOpacity, child: row);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.item.onPressed : null,
          child: row,
        ),
      ),
    );
  }
}

class _SelectionToolbarLayout extends SingleChildLayoutDelegate {
  _SelectionToolbarLayout({
    required this.anchors,
    required this.viewportPadding,
  });

  final TextSelectionToolbarAnchors anchors;
  final double viewportPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxWidth = (constraints.maxWidth - 2 * viewportPadding).clamp(
      0.0,
      double.infinity,
    );
    final double maxHeight = (constraints.maxHeight - 2 * viewportPadding)
        .clamp(0.0, double.infinity);
    return BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Offset? secondaryAnchor = anchors.secondaryAnchor;
    if (secondaryAnchor == null) {
      return _clamp(anchors.primaryAnchor, viewport: size, child: childSize);
    }

    final bool fitsAbove =
        anchors.primaryAnchor.dy - viewportPadding >= childSize.height;
    final Offset anchor = fitsAbove ? anchors.primaryAnchor : secondaryAnchor;
    final Offset target = Offset(
      anchor.dx - childSize.width / 2,
      fitsAbove ? anchor.dy - childSize.height : anchor.dy,
    );
    return _clamp(target, viewport: size, child: childSize);
  }

  Offset _clamp(Offset offset, {required Size viewport, required Size child}) {
    final double maxX = viewport.width - child.width - viewportPadding;
    final double maxY = viewport.height - child.height - viewportPadding;
    return Offset(
      offset.dx.clamp(viewportPadding, maxX.clamp(0.0, double.infinity)),
      offset.dy.clamp(viewportPadding, maxY.clamp(0.0, double.infinity)),
    );
  }

  @override
  bool shouldRelayout(_SelectionToolbarLayout oldDelegate) {
    return anchors != oldDelegate.anchors ||
        viewportPadding != oldDelegate.viewportPadding;
  }
}
