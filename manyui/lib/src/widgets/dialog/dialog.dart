import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'dialog_style.dart';

/// A centered modal surface rendered above a scrim.
///
/// `MDialog` is the visual body that sits at the center of the screen. It
/// applies the resolved [MDialogStyle] (background, border, radius, padding,
/// shadow, max-width clamp) and wraps the caller's [child] in a
/// [DefaultTextStyle] so descendant `Text` inherits the dialog's foreground
/// color.
///
/// Most callers don't construct `MDialog` directly — they call [showMDialog],
/// which pushes a [MDialogRoute] that builds the dialog with the route's
/// scrim, focus trap, and Escape-dismiss behavior.
class MDialog extends StatelessWidget {
  /// Builds a dialog body.
  const MDialog({
    required this.child,
    this.style,
    this.semanticLabel,
    super.key,
  });

  /// The dialog's content.
  final Widget child;

  /// Field-wise overrides for the theme-resolved [MDialogStyle].
  final MDialogStyleDelta? style;

  /// An optional accessibility label applied to the dialog surface.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MDialogStyle resolved = theme.dialog
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(style);

    final Widget surface = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: resolved.maxWidth),
      child: IntrinsicWidth(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: resolved.backgroundColor,
            borderRadius: resolved.radius,
            border: resolved.borderColor != null
                ? Border.all(
                    color: resolved.borderColor!,
                    width: resolved.borderWidth,
                  )
                : null,
            boxShadow: resolved.elevation > 0
                ? <BoxShadow>[
                    BoxShadow(
                      color: resolved.shadowColor,
                      blurRadius: resolved.elevation,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: resolved.padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: resolved.foregroundColor),
              child: child,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: surface,
    );
  }
}

/// A modal route that renders an [MDialog] above a scrim.
///
/// Pushed by [showMDialog]. Returns whatever the content passes to
/// `Navigator.of(context).pop(value)` as the route's result.
///
/// The route is a [PopupRoute] so it inherits the modal-route focus trap and
/// barrier-color animation. [dismissible] toggles both the scrim-tap dismiss
/// and the Escape key dismiss as a unit; an undismissible dialog must be
/// closed programmatically via `Navigator.pop`.
class MDialogRoute<T> extends PopupRoute<T> {
  /// Builds a dialog route.
  MDialogRoute({
    required this.builder,
    required this.scrimColor,
    required this.themeData,
    this.style,
    this.semanticLabel,
    this.dismissible = true,
    this.transitionDuration = const Duration(milliseconds: 150),
  });

  /// Builds the dialog's content. Wrapped in an [MDialog] surface.
  final WidgetBuilder builder;

  /// Color of the modal scrim. Resolved from `theme.dialog` at push time so
  /// the route is independent of theme changes mid-route.
  final Color scrimColor;

  /// The theme data captured at push time. Re-installed inside the route so
  /// the dialog renders against the same theme as its caller even though the
  /// route lives in the [Navigator]'s overlay subtree.
  final MThemeData themeData;

  /// Field-wise overrides for the theme-resolved [MDialogStyle].
  final MDialogStyleDelta? style;

  /// Optional semantic label for the dialog surface.
  final String? semanticLabel;

  /// Whether the dialog can be dismissed by tapping the scrim or pressing
  /// Escape. Defaults to true.
  final bool dismissible;

  @override
  final Duration transitionDuration;

  @override
  bool get barrierDismissible => dismissible;

  @override
  Color? get barrierColor => scrimColor;

  @override
  String? get barrierLabel => semanticLabel ?? 'Dismiss';

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget dialog = MTheme(
      data: themeData,
      child: MDialog(
        style: style,
        semanticLabel: semanticLabel,
        child: Builder(builder: builder),
      ),
    );

    final Widget body = dismissible
        ? _EscapeDismiss(child: dialog)
        : dialog;

    return Center(child: body);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}

/// Pushes an [MDialogRoute] and returns whatever the content pops with.
///
/// The dialog is centered, scrim-backed, focus-trapped, and dismissible by
/// scrim-tap or Escape (set [dismissible] to false to suppress both). Caller
/// content commits via `Navigator.of(context).pop(value)`.
///
/// Requires an ambient [Navigator] — provided by [MWidgetsApp].
///
/// ```dart
/// final bool? confirmed = await showMDialog<bool>(
///   context,
///   builder: (BuildContext ctx) => Column(
///     mainAxisSize: MainAxisSize.min,
///     children: <Widget>[
///       const Text('Delete this?'),
///       Row(children: <Widget>[
///         MButton(
///           onPressed: () => Navigator.of(ctx).pop(false),
///           child: const Text('Cancel'),
///         ),
///         MButton(
///           onPressed: () => Navigator.of(ctx).pop(true),
///           child: const Text('Delete'),
///         ),
///       ]),
///     ],
///   ),
/// );
/// ```
Future<T?> showMDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  MDialogStyleDelta? style,
  String? semanticLabel,
  bool dismissible = true,
}) {
  final MThemeData theme = MTheme.of(context);
  final MDialogStyle resolved = theme.dialog
      .resolve(
        colors: theme.colors,
        typography: theme.typography.inheritFromContext(context),
        radius: theme.radius,
      )
      .applyDelta(style);

  return Navigator.of(context).push<T>(MDialogRoute<T>(
    builder: builder,
    scrimColor: resolved.scrimColor,
    themeData: theme,
    style: style,
    semanticLabel: semanticLabel,
    dismissible: dismissible,
  ));
}

/// Internal helper that closes the route on Escape.
///
/// `PopupRoute.barrierDismissible` already handles the scrim-tap dismiss and
/// installs the modal focus trap. The Escape-key dismiss is a separate beat —
/// we listen on a [Focus] that wraps the dialog and pop the route ourselves.
class _EscapeDismiss extends StatelessWidget {
  const _EscapeDismiss({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(node.context!).maybePop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
