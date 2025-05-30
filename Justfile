arm64only := "ARCHS=arm64 ONLY_ACTIVE_ARCH=yes"

build configuration lib:
    xcodebuild OTHER_LDFLAGS="{{lib}}" -configuration {{configuration}} {{arm64only}}
run configuration:
    ~/Desktop/SharedClipboardClient/build/{{configuration}}/SharedClipboardClient.app/Contents/MacOS/SharedClipboardClient

build-debug lib:
    @just build Debug "{{lib}}"
run-debug:
    @just run Debug

build-release lib:
    @just build Release "{{lib}}"
run-release:
    @just run Release
