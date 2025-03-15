import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'toast_style.dart';

/// A non-modal notification surface that floats in the root [Overlay].
///
/// `MToast` is the visual body. It paints the resolved [MToastStyle] and
/// wraps the caller's [child] in a [DefaultTextStyle] so descendant `Text`
/// inherits the toast's foreground color.
///
/// Most callers don't construct `MToast` directly — they call [showMToast],
/// which inserts an [OverlayEntry] that hosts the toast with its auto-dismiss
/// [Timer], stacking offset, fade-in, and (under mouse modality) hover-to-
/// pause behavior. There is no scrim, no focus trap, no route — toasts sit
/// above every pushed route in the root overlay.
class MToast extends StatelessWidget {
  /// Builds a toast body.
  const MToast({
    required this.child,
    this.style,
    this.semanticLabel,
    super.key,
  });

  /// The toast's content.
  final Widget child;

  /// Field-wise overrides for the theme-resolved [MToastStyle].
  final MToastStyleDelta? style;

  /// An optional accessibility label applied to the toast surface.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MToastStyle resolved = theme.toast
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(style);

    final Widget surface = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: resolved.maxWidth),
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
                    offset: const Offset(0, 4),
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
    );

    return Semantics(
      container: true,
      liveRegion: true,
      label: semanticLabel,
      child: surface,
    );
  }
}

/// A handle to a live toast, returned by [showMToast].
///
/// Call [dismiss] to remove the toast early; the auto-dismiss [Timer] is
/// cancelled and the [OverlayEntry] is removed. [isDismissed] flips to true
/// once the toast has been torn down (either by [dismiss] or by the timer).
class MToastController {
  MToastController._(this._handle);

  final _ToastHandle _handle;

  /// Whether this toast has already been torn down.
  bool get isDismissed => _handle.isDismissed;

  /// Dismisses the toast immediately, cancelling the auto-dismiss timer.
  ///
  /// Safe to call after the toast has already auto-dismissed — the call is a
  /// no-op in that case.
  void dismiss() {
    _handle.dismiss();
  }
}

/// Inserts an [MToast] into the root [Overlay] and returns a controller.
///
/// The toast paints in the root overlay (via `Overlay.of(context,
/// rootOverlay: true)`) so it sits above every pushed route — including
/// [MDialog] and [MSheet]. It anchors to a corner of the viewport, fades in
/// over 150 ms, auto-dismisses after [duration], and shifts already-visible
/// toasts to make room. Under mouse modality, hovering the toast pauses the
/// auto-dismiss timer until the pointer leaves.
///
/// Pass an explicit [overlay] to target a non-default [OverlayState] (for
/// example, when a popup or test pumps its own inline overlay).
///
/// Requires an ambient [Overlay] — provided by [MWidgetsApp]'s [Navigator],
/// or by a manual [Overlay] in a test.
///
/// ```dart
/// final MToastController toast = showMToast(
///   context,
///   builder: (BuildContext ctx) => const Text('Saved'),
///   duration: const Duration(seconds: 3),
/// );
/// // ...later:
/// toast.dismiss();
/// ```
MToastController showMToast(
  BuildContext context, {
  required WidgetBuilder builder,
  Duration duration = const Duration(seconds: 4),
  MToastAnchor anchor = MToastAnchor.bottomEnd,
  MToastStyleDelta? style,
  String? semanticLabel,
  OverlayState? overlay,
}) {
  final MThemeData theme = MTheme.of(context);
  final MInputModality modality = MInputModalityScope.of(context);
  final OverlayState overlayState =
      overlay ?? Overlay.of(context, rootOverlay: true);

  final _ToastRegistry registry = _ToastRegistry.forOverlay(overlayState);
  final _ToastHandle handle = _ToastHandle(
    themeData: theme,
    modality: modality,
    builder: builder,
    duration: duration,
    anchor: anchor,
    styleDelta: style,
    semanticLabel: semanticLabel,
    registry: registry,
  );

  registry.insert(handle, overlayState);
  return MToastController._(handle);
}

