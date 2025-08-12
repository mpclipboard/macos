import Cocoa

class Clipboard {
    var pasteboard: NSPasteboard = NSPasteboard.general
    var lastChangeCount: Int

    init() {
        lastChangeCount = pasteboard.changeCount
    }

    func pollOnce() -> String? {
        let newChangeCount = pasteboard.changeCount
        if newChangeCount == lastChangeCount {
            return nil
        }
        lastChangeCount = newChangeCount
        guard let copiedText = pasteboard.string(forType: .string) else {
            return nil
        }
        return copiedText
    }

    func startPolling(onCopy: @escaping (String) -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            if let copiedText = pollOnce() {
                onCopy(copiedText)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }

    func writeText(text: String) {
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }
}
