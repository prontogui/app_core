# app_core

The free, open-source core of [ProntoGUI](https://prontogui.com) — a Flutter
desktop application that connects to a ProntoGUI server, receives CBOR-encoded
primitive updates, and renders them through an "embodiment" system.

This app is free to use, for both end users of ProntoGUI-based solutions and
the developers building them. It supports multiple simultaneous instance
windows plus the full set of global windows (About, Settings, Event Log,
EULA, Licensing Credits).

## Relationship to other ProntoGUI repos

- [`dartlib`](https://github.com/prontogui/dartlib) — primitive definitions,
  CBOR parsing, and gRPC communication. This package's core dependency.

## Running

```bash
flutter pub get
flutter run
```

## Common commands

```bash
flutter test              # run all tests
flutter analyze           # static analysis
```

## Adding a new primitive embodiment

1. Create `lib/src/embodiment/<primitive>_embodiment.dart`, following the
   pattern of an existing embodiment file: export a `getManifest()` function
   returning an `EmbodimentPackageManifest`, define the widget(s) that render
   the primitive, and specify property accessors for configuration.
2. Create the matching test file at
   `test/src/embodiment/<primitive>_embodiment_test.dart`.
3. Register the manifest in
   `lib/src/embodiment/embodiment_factory.dart`'s `collectManifests()` method.

## License

BSD 3-Clause. See [LICENSE](LICENSE).

---
##### Copyright 2026 ProntoGUI, LLC
##### ProntoGUI™ is a trademark of ProntoGUI, LLC
