# Contributing to manyui

Thanks for your interest in contributing. This covers code style, testing expectations, and how commits are organized.

## Toolchain setup

manyui pins a single Flutter version so golden tests are pixel-stable across machines and CI. The pinned version is in `.fvmrc` (and mirrored in `.flutter-version` for tools that read that filename).

The recommended setup uses [FVM](https://fvm.app):

```sh
# Install fvm once.
dart pub global activate fvm

# From the repo root, install and select the pinned version.
fvm install
fvm use

# Prefix Flutter commands with fvm, or add the shim to your PATH:
fvm flutter test
```

If you would rather not use FVM, install the exact version from `.fvmrc` through any other channel. Goldens generated against a different Flutter version will diverge from CI and will not be accepted.

The `floor_check` CI job runs against the supported SDK floor (currently 3.38.x). It does not run golden tests, so the version difference there is intentional.

## Code style

manyui uses Dart 3 idioms throughout.

- **Use records, patterns, sealed classes, and switch expressions.** Avoid older equivalents when a Dart 3 form is clearer.
- **No `dynamic`** except at clearly-marked boundaries (e.g., decoding untyped JSON). Mark those boundaries with a comment.
- **No `late`** unless genuinely needed. Prefer `?` and explicit null checks.
- **Public APIs are documented** with `///` doc comments. Each public class or top-level function includes at least one example.
- **Prefer composition over inheritance.** Never extend a widget class from another widget class in this library.
- **Widget files include their golden test list as a comment** so reviewers can verify coverage at a glance.

## Tests

Every PR that adds or changes a widget must include:

- **Behavior tests** for taps, keyboard navigation, focus order, and semantics. Interactive widgets are tested across all four input modalities (`touch`, `mouse`, `keyboard`, `stylus`).
- **Golden tests** for every styled widget in light and dark mode, on the three reference viewports: 360x800 (phone), 1024x768 (tablet), 1440x900 (desktop).

Use `pumpManyApp` from `manyui_testing` to set up the test harness. It takes `theme`, `viewport`, and `modality` parameters so each test is one readable line.

Run these locally before pushing:

```sh
flutter analyze
flutter test
dart pub publish --dry-run
```

CI runs the same steps on every package.

## Commits

- Use Conventional Commits prefixes (`feat`, `fix`, `docs`, `test`, `build`, `ci`, `refactor`, `chore`) with a widget-scoped subject: `feat(button): add destructive variant`.
- One logical change per commit. If a description needs the word "and," consider splitting it.
- Leave the tree green at every commit. Tests pass at each step, not just at the end of a PR.

## License

By submitting a PR, you agree your contribution is licensed under MIT (or MPL-2.0 for `manyui_board` files), matching the file you are modifying.
