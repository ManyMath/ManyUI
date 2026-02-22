# Changelog

## 0.1.4 (2026-06-18)

Minor release.

### Added
- `MPressable`, a foundation interaction primitive (hover, focus, press, keyboard activation, modality-aware cursor, focus ring) that any surface can build on to become a button-like control. Pair it with `MCard` for a whole-card link.

### Changed
- `MButton` is now implemented on top of `MPressable`. No public API or visual change.

## 0.1.3 (2026-06-17)

Minor release.

### Added
- `MTextField` now takes `minLines` and `maxLines` (default `maxLines: 1`, so single-line behavior is unchanged). Any other `maxLines` makes the field multiline: `keyboardType` defaults to `TextInputType.multiline`, the field sizes to its content, and Flutter stops stripping `\n` before `inputFormatters` run so a formatter can act on a multi-line paste. Set `minLines` (e.g. `minLines: 1, maxLines: 5`) to grow with content rather than fill the available height.

## 0.1.2 (2026-06-17)

Patch release.

### Fixed
- `MTextField` took no keyboard input. Tapping a field focused it but never opened the platform text-input connection, so it showed a focus ring with no caret and ignored typing and paste. The tap handler now calls `EditableText.requestKeyboard()`, the same path Flutter's `TextField` uses, which both focuses the field and opens the connection.

## 0.1.1 (2026-05-14)

Patch release. Adds the `MScaffold` widget that v0.1.0's docs referenced but never built.

### Added
- `MScaffold`: themed app-shell with a required `body` plus optional `header` and `footer`. Paints `colors.background`, applies safe-area insets, merges `DefaultTextStyle` / `IconTheme` with `colors.foreground`. Resolved via `theme.scaffold` and overridable per-instance with `MScaffoldStyleDelta`.

### Fixed
- README quickstart now compiles. It had called `MScaffold(body: ...)` since v0.1.0, but the widget was missing from the barrel.

## 0.1.0 (2026-05-14)

Initial release. Sixteen widgets, zero non-Flutter runtime dependencies, no `MaterialApp` requirement.

### Layout
- `MDivider`, `MScaffold`, `MCard`
- `MResizable`: drag-handled split with per-pane min/max clamps, keyboard nudge (arrow / shift+arrow / Home / End), modality-aware handle thickness, slider semantics

### Forms
- `MButton`, `MCheckbox`, `MSwitch`
- `MRadio` + `MRadioGroup` (shared-selection group)
- `MSlider`
- `MTextField`, `MDateField`, `MOTPField`
- `MSelect`
- `MLabel`

### Overlays
- `MTooltip`: non-modal anchored overlay
- `MPopover`: controller-aware anchored modal
- `MDialog`: root overlay via `PopupRoute`
- `MSheet`: edge-anchored root overlay via `PopupRoute`
- `MToast`: root overlay via direct `OverlayEntry`

### Navigation
- `MTabs`: persistent-state nav with a tab-bar header
- `MMenuBar`: persistent strip plus per-menu anchored popover
- `MContextMenu`: pointer-anchored popover with viewport-clamp positioning
- `MCommandPalette`: `PopupRoute`-pushed centered modal with typeahead filtering

### Feedback
- `MBadge`, `MAvatar`
- `MProgress` + `MCircularProgress`: determinate and indeterminate
- `MAccordion`: persistent vertical strip with per-item expand/collapse

### Foundation
- `MController<T>`: the state primitive every controller-aware widget uses
- `MThemeData`: 19-token shadcn color scheme, typography, focus ring, and a per-widget style table
- `MInputModality`: touch / mouse / keyboard / stylus, with scope and per-widget override
- `MOverlayAnchor`: shared anchor + overlay surface (used by `MPopover`, `MTooltip`, `MSelect`, `MDateField`, `MMenuBar`, `MContextMenu`)
- `MWidgetsApp`: opt-in root with `Navigator` + `Overlay` for callers who don't supply their own

See `DECISIONS.md` for the shape pin behind each widget.
