arm64only := "ARCHS=arm64 ONLY_ACTIVE_ARCH=yes"

build configuration lib:
    xcodebuild OTHER_LDFLAGS="{{lib}}" -configuration {{configuration}} {{arm64only}}
run configuration:
    ./build/{{configuration}}/SharedClipboardClient.app/Contents/MacOS/SharedClipboardClient

build-debug lib:
    @just build Debug "{{lib}}"
run-debug:
    @just run Debug

build-release lib:
    @just build Release "{{lib}}"
run-release:
    @just run Release

generic_gh_repo_url := "https://github.com/iliabylich/shared-clipboard-client-generic"
base_release_url := generic_gh_repo_url + "/releases/download/aarch64-apple-darwin-latest"

ci-build:
    wget -q "{{base_release_url}}/libshared_clipboard_client_generic.a" -O libshared_clipboard_client_generic.a
    @just build-release "$PWD/libshared_clipboard_client_generic.a"
    cd build/Release && zip -r SharedClipboardClient.app.zip SharedClipboardClient.app
    mv build/Release/SharedClipboardClient.app.zip .

sync-header:
    wget -q "https://raw.githubusercontent.com/iliabylich/shared-clipboard-client-generic/refs/heads/master/shared-clipboard-client-generic.h" -O SharedClipboardClient/shared-clipboard-client-generic.h
