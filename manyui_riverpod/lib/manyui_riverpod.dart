/// `riverpod` adapters for manyui controllers. Importing this package
/// is optional — core manyui has no riverpod dependency.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manyui/manyui.dart';

/// Default Riverpod state for app-level manyui theme mode.
///
/// Apps can use this directly or pass their own [StateProvider] to the helper
/// methods below when theme preference is persisted elsewhere.
final StateProvider<MThemeMode> mThemeModeProvider = StateProvider<MThemeMode>(
  (Ref ref) => MThemeMode.system,
);

/// Ergonomic helpers for manyui theme-mode state in Riverpod widgets.
extension MThemeModeWidgetRef on WidgetRef {
  /// Watches [provider] or the default [mThemeModeProvider].
  MThemeMode watchMThemeMode([ProviderListenable<MThemeMode>? provider]) {
    return watch(provider ?? mThemeModeProvider);
  }

  /// Reads [provider] or the default [mThemeModeProvider] without listening.
  MThemeMode readMThemeMode([ProviderListenable<MThemeMode>? provider]) {
    return read(provider ?? mThemeModeProvider);
  }

  /// Sets [provider] or the default [mThemeModeProvider].
  void setMThemeMode(MThemeMode mode, [StateProvider<MThemeMode>? provider]) {
    read((provider ?? mThemeModeProvider).notifier).state = mode;
  }

  /// Toggles between light and dark mode.
  ///
  /// `system` is treated as not-dark, so the first toggle selects dark.
  void toggleMThemeMode([StateProvider<MThemeMode>? provider]) {
    final StateProvider<MThemeMode> target = provider ?? mThemeModeProvider;
    final MThemeMode current = read(target);
    read(target.notifier).state = current == MThemeMode.dark
        ? MThemeMode.light
        : MThemeMode.dark;
  }
}

/// Builder that keeps an [MController] synchronized with a Riverpod provider.
///
/// Provider changes update the controller. Controller changes call [onChanged],
/// allowing apps to write back to a `StateProvider`, notifier, or persistence
/// layer. The controller is owned by this widget and disposed automatically.
class MProviderController<T> extends ConsumerStatefulWidget {
  /// Creates a provider-backed manyui controller bridge.
  const MProviderController({
    required this.provider,
    required this.builder,
    this.onChanged,
    super.key,
  });

  /// The provider that supplies the authoritative value.
  final ProviderListenable<T> provider;

  /// Called when the controller changes outside provider synchronization.
  final void Function(WidgetRef ref, T value)? onChanged;

  /// Builds descendants with the synchronized controller and watched value.
  final Widget Function(
    BuildContext context,
    MController<T> controller,
    T value,
  )
  builder;

  @override
  ConsumerState<MProviderController<T>> createState() =>
      _MProviderControllerState<T>();
}

class _MProviderControllerState<T>
    extends ConsumerState<MProviderController<T>> {
  late final MController<T> _controller = MController<T>(
    ref.read(widget.provider),
  );
  bool _syncingFromProvider = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(MProviderController<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _syncController(ref.read(widget.provider));
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_syncingFromProvider) return;
    widget.onChanged?.call(ref, _controller.value);
  }

  void _syncController(T value) {
    if (_controller.value == value) return;
    _syncingFromProvider = true;
    _controller.value = value;
    _syncingFromProvider = false;
  }

  @override
  Widget build(BuildContext context) {
    final T value = ref.watch(widget.provider);
    _syncController(value);
    return widget.builder(context, _controller, value);
  }
}
