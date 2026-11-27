#!/usr/bin/env bash
set -euo pipefail
GODOT_VERSION=4.2.2
GODOT_DIR="$HOME/godot"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/android-sdk}}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$GODOT_DIR" "$ANDROID_HOME/cmdline-tools"
base="https://github.com/godotengine/godot/releases/download/$GODOT_VERSION-stable"
if [[ ! -x "$GODOT_DIR/godot" ]] || [[ "$("$GODOT_DIR/godot" --version)" != 4.2.2.* ]]; then
  curl -fL --retry 3 "$base/Godot_v$GODOT_VERSION-stable_linux.x86_64.zip" -o "$work/godot.zip"
  unzip -q "$work/godot.zip" -d "$work"
  install -m 755 "$work/Godot_v$GODOT_VERSION-stable_linux.x86_64" "$GODOT_DIR/godot"
fi
templates="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$GODOT_VERSION.stable"
if [[ ! -s "$templates/android_debug.apk" ]]; then
  curl -fL --retry 3 "$base/Godot_v$GODOT_VERSION-stable_export_templates.tpz" -o "$work/templates.zip"
  unzip -q "$work/templates.zip" -d "$work"
  mkdir -p "$templates"
  cp -a "$work/templates/." "$templates/"
fi
sdkmanager="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
if [[ ! -x "$sdkmanager" ]]; then
  curl -fL --retry 3 https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o "$work/sdk.zip"
  unzip -q "$work/sdk.zip" -d "$work/sdk"
  mv "$work/sdk/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
fi
# yes may receive SIGPIPE when sdkmanager finishes; preserve sdkmanager's status.
(set +o pipefail; yes | "$sdkmanager" --sdk_root="$ANDROID_HOME" --licenses >/dev/null)
"$sdkmanager" --sdk_root="$ANDROID_HOME" --install "platform-tools" "platforms;android-33" "platforms;android-34" "build-tools;33.0.2" "build-tools;34.0.0"
keystore="$HOME/.android/debug.keystore"
if [[ ! -f "$keystore" ]]; then
  mkdir -p "$(dirname "$keystore")"
  "$JAVA_HOME/bin/keytool" -genkeypair -keyalg RSA -keysize 2048 -alias androiddebugkey -keypass android -keystore "$keystore" -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
fi
echo "Setup complete. Run bash build-apk.sh from the repository."
