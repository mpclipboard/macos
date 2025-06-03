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
base_release_url := generic_gh_repo_url + "/releases/download/latest"
download-artifact filename out:
    wget -q "{{base_release_url}}/{{filename}}" -O {{out}}

ci-build:
    rm -f aarch64-apple-darwin.tar.gz
    @just download-artifact aarch64-apple-darwin.tar.gz aarch64-apple-darwin.tar.gz
    rm -rf shared-clipboard-generic-client
    tar xvzf aarch64-apple-darwin.tar.gz

    @just build-release shared-clipboard-generic-client/libshared_clipboard_client_generic.a

    cd build/Release && zip -r SharedClipboardClient.app.zip SharedClipboardClient.app
    mv build/Release/SharedClipboardClient.app.zip .

sync-header:
    @just download-artifact shared-clipboard-client-generic.h SharedClipboardClient/shared-clipboard-client-generic.h
