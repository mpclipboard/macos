import Cocoa

class MPClipboard {
    var handle: OpaquePointer?
    var store: OpaquePointer?
    var app: NSApplicationDelegate

    enum Event {
        case ConnectivityChanged(connected: Bool)
        case NewClip(clip: Clip)
    }

    init(app: NSApplicationDelegate) {
        mpclipboard_logger_init()
        mpclipboard_tls_init()

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

    func send(text: String) {
        text.withCString { cString in
            let ptr: UnsafePointer<UInt8> = UnsafeRawPointer(cString).assumingMemoryBound(to: UInt8.self)
            mpclipboard_handle_send(handle, ptr)
        }
    }

    func pollOnce() -> Array<Event> {
        var events: Array<Event> = []
        var output = mpclipboard_handle_poll(handle)

        if let clipPtr = output.clip {
            let clip = Clip(ptr: clipPtr)
            events.append(.NewClip(clip: clip))
        }

        if let connectivityPtr = output.connectivity {
            let connected = connectivityPtr.pointee == true
            events.append(.ConnectivityChanged(connected: connected))
            free(connectivityPtr)
        }

        return events
    }

    func startPolling(onEvent: @escaping (Event) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [self] _ in
            let events = pollOnce()
            for event in events {
                onEvent(event)
            }
        })
    }
}
