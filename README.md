# macOS client

A simple client that:

1. implements communication over WebSocket using [`generic-client`](https://github.com/mpclipboard/generic-client) and FFI
2. integrates with macOS clipboard to read/write clipboard text
3. shows a tray icon with last 5 clips
4. shows a system notification every time a new text is received

### Building

```sh
# Downloads header and pre-compiled static library (both can be built manually)
just sync

just build Release # or Debug
```

The app will be in `build/Release/mpclipboard.app` (or `build/Debug/mpclipboard.app`).

### Other notes

1. Debug build of the app always reads local config file from `config.toml`, Release build always reads from `$HOME/.config/mpclipboard/config.toml`.
2. The app is not signed, so you need to manually approve running it locally (or take the binary manually out of the quarantine).
3. There's no API in macOS to subscribe to clipboard changes, so we poll it manually every 0.1s. If you know a better way to track clipboard updates please open an issue.
