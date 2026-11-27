#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
GODOT_BIN="${GODOT_BIN:-godot}"
if ! command -v "$GODOT_BIN" >/dev/null; then
  GODOT_BIN="$HOME/godot/godot"
fi
command -v "$GODOT_BIN" >/dev/null || { echo "Godot missing; run bash scripts/setup-codespace.sh" >&2; exit 1; }
[[ "$("$GODOT_BIN" --version)" == 4.2.2.* ]] || { echo "Godot 4.2.2 required" >&2; exit 1; }
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/android-sdk}}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")}"
export GODOT_ANDROID_KEYSTORE_DEBUG_PATH="${GODOT_ANDROID_KEYSTORE_DEBUG_PATH:-$HOME/.android/debug.keystore}"
export GODOT_ANDROID_KEYSTORE_DEBUG_USER="${GODOT_ANDROID_KEYSTORE_DEBUG_USER:-androiddebugkey}"
export GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD="${GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD:-android}"
[[ -d "$ANDROID_HOME" && -x "$JAVA_HOME/bin/java" && -f "$GODOT_ANDROID_KEYSTORE_DEBUG_PATH" ]] || {
  echo "Android SDK, JDK or debug keystore missing; run bash scripts/setup-codespace.sh" >&2; exit 1;
}
mkdir -p build
# Use isolated editor settings, leaving personal Godot settings untouched.
config_dir="$(mktemp -d)"
trap 'rm -rf "$config_dir"; rm -f build/.static-garden-debug.tmp.apk' EXIT
export XDG_CONFIG_HOME="$config_dir"
mkdir -p "$XDG_CONFIG_HOME/godot"
python3 - <<'PY'
import json, os
from pathlib import Path
p = Path(os.environ["XDG_CONFIG_HOME"]) / "godot/editor_settings-4.2.tres"
settings = {
    "export/android/android_sdk_path": os.environ["ANDROID_HOME"],
    "export/android/java_sdk_path": os.environ["JAVA_HOME"],
    "export/android/debug_keystore": os.environ["GODOT_ANDROID_KEYSTORE_DEBUG_PATH"],
    "export/android/debug_keystore_user": os.environ["GODOT_ANDROID_KEYSTORE_DEBUG_USER"],
    "export/android/debug_keystore_pass": os.environ["GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD"],
}
p.write_text('[gd_resource type="EditorSettings" format=3]\n\n[resource]\n' +
             ''.join(f'{key} = {json.dumps(value)}\n' for key, value in settings.items()))
PY
run_checked() {
  local log="$1"; shift
  "$@" 2>&1 | tee "$log"
  if grep -Eq '^(SCRIPT ERROR:|ERROR:)' "$log"; then
    echo "Godot reported an error; see $log" >&2
    return 1
  fi
}
rm -f build/static-garden-debug.apk build/.static-garden-debug.tmp.apk
run_checked build/import.log "$GODOT_BIN" --headless --path . --import
run_checked build/smoke.log env XDG_DATA_HOME="$config_dir/runtime-data" "$GODOT_BIN" --headless --path . --quit-after 5
run_checked build/gameplay.log env XDG_DATA_HOME="$config_dir/test-data" "$GODOT_BIN" --headless --path . res://tests/gameplay.tscn
run_checked build/export.log "$GODOT_BIN" --headless --path . --export-debug Android build/.static-garden-debug.tmp.apk
test -s build/.static-garden-debug.tmp.apk
unzip -tq build/.static-garden-debug.tmp.apk
"$ANDROID_HOME/build-tools/34.0.0/apksigner" verify build/.static-garden-debug.tmp.apk
mv build/.static-garden-debug.tmp.apk build/static-garden-debug.apk
ls -lh build/static-garden-debug.apk
