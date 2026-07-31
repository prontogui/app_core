import Cocoa
import FlutterMacOS
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.tabbingMode = .disallowed

    RegisterGeneratedPlugins(registry: flutterViewController)

    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      // Register the plugin which you want access from other isolate.
      RegisterGeneratedPlugins(registry: controller)
      // Let this window's engine claim the native menu if it turns out
      // to be the instance window — see AppDelegate.registerEngineForMenu.
      (NSApp.delegate as? AppDelegate)?.registerEngineForMenu(controller)
    }

    super.awakeFromNib()
  }
}
