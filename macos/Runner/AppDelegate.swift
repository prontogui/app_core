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

        // Create a channel you’ll use to notify Dart about menu selections.
        menuChannel = FlutterMethodChannel(
            name: "com.prontogui.core/menu",
            binaryMessenger: controller.engine.binaryMessenger
        )
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
