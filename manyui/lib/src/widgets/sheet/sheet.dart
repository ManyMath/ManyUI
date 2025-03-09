import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'sheet_style.dart';

/// Where on the screen an [MSheet] anchors itself.
///
/// `bottom` is the touch-default; `start` and `end` are the desktop/tablet
/// drawer idiom. There is no `center` — for a centered modal use `MDialog`
/// instead.
enum MSheetAnchor {
  /// Anchored to the bottom edge, full-width, intrinsic height up to
  /// [MSheetStyle.maxHeightFraction] of the viewport.
  bottom,

  /// Anchored to the start edge (left in LTR, right in RTL), full-height,
  /// width = [MSheetStyle.sideWidth].
  start,

  /// Anchored to the end edge (right in LTR, left in RTL), full-height,
  /// width = [MSheetStyle.sideWidth].
  end,
}

/// A modal surface anchored to a viewport edge.
///
/// `MSheet` is the visual body that paints the resolved [MSheetStyle] and
/// (for bottom sheets under touch modality) a small drag handle at the top.
/// Most callers don't construct `MSheet` directly — they call [showMSheet],
/// which pushes an [MSheetRoute] that builds the sheet with the route's
/// scrim, focus trap, Escape-dismiss, slide-in transition, and (for bottom +
/// touch) drag-to-dismiss behavior.
class MSheet extends StatelessWidget {
  /// Builds a sheet body.
  const MSheet({
    required this.child,
    required this.anchor,
    this.style,
    this.semanticLabel,
    this.showDragHandle = false,
    super.key,
  });

  /// The sheet's content.
  final Widget child;

  /// Which viewport edge the sheet sits against.
  final MSheetAnchor anchor;

  /// Field-wise overrides for the theme-resolved [MSheetStyle].
  final MSheetStyleDelta? style;

  /// An optional accessibility label applied to the sheet surface.
  final String? semanticLabel;

  /// Whether to paint a leading drag handle on the surface. Only meaningful
  /// for [MSheetAnchor.bottom]. The route sets this based on modality; if
  /// you construct `MSheet` directly you decide.
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MSheetStyle resolved = theme.sheet
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(style);

    final double cornerRadius = resolved.radius is BorderRadius
        ? (resolved.radius as BorderRadius).topLeft.x
        : theme.radius;
    final BorderRadiusGeometry anchoredRadius = switch (anchor) {
      MSheetAnchor.bottom => BorderRadius.only(
          topLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius),
        ),
      MSheetAnchor.start => BorderRadiusDirectional.only(
          topEnd: Radius.circular(cornerRadius),
          bottomEnd: Radius.circular(cornerRadius),
        ),
      MSheetAnchor.end => BorderRadiusDirectional.only(
          topStart: Radius.circular(cornerRadius),
          bottomStart: Radius.circular(cornerRadius),
        ),
    };

    final Widget body = Padding(
      padding: resolved.padding,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: resolved.foregroundColor),
        child: child,
      ),
    );

    final Widget content = (showDragHandle && anchor == MSheetAnchor.bottom)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: resolved.dragHandleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(child: body),
            ],
          )
        : body;

    final Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: resolved.backgroundColor,
        borderRadius: anchoredRadius,
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
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: content,
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: surface,
    );
  }
}

/// A modal route that renders an [MSheet] anchored to a viewport edge.
///
/// Pushed by [showMSheet]. Returns whatever the content passes to
/// `Navigator.of(context).pop(value)` as the route's result.
///
/// The route is a [PopupRoute] so it inherits the modal-route focus trap and
/// barrier-color animation. [dismissible] toggles both the scrim-tap dismiss
/// and the Escape key dismiss as a unit; an undismissible sheet must be
/// closed programmatically via `Navigator.pop`. Bottom sheets under touch
/// modality also gain a drag-to-dismiss gesture that calls `Navigator.pop`.
class MSheetRoute<T> extends PopupRoute<T> {
  /// Builds a sheet route.
  MSheetRoute({
    required this.builder,
    required this.scrimColor,
    required this.themeData,
    required this.anchor,
    this.style,
    this.semanticLabel,
    this.dismissible = true,
    this.transitionDuration = const Duration(milliseconds: 200),
  });

  /// Builds the sheet's content. Wrapped in an [MSheet] surface.
  final WidgetBuilder builder;

  /// Color of the modal scrim. Resolved from `theme.sheet` at push time so
  /// the route is independent of theme changes mid-route.
  final Color scrimColor;

  /// The theme data captured at push time. Re-installed inside the route so
  /// the sheet renders against the same theme as its caller even though the
  /// route lives in the [Navigator]'s overlay subtree.
  final MThemeData themeData;

  /// Which viewport edge the sheet sits against.
  final MSheetAnchor anchor;

  /// Field-wise overrides for the theme-resolved [MSheetStyle].
  final MSheetStyleDelta? style;

  /// Optional semantic label for the sheet surface.
  final String? semanticLabel;

