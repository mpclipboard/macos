import Cocoa

class Clip {
    var ptr: OpaquePointer!

    init(ptr: OpaquePointer!) {
        self.ptr = ptr
    }

    deinit {
        mpclipboard_clip_drop(ptr)
        free(UnsafeMutableRawPointer(ptr))
    }

    func getText() -> String {
        let textPtr = mpclipboard_clip_get_text(ptr)!
        let text = String(cString: textPtr)
        free(textPtr)
        return text
    }
}
