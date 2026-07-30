// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

// Public API surface for apps that build on top of this package — most
// notably the proprietary `app` repo, which adds multi-instance-window
// support and licensing. See CLAUDE.md for the scope boundary between
// this package and that one.

// Rendering pipeline
export 'src/embodifier.dart' show Embodifier, InheritedEmbodifier;
export 'src/inherited_primitive_model.dart'
    show
        PrimitiveModelChangeNotifier,
        InheritedPrimitiveModel,
        InheritedTopLevelPrimitives;
export 'src/inherited_comm.dart';
export 'src/ui_builder_synchro.dart' show UIBuilderSynchro;
export 'src/ui_event_synchro.dart' show UIEventSynchro;
export 'src/top_level_coordinator.dart';
export 'src/background_view.dart';
export 'src/waiting_for_server_view.dart';

// App shell
export 'src/app.dart' show App;
export 'src/app_settings.dart' show AppSettings;
export 'src/debug_config.dart' show DebugConfig;
export 'src/cmd_line_options.dart' show CmdLineOptions;
export 'src/machine_id.dart';
export 'src/json_help.dart';
export 'src/widgets/lic_key_field.dart';

// Global windows
export 'src/global_windows.dart';
export 'src/about_view.dart';
export 'src/settings_view.dart';
export 'src/eula_view.dart';
export 'src/eula_acceptance.dart' show EulaAcceptance, EulaAcceptanceStorage;
export 'src/event_log_viewer.dart';
export 'src/licensing_credits_view.dart';

// Window management (multi-engine instance + global windows)
export 'src/window/window_management.dart';
export 'src/window/window_menu_bar.dart';

// Startup sequencing
export 'src/startup/startup_gate.dart';
export 'src/startup/startup_sequence.dart';
export 'src/startup/debug_startup.dart';
export 'src/startup/logging_setup.dart';
export 'src/startup/global_window_dispatcher.dart' show tryRunGlobalWindow;
export 'src/startup/instance_window_app.dart' show runInstanceWindowApp;

// Storage
export 'src/storage/kv_store.dart' show KvStore;
