#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
mkdir -p build
echo "==> Importing project..."
godot --headless --path . --import || true
echo "==> Exporting Android debug APK..."
godot --headless --path . --export-debug "Android" build/static-garden-debug.apk
echo "APK ready: build/static-garden-debug.apk"
ls -lh build/static-garden-debug.apk
