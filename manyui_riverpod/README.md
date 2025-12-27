# manyui_riverpod

[riverpod](https://pub.dev/packages/flutter_riverpod) adapters for [manyui](https://github.com/sneurlax/manyui) controllers. Optional — core manyui works fine without riverpod.

## Provider-backed controllers

```dart
final volumeProvider = StateProvider<double>((ref) => 0.5);

MProviderController<double>(
  provider: volumeProvider,
  onChanged: (ref, value) {
    ref.read(volumeProvider.notifier).state = value;
  },
  builder: (context, controller, value) {
    return MSlider(controller: controller);
  },
)
```

`MProviderController<T>` keeps a manyui `MController<T>` synchronized with a
Riverpod provider. Provider changes update the controller; controller changes
call `onChanged`, so apps can write back through a `StateProvider`, notifier, or
persistence layer.

## Theme mode

The package also exports `mThemeModeProvider` and `WidgetRef` helpers:

```dart
final mode = ref.watchMThemeMode();
ref.toggleMThemeMode();
```