/// Internal: per-toast state shared between the registry and the host widget.
class _ToastHandle {
  _ToastHandle({
    required this.themeData,
    required this.modality,
    required this.builder,
    required this.duration,
    required this.anchor,
    required this.styleDelta,
    required this.semanticLabel,
    required this.registry,
  });

  final MThemeData themeData;
  final MInputModality modality;
  final WidgetBuilder builder;
  final Duration duration;
  final MToastAnchor anchor;
  final MToastStyleDelta? styleDelta;
  final String? semanticLabel;
  final _ToastRegistry registry;

  late final OverlayEntry entry = OverlayEntry(builder: _buildHost);
  bool isDismissed = false;
  final ValueNotifier<double> stackOffset = ValueNotifier<double>(0);
  final GlobalKey<_ToastHostState> hostKey = GlobalKey<_ToastHostState>();

  Widget _buildHost(BuildContext context) {
    return _ToastHost(
      key: hostKey,
      handle: this,
    );
  }

  void dismiss() {
    if (isDismissed) return;
    isDismissed = true;
    hostKey.currentState?.startExit();
  }

  void detach() {
    if (entry.mounted) {
      entry.remove();
    }
    entry.dispose();
    stackOffset.dispose();
    registry.remove(this);
  }
}

/// Internal: per-[OverlayState] stack registry.
///
/// One registry exists per OverlayState. New toasts join the back of the
/// list; on insert/remove, the registry recomputes each entry's vertical
/// offset based on the cumulative height of the toasts already mounted closer
/// to the anchored edge. Heights are read from rendered render-objects after
/// a frame, then pushed into per-entry [ValueNotifier]s.
class _ToastRegistry {
  _ToastRegistry._();

  static final Map<OverlayState, _ToastRegistry> _byOverlay =
      <OverlayState, _ToastRegistry>{};

  static _ToastRegistry forOverlay(OverlayState overlay) {
    return _byOverlay.putIfAbsent(overlay, () => _ToastRegistry._());
  }

  final List<_ToastHandle> _entries = <_ToastHandle>[];

  void insert(_ToastHandle handle, OverlayState overlay) {
    _entries.add(handle);
    overlay.insert(handle.entry);
    _scheduleRecompute();
  }

  void remove(_ToastHandle handle) {
    _entries.remove(handle);
    if (_entries.isEmpty) {
      _byOverlay.removeWhere((_, value) => value == this);
    } else {
      _scheduleRecompute();
    }
  }

  void _scheduleRecompute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recompute();
    });
  }

  void _recompute() {
    // Toasts anchored at the bottom edge stack upward (newest at the bottom,
    // older ones pushed up by the cumulative height). Top-anchored toasts
    // stack downward.
    //
    // The newest entry is the last in [_entries]. For bottom anchors the
    // newest has offset 0 and prior entries grow positive upward; for top
    // anchors the newest has offset 0 and prior entries grow positive
    // downward. (Each entry's translation sign is applied at paint time
    // based on its own anchor.)
    double offset = 0;
    for (int i = _entries.length - 1; i >= 0; i--) {
      final _ToastHandle handle = _entries[i];
      final double gap = handle.themeData.toast
          .resolve(
            colors: handle.themeData.colors,
            typography: handle.themeData.typography,
            radius: handle.themeData.radius,
          )
          .applyDelta(handle.styleDelta)
          .gap;
      handle.stackOffset.value = offset;
      final RenderBox? box = handle.hostKey.currentContext?.findRenderObject()
          as RenderBox?;
      final double height = (box != null && box.hasSize) ? box.size.height : 0;
      offset += height + gap;
    }
  }
}

