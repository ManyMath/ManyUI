# manyui

manyui provides Flutter widgets and themes for web, mobile (iOS/Android),
and desktop (macOS/Windows/Linux). It works without `MaterialApp` or
`CupertinoApp`.

## Goals

- Keep dependencies in the core package to a minimum.
- Use your own app widget or the included `MWidgetsApp`.
- Use system fonts by default, with optional fonts in `manyui_assets`.
- Adapt interactions for touch, mouse, keyboard, and stylus input.
- Support keyboard navigation, visible focus, and screen readers.

## Status

Under development. The repository includes the widget library, optional
integrations, and an [example gallery](example/README.md) you can run locally.

## License

MIT. See [LICENSE](./LICENSE).

## Private font-license validation

`manyui_assets` preserves upstream font notices and declares them as Flutter
assets. After workspace `dart pub get`, run
`python3 tool/verify_font_payload.py --output /tmp/new-manyui-font-check` to verify
an actual pub-selected archive and a fresh consumer's asset bundle. The output
path must be new; no package is published. Evidence records source revision,
dirty state and exact archive/font/license hashes. Python 3.12+ and provisioned
Flutter/Dart are required.

Private Gitea CI retains analysis, four implemented package test suites, and eight
publication dry-runs. Analysis, publication archives, and font payload checks use
provisioned Flutter 3.47.2 / Dart 3.13.2. Behavior tests and a separate golden
comparison use official-checksum-verified Flutter 3.41.0 / Dart 3.11.0 matching
`.fvmrc`. The original primary baseline and font candidate both produced **705
passing and 138 failing tests** in their full original-SDK suites on the Linux
maintenance host; the failed names and all 136 fresh failure PNG hashes matched.
Two newer-SDK artifacts were excluded from that comparison. The failures include
Ahem text rasterization differences. No expected images or matchers were changed.

The required behavior lane excludes the existing `golden` tag. The separate
`golden-baseline-diagnostic` runs fresh golden-only suites from immutable baseline
`e1dd57073d9fef27e2166d399e9b929b4f72da8b` and committed candidate HEAD. It compares
exit status, test counts, failed names, and fresh failure PNG hashes, rejecting
aborted/empty runs or any differences (including improvements requiring review).
Matching failures print **KNOWN_BASELINE_FAILURE**; a successful comparison does
**not** mean goldens pass. Owner rendering qualification remains pending. Logs,
actual exits, and hashes are retained in the printed private evidence directory.

`manyui_board` has only an empty library declaration and no test directory: its
analyzer/archive checks remain, without a runtime test claim. CI uses provisioned
SDKs and does not install them or change shared defaults. The existing Flutter
3.38 floor lane is explicit manual validation on a separately provisioned
`manymath-flutter-3-38` runner; it remains pending until that runner exists and is
not counted as a passing floor check. GitHub publication remains an owner action.

This metadata-only follow-up preserves the current primary documentation commit
and does not change any product consumer's existing public `88ad861` pin.
The owner must mirror and verify a future revision before consumers adopt these
additional notices; no new public pin is assumed here.
