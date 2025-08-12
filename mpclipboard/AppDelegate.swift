import Cocoa
import Carbon
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var mpclipboard: MPClipboard?
    var mpclipboardTimer: Timer?

    var clipboard: Clipboard = Clipboard()
    var clipboardTimer: Timer?

    var store: Store = Store()

    var tray: Tray = Tray()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Hide Dock icon
        NSApp.setActivationPolicy(.accessory)

        mpclipboard = MPClipboard(app: self)
        mpclipboardTimer = mpclipboard?.startPolling(onEvent: { [self] event in
            switch event {
            case let .ConnectivityChanged(connected):
                connected ? tray.setConnected() : tray.setDisconnected()
            case let .NewClip(clip):
                if store.add(clip: clip) {
                    let text = clip.getText()
                    clipboard.writeText(text: text)
                    tray.pushReceived(text: text)
                }
            }
        })

        clipboardTimer = clipboard.startPolling(onCopy: { [self] text in
            if store.add(text: text) {
                mpclipboard?.send(text: text)
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
