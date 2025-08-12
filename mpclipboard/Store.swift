class Store {
    var store: OpaquePointer

    init() {
        store = mpclipboard_store_new()!
    }

    func drop() {
        mpclipboard_store_drop(store)
    }

    func add(text: String) -> Bool {
        text.withCString { cString in
            mpclipboard_store_add_text(store, cString)
        }
    }

    func add(clip: Clip) -> Bool {
        mpclipboard_store_add_clip(store, clip.ptr)
    }
}
