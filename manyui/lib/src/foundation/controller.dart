import 'package:flutter/foundation.dart';

/// State-management primitive for interactive manyui widgets.
///
/// Widgets accept an optional `MController<T>? controller`; when null they
/// create and dispose one internally. Matches the ownership rhythm of
/// [TextEditingController] and [ScrollController], with a single base class
/// so adapters in `manyui_hooks` and `manyui_riverpod` have one type to bind.
///
/// ```dart
/// final MController<bool> agreed = MController<bool>(false);
/// agreed.addListener(() => print(agreed.value));
/// agreed.value = true;
/// ```
class MController<T> extends ChangeNotifier implements ValueListenable<T> {
  /// Builds a controller with [initial] as its starting value.
  MController(T initial) : _value = initial;

  /// The current value.
  @override
  T get value => _value;
  T _value;

  /// Sets [value] and notifies listeners if the value changed.
  ///
  /// Override to add invariants (e.g. clamping) -- call `super.value` to
  /// perform the notify.
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  /// Wraps an existing [ValueListenable] in a read-only [MController].
  ///
  /// Setting [value] is a no-op. Disposing detaches the listener but does
  /// not dispose the source -- the source's owner is still responsible for it.
  static MController<T> fromValueListenable<T>(ValueListenable<T> source) =>
      _ValueListenableController<T>(source);
}

class _ValueListenableController<T> extends MController<T> {
  _ValueListenableController(this._source) : super(_source.value) {
    _source.addListener(_onSourceChanged);
  }

  final ValueListenable<T> _source;

  void _onSourceChanged() {
    final T next = _source.value;
    if (next == super.value) return;
    super.value = next;
  }

  @override
  set value(T newValue) {
    // Read-only adapter: the source is authoritative.
  }

  @override
  void dispose() {
    _source.removeListener(_onSourceChanged);
    super.dispose();
  }
}
