/// `flutter_hooks` adapters for manyui controllers. Importing this
/// package is optional — core manyui has no hooks dependency.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:manyui/manyui.dart';

/// Creates an [MController] owned by the current hook.
///
/// The controller is created once for the hook position, disposed when the
/// widget unmounts, and recreated when [keys] change. [initialValue] seeds only
/// a newly-created controller; subsequent rebuilds keep the current controller
/// value unless a key changes.
MController<T> useMController<T>(
  T initialValue, [
  List<Object?> keys = const <Object?>[],
]) {
  final MController<T> controller = useMemoized(
    () => MController<T>(initialValue),
    keys,
  );
  useEffect(() => controller.dispose, <Object?>[controller]);
  return controller;
}

/// Creates a read-only [MController] view over [source].
///
/// This is useful when a manyui widget requires an `MController<T>` but the
/// app's state is already exposed as a [ValueListenable]. Assigning to the
/// returned controller is intentionally ignored; [source] remains authoritative.
MController<T> useMControllerFromValueListenable<T>(ValueListenable<T> source) {
  final MController<T> controller = useMemoized(
    () => MController.fromValueListenable<T>(source),
    <Object?>[source],
  );
  useEffect(() => controller.dispose, <Object?>[controller]);
  return controller;
}

/// Returns the current [controller] value and rebuilds when it changes.
T useMControllerValue<T>(MController<T> controller) {
  final ValueNotifier<T> value = useState<T>(controller.value);
  useEffect(() {
    void listener() {
      value.value = controller.value;
    }

    controller.addListener(listener);
    value.value = controller.value;
    return () => controller.removeListener(listener);
  }, <Object?>[controller]);
  return value.value;
}

/// Convenience hook for app-level manyui theme mode state.
MController<MThemeMode> useMThemeModeController([
  MThemeMode initialValue = MThemeMode.system,
  List<Object?> keys = const <Object?>[],
]) {
  return useMController<MThemeMode>(initialValue, keys);
}
