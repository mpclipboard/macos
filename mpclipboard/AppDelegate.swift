import Cocoa
import Carbon
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var mpclipboard: MPClipboard?
    var mpclipboardTimer: Timer?

    var clipboard: Clipboard = Clipboard()
    var clipboardTimer: Timer?

    var tray: Tray = Tray()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Hide Dock icon
        NSApp.setActivationPolicy(.accessory)

        mpclipboard = MPClipboard(app: self)
        mpclipboardTimer = mpclipboard?.startPolling(onEvent: { [self] (text, connected) in
            if let connected = connected {
                connected ? tray.setConnected() : tray.setDisconnected()
            }
            if let text = text {
                clipboard.writeText(text: text)
                tray.pushReceived(text: text)
            }
        })

        clipboardTimer = clipboard.startPolling(onCopy: { [self] text in
            guard let mpclipboard = mpclipboard else {
                return
            }
            if mpclipboard.send(text: text) {
                tray.pushSent(text: text)
            }
        })
    }

    @objc
    func quit() {
        print("Quitting...")
        self.clipboardTimer?.invalidate()
        self.mpclipboardTimer?.invalidate()
        self.mpclipboard?.stop()
        NSApp.terminate(self)
    }
}