  /// Whether the sheet can be dismissed by tapping the scrim, pressing
  /// Escape, or (for bottom + touch) dragging down. Defaults to true.
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
    return MTheme(
      data: themeData,
      child: Builder(
        builder: (BuildContext themedContext) {
          final MInputModality modality =
              MInputModalityScope.of(themedContext);
          final MSheetStyle resolved = themeData.sheet
              .resolve(
                colors: themeData.colors,
                typography: themeData.typography
                    .inheritFromContext(themedContext),
                radius: themeData.radius,
              )
              .applyDelta(style);

          final bool dragToDismiss = dismissible &&
              anchor == MSheetAnchor.bottom &&
              modality == MInputModality.touch;

          final Widget sheet = MSheet(
            anchor: anchor,
            style: style,
            semanticLabel: semanticLabel,
            showDragHandle:
                anchor == MSheetAnchor.bottom &&
                    modality == MInputModality.touch,
            child: Builder(builder: builder),
          );

          final Widget sized = _AnchoredSize(
            anchor: anchor,
            sideWidth: resolved.sideWidth,
            maxHeightFraction: resolved.maxHeightFraction,
            child: sheet,
          );

          // Absorb taps inside the sheet so a tap or drag-end-outside-sheet
          // doesn't bubble to the modal barrier and dismiss the route. The
          // drag wrapper (when present) handles its own gestures.
          final Widget absorbing = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: sized,
          );

          final Widget draggable = dragToDismiss
              ? _DragToDismiss(child: absorbing)
              : absorbing;

          final Widget aligned = Align(
            alignment: _alignmentFor(anchor),
            child: draggable,
          );

          return dismissible
              ? _EscapeDismiss(child: aligned)
              : aligned;
        },
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Offset begin = switch (anchor) {
      MSheetAnchor.bottom => const Offset(0, 1),
      MSheetAnchor.start => const Offset(-1, 0),
      MSheetAnchor.end => const Offset(1, 0),
    };
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: child,
    );
  }

  static AlignmentGeometry _alignmentFor(MSheetAnchor anchor) {
    switch (anchor) {
      case MSheetAnchor.bottom:
        return Alignment.bottomCenter;
      case MSheetAnchor.start:
        return AlignmentDirectional.centerStart;
      case MSheetAnchor.end:
        return AlignmentDirectional.centerEnd;
    }
  }
}

/// Pushes an [MSheetRoute] and returns whatever the content pops with.
///
/// The sheet is anchored to [anchor]'s edge, scrim-backed, focus-trapped,
/// and dismissible by scrim-tap, Escape, or (for bottom + touch) a drag.
/// Set [dismissible] to false to suppress all three. Caller content commits
/// via `Navigator.of(context).pop(value)`.
///
/// Requires an ambient [Navigator] — provided by [MWidgetsApp].
///
/// ```dart
/// final String? choice = await showMSheet<String>(
///   context,
///   anchor: MSheetAnchor.bottom,
///   builder: (BuildContext ctx) => Column(
///     mainAxisSize: MainAxisSize.min,
///     children: <Widget>[
///       MButton(
///         onPressed: () => Navigator.of(ctx).pop('save'),
///         child: const Text('Save'),
///       ),
///       MButton(
///         onPressed: () => Navigator.of(ctx).pop('cancel'),
///         child: const Text('Cancel'),
///       ),
///     ],
///   ),
/// );
/// ```
Future<T?> showMSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  MSheetAnchor anchor = MSheetAnchor.bottom,
  MSheetStyleDelta? style,
  String? semanticLabel,
  bool dismissible = true,
}) {
  final MThemeData theme = MTheme.of(context);
  final MSheetStyle resolved = theme.sheet
      .resolve(
        colors: theme.colors,
        typography: theme.typography.inheritFromContext(context),
        radius: theme.radius,
      )
      .applyDelta(style);

  return Navigator.of(context).push<T>(MSheetRoute<T>(
    builder: builder,
    scrimColor: resolved.scrimColor,
    themeData: theme,
    anchor: anchor,
    style: style,
    semanticLabel: semanticLabel,
    dismissible: dismissible,
  ));
}

/// Wraps a sheet in viewport-relative constraints.
///
/// Bottom anchors expand to full width; height is intrinsic up to
/// [maxHeightFraction] of the viewport. Side anchors expand to full height;
/// width is fixed at [sideWidth].
class _AnchoredSize extends StatelessWidget {
  const _AnchoredSize({
    required this.anchor,
    required this.sideWidth,
    required this.maxHeightFraction,
    required this.child,
  });

  final MSheetAnchor anchor;
  final double sideWidth;
  final double maxHeightFraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size viewport = MediaQuery.sizeOf(context);
    switch (anchor) {
      case MSheetAnchor.bottom:
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: viewport.height * maxHeightFraction,
          ),
          child: SizedBox(
            width: viewport.width,
            child: child,
          ),
        );
      case MSheetAnchor.start:
      case MSheetAnchor.end:
        return SizedBox(
          width: sideWidth,
          height: viewport.height,
          child: child,
        );
    }
  }
}

/// Vertical-drag-to-dismiss wrapper for bottom sheets under touch modality.
///
/// Keep the gesture detector INSIDE any translation we wrap the child in —
/// the FractionalTranslation hit-test gotcha applies (see MTooltip): a
/// pointer event hits the *pre-translation* bounds otherwise.
class _DragToDismiss extends StatefulWidget {
  const _DragToDismiss({required this.child});

  final Widget child;

  @override
  State<_DragToDismiss> createState() => _DragToDismissState();
}

class _DragToDismissState extends State<_DragToDismiss> {
  double _dragOffset = 0;

  static const double _flingVelocityThreshold = 700;
  static const double _distanceThresholdFraction = 0.4;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final double height = box?.size.height ?? 0;
    final bool flingDown =
        details.velocity.pixelsPerSecond.dy > _flingVelocityThreshold;
    final bool draggedFar =
        height > 0 && _dragOffset / height > _distanceThresholdFraction;

    if (flingDown || draggedFar) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _dragOffset),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: widget.child,
      ),
    );
  }
}

/// Internal helper that closes the route on Escape.
///
/// `PopupRoute.barrierDismissible` already handles the scrim-tap dismiss and
/// installs the modal focus trap. The Escape-key dismiss is a separate beat —
/// we listen on a [Focus] that wraps the sheet and pop the route ourselves.
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
