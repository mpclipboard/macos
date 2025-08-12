import Cocoa

class Tray {
    var redImage: NSImage? = NSImage(named: "red")
    var greenImage: NSImage? = NSImage(named: "green")

    var statusItem: NSStatusItem
    var trayButton: NSStatusBarButton?

    static let MAX_ITEMS_COUNT: Int = 4 // 3 clips + Quit
    static let SENT: String = "S"
    static let RECEIVED: String = "R"

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = redImage
            trayButton = button
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    func setConnected() {
        trayButton?.image = greenImage
    }

    func setDisconnected() {
        trayButton?.image = redImage
    }

    enum ItemKind {
        case Sent
        case Received
    }

    func pushSent(text: String) {
        push(kind: Tray.SENT, text: text)
    }

    func pushReceived(text: String) {
        push(kind: Tray.RECEIVED, text: text)
    }

    func push(kind: String, text: String) {
        guard let menu = statusItem.menu else {
            return;
        }
        while menu.items.count > Tray.MAX_ITEMS_COUNT {
            menu.items.remove(at: Tray.MAX_ITEMS_COUNT - 1)
        }

        let item = NSMenuItem(title: "\(kind) \(text)", action: nil, keyEquivalent: "");
        item.isEnabled = false
        menu.insertItem(item, at: 0)
    }
}
