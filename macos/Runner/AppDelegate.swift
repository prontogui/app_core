import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    private var menuChannel: FlutterMethodChannel?

    override func applicationDidFinishLaunching(_ notification: Notification) {
        // Get the FlutterViewController from the main window.
        guard
            let window = NSApplication.shared.windows.first,
            let controller = window.contentViewController as? FlutterViewController
        else { return }

        registerEngineForMenu(controller)
    }

    /// Makes [controller]'s engine eligible to own the shared native
    /// menu channel: listens for that engine to claim itself as the
    /// menu target and rebinds `menuChannel` to it when it does.
    ///
    /// The primary engine isn't always the instance window — at first
    /// launch it's the EULA gate window instead, and the real instance
    /// window only comes up afterward in a separate engine (see
    /// `StartupSequence`/`main.dart`). Binding `menuChannel` once,
    /// statically, to whichever window happened to exist at
    /// `applicationDidFinishLaunching` would wire native menu clicks to
    /// an engine that never listens for them. Only the engine that runs
    /// `runInstanceWindowApp` (`instance_window_app.dart`'s
    /// `_menuHandler`) ever claims — gate/global-window engines (EULA,
    /// About, Settings, ...) never do — so this call must be made once
    /// for the primary window here, and once per secondary window from
    /// `MainFlutterWindow`'s window-created callback.
    func registerEngineForMenu(_ controller: FlutterViewController) {
        let registrationChannel = FlutterMethodChannel(
            name: "com.prontogui.core/menu_registration",
            binaryMessenger: controller.engine.binaryMessenger
        )
        registrationChannel.setMethodCallHandler { [weak self] call, result in
            guard call.method == "claimTarget" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.menuChannel = FlutterMethodChannel(
                name: "com.prontogui.core/menu",
                binaryMessenger: controller.engine.binaryMessenger
            )
            result(nil)
        }
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction func about(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.about", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

    @IBAction func settings(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.settings", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

    @IBAction func showLog(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.showLog", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

    @IBAction func developmentDocumentation(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.developerDocumentation", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

    @IBAction func releaseNotes(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.releaseNotes", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

    @IBAction func provideFeedback(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.provideFeedback", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

    @IBAction func newWindow(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.newWindow", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

    @IBAction func configureWindow(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.configureWindow", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

    @IBAction func closeWindow(_ sender: NSMenuItem) {
        menuChannel?.invokeMethod("menu.closeWindow", arguments: [
            "title": sender.title,
            "tag": sender.tag
        ])
    }

}
