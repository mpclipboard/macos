import Cocoa
import Carbon
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var settingsWindow: NSWindow!
    var monitor: Any?

    var clipboardTimer: Timer?
    var lastChangeCount: Int = NSPasteboard.general.changeCount
    var pollingTimer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Hide Dock icon
        NSApp.setActivationPolicy(.accessory)

        buildMenu()
        startClipboardPolling()
    
        shared_clipboard_setup();
        let config = shared_clipboard_config_read_from_xdg_cofig_dir();
        shared_clipboard_start_thread(config)

        startSharedClipboardThreadPolling()
    }

    func buildMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Keyboard Monitor")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    func startClipboardPolling() {
        clipboardTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let pasteboard = NSPasteboard.general
            if pasteboard.changeCount != self.lastChangeCount {
                self.lastChangeCount = pasteboard.changeCount
                if let copiedText = pasteboard.string(forType: .string) {
                    copiedText.withCString { cString in
                        let ptr: UnsafePointer<UInt8> = UnsafeRawPointer(cString).assumingMemoryBound(to: UInt8.self);
                        shared_clipboard_send(ptr);
                    };
                    print("Copied: \(copiedText)")
                }
            }
        }

        RunLoop.main.add(clipboardTimer!, forMode: .common)
    }

    func startSharedClipboardThreadPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            let output = shared_clipboard_poll();
            if let connectivityPtr = output.connectivity {
                let connectivity = connectivityPtr.pointee == true;
                free(connectivityPtr);
                print("Connectivity: \(connectivity)");
            }
            if let textPtr = output.text {
                let text = String(cString: output.text);
                free(output.text);
                print("Text: \(text)");
            }
        })
    }
}
