import Cocoa
import FlutterMacOS

/// Janela do MainMenu.xib; fica oculta (visibleAtLaunch="NO"). Ao carregar,
/// cria o KeyboardPanel, porque um NSPanel só deixa de roubar o foco se for
/// criado já com o estilo .nonactivatingPanel.
class MainFlutterWindow: NSWindow {
  static var panel: KeyboardPanel?

  override func awakeFromNib() {
    super.awakeFromNib()

    let controller = FlutterViewController()
    // O painel quase nunca é a janela-chave; sem isso não há hover nem tooltip.
    controller.mouseTrackingMode = .always
    let panel = KeyboardPanel(
      contentRect: NSRect(x: 0, y: 0, width: 448, height: 108),
      styleMask: [.titled, .closable, .miniaturizable, .nonactivatingPanel],
      backing: .buffered,
      defer: false)
    panel.title = "Teclado Taiwanês"
    panel.contentViewController = controller
    panel.setContentSize(NSSize(width: 448, height: 108))
    panel.level = .floating
    panel.isFloatingPanel = true
    panel.becomesKeyOnlyIfNeeded = true
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    panel.center()
    panel.delegate = PanelDelegate.shared

    RegisterGeneratedPlugins(registry: controller)
    PojChannel.register(messenger: controller.engine.binaryMessenger)

    panel.orderFrontRegardless()
    MainFlutterWindow.panel = panel
  }
}

/// Fechar o painel encerra o app (ele não conta como "última janela").
final class PanelDelegate: NSObject, NSWindowDelegate {
  static let shared = PanelDelegate()

  func windowWillClose(_ notification: Notification) {
    NSApp.terminate(nil)
  }
}
