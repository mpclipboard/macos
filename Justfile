sync:
    rm -f mpclipboard/mpclipboard-generic-client.h
    @just download mpclipboard-generic-client.h mpclipboard/mpclipboard-generic-client.h

    rm -f aarch64-apple-darwin.tar.gz
    @just download aarch64-apple-darwin.tar.gz aarch64-apple-darwin.tar.gz
    rm -rf mpclipboard-generic-client
    tar xvzf aarch64-apple-darwin.tar.gz

# configuration is either "Debug" or "Release"
build configuration:
    xcodebuild -configuration {{configuration}}
run configuration:
    ./build/{{configuration}}/mpclipboard.app/Contents/MacOS/mpclipboard

gh_repo_url := "https://github.com/mpclipboard/generic-client"
download filename out:
    wget -q "{{gh_repo_url}}/releases/download/v0.1.0/{{filename}}" -O {{out}}

ci-build:
    @just sync
    @just build Release

    cd build/Release && zip -r mpclipboard.app.zip mpclipboard.app
    mv build/Release/mpclipboard.app.zip .

clean:
    rm -rf build
    rm -f mpclipboard/mpclipboard-generic-client.h
    rm -rf aarch64-apple-darwin.tar.gz mpclipboard-generic-client
    rm -f mpclipboard.app.zip
