import Cocoa
import FlutterMacOS

/// Janela do MainMenu.xib; fica oculta (visibleAtLaunch="NO"). Ao carregar,
/// cria o KeyboardPanel, porque um NSPanel só deixa de roubar o foco se for
/// criado já com o estilo .nonactivatingPanel.
class MainFlutterWindow: NSWindow {
  private static var panel: KeyboardPanel?

  override func awakeFromNib() {
    super.awakeFromNib()

    let controller = FlutterViewController()
    let panel = KeyboardPanel(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 460),
      styleMask: [.titled, .closable, .miniaturizable, .nonactivatingPanel],
      backing: .buffered,
      defer: false)
    panel.title = "Teclado Taiwanês"
    panel.contentViewController = controller
    panel.setContentSize(NSSize(width: 400, height: 460))
    panel.level = .floating
    panel.isFloatingPanel = true
    panel.becomesKeyOnlyIfNeeded = true
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    panel.center()

    RegisterGeneratedPlugins(registry: controller)
    PojChannel.register(messenger: controller.engine.binaryMessenger)

    panel.orderFrontRegardless()
    MainFlutterWindow.panel = panel
  }
}
