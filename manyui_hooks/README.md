# manyui_hooks

[flutter_hooks](https://pub.dev/packages/flutter_hooks) adapters for [manyui](https://github.com/sneurlax/manyui) controllers. Optional — core manyui works fine without hooks.

## Controller hooks

```dart
final controller = useMController<String>('');
final value = useMControllerValue(controller);
```

- `useMController<T>(initialValue, [keys])` creates and disposes an
  `MController<T>` for the hook owner.
- `useMControllerValue(controller)` rebuilds when the controller value changes.
- `useMControllerFromValueListenable(source)` exposes an existing
  `ValueListenable<T>` as a read-only `MController<T>`.
- `useMThemeModeController()` is a small convenience for app-level
  `MThemeMode` state.
