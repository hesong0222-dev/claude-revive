#!/bin/bash
# app/main.swift 를 "Claude Revive.app" 으로 만든다. 사용: app/build.sh <출력 경로>
set -e
src=$(cd "$(dirname "$0")" && pwd)
out="$1"
rm -rf "$out"; mkdir -p "$out/Contents/MacOS"
swiftc -O "$src/main.swift" -o "$out/Contents/MacOS/claude-revive"
cat > "$out/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>dev.claude-revive</string>
  <key>CFBundleName</key><string>Claude Revive</string>
  <key>CFBundleExecutable</key><string>claude-revive</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign -s - --force "$out" >/dev/null 2>&1
