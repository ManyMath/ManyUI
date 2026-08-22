# manyui_testing

Test harness for [manyui](https://github.com/sneurlax/manyui). Add as a dev dependency:

```yaml
dev_dependencies:
  manyui_testing: ^0.1.0
```

Provides `pumpManyApp(WidgetTester, Widget, {MThemeData? theme, Size? viewport, MInputModality? modality})`.

## Widget Test Patterns

`pumpManyApp` installs the theme, media query, text direction, and input
modality that ManyUI widgets expect. Use it for widget-level behavior tests
instead of constructing a full app shell.

```dart
await pumpManyApp(
  tester,
  MButton(onPressed: () {}, child: const Text('Save')),
  modality: MInputModality.keyboard,
);
```

### Text Fields

For text entry, focus the field first, pump one frame so the editable child is
ready, then type into the `EditableText`.

```dart
await tester.tap(find.byType(MTextField));
await tester.pump();
await tester.enterText(find.byType(EditableText), 'hello');
await tester.pump();
```

If a widget opens an editor control in an overlay, pass
`installOverlay: true` to `pumpManyApp`.

### Indeterminate Progress

Do not use `pumpAndSettle()` while an indeterminate progress
indicator is mounted. The animation keeps scheduling frames, so
the settle loop can time out. Pump a fixed number of frames instead.

```dart
await tester.pump();
await tester.pump(const Duration(milliseconds: 120));
```

For golden tests, prefer determinate progress indicators. If the state under
test must include an indeterminate indicator, advance to a fixed duration before
capturing so the frame is deterministic.

### Golden Tests

Use explicit viewports for goldens and run light and dark themes separately.
The reference sizes used across ManyUI are phone, tablet, and desktop
breakpoints. Keep animated widgets in deterministic states before matching a
golden file.
