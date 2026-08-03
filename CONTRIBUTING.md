# Contributing to app_core

Thanks for your interest in contributing to `app_core`, the free and
open-source core of [ProntoGUI](https://prontogui.com).

## Scope of this repo

`app_core` is licensed as a free product: a desktop renderer supporting multiple
instance windows plus the full set of global windows (About, Settings,
Event Log, EULA, Licensing Credits).

Pull requests that add license-gating logic or otherwise blur this boundary
will be asked to be reworked or closed. If you're unsure whether something
belongs here, open an issue first and ask.

## Getting set up

```bash
flutter pub get
flutter run
```

This package depends on [`dartlib`](https://github.com/prontogui/dartlib)
for primitive definitions, CBOR parsing, and gRPC communication. During
development you can point at a local checkout via a path override in
`pubspec_overrides.yaml`:

```yaml
dependency_overrides:
  dartlib:
    path: ../dartlib
```

## Making changes

- Run `flutter analyze` and `flutter test` before opening a PR. Both must
  pass cleanly.
- Add or update tests alongside any behavioral change. Test files mirror the
  `lib/` structure under `test/` (e.g. `lib/src/embodiment/foo.dart` →
  `test/src/embodiment/foo_test.dart`).
- Match the style of surrounding code rather than introducing new patterns.
  If you're adding a new primitive embodiment, follow the steps in the
  README's "Adding a new primitive embodiment" section.
- Keep PRs focused. Unrelated formatting or refactors mixed into a
  functional change make review harder — split them out.

## Commit messages and PRs

- Write commit messages that explain *why*, not just *what*.
- Describe what you tested in the PR description (e.g. platforms run on,
  `flutter test` output).
- Link any related issue.

## Reporting bugs / requesting features

Open a GitHub issue with:

- What you expected to happen vs. what happened.
- Steps to reproduce, including platform (macOS/Windows/Linux) and Flutter
  version (`flutter --version`).
- Relevant logs or screenshots, if applicable.

## License

By contributing, you agree that your contributions will be licensed under
the project's [BSD 3-Clause License](LICENSE).
