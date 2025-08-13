import Cocoa

class MPClipboard {
    var handle: OpaquePointer?
    var store: OpaquePointer?
    var app: NSApplicationDelegate

    init(app: NSApplicationDelegate) {
        mpclipboard_init()

#if DEBUG
        print("Debug build, using local config")
        var option = MPCLIPBOARD_CONFIG_READ_OPTION_T_FROM_LOCAL_FILE
#else
        print("Release build, using config from XDG dir")
        var option = MPCLIPBOARD_CONFIG_READ_OPTION_T_FROM_XDG_CONFIG_DIR
#endif

        self.app = app

        guard let config = mpclipboard_config_read(option) else {
            fputs("NULL config", stderr)
            NSApp.terminate(app)
            return
        }

        guard let handle = mpclipboard_thread_start(config) else {
            fputs("NULL handle", stderr)
            NSApp.terminate(app)
            return
        }
        self.handle = handle
    }

    func stop() {
        mpclipboard_handle_stop(handle)
    }

    func send(text: String) -> Bool {
        text.withCString { cString in
            let ptr: UnsafePointer<UInt8> = UnsafeRawPointer(cString).assumingMemoryBound(to: UInt8.self)
            return mpclipboard_handle_send(handle, ptr)
        }
    }

    func pollOnce() -> (String?, Bool?) {
        var output = mpclipboard_handle_poll(handle)
        var text: String? = nil
        var connected: Bool? = nil

        if let textPtr = output.text {
            text = String(cString: textPtr)
            free(textPtr)
        }

        if let connectivityPtr = output.connectivity {
            connected = connectivityPtr.pointee == true
            free(connectivityPtr)
        }

        return (text, connected)
    }

    func startPolling(onEvent: @escaping ((String?, Bool?)) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [self] _ in
            let polled = pollOnce()
            onEvent(polled)
        })
    }
}
