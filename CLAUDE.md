# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the free, open-source (BSD-3-Clause) core of the ProntoGUI Flutter application. It connects to a remote server via gRPC, receives CBOR-encoded primitive updates, and renders them as Flutter widgets through an "embodiment" system.

It is a real, independently runnable and distributable desktop app — not just a library — and is the literal free/evaluation product. A separate, proprietary repo (`app`) depends on this package via a git dependency (the same way this package depends on `dartlib`) and adds multi-instance-window support plus licensing.

## Scope boundary with the proprietary `app` repo

- This repo: single **instance** window (the document-style window a user works in) but full **global** window support — About, Settings, Event Log, EULA, Licensing Credits — each opened via `desktop_multi_window`/`window_manager` in its own Flutter engine, same mechanism as any multi-window desktop Flutter app.
- The instance-window count is capped at 1 here. `app` raises that cap and adds a "New Window" menu affordance.
- `licensing.dart`-equivalent code (license activation/validation/enforcement, LemonSqueezy integration) does **not** live here — it's proprietary and lives only in `app`. Do not add license-gating logic to this repo.
- `about_view.dart`'s `AboutInfo` and similar widgets are parameterized so `app` can supply license-aware fields (expiration, manage-license link) without this repo needing to know what a license is.

## Common Commands

```bash
# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze code for issues
flutter analyze

# Get dependencies (uses local dartlib at ../dartlib during development)
flutter pub get
```

## Architecture

### Core Data Flow

1. **Server Communication**: `GrpcCommClient` (from dartlib) connects to a ProntoGUI server and receives CBOR updates
2. **Model Layer**: `PrimitiveModel` (from dartlib) stores primitives and notifies watchers of changes
3. **Embodification**: `Embodifier` converts primitives to Flutter widgets via `EmbodimentFactory`
4. **Event Sync**: `UIEventSynchro` sends UI events (clicks, text entries) back to the server

### Key Components

- **`lib/main.dart`**: Entry point. Sets up model, gRPC client, embodifier, event synchronization, and the global-window dispatch chain, exactly like the proprietary app's entry point minus the licensing-specific startup steps.
- **`lib/src/embodifier.dart`**: Central coordinator that builds widgets from primitives and manages notification points for UI updates
- **`lib/src/embodiment/`**: Contains embodiment implementations for each primitive type (command, text, check, list, table, etc.)
- **`lib/src/embodiment/embodiment_factory.dart`**: Maps primitive types to their embodiment implementations using a manifest system
- **`lib/src/window/`**: Multi-engine window management (`WindowManagement`, `WindowSettings`, cross-engine messaging) — shared infrastructure for both instance and global windows
- **`lib/src/startup/`**: Per-engine startup dispatch (global window vs. instance window), pre-flight gates (EULA)

### Inherited Widgets Pattern

- `InheritedPrimitiveModel`: Access to the primitive model
- `InheritedEmbodifier`: Access to the embodifier
- `InheritedCommClient`: Access to server connection state

## Adding a New Primitive

See the README's "Adding a new primitive embodiment" section.

## Dependencies

- **dartlib**: primitive definitions, CBOR parsing, and gRPC communication (git dependency; local sibling path override available for development)
- Uses Material 3 design system
