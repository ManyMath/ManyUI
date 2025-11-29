# manyui example

Runnable gallery of every widget the `manyui` library ships at v0.1.1.

```sh
flutter run -d chrome     # web
flutter run                # desktop / mobile, whichever device is selected
```

A single `MWidgetsApp` containing an `MScaffold`. The header carries the title
and a light/dark toggle. The body splits a sidebar of family pages from a
content area: Layout, Forms, Overlays, Navigation, Feedback. Each page renders
every widget in its family in at least two states.

No `MaterialApp` anywhere. That's the point.