/// Internal: hosts one toast in the overlay. Owns the auto-dismiss timer,
/// fade-in/out animation, hover-to-pause MouseRegion, and the registered
/// stack offset.
class _ToastHost extends StatefulWidget {
  const _ToastHost({super.key, required this.handle});

  final _ToastHandle handle;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );
  Timer? _autoDismiss;
  bool _paused = false;
  Duration _remaining = Duration.zero;
  DateTime _resumedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _remaining = widget.handle.duration;
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.handle.registry._recompute();
    });
  }

  void _startTimer() {
    _autoDismiss?.cancel();
    if (_remaining <= Duration.zero) return;
    _resumedAt = DateTime.now();
    _autoDismiss = Timer(_remaining, _onAutoDismiss);
  }

  void _pauseTimer() {
    if (_paused) return;
    _paused = true;
    _autoDismiss?.cancel();
    _autoDismiss = null;
    final Duration elapsed = DateTime.now().difference(_resumedAt);
    _remaining = _remaining - elapsed;
    if (_remaining < Duration.zero) _remaining = Duration.zero;
  }

  void _resumeTimer() {
    if (!_paused) return;
    _paused = false;
    _startTimer();
  }

  void _onAutoDismiss() {
    if (widget.handle.isDismissed) return;
    widget.handle.isDismissed = true;
    startExit();
  }

  /// Plays the exit animation and tears down the overlay entry.
  void startExit() {
    if (!mounted) {
      widget.handle.detach();
      return;
    }
    _autoDismiss?.cancel();
    _controller.reverse().whenComplete(() {
      widget.handle.detach();
    });
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Alignment _alignmentFor(MToastAnchor anchor) {
    switch (anchor) {
      case MToastAnchor.topStart:
        return Alignment.topLeft;
      case MToastAnchor.topEnd:
        return Alignment.topRight;
      case MToastAnchor.bottomStart:
        return Alignment.bottomLeft;
      case MToastAnchor.bottomEnd:
        return Alignment.bottomRight;
    }
  }

  bool _isTop(MToastAnchor anchor) =>
      anchor == MToastAnchor.topStart || anchor == MToastAnchor.topEnd;

  @override
  Widget build(BuildContext context) {
    final _ToastHandle handle = widget.handle;
    final MToastStyle resolved = handle.themeData.toast
        .resolve(
          colors: handle.themeData.colors,
          typography: handle.themeData.typography,
          radius: handle.themeData.radius,
        )
        .applyDelta(handle.styleDelta);

    final bool top = _isTop(handle.anchor);
    final double edge = resolved.edgeInset;

    Widget surface = MTheme(
      data: handle.themeData,
      child: Builder(
        builder: (BuildContext themedContext) {
          return MToast(
            style: handle.styleDelta,
            semanticLabel: handle.semanticLabel,
            child: Builder(builder: handle.builder),
          );
        },
      ),
    );

    if (handle.modality == MInputModality.mouse) {
      surface = MouseRegion(
        onEnter: (_) => _pauseTimer(),
        onExit: (_) => _resumeTimer(),
        child: surface,
      );
    }

    final Widget animated = FadeTransition(
      opacity: _controller,
      child: ValueListenableBuilder<double>(
        valueListenable: handle.stackOffset,
        builder: (BuildContext context, double offset, Widget? child) {
          return Transform.translate(
            offset: Offset(0, top ? offset : -offset),
            child: child,
          );
        },
        child: surface,
      ),
    );

    return Positioned(
      top: top ? edge : null,
      bottom: top ? null : edge,
      left: (handle.anchor == MToastAnchor.topStart ||
              handle.anchor == MToastAnchor.bottomStart)
          ? edge
          : null,
      right: (handle.anchor == MToastAnchor.topEnd ||
              handle.anchor == MToastAnchor.bottomEnd)
          ? edge
          : null,
      child: Align(
        alignment: _alignmentFor(handle.anchor),
        child: animated,
      ),
    );
  }
}
