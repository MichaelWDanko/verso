#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release
bin_dir="$(swift build -c release --show-bin-path)"
app="dist/Verso.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin_dir/Verso" "$app/Contents/MacOS/Verso"
cp Resources/Verso.icns "$app/Contents/Resources/Verso.icns"
cp Resources/Info.plist "$app/Contents/Info.plist"
codesign --force --sign - "$app"
printf 'Built %s/dist/Verso.app\n' "$PWD"
